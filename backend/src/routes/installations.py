"""
API Routes for Installations
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text, desc
from typing import List
from database import get_db
from models import Instalacao, HistoricoConsumo, Fraude, NotaServico, StatusInstalacao
from schemas import (
    InstalacaoDetailResponse, 
    ConsumoHistoricoResponse,
    FraudeResponse,
    NotaServicoResponse,
    StatusInstalacaoUpdate,
    StatusInstalacaoResponse
)

router = APIRouter()


@router.get("/{id_instalacao}", response_model=InstalacaoDetailResponse)
async def get_installation_details(id_instalacao: str, db: Session = Depends(get_db)):
    """
    Get detailed information about a specific installation.
    """
    instalacao = db.query(Instalacao).filter(Instalacao.id_instalacao == id_instalacao).first()
    
    if not instalacao:
        raise HTTPException(status_code=404, detail="Installation not found")
    
    return instalacao


@router.get("/{id_instalacao}/consumption", response_model=List[ConsumoHistoricoResponse])
async def get_installation_consumption(
    id_instalacao: str, 
    limit: int = 12,  # Default to last 12 months
    db: Session = Depends(get_db)
):
    """
    Get consumption history for an installation.
    Returns most recent records first.
    """
    consumo = db.query(HistoricoConsumo).filter(
        HistoricoConsumo.id_instalacao == id_instalacao
    ).order_by(
        desc(HistoricoConsumo.data_referencia)
    ).limit(limit).all()
    
    # Reverse to show chronologically
    return list(reversed(consumo))


@router.get("/{id_instalacao}/frauds", response_model=List[FraudeResponse])
async def get_installation_frauds(id_instalacao: str, db: Session = Depends(get_db)):
    """
    Get fraud history for an installation.
    """
    fraudes = db.query(Fraude).filter(
        Fraude.id_instalacao == id_instalacao
    ).order_by(
        desc(Fraude.data_fraude)
    ).all()
    
    return fraudes


@router.get("/{id_instalacao}/service-notes", response_model=List[NotaServicoResponse])
async def get_installation_service_notes(
    id_instalacao: str, 
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """
    Get service notes for an installation.
    """
    notas = db.query(NotaServico).filter(
        NotaServico.id_instalacao == id_instalacao
    ).order_by(
        desc(NotaServico.data_nota)
    ).limit(limit).all()
    
    return notas


@router.put("/{id_instalacao}/status", response_model=StatusInstalacaoResponse)
async def update_installation_status(
    id_instalacao: str,
    status_update: StatusInstalacaoUpdate,
    db: Session = Depends(get_db)
):
    """
    Update the status of an installation.
    Creates a new status record (maintains history).
    """
    # Verify installation exists
    instalacao = db.query(Instalacao).filter(Instalacao.id_instalacao == id_instalacao).first()
    if not instalacao:
        raise HTTPException(status_code=404, detail="Installation not found")
    
    # Create new status record
    new_status = StatusInstalacao(
        id_instalacao=id_instalacao,
        status=status_update.status,
        usuario=status_update.usuario,
        observacoes=status_update.observacoes
    )
    
    db.add(new_status)
    db.commit()
    db.refresh(new_status)
    
    return new_status


@router.get("/{id_instalacao}/status", response_model=StatusInstalacaoResponse)
async def get_installation_current_status(id_instalacao: str, db: Session = Depends(get_db)):
    """
    Get the current (most recent) status of an installation.
    """
    status = db.query(StatusInstalacao).filter(
        StatusInstalacao.id_instalacao == id_instalacao
    ).order_by(
        desc(StatusInstalacao.data_atualizacao)
    ).first()
    
    if not status:
        raise HTTPException(status_code=404, detail="No status found for this installation")
    
    return status
