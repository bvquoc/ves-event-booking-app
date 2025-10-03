package com.devteria.identityservice.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class OAuth2Request {
    String name; // firstName + lastName
    String email;
    String firstName;
    String lastName;
    String sub;

    public String getUsername() {
        return this.email.split("@")[0];
    }
}
