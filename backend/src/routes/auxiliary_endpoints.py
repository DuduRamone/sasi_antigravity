# Add this to the end of queries.py

# ============================================
# Auxiliary Queries Endpoints
# ============================================

@router.get("/auxiliary", response_model=List[QueryAuxiliarResponse])
async def get_auxiliary_queries(db: Session = Depends(get_db)):
    """
    Get all active auxiliary queries.
    Auxiliary queries provide context within a selected area.
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
    Get installation results for a specific auxiliary query filtered by area.
    
    Query Parameters:
    - area_type: 'municipio' or 'poligono'
    - area_value: municipality name (string) or GeoJSON polygon (JSON string)
    """
    # Get query info
    query = db.query(QueryAuxiliar).filter(QueryAuxiliar.id_query == query_id).first()
    if not query:
        return QueryResultResponse(features=[], metadata={"error": "Query  not found"})
    
    # Build SQL based on area type
    if area_type == "municipio":
        sql = text("""
            SELECT 
                i.id_instalacao,
                i.municipio,
                i.classe_tarifaria,
                i.latitude,
                i.longitude,
                ST_AsGeoJSON(i.geom) as geom_json,
                r.intensidade as score
            FROM instalacoes i
            JOIN resultado_queries_auxiliares r ON i.id_instalacao = r.id_instalacao
            WHERE r.id_query = :query_id
            AND i.municipio = :municipio
        """)
        params = {"query_id": query_id, "municipio": area_value}
    
    elif area_type == "poligono":
        # Parse GeoJSON polygon
        try:
            polygon_geojson = area_value  # Already a JSON string
        except:
            return QueryResultResponse(features=[], metadata={"error": "Invalid polygon GeoJSON"})
        
        sql = text("""
            SELECT 
                i.id_instalacao,
                i.municipio,
                i.classe_tarifaria,
                i.latitude,
                i.longitude,
                ST_AsGeoJSON(i.geom) as geom_json,
                r.intensidade as score
            FROM instalacoes i
            JOIN resultado_queries_auxiliares r ON i.id_instalacao = r.id_instalacao
            WHERE r.id_query = :query_id
            AND ST_Contains(ST_GeomFromGeoJSON(:polygon), i.geom)
        """)
        params = {"query_id": query_id, "polygon": polygon_geojson}
    
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
                "score": float(row.score) if row.score else None,
                "query_id": query_id,
                "query_nome": query.nome,
                "tipo_retorno": query.tipo_retorno
            }
        }
        features.append(feature)
    
    return QueryResultResponse(
        features=features,
        metadata={
            "query_id": query_id,
            "query_nome": query.nome,
            "tipo_retorno": query.tipo_retorno,
            "area_type": area_type,
            "total_results": len(features)
        }
    )
