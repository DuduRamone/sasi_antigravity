/**
 * Heatmap Component - Phase 4
 * Renders heatmap overlay for auxiliary queries with tipo_retorno='heatmap'
 * Uses leaflet.heat plugin
 */
import { useEffect } from 'react';
import { useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet.heat';

const Heatmap = ({ results }) => {
  const map = useMap();

  console.log('🔥 Heatmap component rendered');
  console.log('🔥 Heatmap results:', results);
  console.log('🔥 Map object:', map);

  useEffect(() => {
    console.log('🔥 Heatmap useEffect triggered');
    
    if (!map) {
      console.warn('⚠️ Heatmap: No map instance');
      return;
    }
    
    if (!results || results.length === 0) {
      console.warn('⚠️ Heatmap: No results', results);
      return;
    }

    console.log('🔥 Heatmap rendering with', results.length, 'points');

    // Convert GeoJSON features to heatmap data format
    const heatmapData = results.map(feature => {
      const [lng, lat] = feature.geometry.coordinates;
      // Use intensidade as heat intensity (0-1 range)
      const intensity = feature.properties.intensidade || 0.5;
      return [lat, lng, intensity];
    });

    // Create heatmap layer with MUCH MORE SENSITIVE settings
    const heatLayer = L.heatLayer(heatmapData, {
      radius: 35,          // Increased from 25 - bigger heat circles
      blur: 45,            // Increased from 35 - smoother transitions
      maxZoom: 17,
      max: 0.6,            // LOWERED from 1.0 - makes colors appear faster!
      minOpacity: 0.3,     // Minimum opacity for visibility
      gradient: {          // Vibrant gradient for light backgrounds
        0.0: '#6B00B3',    // Deep Purple (low)
        0.2: '#9D00FF',    // Bright Purple
        0.4: '#FF00FF',    // Magenta
        0.6: '#FF6600',    // Vibrant Orange
        0.8: '#FF3300',    // Red-Orange
        1.0: '#CC0000'     // Deep Red (high)
      }
    });

    heatLayer.addTo(map);

    // Cleanup
    return () => {
      map.removeLayer(heatLayer);
    };
  }, [map, results]);

  return null;
};

export default Heatmap;
