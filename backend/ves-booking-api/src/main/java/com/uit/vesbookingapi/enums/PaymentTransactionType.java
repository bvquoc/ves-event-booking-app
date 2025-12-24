package com.uit.vesbookingapi.enums;

public enum PaymentTransactionType {
    CREATE,     // Initial payment creation
    CALLBACK,   // Callback from payment gateway
    QUERY,      // Status query
    REFUND      // Refund request
}
