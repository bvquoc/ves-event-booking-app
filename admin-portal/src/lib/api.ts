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
  errorDetails?: string;
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
// Ticket types
export interface TicketResponse {
  id: string;
  eventId: string;
  eventName: string;
  eventThumbnail?: string;
  eventStartDate: string;
  venueName?: string;
  ticketTypeName: string;
  seatNumber?: string;
  status: "ACTIVE" | "USED" | "CANCELLED" | "REFUNDED";
  qrCode?: string;
  purchaseDate: string;
}

export interface TicketDetailResponse {
  id: string;
  eventId: string;
  eventName: string;
  eventDescription?: string;
  eventThumbnail?: string;
  eventStartDate: string;
  eventEndDate?: string;
  venueName?: string;
  venueAddress?: string;
  ticketTypeId: string;
  ticketTypeName: string;
  ticketTypeDescription?: string;
  ticketTypePrice: number;
  seatNumber?: string;
  qrCode?: string;
  qrCodeImage?: string;
  status: "ACTIVE" | "USED" | "CANCELLED" | "REFUNDED";
  purchaseDate: string;
  checkedInAt?: string;
  cancellationReason?: string;
  refundAmount?: number;
  refundStatus?: "PENDING" | "PROCESSING" | "COMPLETED" | "FAILED";
  cancelledAt?: string;
}

export interface CancelTicketRequest {
  reason?: string;
}

export interface CancellationResponse {
  ticketId: string;
  status: "ACTIVE" | "USED" | "CANCELLED" | "REFUNDED";
  refundAmount?: number;
  refundPercentage?: number;
  refundStatus?: "PENDING" | "PROCESSING" | "COMPLETED" | "FAILED";
  cancelledAt?: string;
  message?: string;
}

export interface PageTicketResponse {
  totalElements: number;
  totalPages: number;
  size: number;
  content: TicketResponse[];
  number: number;
  sort: SortObject;
  pageable: PageableObject;
  numberOfElements: number;
  first: boolean;
  last: boolean;
  empty: boolean;
}

export interface SortObject {
  empty: boolean;
  sorted: boolean;
  unsorted: boolean;
}

export interface PageableObject {
  offset: number;
  sort: SortObject;
  pageNumber: number;
  pageSize: number;
  paged: boolean;
  unpaged: boolean;
}

// Notification types
export interface NotificationResponse {
  id: string;
  type:
    | "TICKET_PURCHASED"
    | "EVENT_REMINDER"
    | "EVENT_CANCELLED"
    | "PROMOTION"
    | "SYSTEM";
  title: string;
  message: string;
  isRead: boolean;
  data?: Record<string, string>;
  createdAt: string;
}

export interface PageResponseNotificationResponse {
  content: NotificationResponse[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}

// Voucher types
export interface VoucherResponse {
  id: string;
  code: string;
  title: string;
  description?: string;
  discountType: "FIXED_AMOUNT" | "PERCENTAGE";
  discountValue: number;
  minOrderAmount?: number;
  maxDiscount?: number;
  startDate: string;
  endDate: string;
  usageLimit?: number;
  usedCount?: number;
  applicableEvents?: string[];
  applicableCategories?: string[];
  isPublic: boolean;
}

export interface UserVoucherResponse {
  id: string;
  voucher: VoucherResponse;
  isUsed: boolean;
  usedAt?: string;
  orderId?: string;
  addedAt: string;
}

export interface ValidateVoucherRequest {
  voucherCode: string;
  eventId: string;
  ticketTypeId: string;
  quantity: number;
}

export interface VoucherValidationResponse {
  isValid: boolean;
  message?: string;
  orderAmount?: number;
  discountAmount?: number;
  finalAmount?: number;
  voucher?: VoucherResponse;
}

// Error Code types
export interface ErrorCodeResponse {
  name: string;
  code: number;
  message: string;
  httpStatus: number;
  category?: string;
}

export const authApi = {
  login: async (credentials: AuthenticationRequest) => {
    const response = await apiClient.post<ApiResponse<AuthenticationResponse>>(
      "/auth/login",
      credentials
    );
    return response.data;
  },
  register: async (user: UserCreationRequest) => {
    const response = await apiClient.post<ApiResponse<AuthenticationResponse>>(
      "/auth/register",
      user
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

export const ticketApi = {
  getTickets: async (params?: {
    status?: "ACTIVE" | "USED" | "CANCELLED" | "REFUNDED";
    pageable: Pageable;
  }) => {
    const response = await apiClient.get<ApiResponse<PageTicketResponse>>(
      "/tickets",
      { params }
    );
    return response.data;
  },
  getTicketDetails: async (ticketId: string) => {
    const response = await apiClient.get<ApiResponse<TicketDetailResponse>>(
      `/tickets/${ticketId}`
    );
    return response.data;
  },
  cancelTicket: async (ticketId: string, request: CancelTicketRequest) => {
    const response = await apiClient.put<ApiResponse<CancellationResponse>>(
      `/tickets/${ticketId}/cancel`,
      request
    );
    return response.data;
  },
};

export const notificationApi = {
  getNotifications: async (params?: {
    unreadOnly?: boolean;
    pageable: Pageable;
  }) => {
    const response = await apiClient.get<
      ApiResponse<PageResponseNotificationResponse>
    >("/notifications", { params });
    return response.data;
  },
  markAsRead: async (notificationId: string) => {
    const response = await apiClient.put<ApiResponse<void>>(
      `/notifications/${notificationId}/read`
    );
    return response.data;
  },
  markAllAsRead: async () => {
    const response = await apiClient.put<ApiResponse<void>>(
      "/notifications/read-all"
    );
    return response.data;
  },
};

export const voucherApi = {
  getPublicVouchers: async () => {
    const response = await apiClient.get<ApiResponse<VoucherResponse[]>>(
      "/vouchers"
    );
    return response.data;
  },
  getUserVouchers: async (status?: string) => {
    const response = await apiClient.get<ApiResponse<UserVoucherResponse[]>>(
      "/vouchers/my-vouchers",
      { params: status ? { status } : undefined }
    );
    return response.data;
  },
  validateVoucher: async (request: ValidateVoucherRequest) => {
    const response = await apiClient.post<
      ApiResponse<VoucherValidationResponse>
    >("/vouchers/validate", request);
    return response.data;
  },
};

export const favoriteApi = {
  getFavorites: async (pageable: Pageable) => {
    const response = await apiClient.get<
      ApiResponse<PageResponse<EventResponse>>
    >("/favorites", { params: pageable });
    return response.data;
  },
  addFavorite: async (eventId: string) => {
    const response = await apiClient.post<ApiResponse<void>>(
      `/favorites/${eventId}`
    );
    return response.data;
  },
  removeFavorite: async (eventId: string) => {
    const response = await apiClient.delete<ApiResponse<void>>(
      `/favorites/${eventId}`
    );
    return response.data;
  },
};

export const errorCodeApi = {
  getAllErrorCodes: async () => {
    const response = await apiClient.get<ApiResponse<ErrorCodeResponse[]>>(
      "/error-codes"
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
