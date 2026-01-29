/**
 * MainQuerySelector Component - Phase 2
 * Allows users to select main queries
 */
import React, { useEffect, useState } from 'react';
import { getMainQueries } from '../../services/api';

const MainQuerySelector = ({ selectedQueries, onQueryChange }) => {
  const [queries, setQueries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadQueries();
  }, []);

  const loadQueries = async () => {
    try {
      setLoading(true);
      const data = await getMainQueries();
      setQueries(data);
      setError(null);
    } catch (err) {
      setError('Erro ao carregar queries principais');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleQueryToggle = (queryId) => {
    const newSelection = selectedQueries.includes(queryId)
      ? selectedQueries.filter((id) => id !== queryId)
      : [...selectedQueries, queryId];
    
    onQueryChange(newSelection);
  };

  if (loading) {
    return (
      <div className="sidebar-section">
        <h3>📊 Queries Principais</h3>
        <div style={{ display: 'flex', justifyContent: 'center', padding: '2rem' }}>
          <div className="loading-spinner"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="sidebar-section">
        <h3>📊 Queries Principais</h3>
        <p className="warning-text">{error}</p>
      </div>
    );
  }

  return (
    <div className="sidebar-section">
      <h3>📊 Queries Principais</h3>
      <p className="info-text" style={{ marginBottom: '1rem' }}>
        Selecione uma ou mais queries para visualizar alvos em todo o RN.
      </p>
      
      <div className="checkbox-group">
        {queries.map((query) => (
          <div key={query.id_query} className="checkbox-item">
            <input
              type="checkbox"
              id={`query-${query.id_query}`}
              checked={selectedQueries.includes(query.id_query)}
              onChange={() => handleQueryToggle(query.id_query)}
            />
            <label htmlFor={`query-${query.id_query}`}>
              <span>{query.nome}</span>
              <span className={`query-type-badge badge-${query.tipo_alvo}`}>
                {query.tipo_alvo}
              </span>
            </label>
          </div>
        ))}
      </div>

      {selectedQueries.length > 0 && (
        <div style={{ marginTop: '1rem', fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
          {selectedQueries.length} {selectedQueries.length === 1 ? 'query selecionada' : 'queries selecionadas'}
        </div>
      )}
    </div>
  );
};

export default MainQuerySelector;
