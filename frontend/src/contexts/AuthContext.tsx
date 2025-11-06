import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import api, { setAuthToken } from '../services/api';

// Types
interface User {
  id: string;
  email: string;
  name: string;
  phone?: string;
  roles: string[];
  created_at: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (userData: RegisterData) => Promise<void>;
  logout: () => void;
  updateUser: (userData: Partial<User>) => void;
}

interface RegisterData {
  email: string;
  password: string;
  name: string;
  phone?: string;
}

interface AuthProviderProps {
  children: ReactNode;
}

// Create context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

console.log('🔧 API Configuration:');
console.log('  Using API service with base URL: /api');
console.log('  window.location.origin:', window.location.origin);

// Auth Provider Component
export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [loading, setLoading] = useState(true);

  // Set up API auth token
  useEffect(() => {
    setAuthToken(token);
  }, [token]);

  // Token expiration handling is now done in the API service

  // Load user on app start
  useEffect(() => {
    const loadUser = async () => {
      if (token) {
        try {
          const response = await api.get('/auth/me');
          setUser(response.data.user);
        } catch (error) {
          console.error('Failed to load user:', error);
          // Token might be invalid, remove it
          localStorage.removeItem('token');
          setToken(null);
        }
      }
      setLoading(false);
    };

    loadUser();
  }, [token]);

  const login = async (email: string, password: string): Promise<void> => {
    try {
      const response = await api.post('/auth/login', { email, password });
      const { token: newToken } = response.data;
      
      // Set token first so the next request has authorization
      setToken(newToken);
      localStorage.setItem('token', newToken);
      
      // Now get full user data including roles
      const userResponse = await api.get('/auth/me');
      setUser(userResponse.data.user);
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Login failed');
    }
  };

  const register = async (userData: RegisterData): Promise<void> => {
    try {
      const response = await api.post('/auth/register', userData);
      const { user: newUser, token: newToken } = response.data;
      
      setUser(newUser);
      setToken(newToken);
      localStorage.setItem('token', newToken);
    } catch (error: any) {
      throw new Error(error.response?.data?.error || 'Registration failed');
    }
  };

  const logout = () => {
    // Call logout endpoint (fire and forget)
    if (token) {
      api.post('/auth/logout').catch(console.error);
    }
    
    setUser(null);
    setToken(null);
    localStorage.removeItem('token');
    setAuthToken(null);
  };

  const updateUser = (userData: Partial<User>) => {
    if (user) {
      setUser({ ...user, ...userData });
    }
  };

  const value: AuthContextType = {
    user,
    token,
    loading,
    login,
    register,
    logout,
    updateUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

// Hook to use auth context
export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export default AuthContext;