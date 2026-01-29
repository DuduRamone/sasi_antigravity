"""
SQLAlchemy ORM Models
"""
from sqlalchemy import Column, Integer, String, Numeric, Date, DateTime, Boolean, Text, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
from datetime import datetime
from database import Base


class Instalacao(Base):
    __tablename__ = "instalacoes"
    
    id_instalacao = Column(String(50), primary_key=True)
    latitude = Column(Numeric(10, 8), nullable=False)
    longitude = Column(Numeric(11, 8), nullable=False)
    geom = Column(Geometry('POINT', srid=4326), nullable=False)
    municipio = Column(String(100), nullable=False)
    classe_tarifaria = Column(String(50))
    endereco = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    historico_consumo = relationship("HistoricoConsumo", back_populates="instalacao")
    fraudes = relationship("Fraude", back_populates="instalacao")
    status = relationship("StatusInstalacao", back_populates="instalacao")
    notas_servico = relationship("NotaServico", back_populates="instalacao")


class QueryPrincipal(Base):
    __tablename__ = "queries_principais"
    
    id_query = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(200), nullable=False)
    descricao = Column(Text)
    cor = Column(String(7), nullable=False)  # Hex color for this query
    ativa = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    resultados = relationship("ResultadoQueryPrincipal", back_populates="query")


class ResultadoQueryPrincipal(Base):
    __tablename__ = "resultado_queries_principais"
    
    id_query = Column(Integer, ForeignKey('queries_principais.id_query', ondelete='CASCADE'), primary_key=True)
    id_instalacao = Column(String(50), ForeignKey('instalacoes.id_instalacao', ondelete='CASCADE'), primary_key=True)
    tipo_alvo = Column(String(20), nullable=False)  # Moved from QueryPrincipal
    score = Column(Numeric(5, 2))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    __table_args__ = (
        CheckConstraint("tipo_alvo IN ('regular', 'forte')", name='check_tipo_alvo_result'),
    )
    
    # Relationships
    query = relationship("QueryPrincipal", back_populates="resultados")


class QueryAuxiliar(Base):
    __tablename__ = "queries_auxiliares"
    
    id_query = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(100), nullable=False)
    descricao = Column(Text)
    tipo_retorno = Column(String(20), nullable=False)
    ativa = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    __table_args__ = (
        CheckConstraint("tipo_retorno IN ('instalacao', 'heatmap')", name='check_tipo_retorno'),
    )
    
    # Relationships
    resultados = relationship("ResultadoQueryAuxiliar", back_populates="query")


class ResultadoQueryAuxiliar(Base):
    __tablename__ = "resultado_queries_auxiliares"
    
    id_query = Column(Integer, ForeignKey('queries_auxiliares.id_query', ondelete='CASCADE'), primary_key=True)
    id_instalacao = Column(String(50), ForeignKey('instalacoes.id_instalacao', ondelete='CASCADE'), primary_key=True)
    intensidade = Column(Numeric(5, 4))
    data_calculo = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    query = relationship("QueryAuxiliar", back_populates="resultados")


class HistoricoConsumo(Base):
    __tablename__ = "historico_consumo"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    id_instalacao = Column(String(50), ForeignKey('instalacoes.id_instalacao', ondelete='CASCADE'), nullable=False)
    data_referencia = Column(Date, nullable=False)
    consumo = Column(Numeric(10, 2), nullable=False)
    demanda = Column(Numeric(10, 2))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    instalacao = relationship("Instalacao", back_populates="historico_consumo")


class Fraude(Base):
    __tablename__ = "fraudes"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    id_instalacao = Column(String(50), ForeignKey('instalacoes.id_instalacao', ondelete='CASCADE'), nullable=False)
    data_fraude = Column(Date, nullable=False)
    tipo_fraude = Column(String(100))
    valor_recuperado = Column(Numeric(12, 2))
    observacoes = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    instalacao = relationship("Instalacao", back_populates="fraudes")


class StatusInstalacao(Base):
    __tablename__ = "status_instalacao"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    id_instalacao = Column(String(50), ForeignKey('instalacoes.id_instalacao', ondelete='CASCADE'), nullable=False)
    status = Column(String(20), nullable=False)
    usuario = Column(String(100), nullable=False)
    data_atualizacao = Column(DateTime, default=datetime.utcnow)
    observacoes = Column(Text)
    
    __table_args__ = (
        CheckConstraint("status IN ('selecionado', 'nao_selecionado', 'verificar')", name='check_status'),
    )
    
    # Relationships
    instalacao = relationship("Instalacao", back_populates="status")


class Municipio(Base):
    __tablename__ = "municipios"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    nome = Column(String(100), nullable=False, unique=True)
    geom = Column(Geometry('MULTIPOLYGON', srid=4326), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class NotaServico(Base):
    __tablename__ = "notas_servico"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    id_instalacao = Column(String(50), ForeignKey('instalacoes.id_instalacao', ondelete='CASCADE'), nullable=False)
    numero_nota = Column(String(50), nullable=False)
    data_nota = Column(Date, nullable=False)
    tipo_servico = Column(String(100))
    descricao = Column(Text)
    status = Column(String(50))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    instalacao = relationship("Instalacao", back_populates="notas_servico")
