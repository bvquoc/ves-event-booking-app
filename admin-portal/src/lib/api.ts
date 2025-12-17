import axios, { AxiosInstance, AxiosError } from "axios";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8080/api";

class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        "Content-Type": "application/json",
      },
    });

    // Request interceptor to add auth token
    this.client.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem("auth_token");
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        if (error.response?.status === 401) {
          localStorage.removeItem("auth_token");
          window.location.href = "/login";
        }
        return Promise.reject(error);
      }
    );
  }

  get instance() {
    return this.client;
  }
}

export const apiClient = new ApiClient().instance;

// API Response wrapper
export interface ApiResponse<T> {
  code: number;
  message: string;
  result: T;
}

// Auth types
export interface AuthenticationRequest {
  username: string;
  password: string;
}

export interface AuthenticationResponse {
  token: string;
  authenticated: boolean;
}

// User types
export interface UserResponse {
  id: string;
  username: string;
  firstName: string;
  lastName: string;
  dob?: string;
  roles: RoleResponse[];
}

export interface UserCreationRequest {
  username: string;
  password: string;
  firstName?: string;
  lastName?: string;
  dob?: string;
}

export interface UserUpdateRequest {
  password?: string;
  firstName?: string;
  lastName?: string;
  dob?: string;
  roles?: string[];
}

// Role & Permission types
export interface RoleResponse {
  name: string;
  description?: string;
  permissions: PermissionResponse[];
}

export interface RoleRequest {
  name: string;
  description?: string;
  permissions?: string[];
}

export interface PermissionResponse {
  name: string;
  description?: string;
}

export interface PermissionRequest {
  name: string;
  description?: string;
}

// Event types
export interface EventResponse {
  id: string;
  name: string;
  slug: string;
  description?: string;
  thumbnail?: string;
  images?: string[];
  startDate: string;
  endDate?: string;
  category?: CategoryResponse;
  city?: CityResponse;
  venueId?: string;
  venueName?: string;
  venueAddress?: string;
  currency?: string;
  isTrending?: boolean;
  organizerName?: string;
  organizerLogo?: string;
  tags?: string[];
  minPrice?: number;
  maxPrice?: number;
  availableTickets?: number;
  isFavorite?: boolean;
}

export interface EventDetailResponse extends EventResponse {
  longDescription?: string;
  organizerId?: string;
  terms?: string;
  cancellationPolicy?: string;
  ticketTypes?: TicketTypeResponse[];
  venue?: VenueSeatingResponse;
  createdAt?: string;
  updatedAt?: string;
}

export interface EventRequest {
  name: string;
  slug: string;
  description?: string;
  longDescription?: string;
  categoryId: string;
  thumbnail?: string;
  images?: string[];
  startDate: string;
  endDate?: string;
  cityId: string;
  venueId?: string;
  venueName?: string;
  venueAddress?: string;
  currency?: string;
  isTrending?: boolean;
  organizerId?: string;
  organizerName?: string;
  organizerLogo?: string;
  terms?: string;
  cancellationPolicy?: string;
  tags?: string[];
  ticketTypes?: TicketTypeRequest[];
}

export interface TicketTypeRequest {
  name: string;
  description?: string;
  price: number;
  currency?: string;
  available: number;
  maxPerOrder?: number;
  benefits?: string[];
  requiresSeatSelection: boolean;
}

export interface TicketTypeResponse {
  id: string;
  name: string;
  description?: string;
  price: number;
  currency?: string;
  available: number;
  maxPerOrder?: number;
  benefits?: string[];
  requiresSeatSelection: boolean;
}

// Venue types
export interface VenueResponse {
  id: string;
  name: string;
  address?: string;
  capacity?: number;
  city?: CityResponse;
}

export interface VenueSeatingResponse {
  venueId: string;
  venueName: string;
  eventId: string;
  sections?: SectionResponse[];
}

