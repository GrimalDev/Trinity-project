import axios from "axios";
import type { AxiosInstance } from "axios";

// Create an Axios instance
export const apiClient: AxiosInstance = axios.create({
  baseURL: "/api", // Base URL for your API
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  },
});
export const apiClientProtected: AxiosInstance = axios.create({
  baseURL: "/api",
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "max-age=60",
  },
});

// Add a request interceptor to dynamically set the Authorization header
apiClientProtected.interceptors.request.use((config) => {
  const token = sessionStorage.getItem("access_token");
  if (token) {
    config.headers["Authorization"] = `Bearer ${token}`;
  }
  return config;
});