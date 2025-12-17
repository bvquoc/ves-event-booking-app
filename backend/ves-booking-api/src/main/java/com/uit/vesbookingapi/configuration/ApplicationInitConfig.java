package com.uit.vesbookingapi.configuration;

import java.util.HashSet;

import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.uit.vesbookingapi.constant.PredefinedRole;
import com.uit.vesbookingapi.entity.Category;
import com.uit.vesbookingapi.entity.City;
import com.uit.vesbookingapi.entity.Role;
import com.uit.vesbookingapi.entity.User;
import com.uit.vesbookingapi.repository.CategoryRepository;
import com.uit.vesbookingapi.repository.CityRepository;
import com.uit.vesbookingapi.repository.RoleRepository;
import com.uit.vesbookingapi.repository.UserRepository;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;

@Configuration
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ApplicationInitConfig {

    PasswordEncoder passwordEncoder;

    @NonFinal
    static final String ADMIN_USER_NAME = "admin";

    @NonFinal
    static final String ADMIN_PASSWORD = "admin";

    @Bean
    @ConditionalOnProperty(
            prefix = "spring",
            value = "datasource.driverClassName",
            havingValue = "com.mysql.cj.jdbc.Driver")
    ApplicationRunner applicationRunner(
            UserRepository userRepository,
            RoleRepository roleRepository,
            CategoryRepository categoryRepository,
            CityRepository cityRepository) {
        log.info("Initializing application.....");
        return args -> {
            if (userRepository.findByUsername(ADMIN_USER_NAME).isEmpty()) {
                roleRepository.save(Role.builder()
                        .name(PredefinedRole.USER_ROLE)
                        .description("User role")
                        .build());

                Role adminRole = roleRepository.save(Role.builder()
                        .name(PredefinedRole.ADMIN_ROLE)
                        .description("Admin role")
                        .build());

                var roles = new HashSet<Role>();
                roles.add(adminRole);

                User user = User.builder()
                        .username(ADMIN_USER_NAME)
                        .password(passwordEncoder.encode(ADMIN_PASSWORD))
                        .roles(roles)
                        .build();

                userRepository.save(user);
                log.warn("admin user has been created with default password: admin, please change it");
            }

            // Seed categories if empty
            if (categoryRepository.count() == 0) {
                // Icon Library Options:
                // 1. Material Icons (Google) - Recommended for web/mobile
                //    CDN: https://fonts.googleapis.com/icon?family=Material+Icons
                //    Usage: <i class="material-icons">sports_soccer</i>
                //    Docs: https://fonts.google.com/icons
                //
                // 2. Font Awesome (Free version available)
                //    CDN: https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css
                //    Usage: <i class="fas fa-futbol"></i>
                //    Docs: https://fontawesome.com/icons
                //
                // 3. Heroicons (Modern, clean SVG icons)
                //    CDN: https://cdn.jsdelivr.net/npm/heroicons@latest
                //    Usage: Import and use as React/Vue components or SVG
                //    Docs: https://heroicons.com/
                //
                // 4. Lucide Icons (Beautiful, consistent)
                //    CDN: https://cdn.jsdelivr.net/npm/lucide@latest
                //    Docs: https://lucide.dev/
                //
                // Current implementation uses Material Icons identifiers
                // Frontend should render: <i class="material-icons">{icon}</i>
                
                categoryRepository.save(Category.builder()
                        .name("Thể thao")
                        .slug("the-thao")
                        .icon("sports_soccer") // Material Icons: sports_soccer
                        .build());

                categoryRepository.save(Category.builder()
                        .name("Hòa nhạc")
                        .slug("hoa-nhac")
                        .icon("music_note") // Material Icons: music_note
                        .build());

                categoryRepository.save(Category.builder()
                        .name("Sân khấu kịch")
                        .slug("san-khau-kich")
                        .icon("theater_comedy") // Material Icons: theater_comedy
                        .build());

                categoryRepository.save(Category.builder()
                        .name("Triển lãm")
                        .slug("trien-lam")
                        .icon("palette") // Material Icons: palette
                        .build());

                log.info("Seeded 4 categories");
            }

            // Seed cities if empty
            if (cityRepository.count() == 0) {
                cityRepository.save(City.builder()
                        .name("Ho Chi Minh")
                        .slug("ho-chi-minh")
                        .build());

                cityRepository.save(City.builder()
                        .name("Hanoi")
                        .slug("hanoi")
                        .build());

                cityRepository.save(City.builder()
                        .name("Da Nang")
                        .slug("da-nang")
                        .build());

                log.info("Seeded 3 cities");
            }

            log.info("Application initialization completed .....");
        };
    }
}
