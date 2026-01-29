/**
 * App Component - Main Application
 * Fixed version with all issues resolved
 */
import React, { useState, useEffect } from 'react';
import BaseMap from './components/Map/BaseMap';
import InstallationMarkers from './components/Map/InstallationMarkers';
import Heatmap from './components/Map/Heatmap';
import MainQuerySelector from './components/QuerySelector/MainQuerySelector';
import AuxiliaryQuerySelector from './components/QuerySelector/AuxiliaryQuerySelector';
import AreaSelector from './components/AreaSelector/AreaSelector';
import { getMainQueryResults, getMunicipalityGeometry, getAuxiliaryQueryResults } from './services/api';

function App() {
  // State for main queries
  const [selectedMainQueries, setSelectedMainQueries] = useState([]);
  const [queryResults, setQueryResults] = useState(new Map());
  const [loading, setLoading] = useState(false);

  // State for area selection (Phase 3)
  const [selectedArea, setSelectedArea] = useState({ type: null, value: null });
  const [municipalityGeometry, setMunicipalityGeometry] = useState(null);

  // State for auxiliary queries (Phase 4)
  const [selectedAuxiliaryQueries, setSelectedAuxiliaryQueries] = useState([]);
  const [auxiliaryResults, setAuxiliaryResults] = useState(new Map());
  const [loadingAuxiliary, setLoadingAuxiliary] = useState(false);

  // Load query results when selection changes
  useEffect(() => {
    if (selectedMainQueries.length === 0) {
      setQueryResults(new Map());
      return;
    }

    loadQueryResults();
  }, [selectedMainQueries]);

  // Load municipality geometry when municipality is selected
  useEffect(() => {
    if (selectedArea?.type === 'municipio' && selectedArea?.value) {
      loadMunicipalityGeometry(selectedArea.value);
    } else {
      setMunicipalityGeometry(null);
    }
  }, [selectedArea]);

  // Load auxiliary query results when auxiliary queries or area changes
  useEffect(() => {
    if (!selectedArea.value || selectedAuxiliaryQueries.length === 0) {
      setAuxiliaryResults(new Map());
      return;
    }
    loadAuxiliaryResults();
  }, [selectedAuxiliaryQueries, selectedArea]);

  const loadQueryResults = async () => {
    setLoading(true);
    const newResults = new Map();

    try {
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

  const loadMunicipalityGeometry = async (municipalityName) => {
    try {
      const geometry = await getMunicipalityGeometry(municipalityName);
      setMunicipalityGeometry(geometry);
    } catch (error) {
      console.error('Error loading municipality geometry:', error);
      setMunicipalityGeometry(null);
    }
  };

  const loadAuxiliaryResults = async () => {
    if (!selectedArea.value) return;
    
    setLoadingAuxiliary(true);
    const newResults = new Map();

    try {
      const promises = selectedAuxiliaryQueries.map(async (queryId) => {
        const data = await getAuxiliaryQueryResults(
          queryId,
          selectedArea.type,
          selectedArea.value
        );
        return [queryId, data];
      });

      const results = await Promise.all(promises);
      results.forEach(([queryId, data]) => {
        newResults.set(queryId, data);
      });

      setAuxiliaryResults(newResults);
    } catch (error) {
      console.error('Error loading auxiliary results:', error);
    } finally {
      setLoadingAuxiliary(false);
    }
  };

  const handleAreaChange = (newArea) => {
    setSelectedArea(newArea);
  };

  const handlePolygonCreated = (polygonGeometry) => {
    setSelectedArea({ type: 'poligono', value: polygonGeometry });
  };

  const handlePolygonEdited = (polygonGeometry) => {
    setSelectedArea({ type: 'poligono', value: polygonGeometry });
  };

  const handlePolygonDeleted = () => {
    setSelectedArea({ type: 'poligono', value: null });
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
  console.log('🔵 Main Query Features:', allFeatures.length, allFeatures);

  // Combine auxiliary features - separate by type
  const auxiliaryMarkerFeatures = [];
  const auxiliaryHeatmapFeatures = [];
  
  auxiliaryResults.forEach((result) => {
    if (result.metadata.tipo_retorno === 'heatmap') {
      auxiliaryHeatmapFeatures.push(...result.features);
    } else {
      auxiliaryMarkerFeatures.push(...result.features);
    }
  });
  
  console.log('🟢 Auxiliary Features:', auxiliaryMarkerFeatures.length, 'markers,', auxiliaryHeatmapFeatures.length, 'heatmap points');

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

          {/* Area Selector - Phase 3 */}
          <AreaSelector
            selectedArea={selectedArea}
            onAreaChange={handleAreaChange}
            disabled={false}
          />

          {/* Auxiliary Query Selector - Phase 4 */}
          <AuxiliaryQuerySelector
            selectedQueries={selectedAuxiliaryQueries}
            onQueryChange={setSelectedAuxiliaryQueries}
            disabled={!selectedArea.value}
          />

          {/* Auxiliary Loading indicator */}
          {loadingAuxiliary && (
            <div className="sidebar-section">
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <div className="loading-spinner"></div>
                <span style={{ fontSize: '0.875rem' }}>Carregando queries auxiliares...</span>
              </div>
            </div>
          )}
        </aside>

        {/* Map */}
        <BaseMap 
          showEmptyState={showEmptyState}
          areaSelectionMode={selectedArea?.type}
          municipalityGeometry={null}
          onPolygonCreated={handlePolygonCreated}
          onPolygonEdited={handlePolygonEdited}
          onPolygonDeleted={handlePolygonDeleted}
        >
          {/* Main query markers - ALWAYS render when there are features */}
          {allFeatures.length > 0 && (
            <InstallationMarkers
              results={allFeatures}
              onMarkerClick={handleMarkerClick}
            />
          )}

          {/* Auxiliary markers - Render with different style */}
          {auxiliaryMarkerFeatures.length > 0 && (
            <InstallationMarkers
              results={auxiliaryMarkerFeatures}
              onMarkerClick={handleMarkerClick}
              isAuxiliary={true}
            />
          )}

          {/* Auxiliary heatmap - Render as heatmap layer */}
          {auxiliaryHeatmapFeatures.length > 0 && (
            <Heatmap results={auxiliaryHeatmapFeatures} />
          )}
        </BaseMap>
      </div>
    </div>
  );
}

export default App;
