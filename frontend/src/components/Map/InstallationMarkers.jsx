/**
 * InstallationMarkers Component - Phase 2 Updated
 * Renders installation markers on map with query-specific colors
 * - Each query has its own color
 * - Darker shade for regular targets, lighter shade for forte targets
 */
import React from 'react';
import {Marker, Popup } from 'react-leaflet';
import L from 'leaflet';

/**
 * Generate marker color based on query color and tipo_alvo
 * @param {string} queryColor - Base color from query (e.g., '#3B82F6')
 * @param {string} tipoAlvo - 'regular' or 'forte'
 * @returns {string} Color for the marker
 */
const getMarkerColor = (queryColor, tipoAlvo) => {
  if (tipoAlvo === 'forte') {
    // Return lighter version of query color for forte targets
    return lightenColor(queryColor, 30);
  }
  // Return darker version of query color for regular targets
  return darkenColor(queryColor, 20);
};

/**
 * Lighten a hex color
 */
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

/**
 * Darken a hex color
 */
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
    (B > 0 ? B : 0)
  ).toString(16).slice(1);
};

/**
 * Create custom marker icon with specific color
 */
const createMarkerIcon = (color, tipoAlvo) => {
  const size = tipoAlvo === 'forte' ? 14 : 10;
  const opacity = tipoAlvo === 'forte' ? 1 : 0.85;
  
  const svgIcon = `
    <svg width="${size}" height="${size}" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <circle cx="50" cy="50" r="45" fill="${color}" opacity="${opacity}" stroke="#ffffff" stroke-width="8"/>
    </svg>
  `;

  return L.divIcon({
    html: svgIcon,
    className: 'custom-marker-icon',
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  });
};

const InstallationMarkers = ({ results }) => {
  if (!results || results.length === 0) {
    return null;
  }

  return (
    <>
      {results.map((feature) => {
        const { geometry, properties } = feature;
        const [lng, lat] = geometry.coordinates;
        
        // Get query color and tipo_alvo from properties
        const queryColor = properties.query_cor || '#6B7280'; // Fallback gray
        const tipoAlvo = properties.tipo_alvo || 'regular';
        
        // Calculate marker color based on query and tipo_alvo
        const markerColor = getMarkerColor(queryColor, tipoAlvo);
        const icon = createMarkerIcon(markerColor, tipoAlvo);

        return (
          <Marker
            key={`${properties.query_id}-${properties.id_instalacao}`}
            position={[lat, lng]}
            icon={icon}
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
                </h4>
                <div style={{ fontSize: '12px', color: '#6B7280' }}>
                  <p style={{ margin: '4px 0' }}>
                    <strong>Instalacao:</strong> {properties.id_instalacao}
                  </p>
                  <p style={{ margin: '4px 0' }}>
                    <strong>Municipio:</strong> {properties.municipio}
                  </p>
                  <p style={{ margin: '4px 0' }}>
                    <strong>Classe:</strong> {properties.classe_tarifaria}
                  </p>
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
                  {properties.score && (
                    <p style={{ margin: '4px 0' }}>
                      <strong>Score:</strong> {properties.score.toFixed(2)}
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
