/**
 * AreaSelector Component - Simplified version
 * Clean, discrete interface following user's image 4 reference
 */
import React, { useState, useEffect } from 'react';
import { getMunicipalities } from '../../services/api';

const AreaSelector = ({ selectedArea, onAreaChange, disabled }) => {
  const [municipalities, setMunicipalities] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadMunicipalities();
  }, []);

  const loadMunicipalities = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getMunicipalities();
      setMunicipalities(data);
    } catch (err) {
      console.error('Error loading municipalities:', err);
      setError('Erro ao carregar municípios');
    } finally {
      setLoading(false);
    }
  };

  const handleAreaTypeChange = (type) => {
    if (disabled) return;
    
    if (type === selectedArea?.type) {
      return;
    }
    
    onAreaChange({ type, value: null });
  };

  const handleMunicipalityChange = (e) => {
    const municipalityName = e.target.value;
    if (!municipalityName) {
      onAreaChange({ type: 'municipio', value: null });
      return;
    }
    onAreaChange({ type: 'municipio', value: municipalityName });
  };

  const handleClearArea = () => {
    onAreaChange({ type: null, value: null });
  };

  const hasAreaSelected = selectedArea?.value !== null;

  return (
    <div className="sidebar-section">
      <h3>📍 Área de Interesse</h3>

      {error && (
        <div className="error-message" style={{ marginBottom: '1rem' }}>
          ⚠️ {error}
        </div>
      )}

      {/* Simple radio buttons */}
      <div style={{ marginBottom: '1rem' }}>
        <div className="checkbox-item" onClick={() => handleAreaTypeChange('municipio')}>
          <input
            type="radio"
            name="area-type"
            checked={selectedArea?.type === 'municipio'}
            onChange={() => {}}
            disabled={disabled}
          />
          <label style={{ cursor: 'pointer', flex: 1 }}>
            Município
          </label>
        </div>
        <div className="checkbox-item" onClick={() => handleAreaTypeChange('poligono')}>
          <input
            type="radio"
            name="area-type"
            checked={selectedArea?.type === 'poligono'}
            onChange={() => {}}
            disabled={disabled}
          />
          <label style={{ cursor: 'pointer', flex: 1 }}>
            Desenhar Polígono
          </label>
        </div>
      </div>

      {/* Municipality Dropdown */}
      {selectedArea?.type === 'municipio' && (
        <div style={{ marginBottom: '1rem' }}>
          {loading ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.5rem' }}>
              <div className="loading-spinner"></div>
              <span style={{ fontSize: '0.875rem' }}>Carregando...</span>
            </div>
          ) : (
            <select
              className="municipality-dropdown"
              value={selectedArea.value || ''}
              onChange={handleMunicipalityChange}
              disabled={disabled}
            >
              <option value="">-- Selecione --</option>
              {municipalities.map((mun) => (
                <option key={mun.id} value={mun.nome}>
                  {mun.nome}
                </option>
              ))}
            </select>
          )}
        </div>
      )}

      {/* Polygon Drawing Instructions */}
      {selectedArea?.type === 'poligono' && (
        <div style={{ marginBottom: '1rem', fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
          {!hasAreaSelected ? (
            <>
              ℹ️ Clique no ícone de polígono no canto superior direito do mapa para desenhar
            </>
          ) : (
            <>
              ✅ Polígono desenhado. Use os ícones para editar ou excluir.
            </>
          )}
        </div>
      )}

      {/* Clear button */}
      {hasAreaSelected && (
        <button
          className="btn btn-secondary"
          onClick={handleClearArea}
          disabled={disabled}
          style={{ width: '100%', fontSize: '0.875rem' }}
        >
          🗑️ Limpar Área
        </button>
      )}

      {/* Status */}
      {!hasAreaSelected && (
        <div style={{ marginTop: '0.5rem', fontSize: '0.75rem', color: 'var(--text-muted)', fontStyle: 'italic' }}>
          Queries auxiliares disponíveis após seleção
        </div>
      )}
    </div>
  );
};

export default AreaSelector;
