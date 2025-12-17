package com.uit.vesbookingapi.enums;

public enum OrderStatus {
    PENDING,      // Payment pending
    COMPLETED,    // Payment successful
    CANCELLED,    // Cancelled by user
    EXPIRED,      // Payment timeout
    REFUNDED      // Refunded after cancellation
}
