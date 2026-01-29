/**
 * App Component - Main Application
 * Phase 1 Implementation: Base map with empty state
 * Phase 2 Implementation: Main queries and markers
 */
import React, { useState, useEffect } from 'react';
import BaseMap from './components/Map/BaseMap';
import InstallationMarkers from './components/Map/InstallationMarkers';
import MainQuerySelector from './components/QuerySelector/MainQuerySelector';
import { getMainQueryResults } from './services/api';

function App() {
  // State for main queries
  const [selectedMainQueries, setSelectedMainQueries] = useState([]);
  const [queryResults, setQueryResults] = useState(new Map());
  const [loading, setLoading] = useState(false);

  // Load query results when selection changes
  useEffect(() => {
    if (selectedMainQueries.length === 0) {
      setQueryResults(new Map());
      return;
    }

    loadQueryResults();
  }, [selectedMainQueries]);

  const loadQueryResults = async () => {
    setLoading(true);
    const newResults = new Map();

    try {
      // Load results for each selected query
      const promises = selectedMainQueries.map(async (queryId) => {
        const data = await getMainQueryResults(queryId);
        return [queryId, data];
      });

      const results = await Promise.all(promises);
      results.forEach(([queryId, data]) => {
        newResults.set(queryId, data);
      });

      setQueryResults(newResults);
    } catch (error) {
      console.error('Error loading query results:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleMarkerClick = (properties) => {
    console.log('Installation clicked:', properties);
    // Phase 5: This will open the installation detail panel
  };

  // Combine all features from all selected queries
  const allFeatures = [];
  queryResults.forEach((result) => {
    allFeatures.push(...result.features);
  });

  // Show empty state if no queries selected
  const showEmptyState = selectedMainQueries.length === 0;

  return (
    <div className="app-container">
      {/* Header */}
      <header className="header">
        <div className="header-content">
          <div className="header-title">
            <h1>SASI - Mapa de Inspeções</h1>
          </div>
          <div className="header-subtitle">
            Sistema de Apoio à Seleção de Inspeções - Combate à Fraude de Energia
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="main-content">
        {/* Sidebar */}
        <aside className="sidebar">
          <MainQuerySelector
            selectedQueries={selectedMainQueries}
            onQueryChange={setSelectedMainQueries}
          />

          {/* Loading indicator */}
          {loading && (
            <div className="sidebar-section">
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div className="loading-spinner"></div>
                <span>Carregando dados...</span>
              </div>
            </div>
          )}

          {/* Results summary */}
          {!loading && allFeatures.length > 0 && (
            <div className="sidebar-section">
              <h3>📈 Resumo</h3>
              <div style={{ color: 'var(--text-secondary)', fontSize: '0.875rem' }}>
                <p style={{ marginBottom: '0.5rem' }}>
                  <strong style={{ color: 'var(--text-primary)' }}>
                    {allFeatures.length}
                  </strong>{' '}
                  instalações encontradas
                </p>
                {queryResults.size > 0 && (
                  <div style={{ marginTop: '1rem' }}>
                    {Array.from(queryResults.entries()).map(([queryId, result]) => (
                      <div key={queryId} style={{ marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <div 
                          style={{
                            width: '12px',
                            height: '12px',
                            borderRadius: '50%',
                            backgroundColor: result.metadata.query_cor,
                            flexShrink: 0
                          }}
                        />
                        <span style={{ flex: 1 }}>{result.metadata.query_nome}</span>
                        <span style={{ fontWeight: '600' }}>{result.features.length}</span>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}
        </aside>

        {/* Map */}
        <BaseMap showEmptyState={showEmptyState}>
          {!showEmptyState && (
            <InstallationMarkers
              results={allFeatures}
              onMarkerClick={handleMarkerClick}
            />
          )}
        </BaseMap>
      </div>
    </div>
  );
}

export default App;