export interface SectionResponse {
  sectionName: string;
  rows?: RowResponse[];
}

export interface RowResponse {
  rowName: string;
  seats?: SeatResponse[];
}

export interface SeatResponse {
  id: string;
  seatNumber: string;
  status: "AVAILABLE" | "RESERVED" | "SOLD" | "BLOCKED";
}

// Reference data types
export interface CategoryResponse {
  id: string;
  name: string;
  slug: string;
  icon?: string;
  eventCount?: number;
}

export interface CityResponse {
  id: string;
  name: string;
  slug: string;
  eventCount?: number;
}

export interface CityRequest {
  name: string;
  slug: string;
}

export interface VenueRequest {
  name: string;
  cityId: string;
  address?: string;
  capacity?: number;
}

// Pageable types
export interface Pageable {
  page: number;
  size: number;
  sort?: string[];
}

export interface PageResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}

// API functions
export const authApi = {
  login: async (credentials: AuthenticationRequest) => {
    const response = await apiClient.post<ApiResponse<AuthenticationResponse>>(
      "/auth/token",
      credentials
    );
    return response.data;
  },
  refresh: async (token: string) => {
    const response = await apiClient.post<ApiResponse<AuthenticationResponse>>(
      "/auth/refresh",
      { token }
    );
    return response.data;
  },
  logout: async (token: string) => {
    const response = await apiClient.post<ApiResponse<void>>("/auth/logout", {
      token,
    });
    return response.data;
  },
  introspect: async (token: string) => {
    const response = await apiClient.post<ApiResponse<{ valid: boolean }>>(
      "/auth/introspect",
      { token }
    );
    return response.data;
  },
};

export const userApi = {
  getUsers: async () => {
    const response = await apiClient.get<ApiResponse<UserResponse[]>>("/users");
    return response.data;
  },
  getUser: async (userId: string) => {
    const response = await apiClient.get<ApiResponse<UserResponse>>(
      `/users/${userId}`
    );
    return response.data;
  },
  getMyInfo: async () => {
    const response = await apiClient.get<ApiResponse<UserResponse>>(
      "/users/my-info"
    );
    return response.data;
  },
  createUser: async (user: UserCreationRequest) => {
    const response = await apiClient.post<ApiResponse<UserResponse>>(
      "/users",
      user
    );
    return response.data;
  },
  updateUser: async (userId: string, user: UserUpdateRequest) => {
    const response = await apiClient.put<ApiResponse<UserResponse>>(
      `/users/${userId}`,
      user
    );
    return response.data;
  },
  deleteUser: async (userId: string) => {
    const response = await apiClient.delete<ApiResponse<string>>(
      `/users/${userId}`
    );
    return response.data;
  },
};

export const eventApi = {
  getEvents: async (params?: {
    category?: string;
    city?: string;
    trending?: boolean;
    startDate?: string;
    endDate?: string;
    search?: string;
    sortBy?: string;
    pageable: Pageable;
  }) => {
    const response = await apiClient.get<
      ApiResponse<PageResponse<EventResponse>>
    >("/events", { params });
    return response.data;
  },
  getEventDetails: async (eventId: string) => {
    const response = await apiClient.get<ApiResponse<EventDetailResponse>>(
      `/events/${eventId}`
    );
    return response.data;
  },
  createEvent: async (event: EventRequest) => {
    const response = await apiClient.post<ApiResponse<EventDetailResponse>>(
      "/events",
      event
    );
    return response.data;
  },
  updateEvent: async (eventId: string, event: EventRequest) => {
    const response = await apiClient.put<ApiResponse<EventDetailResponse>>(
      `/events/${eventId}`,
      event
    );
    return response.data;
  },
  deleteEvent: async (eventId: string) => {
    const response = await apiClient.delete<ApiResponse<void>>(
      `/events/${eventId}`
    );
    return response.data;
  },
  getEventTickets: async (eventId: string) => {
    const response = await apiClient.get<ApiResponse<TicketTypeResponse[]>>(
      `/events/${eventId}/tickets`
    );
    return response.data;
  },
  searchEvents: async (q: string, pageable: Pageable) => {
    const response = await apiClient.get<
      ApiResponse<PageResponse<EventResponse>>
    >("/events/search", {
      params: { q, ...pageable },
    });
    return response.data;
  },
};

