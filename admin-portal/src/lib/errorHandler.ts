import { AxiosError } from "axios";
import toast from "react-hot-toast";

// Error code mapping from backend
const ERROR_CODES: Record<number, { message: string; category: string }> = {
  9999: { message: "An unexpected error occurred", category: "System errors" },
  1001: { message: "Invalid key", category: "User errors" },
  1002: { message: "User already exists", category: "User errors" },
  1003: { message: "Username is invalid", category: "User errors" },
  1004: { message: "Password is invalid", category: "User errors" },
  1005: { message: "User not found", category: "User errors" },
  1006: { message: "Please login to continue", category: "User errors" },
  1007: {
    message: "You do not have permission to perform this action",
    category: "User errors",
  },
  1008: { message: "Invalid date of birth", category: "User errors" },
  2001: { message: "Event not found", category: "Event errors" },
  2002: { message: "Event slug already exists", category: "Event errors" },
  2003: { message: "Invalid event date range", category: "Event errors" },
  2004: {
    message: "Cannot delete event with sold tickets",
    category: "Event errors",
  },
  3001: { message: "Ticket type not found", category: "Ticket errors" },
  3002: {
    message: "Requested tickets are not available",
    category: "Ticket errors",
  },
  3003: { message: "Invalid ticket quantity", category: "Ticket errors" },
  3004: { message: "Ticket not found", category: "Ticket errors" },
  3005: { message: "Ticket cannot be cancelled", category: "Ticket errors" },
  3006: {
    message: "Cannot delete ticket type with sold tickets",
    category: "Ticket errors",
  },
  3007: {
    message: "Ticket has already been checked in",
    category: "Ticket errors",
  },
  3008: {
    message: "Ticket is not in ACTIVE status",
    category: "Ticket errors",
  },
  3009: {
    message: "QR code does not match any ticket",
    category: "Ticket errors",
  },
  4001: { message: "Seat not found", category: "Seat errors" },
  4002: { message: "Seat is already taken", category: "Seat errors" },
  4003: {
    message: "Seat selection is required for this ticket type",
    category: "Seat errors",
  },
  5001: { message: "Order not found", category: "Order errors" },
  5002: { message: "Order has expired", category: "Order errors" },
  5003: { message: "Order already completed", category: "Order errors" },
  5004: {
    message: "Order is not completed, ticket is not valid",
    category: "Order errors",
  },
  6001: { message: "Voucher not found", category: "Voucher errors" },
  6002: {
    message: "Voucher is invalid or expired",
    category: "Voucher errors",
  },
  6003: {
    message: "Voucher not applicable for this event",
    category: "Voucher errors",
  },
  6004: { message: "Voucher usage limit reached", category: "Voucher errors" },
  6005: { message: "Minimum order amount not met", category: "Voucher errors" },
  7001: { message: "Venue not found", category: "Venue errors" },
  8001: { message: "Category not found", category: "Category/City errors" },
  8002: { message: "City not found", category: "Category/City errors" },
  9001: { message: "Notification not found", category: "Notification errors" },
  9002: { message: "Favorite not found", category: "Notification errors" },
};

interface ApiErrorResponse {
  code?: number;
  message?: string;
  errorDetails?: string;
}

/**
 * Extracts error message from API error response
 */
export function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    // Check if it's an Axios error
    if ("response" in error) {
      const axiosError = error as AxiosError<ApiErrorResponse>;
      const errorData = axiosError.response?.data;

      if (errorData?.code && ERROR_CODES[errorData.code]) {
        let message = ERROR_CODES[errorData.code].message;

        // Handle message templates with placeholders (e.g., {min})
        if (errorData.message && errorData.message !== message) {
          // Use the backend message if it has more details
          message = errorData.message;
        }

        return message;
      }

      // Fallback to response message
      if (errorData?.message) {
        return errorData.message;
      }

      // Fallback to HTTP status message
      if (axiosError.response?.status) {
        return `Request failed with status ${axiosError.response.status}`;
      }
    }

    // Return generic error message
    return error.message || "An unexpected error occurred";
  }

  return "An unexpected error occurred";
}

/**
 * Shows error toast notification
 */
export function showError(error: unknown, customMessage?: string): void {
  const message = customMessage || getErrorMessage(error);
  toast.error(message, {
    duration: 5000,
    position: "top-right",
  });
}

/**
 * Shows success toast notification
 */
export function showSuccess(message: string): void {
  toast.success(message, {
    duration: 3000,
    position: "top-right",
  });
}

/**
 * Shows info toast notification
 */
export function showInfo(message: string): void {
  toast(message, {
    duration: 3000,
    position: "top-right",
    icon: "ℹ️",
  });
}

/**
 * Shows warning toast notification
 */
export function showWarning(message: string): void {
  toast(message, {
    duration: 4000,
    position: "top-right",
    icon: "⚠️",
  });
}
