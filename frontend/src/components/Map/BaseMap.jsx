/**
 * BaseMap Component - Phase 1
 * Displays the map of Rio Grande do Norte with empty state
 */
import React from 'react';
import { MapContainer, TileLayer, GeoJSON } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

// RN (Rio Grande do Norte) bounds
const RN_CENTER = [-5.79, -36.65];
const RN_BOUNDS = [
  [-6.9, -38.6], // Southwest
  [-4.8, -34.9]  // Northeast
];

const BaseMap = ({ children, showEmptyState }) => {
  return (
    <div className="map-container">
      <MapContainer
        center={RN_CENTER}
        zoom={7}
        style={{ height: '100%', width: '100%' }}
        maxBounds={RN_BOUNDS}
        maxBoundsViscosity={0.5}
        minZoom={6}
      >
        {/* Tile Layer - OpenStreetMap */}
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        
        {/* Children components (markers, layers, etc.) */}
        {children}
      </MapContainer>
      
      {/* Empty State Overlay */}
      {showEmptyState && (
        <div className="empty-state-overlay">
          <div className="empty-state-icon">📍</div>
          <h2>Nenhuma Query Principal Selecionada</h2>
          <p>
            Selecione uma ou mais <strong>queries principais</strong> no painel lateral 
            para visualizar os alvos de inspeção no mapa.
          </p>
          <p className="warning-text" style={{ marginTop: '1rem', fontSize: '0.875rem' }}>
            ⚠️ Os dados só serão exibidos após a seleção de pelo menos uma query principal.
          </p>
        </div>
      )}
    </div>
  );
};

export default BaseMap;
