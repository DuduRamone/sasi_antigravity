"""
API Routes for Queries (Main and Auxiliary)
"""
from fastapi import APIRouter, Depends, Query as QueryParam
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional
from database import get_db
from models import QueryPrincipal, QueryAuxiliar, ResultadoQueryPrincipal, ResultadoQueryAuxiliar, Instalacao
from schemas import QueryPrincipalResponse, QueryAuxiliarResponse, QueryResultResponse
import json

router = APIRouter()


# ============================================
# Main Queries Endpoints
# ============================================

@router.get("/main", response_model=List[QueryPrincipalResponse])
async def get_main_queries(db: Session = Depends(get_db)):
    """
    Get all active main queries.
    Main queries return statewide installation targets.
    """
    queries = db.query(QueryPrincipal).filter(QueryPrincipal.ativa == True).all()
    return queries


@router.get("/main/{query_id}/results", response_model=QueryResultResponse)
async def get_main_query_results(
    query_id: int,
    bounds: Optional[str] = QueryParam(None, description="Bounding box: minLng,minLat,maxLng,maxLat"),
    db: Session = Depends(get_db)
):
    """
    Get installation results for a specific main query.
    Returns GeoJSON FeatureCollection.
    
    Optional bounds parameter for viewport optimization (reduce data transfer).
    """
    # Get query info
    query = db.query(QueryPrincipal).filter(QueryPrincipal.id_query == query_id).first()
    if not query:
        return QueryResultResponse(features=[], metadata={"error": "Query not found"})
    
    # Build query with spatial filtering - NOW including tipo_alvo from results
    sql = text("""
        SELECT 
            i.id_instalacao,
            i.municipio,
            i.classe_tarifaria,
            i.latitude,
            i.longitude,
            ST_AsGeoJSON(i.geom) as geom_json,
            r.tipo_alvo,
            r.score
        FROM instalacoes i
        JOIN resultado_queries_principais r ON i.id_instalacao = r.id_instalacao
        WHERE r.id_query = :query_id
    """)
    
    params = {"query_id": query_id}
    
    # Add bounding box filter if provided
    if bounds:
        try:
            min_lng, min_lat, max_lng, max_lat = map(float, bounds.split(","))
            sql = text("""
                SELECT 
                    i.id_instalacao,
                    i.municipio,
                    i.classe_tarifaria,
                    i.latitude,
                    i.longitude,
                    ST_AsGeoJSON(i.geom) as geom_json,
                    r.tipo_alvo,
                    r.score
                FROM instalacoes i
                JOIN resultado_queries_principais r ON i.id_instalacao = r.id_instalacao
                WHERE r.id_query = :query_id
                AND i.geom && ST_MakeEnvelope(:min_lng, :min_lat, :max_lng, :max_lat, 4326)
            """)
            params.update({
                "min_lng": min_lng,
                "min_lat": min_lat,
                "max_lng": max_lng,
                "max_lat": max_lat
            })
        except ValueError:
            pass  # Invalid bounds, ignore
    
    results = db.execute(sql, params).fetchall()
    
    # Convert to GeoJSON features
    features = []
    for row in results:
        feature = {
            "type": "Feature",
            "geometry": json.loads(row.geom_json),
            "properties": {
                "id_instalacao": row.id_instalacao,
                "municipio": row.municipio,
                "classe_tarifaria": row.classe_tarifaria,
                "tipo_alvo": row.tipo_alvo,  # From result, not query
                "score": float(row.score) if row.score else None,
                "query_id": query_id,
                "query_nome": query.nome,
                "query_cor": query.cor  # NEW: include query color
            }
        }
        features.append(feature)
    
    return QueryResultResponse(
        features=features,
        metadata={
            "query_id": query_id,
            "query_nome": query.nome,
            "query_cor": query.cor,
            "total_results": len(features)
        }
    )


# ============================================
# Auxiliary Queries Endpoints
# ============================================

@router.get("/auxiliary", response_model=List[QueryAuxiliarResponse])
async def get_auxiliary_queries(db: Session = Depends(get_db)):
    """
    Get all active auxiliary queries.
    Auxiliary queries can only be applied after area selection.
    """
    queries = db.query(QueryAuxiliar).filter(QueryAuxiliar.ativa == True).all()
    return queries


@router.get("/auxiliary/{query_id}/results", response_model=QueryResultResponse)
async def get_auxiliary_query_results(
    query_id: int,
    area_type: str = QueryParam(..., description="'municipio' or 'poligono'"),
    area_value: str = QueryParam(..., description="Municipality name or GeoJSON polygon"),
    db: Session = Depends(get_db)
):
    """
    Get results for auxiliary query within a specific area.
    Returns installations or heatmap data depending on query type.
    
    CRITICAL: This endpoint requires area selection (business rule).
    """
    # Get query info
    query = db.query(QueryAuxiliar).filter(QueryAuxiliar.id_query == query_id).first()
    if not query:
        return QueryResultResponse(features=[], metadata={"error": "Query not found"})
    
    # Build spatial filter based on area type
    if area_type == "municipio":
        sql = text("""
            SELECT 
                i.id_instalacao,
                i.municipio,
                i.classe_tarifaria,
                i.latitude,
                i.longitude,
                ST_AsGeoJSON(i.geom) as geom_json,
                r.intensidade
            FROM instalacoes i
            JOIN resultado_queries_auxiliares r ON i.id_instalacao = r.id_instalacao
            WHERE r.id_query = :query_id
            AND i.municipio = :municipio
        """)
        params = {"query_id": query_id, "municipio": area_value}
    
    elif area_type == "poligono":
        # Parse GeoJSON polygon
        polygon_geojson = json.loads(area_value)
        sql = text("""
            SELECT 
                i.id_instalacao,
                i.municipio,
                i.classe_tarifaria,
                i.latitude,
                i.longitude,
                ST_AsGeoJSON(i.geom) as geom_json,
                r.intensidade
            FROM instalacoes i
            JOIN resultado_queries_auxiliares r ON i.id_instalacao = r.id_instalacao
            WHERE r.id_query = :query_id
            AND ST_Contains(ST_GeomFromGeoJSON(:polygon), i.geom)
        """)
        params = {"query_id": query_id, "polygon": json.dumps(polygon_geojson)}
    
    else:
        return QueryResultResponse(features=[], metadata={"error": "Invalid area_type"})
    
    results = db.execute(sql, params).fetchall()
    
    # Convert to GeoJSON features
    features = []
    for row in results:
        feature = {
            "type": "Feature",
            "geometry": json.loads(row.geom_json),
            "properties": {
                "id_instalacao": row.id_instalacao,
                "municipio": row.municipio,
                "classe_tarifaria": row.classe_tarifaria,
                "tipo_retorno": query.tipo_retorno,
                "intensidade": float(row.intensidade) if row.intensidade else None,
                "query_id": query_id,
                "query_nome": query.nome
            }
        }
        features.append(feature)
    
    return QueryResultResponse(
        features=features,
        metadata={
            "query_id": query_id,
            "query_nome": query.nome,
            "tipo_retorno": query.tipo_retorno,
            "total_results": len(features)
        }
    )
