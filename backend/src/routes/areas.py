"""
API Routes for Area Analysis
"""
from fastapi import APIRouter, Depends, Body
from sqlalchemy.orm import Session
from sqlalchemy import text, func
from typing import List
from database import get_db
from models import Municipio
from schemas import MunicipioResponse, AreaMetricsRequest, AreaMetricsResponse, TarifaDistribuicao, MunicipioGeoJSONResponse
import json
from datetime import datetime, timedelta

router = APIRouter()


@router.get("/municipalities", response_model=List[MunicipioResponse])
async def get_municipalities(db: Session = Depends(get_db)):
    """
    Get list of all municipalities in Rio Grande do Norte.
    """
    municipios = db.query(Municipio).order_by(Municipio.nome).all()
    return municipios


@router.get("/municipalities/{nome}/geometry", response_model=MunicipioGeoJSONResponse)
async def get_municipality_geometry(nome: str, db: Session = Depends(get_db)):
    """
    Get the GeoJSON geometry for a specific municipality.
    """
    sql = text("""
        SELECT 
            id,
            nome,
            ST_AsGeoJSON(geom) as geom_json
        FROM municipios
        WHERE nome = :nome
    """)
    
    result = db.execute(sql, {"nome": nome}).fetchone()
    
    if not result:
        return MunicipioGeoJSONResponse(
            type="Feature",
            geometry={},
            properties={"error": "Municipality not found"}
        )
    
    return MunicipioGeoJSONResponse(
        type="Feature",
        geometry=json.loads(result.geom_json),
        properties={
            "id": result.id,
            "nome": result.nome
        }
    )


@router.post("/metrics", response_model=AreaMetricsResponse)
async def get_area_metrics(
    area_request: AreaMetricsRequest = Body(...),
    db: Session = Depends(get_db)
):
    """
    Get aggregated metrics for a selected area (municipality or polygon).
    
    Returns:
    - Perimeter in kilometers
    - Total installations in area
    - Total frauds in last 5 years
    - Distribution by tariff class
    """
    
    if area_request.tipo == "municipio":
        # Municipality-based metrics
        municipio_nome = area_request.valor
        
        # Get perimeter
        perimeter_sql = text("""
            SELECT ST_Perimeter(geom::geography) / 1000 as perimetro_km
            FROM municipios
            WHERE nome = :nome
        """)
        perimeter_result = db.execute(perimeter_sql, {"nome": municipio_nome}).fetchone()
        perimetro_km = float(perimeter_result.perimetro_km) if perimeter_result else None
        
        # Get total installations
        total_sql = text("""
            SELECT COUNT(*) as total
            FROM instalacoes
            WHERE municipio = :nome
        """)
        total_result = db.execute(total_sql, {"nome": municipio_nome}).fetchone()
        total_instalacoes = total_result.total if total_result else 0
        
        # Get frauds in last 5 years
        five_years_ago = datetime.now() - timedelta(days=5*365)
        frauds_sql = text("""
            SELECT COUNT(DISTINCT f.id_instalacao) as total_fraudes
            FROM fraudes f
            JOIN instalacoes i ON f.id_instalacao = i.id_instalacao
            WHERE i.municipio = :nome
            AND f.data_fraude >= :data_inicio
        """)
        frauds_result = db.execute(frauds_sql, {
            "nome": municipio_nome,
            "data_inicio": five_years_ago.date()
        }).fetchone()
        total_fraudes = frauds_result.total_fraudes if frauds_result else 0
        
        # Get tariff distribution
        tarifa_sql = text("""
            SELECT 
                COALESCE(classe_tarifaria, 'Não Classificado') as classe_tarifaria,
                COUNT(*) as count
            FROM instalacoes
            WHERE municipio = :nome
            GROUP BY classe_tarifaria
            ORDER BY count DESC
        """)
        tarifa_results = db.execute(tarifa_sql, {"nome": municipio_nome}).fetchall()
        
    elif area_request.tipo == "poligono":
        # Polygon-based metrics
        polygon_geojson = json.dumps(area_request.valor)
        
        # Get perimeter
        perimeter_sql = text("""
            SELECT ST_Perimeter(ST_GeomFromGeoJSON(:polygon)::geography) / 1000 as perimetro_km
        """)
        perimeter_result = db.execute(perimeter_sql, {"polygon": polygon_geojson}).fetchone()
        perimetro_km = float(perimeter_result.perimetro_km) if perimeter_result else None
        
        # Get total installations
        total_sql = text("""
            SELECT COUNT(*) as total
            FROM instalacoes
            WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), geom)
        """)
        total_result = db.execute(total_sql, {"polygon": polygon_geojson}).fetchone()
        total_instalacoes = total_result.total if total_result else 0
        
        # Get frauds in last 5 years
        five_years_ago = datetime.now() - timedelta(days=5*365)
        frauds_sql = text("""
            SELECT COUNT(DISTINCT f.id_instalacao) as total_fraudes
            FROM fraudes f
            JOIN instalacoes i ON f.id_instalacao = i.id_instalacao
            WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), i.geom)
            AND f.data_fraude >= :data_inicio
        """)
        frauds_result = db.execute(frauds_sql, {
            "polygon": polygon_geojson,
            "data_inicio": five_years_ago.date()
        }).fetchone()
        total_fraudes = frauds_result.total_fraudes if frauds_result else 0
        
        # Get tariff distribution
        tarifa_sql = text("""
            SELECT 
                COALESCE(classe_tarifaria, 'Não Classificado') as classe_tarifaria,
                COUNT(*) as count
            FROM instalacoes
            WHERE ST_Contains(ST_GeomFromGeoJSON(:polygon), geom)
            GROUP BY classe_tarifaria
            ORDER BY count DESC
        """)
        tarifa_results = db.execute(tarifa_sql, {"polygon": polygon_geojson}).fetchall()
    
    else:
        return AreaMetricsResponse(
            total_instalacoes=0,
            total_fraudes_5anos=0,
            distribuicao_tarifa=[]
        )
    
    # Format tariff distribution
    distribuicao = [
        TarifaDistribuicao(classe_tarifaria=row.classe_tarifaria, count=row.count)
        for row in tarifa_results
    ]
    
    return AreaMetricsResponse(
        perimetro_km=perimetro_km,
        total_instalacoes=total_instalacoes,
        total_fraudes_5anos=total_fraudes,
        distribuicao_tarifa=distribuicao
    )
