/**
 * AuxiliaryQuerySelector - Simplified version
 * Clean discrete interface like image 4 reference
 */
import React, { useState, useEffect } from 'react';
import { getAuxiliaryQueries } from '../../services/api';

const AuxiliaryQuerySelector = ({ selectedQueries, onQueryChange, disabled }) => {
  const [queries, setQueries] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadQueries();
  }, []);

  const loadQueries = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getAuxiliaryQueries();
      setQueries(data);
    } catch (err) {
      console.error('Error loading auxiliary queries:', err);
      setError('Erro ao carregar queries auxiliares');
    } finally {
      setLoading(false);
    }
  };

  const handleQueryToggle = (queryId) => {
    if (disabled) return;
    
    if (selectedQueries.includes(queryId)) {
      onQueryChange(selectedQueries.filter(id => id !== queryId));
    } else {
      onQueryChange([...selectedQueries, queryId]);
    }
  };

  return (
    <div className="sidebar-section">
      <h3>🔍 Queries Auxiliares</h3>

      {disabled && (
        <div style={{ marginBottom: '1rem', fontSize: '0.875rem', color: 'var(--text-muted)', fontStyle: 'italic' }}>
          ℹ️ Selecione uma área para habilitar
        </div>
      )}

      {error && (
        <div className="error-message" style={{ marginBottom: '1rem' }}>
          ⚠️ {error}
        </div>
      )}

      {loading ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.5rem' }}>
          <div className="loading-spinner"></div>
          <span style={{ fontSize: '0.875rem' }}>Carregando...</span>
        </div>
      ) : (
        <div className="checkbox-group">
          {queries.map((query) => (
            <div
              key={query.id_query}
              className={`checkbox-item ${disabled ? 'disabled' : ''}`}
              onClick={() => handleQueryToggle(query.id_query)}
            >
              <input
                type="checkbox"
                id={`aux-query-${query.id_query}`}
                checked={selectedQueries.includes(query.id_query)}
                onChange={() => {}}
                disabled={disabled}
              />
              <label htmlFor={`aux-query-${query.id_query}`} style={{ cursor: 'pointer', flex: 1 }}>
                {query.nome}
              </label>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default AuxiliaryQuerySelector;