export const roleApi = {
  getRoles: async () => {
    const response = await apiClient.get<ApiResponse<RoleResponse[]>>("/roles");
    return response.data;
  },
  createRole: async (role: RoleRequest) => {
    const response = await apiClient.post<ApiResponse<RoleResponse>>(
      "/roles",
      role
    );
    return response.data;
  },
  deleteRole: async (role: string) => {
    const response = await apiClient.delete<ApiResponse<void>>(
      `/roles/${role}`
    );
    return response.data;
  },
};

export const permissionApi = {
  getPermissions: async () => {
    const response = await apiClient.get<ApiResponse<PermissionResponse[]>>(
      "/permissions"
    );
    return response.data;
  },
  createPermission: async (permission: PermissionRequest) => {
    const response = await apiClient.post<ApiResponse<PermissionResponse>>(
      "/permissions",
      permission
    );
    return response.data;
  },
  deletePermission: async (permission: string) => {
    const response = await apiClient.delete<ApiResponse<void>>(
      `/permissions/${permission}`
    );
    return response.data;
  },
};

export const venueApi = {
  getVenues: async () => {
    const response = await apiClient.get<ApiResponse<VenueResponse[]>>(
      "/venues"
    );
    return response.data;
  },
  getVenueById: async (venueId: string) => {
    const response = await apiClient.get<ApiResponse<VenueResponse>>(
      `/venues/${venueId}`
    );
    return response.data;
  },
  createVenue: async (venue: VenueRequest) => {
    const response = await apiClient.post<ApiResponse<VenueResponse>>(
      "/venues",
      venue
    );
    return response.data;
  },
  updateVenue: async (venueId: string, venue: VenueRequest) => {
    const response = await apiClient.put<ApiResponse<VenueResponse>>(
      `/venues/${venueId}`,
      venue
    );
    return response.data;
  },
  deleteVenue: async (venueId: string) => {
    const response = await apiClient.delete<ApiResponse<void>>(
      `/venues/${venueId}`
    );
    return response.data;
  },
  getVenueSeating: async (venueId: string, eventId: string) => {
    const response = await apiClient.get<ApiResponse<VenueSeatingResponse>>(
      `/venues/${venueId}/seats`,
      {
        params: { eventId },
      }
    );
    return response.data;
  },
};

export const cityApi = {
  getCities: async () => {
    const response = await apiClient.get<ApiResponse<CityResponse[]>>(
      "/cities"
    );
    return response.data;
  },
  getCityById: async (cityId: string) => {
    const response = await apiClient.get<ApiResponse<CityResponse>>(
      `/cities/${cityId}`
    );
    return response.data;
  },
  createCity: async (city: CityRequest) => {
    const response = await apiClient.post<ApiResponse<CityResponse>>(
      "/cities",
      city
    );
    return response.data;
  },
  updateCity: async (cityId: string, city: CityRequest) => {
    const response = await apiClient.put<ApiResponse<CityResponse>>(
      `/cities/${cityId}`,
      city
    );
    return response.data;
  },
  deleteCity: async (cityId: string) => {
    const response = await apiClient.delete<ApiResponse<void>>(
      `/cities/${cityId}`
    );
    return response.data;
  },
};

export const referenceApi = {
  getCities: async () => {
    const response = await apiClient.get<ApiResponse<CityResponse[]>>(
      "/cities"
    );
    return response.data;
  },
  getCategories: async () => {
    const response = await apiClient.get<ApiResponse<CategoryResponse[]>>(
      "/categories"
    );
    return response.data;
  },
};
