package com.devteria.identityservice.configuration;

import com.devteria.identityservice.dto.request.OAuth2Request;
import com.devteria.identityservice.service.AuthenticationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.experimental.NonFinal;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Map;

@Component
public class CustomOAuth2SuccessHandler implements AuthenticationSuccessHandler {
    @Autowired
    private AuthenticationService authenticationService;

    @NonFinal
    @Value("${app.oauth2.redirect-uri}")
    protected String APP_REDIRECT_URI;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) authentication;
        Map<String, Object> attributes = token.getPrincipal().getAttributes();

        String email = (String) attributes.get("email");
        String name = (String) attributes.get("name");
        String sub = (String) attributes.get("sub");
        String firstName = (String) attributes.get("given_name");
        String lastName = (String) attributes.get("family_name");

        var oauth2Request = OAuth2Request.builder()
                .email(email)
                .name(name)
                .sub(sub)
                .firstName(firstName)
                .lastName(lastName)
                .build();

        var authenticationResponse = authenticationService.authenticate(oauth2Request);
        response.sendRedirect(APP_REDIRECT_URI + "?token=" + authenticationResponse.getToken());
    }
}

