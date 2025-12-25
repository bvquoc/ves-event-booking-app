package com.uit.vesbookingapi.exception;

import com.uit.vesbookingapi.dto.request.ApiResponse;
import jakarta.validation.ConstraintViolation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.sql.SQLException;
import java.util.Map;
import java.util.Objects;

@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    private static final String MIN_ATTRIBUTE = "min";

    /**
     * Extract a short, simple error message from exception or throwable
     */
    private String extractShortError(Throwable throwable) {
        if (throwable.getMessage() != null && !throwable.getMessage().isEmpty()) {
            String msg = throwable.getMessage();
            // Take first line if multi-line
            if (msg.contains("\n")) {
                msg = msg.split("\n")[0];
            }
            // Limit length to 200 chars
            if (msg.length() > 200) {
                msg = msg.substring(0, 197) + "...";
            }
            return msg;
        }
        return throwable.getClass().getSimpleName();
    }

    @ExceptionHandler(value = Exception.class)
    ResponseEntity<ApiResponse> handlingException(Exception exception) {
        log.error("Unhandled exception: ", exception);

        String errorMessage = ErrorCode.UNCATEGORIZED_EXCEPTION.getMessage();
        String errorDetails = extractShortError(exception);

        ApiResponse apiResponse = ApiResponse.builder()
                .code(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode())
                .message(errorMessage)
                .errorDetails(errorDetails)
                .build();

        return ResponseEntity.status(ErrorCode.UNCATEGORIZED_EXCEPTION.getStatusCode())
                .body(apiResponse);
    }

    @ExceptionHandler(value = DataIntegrityViolationException.class)
    ResponseEntity<ApiResponse> handlingDataIntegrityViolation(DataIntegrityViolationException exception) {
        log.error("Data integrity violation: ", exception);

        String errorMessage = "Data integrity violation";
        String errorDetails = extractShortError(exception);

        // Check for common constraint violations
        if (exception.getMessage() != null) {
            String msg = exception.getMessage();
            if (msg.contains("Duplicate entry")) {
                errorMessage = "Duplicate entry. This record already exists.";
                // Extract the duplicate key/value if possible
                if (msg.contains("for key")) {
                    int keyIndex = msg.indexOf("for key");
                    if (keyIndex > 0) {
                        errorDetails = msg.substring(0, Math.min(keyIndex + 50, msg.length())).trim();
                    }
                }
            } else if (msg.contains("foreign key constraint")) {
                errorMessage = "Cannot delete. This record is referenced by other records.";
            } else if (msg.contains("UNIQUE constraint")) {
                errorMessage = "Unique constraint violation. This value already exists.";
            }
        }

        ApiResponse apiResponse = ApiResponse.builder()
                .code(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode())
                .message(errorMessage)
                .errorDetails(errorDetails)
                .build();

        return ResponseEntity.badRequest().body(apiResponse);
    }

    @ExceptionHandler(value = SQLException.class)
    ResponseEntity<ApiResponse> handlingSQLException(SQLException exception) {
        log.error("SQL exception: ", exception);

        String errorMessage = "Database error occurred";
        String errorDetails = extractShortError(exception);

        // Extract SQL state if available
        if (exception.getSQLState() != null) {
            errorDetails = String.format("SQL Error [%s]: %s",
                    exception.getSQLState(),
                    extractShortError(exception));
        }

        ApiResponse apiResponse = ApiResponse.builder()
                .code(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode())
                .message(errorMessage)
                .errorDetails(errorDetails)
                .build();

        return ResponseEntity.status(ErrorCode.UNCATEGORIZED_EXCEPTION.getStatusCode())
                .body(apiResponse);
    }

    @ExceptionHandler(value = IllegalArgumentException.class)
    ResponseEntity<ApiResponse> handlingIllegalArgument(IllegalArgumentException exception) {
        log.error("Illegal argument: ", exception);

        String errorMessage = exception.getMessage() != null
                ? exception.getMessage()
                : "Invalid argument";

        ApiResponse apiResponse = ApiResponse.builder()
                .code(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode())
                .message(errorMessage)
                .errorDetails(extractShortError(exception))
                .build();

        return ResponseEntity.badRequest().body(apiResponse);
    }

    @ExceptionHandler(value = AppException.class)
    ResponseEntity<ApiResponse> handlingAppException(AppException exception) {
        ErrorCode errorCode = exception.getErrorCode();

        log.warn("AppException: {} - {}", errorCode.getCode(), errorCode.getMessage());
        if (exception.getCause() != null) {
            log.debug("AppException cause: ", exception.getCause());
        }

        String errorDetails = null;
        if (exception.getCause() != null) {
            errorDetails = extractShortError(exception.getCause());
        }

        ApiResponse apiResponse = ApiResponse.builder()
                .code(errorCode.getCode())
                .message(errorCode.getMessage())
                .errorDetails(errorDetails)
                .build();

        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }

    @ExceptionHandler(value = AccessDeniedException.class)
    ResponseEntity<ApiResponse> handlingAccessDeniedException(AccessDeniedException exception) {
        ErrorCode errorCode = ErrorCode.UNAUTHORIZED;

        return ResponseEntity.status(errorCode.getStatusCode())
                .body(ApiResponse.builder()
                        .code(errorCode.getCode())
                        .message(errorCode.getMessage())
                        .build());
    }

    @ExceptionHandler(value = MethodArgumentNotValidException.class)
    ResponseEntity<ApiResponse> handlingValidation(MethodArgumentNotValidException exception) {
        String enumKey = exception.getFieldError() != null
                ? exception.getFieldError().getDefaultMessage()
                : null;

        ErrorCode errorCode = ErrorCode.INVALID_KEY;
        Map<String, Object> attributes = null;
        String fieldName = null;
        String validationMessage = null;

        try {
            if (enumKey != null) {
                errorCode = ErrorCode.valueOf(enumKey);
            }

            if (exception.getBindingResult().hasFieldErrors()) {
                var fieldError = exception.getBindingResult().getFieldError();
                fieldName = fieldError != null ? fieldError.getField() : null;
                validationMessage = fieldError != null ? fieldError.getDefaultMessage() : null;
            }

            if (exception.getBindingResult().hasGlobalErrors()) {
                var globalError = exception.getBindingResult().getGlobalError();
                validationMessage = globalError != null ? globalError.getDefaultMessage() : null;
            }

            var constraintViolation =
                    exception.getBindingResult().getAllErrors().getFirst().unwrap(ConstraintViolation.class);

            attributes = constraintViolation.getConstraintDescriptor().getAttributes();

            log.info("Validation error - Field: {}, Attributes: {}", fieldName, attributes);

        } catch (IllegalArgumentException | ClassCastException e) {
            log.debug("Could not extract constraint violation details", e);
        }

        String finalMessage = Objects.nonNull(attributes)
                ? mapAttribute(errorCode.getMessage(), attributes)
                : (validationMessage != null ? validationMessage : errorCode.getMessage());

        String errorDetails = null;
        if (fieldName != null) {
            errorDetails = String.format("Field '%s': %s", fieldName,
                    validationMessage != null ? validationMessage : "validation failed");
        } else if (validationMessage != null) {
            errorDetails = validationMessage;
        }

        ApiResponse apiResponse = ApiResponse.builder()
                .code(errorCode.getCode())
                .message(finalMessage)
                .errorDetails(errorDetails)
                .build();

        return ResponseEntity.badRequest().body(apiResponse);
    }

    private String mapAttribute(String message, Map<String, Object> attributes) {
        String minValue = String.valueOf(attributes.get(MIN_ATTRIBUTE));

        return message.replace("{" + MIN_ATTRIBUTE + "}", minValue);
    }
}
