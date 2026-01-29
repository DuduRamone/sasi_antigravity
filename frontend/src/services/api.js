/**
 * API Service - Centralized API communication
 */
import axios from 'axios';

// Use full backend URL directly to avoid proxy issues
const API_BASE_URL = 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 second timeout
});

// Add response interceptor for better error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response || error);
    throw error;
  }
);

// ============================================
// Query Endpoints
// ============================================

export const getMainQueries = async () => {
  try {
    const response = await api.get('/queries/main');
    console.log('Main queries response:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error fetching main queries:', error);
    throw error;
  }
};

export const getMainQueryResults = async (queryId, bounds = null) => {
  const params = bounds ? { bounds } : {};
  const response = await api.get(`/queries/main/${queryId}/results`, { params });
  console.log('📥 Main Query Results:', queryId, response.data);
  return response.data;
};

export const getAuxiliaryQueries = async () => {
  const response = await api.get('/queries/auxiliary');
  return response.data;
};

export const getAuxiliaryQueryResults = async (queryId, areaType, areaValue) => {
  const params = {
    area_type: areaType,
    area_value: typeof areaValue === 'object' ? JSON.stringify(areaValue) : areaValue,
  };
  const response = await api.get(`/queries/auxiliary/${queryId}/results`, { params });
  return response.data;
};

// ============================================
// Installation Endpoints
// ============================================

export const getInstallationDetails = async (installationId) => {
  const response = await api.get(`/installations/${installationId}`);
  return response.data;
};

export const getInstallationConsumption = async (installationId, limit = 12) => {
  const response = await api.get(`/installations/${installationId}/consumption`, {
    params: { limit },
  });
  return response.data;
};

export const getInstallationFrauds = async (installationId) => {
  const response = await api.get(`/installations/${installationId}/frauds`);
  return response.data;
};

export const getInstallationServiceNotes = async (installationId, limit = 20) => {
  const response = await api.get(`/installations/${installationId}/service-notes`, {
    params: { limit },
  });
  return response.data;
};

export const updateInstallationStatus = async (installationId, status, usuario, observacoes = null) => {
  const response = await api.put(`/installations/${installationId}/status`, {
    status,
    usuario,
    observacoes,
  });
  return response.data;
};

export const getInstallationStatus = async (installationId) => {
  const response = await api.get(`/installations/${installationId}/status`);
  return response.data;
};

// ============================================
// Area Endpoints
// ============================================

export const getMunicipalities = async () => {
  const response = await api.get('/areas/municipalities');
  return response.data;
};

export const getMunicipalityGeometry = async (municipalityName) => {
  const response = await api.get(`/areas/municipalities/${municipalityName}/geometry`);
  return response.data;
};

export const getAreaMetrics = async (areaType, areaValue) => {
  const response = await api.post('/areas/metrics', {
    tipo: areaType,
    valor: areaValue,
  });
  return response.data;
};

export default api;
