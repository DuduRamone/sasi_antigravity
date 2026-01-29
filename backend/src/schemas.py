"""
Pydantic schemas for request/response validation
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Literal
from datetime import datetime, date
from decimal import Decimal


# ============================================
# Query Schemas
# ============================================

class QueryPrincipalBase(BaseModel):
    nome: str
    descricao: Optional[str] = None
    cor: str = Field(..., pattern=r'^#[0-9A-Fa-f]{6}$')  # Hex color

class QueryPrincipalResponse(QueryPrincipalBase):
    id_query: int
    ativa: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class QueryAuxiliarBase(BaseModel):
    nome: str
    descricao: Optional[str] = None
    tipo_retorno: Literal['instalacao', 'heatmap']

class QueryAuxiliarResponse(QueryAuxiliarBase):
    id_query: int
    ativa: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# ============================================
# Installation Schemas
# ============================================

class InstalacaoBase(BaseModel):
    id_instalacao: str
    latitude: Decimal
    longitude: Decimal
    municipio: str
    classe_tarifaria: Optional[str] = None
    endereco: Optional[str] = None


class InstalacaoGeoJSON(BaseModel):
    """GeoJSON Feature for map rendering"""
    type: str = "Feature"
    geometry: dict
    properties: dict


class InstalacaoDetailResponse(InstalacaoBase):
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# ============================================
# Query Result Schemas
# ============================================

class QueryResultResponse(BaseModel):
    """Response for query results with GeoJSON features"""
    type: str = "FeatureCollection"
    features: List[InstalacaoGeoJSON]
    metadata: dict = Field(default_factory=dict)


# ============================================
# Consumption History Schemas
# ============================================

class ConsumoHistoricoResponse(BaseModel):
    data_referencia: date
    consumo: Decimal
    demanda: Optional[Decimal] = None
    
    class Config:
        from_attributes = True


# ============================================
# Fraud Schemas
# ============================================

class FraudeResponse(BaseModel):
    data_fraude: date
    tipo_fraude: Optional[str] = None
    valor_recuperado: Optional[Decimal] = None
    observacoes: Optional[str] = None
    
    class Config:
        from_attributes = True


# ============================================
# Service Notes Schemas
# ============================================

class NotaServicoResponse(BaseModel):
    numero_nota: str
    data_nota: date
    tipo_servico: Optional[str] = None
    descricao: Optional[str] = None
    status: Optional[str] = None
    
    class Config:
        from_attributes = True


# ============================================
# Status Schemas
# ============================================

class StatusInstalacaoUpdate(BaseModel):
    status: Literal['selecionado', 'nao_selecionado', 'verificar']
    usuario: str
    observacoes: Optional[str] = None


class StatusInstalacaoResponse(BaseModel):
    id_instalacao: str
    status: str
    usuario: str
    data_atualizacao: datetime
    observacoes: Optional[str] = None
    
    class Config:
        from_attributes = True


# ============================================
# Area Metrics Schemas
# ============================================

class AreaMetricsRequest(BaseModel):
    tipo: Literal['municipio', 'poligono']
    valor: str | dict  # municipality name or GeoJSON polygon


class TarifaDistribuicao(BaseModel):
    classe_tarifaria: str
    count: int


class AreaMetricsResponse(BaseModel):
    perimetro_km: Optional[float] = None
    total_instalacoes: int
    total_fraudes_5anos: int
    distribuicao_tarifa: List[TarifaDistribuicao]


# ============================================
# Municipality Schemas
# ============================================

class MunicipioResponse(BaseModel):
    id: int
    nome: str
    populacao: Optional[int] = None
    
    class Config:
        from_attributes = True


class MunicipioGeoJSONResponse(BaseModel):
    type: str = "Feature"
    geometry: dict
    properties: dict
