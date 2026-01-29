/**
 * InstallationMarkers Component - Updated with full prop support
 * Renders installation markers on map with query-specific colors
 * - Supports both main and auxiliary markers
 * - Click handler support
 * - Different styling for auxiliary markers
 */
import React from 'react';
import { Marker, Popup } from 'react-leaflet';
import L from 'leaflet';

/**
 * Generate marker color based on query color and tipo_alvo
 */
const getMarkerColor = (queryColor, tipoAlvo) => {
  if (tipoAlvo === 'forte') {
    return lightenColor(queryColor, 30);
  }
  return darkenColor(queryColor, 20);
};

const lightenColor = (color, percent) => {
  const num = parseInt(color.replace("#",""), 16);
  const amt = Math.round(2.55 * percent);
  const R = (num >> 16) + amt;
  const G = (num >> 8 & 0x00FF) + amt;
  const B = (num & 0x0000FF) + amt;
  return "#" + (
    0x1000000 +
    (R < 255 ? (R < 1 ? 0 : R) : 255) * 0x10000 +
    (G < 255 ? (G < 1 ? 0 : G) : 255) * 0x100 +
    (B < 255 ? (B < 1 ? 0 : B) : 255)
  ).toString(16).slice(1);
};

const darkenColor = (color, percent) => {
  const num = parseInt(color.replace("#",""), 16);
  const amt = Math.round(2.55 * percent);
  const R = (num >> 16) - amt;
  const G = (num >> 8 & 0x00FF) - amt;
  const B = (num & 0x0000FF) - amt;
  return "#" + (
    0x1000000 +
    (R > 0 ? R : 0) * 0x10000 +
    (G > 0 ? G : 0) * 0x100 +
    (B > 0 ? R : 0)
  ).toString(16).slice(1);
};

/**
 * Create custom marker icon with specific color
 */
const createMarkerIcon = (color, tipoAlvo, isAuxiliary = false) => {
  // Balanced marker sizes for good visibility
  // Main markers: 16px regular, 20px forte
  // Auxiliary markers: 12px
  const size = isAuxiliary ? 12 : (tipoAlvo === 'forte' ? 20 : 16);
  const opacity = isAuxiliary ? 0.7 : (tipoAlvo === 'forte' ? 1 : 0.85);
  const shape = isAuxiliary ? 'square' : 'circle';
  
  const svgIcon = shape === 'circle' 
    ? `<svg width="${size}" height="${size}" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
         <circle cx="50" cy="50" r="45" fill="${color}" opacity="${opacity}" stroke="#ffffff" stroke-width="8"/>
       </svg>`
    : `<svg width="${size}" height="${size}" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
         <rect x="10" y="10" width="80" height="80" fill="${color}" opacity="${opacity}" stroke="#ffffff" stroke-width="8"/>
       </svg>`;

  return L.divIcon({
    html: svgIcon,
    className: 'custom-marker-icon',
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  });
};

const InstallationMarkers = ({ results, onMarkerClick, isAuxiliary = false }) => {
  console.log(`${isAuxiliary ? '🟢' : '🔵'} InstallationMarkers rendering ${results?.length || 0} markers, isAuxiliary: ${isAuxiliary}`);
  
  if (!results || results.length === 0) {
    console.warn(`${isAuxiliary ? '🟢' : '🔵'} No results to render`);
    return null;
  }

  return (
    <>
      {results.map((feature, index) => {
        const { geometry, properties } = feature;
        
        if (!geometry || !geometry.coordinates) {
          console.error('Invalid geometry:', feature);
          return null;
        }
        
        const [lng, lat] = geometry.coordinates;
        
        // Get query color and tipo_alvo from properties
        const queryColor = properties.query_cor || '#6B7280';
        const tipoAlvo = properties.tipo_alvo || 'regular';
        
        // Calculate marker color based on query and tipo_alvo
        const markerColor = getMarkerColor(queryColor, tipoAlvo);
        const icon = createMarkerIcon(markerColor, tipoAlvo, isAuxiliary);

        const markerKey = `${isAuxiliary ? 'aux' : 'main'}-${properties.query_id}-${properties.id_instalacao}-${index}`;

        return (
          <Marker
            key={markerKey}
            position={[lat, lng]}
            icon={icon}
            eventHandlers={{
              click: () => {
                console.log('Marker clicked:', properties);
                if (onMarkerClick) {
                  onMarkerClick(properties);
                }
              }
            }}
          >
            <Popup>
              <div style={{ minWidth: '200px' }}>
                <h4 style={{ 
                  margin: '0 0 8px 0', 
                  color: queryColor,
                  fontSize: '14px',
                  fontWeight: '600'
                }}>
                  {properties.query_nome}
                  {isAuxiliary && <span style={{ marginLeft: '8px', fontSize: '10px', opacity: 0.7 }}>(Aux)</span>}
                </h4>
                <div style={{ fontSize: '12px', color: '#6B7280' }}>
                  <p style={{ margin: '4px 0' }}>
                    <strong>Instalação:</strong> {properties.id_instalacao}
                  </p>
                  <p style={{ margin: '4px 0' }}>
                    <strong>Município:</strong> {properties.municipio}
                  </p>
                  <p style={{ margin: '4px 0' }}>
                    <strong>Classe:</strong> {properties.classe_tarifaria}
                  </p>
                  {!isAuxiliary && properties.tipo_alvo && (
                    <p style={{ margin: '4px 0' }}>
                      <strong>Tipo:</strong>{' '}
                      <span 
                        style={{ 
                          padding: '2px 6px', 
                          borderRadius: '4px',
                          backgroundColor: tipoAlvo === 'forte' ? '#FEF3C7' : '#E5E7EB',
                          color: tipoAlvo === 'forte' ? '#92400E' : '#374151',
                          fontSize: '11px',
                          fontWeight: '600'
                        }}
                      >
                        {tipoAlvo.toUpperCase()}
                      </span>
                    </p>
                  )}
                  {properties.score && (
                    <p style={{ margin: '4px 0' }}>
                      <strong>Score:</strong> {properties.score.toFixed(2)}
                    </p>
                  )}
                  {isAuxiliary && properties.intensidade && (
                    <p style={{ margin: '4px 0' }}>
                      <strong>Intensidade:</strong> {properties.intensidade.toFixed(2)}
                    </p>
                  )}
                </div>
              </div>
            </Popup>
          </Marker>
        );
      })}
    </>
  );
};

export default InstallationMarkers;
