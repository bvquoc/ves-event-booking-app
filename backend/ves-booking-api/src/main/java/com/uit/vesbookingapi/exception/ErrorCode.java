package com.uit.vesbookingapi.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Uncategorized error", HttpStatus.INTERNAL_SERVER_ERROR),
    INVALID_KEY(1001, "Uncategorized error", HttpStatus.BAD_REQUEST),
    USER_EXISTED(1002, "User existed", HttpStatus.BAD_REQUEST),
    USERNAME_INVALID(1003, "Username must be at least {min} characters", HttpStatus.BAD_REQUEST),
    INVALID_PASSWORD(1004, "Password must be at least {min} characters", HttpStatus.BAD_REQUEST),
    USER_NOT_EXISTED(1005, "User not existed", HttpStatus.NOT_FOUND),
    UNAUTHENTICATED(1006, "Unauthenticated", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED(1007, "You do not have permission", HttpStatus.FORBIDDEN),
    INVALID_DOB(1008, "Your age must be at least {min}", HttpStatus.BAD_REQUEST),

    // Event errors (2xxx)
    EVENT_NOT_FOUND(2001, "Event not found", HttpStatus.NOT_FOUND),
    EVENT_SLUG_EXISTED(2002, "Event slug already exists", HttpStatus.BAD_REQUEST),
    INVALID_EVENT_DATE(2003, "Invalid event date range", HttpStatus.BAD_REQUEST),
    EVENT_HAS_SOLD_TICKETS(2004, "Cannot delete event with sold tickets", HttpStatus.BAD_REQUEST),

    // Ticket errors (3xxx)
    TICKET_TYPE_NOT_FOUND(3001, "Ticket type not found", HttpStatus.NOT_FOUND),
    TICKETS_UNAVAILABLE(3002, "Requested tickets are not available", HttpStatus.BAD_REQUEST),
    INVALID_TICKET_QUANTITY(3003, "Invalid ticket quantity", HttpStatus.BAD_REQUEST),
    TICKET_NOT_FOUND(3004, "Ticket not found", HttpStatus.NOT_FOUND),
    TICKET_NOT_CANCELLABLE(3005, "Ticket cannot be cancelled", HttpStatus.BAD_REQUEST),
    TICKET_TYPE_HAS_SOLD_TICKETS(3006, "Cannot delete ticket type with sold tickets", HttpStatus.BAD_REQUEST),

    // Seat errors (4xxx)
    SEAT_NOT_FOUND(4001, "Seat not found", HttpStatus.NOT_FOUND),
    SEAT_ALREADY_TAKEN(4002, "Seat is already taken", HttpStatus.CONFLICT),
    SEAT_SELECTION_REQUIRED(4003, "Seat selection is required for this ticket type", HttpStatus.BAD_REQUEST),

    // Order errors (5xxx)
    ORDER_NOT_FOUND(5001, "Order not found", HttpStatus.NOT_FOUND),
    ORDER_EXPIRED(5002, "Order has expired", HttpStatus.BAD_REQUEST),
    ORDER_ALREADY_COMPLETED(5003, "Order already completed", HttpStatus.BAD_REQUEST),

    // Voucher errors (6xxx)
    VOUCHER_NOT_FOUND(6001, "Voucher not found", HttpStatus.NOT_FOUND),
    VOUCHER_INVALID(6002, "Voucher is invalid or expired", HttpStatus.BAD_REQUEST),
    VOUCHER_NOT_APPLICABLE(6003, "Voucher not applicable for this event", HttpStatus.BAD_REQUEST),
    VOUCHER_USAGE_LIMIT_REACHED(6004, "Voucher usage limit reached", HttpStatus.BAD_REQUEST),
    VOUCHER_MIN_ORDER_NOT_MET(6005, "Minimum order amount not met", HttpStatus.BAD_REQUEST),

    // Venue errors (7xxx)
    VENUE_NOT_FOUND(7001, "Venue not found", HttpStatus.NOT_FOUND),

    // Category/City errors (8xxx)
    CATEGORY_NOT_FOUND(8001, "Category not found", HttpStatus.NOT_FOUND),
    CITY_NOT_FOUND(8002, "City not found", HttpStatus.NOT_FOUND),

    // Notification errors (9xxx)
    NOTIFICATION_NOT_FOUND(9001, "Notification not found", HttpStatus.NOT_FOUND),
    FAVORITE_NOT_FOUND(9002, "Favorite not found", HttpStatus.NOT_FOUND),
    ;

    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }

    private final int code;
    private final String message;
    private final HttpStatusCode statusCode;
}
