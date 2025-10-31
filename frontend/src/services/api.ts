import axios from 'axios';

const API_BASE_URL = '/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true, // Include cookies for session management
  headers: {
    'Content-Type': 'application/json',
  },
});

export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  roles: string[];
  role_displays: string[];
  primary_role: string;
  position?: string;
  jersey_number?: number;
  is_captain: boolean;
  emergency_contact?: string;
  emergency_phone?: string;
}

export interface LoginResponse {
  success: boolean;
  user: User;
  token: string;
}

export interface Event {
  id: string;
  title: string;
  description: string;
  event_date: string;
  event_time: string;
  location: string;
  event_type: string;
  created_at: string;
  user_rsvp_status?: string;
  user_rsvp_display?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

class ApiService {
  async login(email: string, password: string): Promise<LoginResponse> {
    const response = await apiClient.post('/auth/login', { email, password });
    return response.data;
  }

  async logout(): Promise<void> {
    await apiClient.post('/auth/logout');
  }

  async getCurrentUser(): Promise<{ success: boolean; user?: User }> {
    try {
      const response = await apiClient.get('/auth/me');
      return response.data;
    } catch (error) {
      return { success: false };
    }
  }

  async updateProfile(profileData: Partial<User>): Promise<{ success: boolean; message?: string }> {
    const response = await apiClient.put('/user/profile', profileData);
    return response.data;
  }

  async getTeamEvents(teamId: string): Promise<{ success: boolean; events: Event[]; error?: string }> {
    const response = await apiClient.get(`/teams/${teamId}/events`);
    return response.data;
  }

  async createEvent(eventData: Partial<Event>): Promise<{ success: boolean; event?: Event }> {
    const response = await apiClient.post('/events', eventData);
    return response.data;
  }

  async updateEvent(eventId: string, eventData: Partial<Event>): Promise<{ success: boolean }> {
    const response = await apiClient.put(`/events/${eventId}`, eventData);
    return response.data;
  }

  async deleteEvent(eventId: string): Promise<{ success: boolean }> {
    const response = await apiClient.delete(`/events/${eventId}`);
    return response.data;
  }

  async rsvpEvent(eventId: string, status: 'yes' | 'no' | 'maybe'): Promise<{ success: boolean }> {
    const response = await apiClient.post(`/events/${eventId}/rsvp`, { status });
    return response.data;
  }
}

export const apiService = new ApiService();