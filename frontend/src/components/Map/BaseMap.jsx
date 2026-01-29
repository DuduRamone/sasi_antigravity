/**
 * BaseMap Component - Using Leaflet Geoman (more reliable than leaflet-draw)
 * Clean implementation with polygon drawing that actually works
 */
import React, { useEffect, useRef } from 'react';
import { MapContainer, TileLayer, GeoJSON, useMap } from 'react-leaflet';
import L from 'leaflet';
import '@geoman-io/leaflet-geoman-free';
import '@geoman-io/leaflet-geoman-free/dist/leaflet-geoman.css';

// RN state center coordinates
const RN_CENTER = [-5.79, -36.52];
const RN_BOUNDS = [
  [-6.98, -38.56], // Southwest
  [-4.83, -34.91]  // Northeast
];

// Approximate RN boundary (simplified polygon)
const RN_BOUNDARY_GEOJSON = {
  type: "FeatureCollection",
  features: [{
    type: "Feature",
    properties: { name: "Rio Grande do Norte" },
    geometry: {
      type: "Polygon",
      coordinates: [[
        [-38.5, -4.8],
        [-34.9, -4.8],
        [-34.9, -7.0],
        [-38.5, -7.0],
        [-38.5, -4.8]
      ]]
    }
  }]
};

// Geoman Drawing Control Component
const GeomanControl = ({ enabled, onPolygonCreated, onPolygonEdited, onPolygonDeleted }) => {
  const map = useMap();
  const currentPolygonRef = useRef(null);

  useEffect(() => {
    if (!map) return;

    console.log('🎨 Geoman enabled:', enabled);

    if (enabled) {
      // Enable Geoman controls
      map.pm.addControls({
        position: 'topright',
        drawPolygon: true,
        drawMarker: false,
        drawCircleMarker: false,
        drawPolyline: false,
        drawRectangle: false,
        drawCircle: false,
        drawText: false,
        editMode: true,
        dragMode: false,
        cutPolygon: false,
        removalMode: true,
        rotateMode: false
      });

      // Set polygon style
      map.pm.setPathOptions({
        color: '#F59E0B',
        fillColor: '#F59E0B',
        fillOpacity: 0.2,
        weight: 2
      });

      // Event: polygon created
      const handleCreate = (e) => {
        console.log('✅ Polygon created', e);
        
        // Remove previous polygon if exists
        if (currentPolygonRef.current) {
          map.removeLayer(currentPolygonRef.current);
        }
        
        currentPolygonRef.current = e.layer;
        const geoJSON = e.layer.toGeoJSON();
        
        if (onPolygonCreated) {
          onPolygonCreated(geoJSON.geometry);
        }
      };

      // Event: polygon edited
      const handleEdit = (e) => {
        console.log('✏️ Polygon edited', e);
        const layers = e.layers;
        layers.eachLayer((layer) => {
          const geoJSON = layer.toGeoJSON();
          if (onPolygonEdited) {
            onPolygonEdited(geoJSON.geometry);
          }
        });
      };

      // Event: polygon removed
      const handleRemove = (e) => {
        console.log('🗑️ Polygon removed', e);
        currentPolygonRef.current = null;
        if (onPolygonDeleted) {
          onPolygonDeleted();
        }
      };

      map.on('pm:create', handleCreate);
      map.on('pm:edit', handleEdit);
      map.on('pm:remove', handleRemove);

      return () => {
        map.off('pm:create', handleCreate);
        map.off('pm:edit', handleEdit);
        map.off('pm:remove', handleRemove);
        map.pm.removeControls();
        if (currentPolygonRef.current) {
          map.removeLayer(currentPolygonRef.current);
        }
      };
    } else {
      // Disabled: remove controls and polygon
      map.pm.removeControls();
      if (currentPolygonRef.current) {
        map.removeLayer(currentPolygonRef.current);
        currentPolygonRef.current = null;
      }
    }
  }, [map, enabled, onPolygonCreated, onPolygonEdited, onPolygonDeleted]);

  return null;
};

const BaseMap = ({ 
  children, 
  showEmptyState,
  areaSelectionMode,
  onPolygonCreated,
  onPolygonEdited,
  onPolygonDeleted
}) => {
  // RN boundary style (very subtle, just for context)
  const rnBoundaryStyle = {
    fillColor: 'transparent',
    fillOpacity: 0,
    color: '#6B7280',
    weight: 1,
    opacity: 0.3,
    dashArray: '5, 5'
  };

  console.log('🗺️ BaseMap render - areaSelectionMode:', areaSelectionMode, 'children:', children);

  return (
    <div className="map-container">
      <MapContainer
        center={RN_CENTER}
        zoom={7}
        maxBounds={RN_BOUNDS}
        maxBoundsViscosity={0.8}
        style={{ height: '100%', width: '100%' }}
      >
        {/* Base Tile Layer */}
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />

        {/* RN State Boundary - Very subtle */}
        <GeoJSON data={RN_BOUNDARY_GEOJSON} style={rnBoundaryStyle} />

        {/* Geoman Drawing Controls */}
        <GeomanControl 
          enabled={areaSelectionMode === 'poligono'}
          onPolygonCreated={onPolygonCreated}
          onPolygonEdited={onPolygonEdited}
          onPolygonDeleted={onPolygonDeleted}
        />

        {/* Installation Markers (passed as children) */}
        {children}

        {/* Empty State Overlay */}
        {showEmptyState && (
          <div className="map-empty-state">
            <div className="empty-state-content">
              <h2>🗺️ Bem-vindo ao SASI</h2>
              <p>Selecione uma ou mais queries principais para visualizar dados no mapa</p>
            </div>
          </div>
        )}
      </MapContainer>
    </div>
  );
};

export default BaseMap;
