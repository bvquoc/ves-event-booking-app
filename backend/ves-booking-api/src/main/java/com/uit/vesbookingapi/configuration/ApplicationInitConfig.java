package com.uit.vesbookingapi.configuration;

import com.uit.vesbookingapi.constant.PredefinedRole;
import com.uit.vesbookingapi.entity.*;
import com.uit.vesbookingapi.repository.*;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

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
            CityRepository cityRepository,
            VenueRepository venueRepository,
            EventRepository eventRepository,
            TicketTypeRepository ticketTypeRepository,
            SeatRepository seatRepository) {
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

            // Seed venues if empty
            List<Venue> venues = new ArrayList<>();
            if (venueRepository.count() == 0) {
                List<City> cities = cityRepository.findAll();
                City hcmCity = cities.stream().filter(c -> c.getSlug().equals("ho-chi-minh")).findFirst().orElse(cities.get(0));
                City hanoiCity = cities.stream().filter(c -> c.getSlug().equals("hanoi")).findFirst().orElse(cities.get(0));

                venues.add(venueRepository.save(Venue.builder()
                        .name("Nhà hát Thành phố Hồ Chí Minh")
                        .address("7 Công Trường Lam Sơn, Bến Nghé, Quận 1, Hồ Chí Minh")
                        .capacity(2000)
                        .city(hcmCity)
                        .build()));

                venues.add(venueRepository.save(Venue.builder()
                        .name("Sân vận động Quốc gia Mỹ Đình")
                        .address("Mỹ Đình, Nam Từ Liêm, Hà Nội")
                        .capacity(40000)
                        .city(hanoiCity)
                        .build()));

                venues.add(venueRepository.save(Venue.builder()
                        .name("Trung tâm Hội nghị Quốc gia")
                        .address("57 Phạm Hùng, Mỹ Đình, Nam Từ Liêm, Hà Nội")
                        .capacity(3500)
                        .city(hanoiCity)
                        .build()));

                log.info("Seeded 3 venues");
            } else {
                venues = venueRepository.findAll();
            }

            // Seed events if empty
            if (eventRepository.count() == 0) {
                List<Category> categories = categoryRepository.findAll();
                List<City> cities = cityRepository.findAll();

                Category sportsCategory = categories.stream().filter(c -> c.getSlug().equals("the-thao")).findFirst().orElse(categories.get(0));
                Category musicCategory = categories.stream().filter(c -> c.getSlug().equals("hoa-nhac")).findFirst().orElse(categories.get(0));
                Category theaterCategory = categories.stream().filter(c -> c.getSlug().equals("san-khau-kich")).findFirst().orElse(categories.get(0));

                City hcmCity = cities.stream().filter(c -> c.getSlug().equals("ho-chi-minh")).findFirst().orElse(cities.get(0));
                City hanoiCity = cities.stream().filter(c -> c.getSlug().equals("hanoi")).findFirst().orElse(cities.get(0));

                Venue hcmVenue = venues.stream().filter(v -> v.getName().contains("Hồ Chí Minh")).findFirst().orElse(venues.isEmpty() ? null : venues.get(0));
                Venue hanoiVenue = venues.stream().filter(v -> v.getName().contains("Mỹ Đình")).findFirst().orElse(venues.isEmpty() ? null : venues.get(0));

                LocalDateTime now = LocalDateTime.now();

                // Event 1: Football Match
                Event event1 = Event.builder()
                        .name("Trận đấu bóng đá: Việt Nam vs Thái Lan")
                        .slug("tran-dau-bong-da-viet-nam-vs-thai-lan")
                        .description("Trận đấu giao hữu quốc tế giữa đội tuyển Việt Nam và Thái Lan")
                        .longDescription("Trận đấu bóng đá giao hữu quốc tế đầy hấp dẫn giữa hai đội tuyển hàng đầu Đông Nam Á. Đây là cơ hội để các cầu thủ chuẩn bị cho các giải đấu lớn sắp tới.")
                        .category(sportsCategory)
                        .thumbnail("https://example.com/images/football-match.jpg")
                        .images(List.of("https://example.com/images/football-1.jpg", "https://example.com/images/football-2.jpg"))
                        .startDate(now.plusDays(30))
                        .endDate(now.plusDays(30).plusHours(2))
                        .city(hanoiCity)
                        .venue(hanoiVenue)
                        .venueName(hanoiVenue != null ? hanoiVenue.getName() : "Sân vận động Quốc gia Mỹ Đình")
                        .venueAddress(hanoiVenue != null ? hanoiVenue.getAddress() : "Mỹ Đình, Nam Từ Liêm, Hà Nội")
                        .currency("VND")
                        .isTrending(true)
                        .organizerName("Liên đoàn Bóng đá Việt Nam")
                        .organizerLogo("https://example.com/logos/vff.png")
                        .terms("Vé không được hoàn lại. Vui lòng đến sớm 30 phút trước khi trận đấu bắt đầu.")
                        .cancellationPolicy("Hủy vé trước 7 ngày: hoàn 100%. Hủy vé trước 3 ngày: hoàn 50%. Hủy vé sau 3 ngày: không hoàn tiền.")
                        .tags(List.of("bóng đá", "thể thao", "quốc tế", "giao hữu"))
                        .build();
                event1 = eventRepository.save(event1);

                // Ticket types for event1
                ticketTypeRepository.save(TicketType.builder()
                        .event(event1)
                        .name("Vé VIP")
                        .description("Vé VIP với chỗ ngồi tốt nhất, bao gồm đồ uống miễn phí")
                        .price(500000)
                        .currency("VND")
                        .available(100)
                        .maxPerOrder(4)
                        .benefits(List.of("Chỗ ngồi tốt nhất", "Đồ uống miễn phí", "Parking miễn phí"))
                        .requiresSeatSelection(true)
                        .build());

                ticketTypeRepository.save(TicketType.builder()
                        .event(event1)
                        .name("Vé Thường")
                        .description("Vé thường với giá hợp lý")
                        .price(200000)
                        .currency("VND")
                        .available(500)
                        .maxPerOrder(6)
                        .benefits(List.of("Xem trận đấu trực tiếp"))
                        .requiresSeatSelection(true)
                        .build());

                // Event 2: Concert
                Event event2 = Event.builder()
                        .name("Đêm nhạc Sơn Tùng M-TP")
                        .slug("dem-nhac-son-tung-mtp")
                        .description("Đêm nhạc đặc biệt với ca sĩ Sơn Tùng M-TP")
                        .longDescription("Đêm nhạc đầy cảm xúc với những ca khúc hit nhất của Sơn Tùng M-TP. Chương trình sẽ có nhiều tiết mục đặc sắc và bất ngờ.")
                        .category(musicCategory)
                        .thumbnail("https://example.com/images/concert.jpg")
                        .images(List.of("https://example.com/images/concert-1.jpg"))
                        .startDate(now.plusDays(45))
                        .endDate(now.plusDays(45).plusHours(3))
                        .city(hcmCity)
                        .venue(hcmVenue)
                        .venueName(hcmVenue != null ? hcmVenue.getName() : "Nhà hát Thành phố Hồ Chí Minh")
                        .venueAddress(hcmVenue != null ? hcmVenue.getAddress() : "7 Công Trường Lam Sơn, Bến Nghé, Quận 1, Hồ Chí Minh")
                        .currency("VND")
                        .isTrending(true)
                        .organizerName("Công ty Giải trí M-TP")
                        .organizerLogo("https://example.com/logos/mtp.png")
                        .terms("Vé không được chuyển nhượng. Cấm mang theo đồ uống và thức ăn.")
                        .cancellationPolicy("Hủy vé trước 14 ngày: hoàn 100%. Hủy vé trước 7 ngày: hoàn 70%. Hủy vé sau 7 ngày: không hoàn tiền.")
                        .tags(List.of("nhạc pop", "Sơn Tùng", "concert", "giải trí"))
                        .build();
                event2 = eventRepository.save(event2);

                ticketTypeRepository.save(TicketType.builder()
                        .event(event2)
                        .name("Vé VIP")
                        .description("Vé VIP với chỗ ngồi gần sân khấu nhất")
                        .price(3000000)
                        .currency("VND")
                        .available(50)
                        .maxPerOrder(2)
                        .benefits(List.of("Chỗ ngồi gần sân khấu", "Meet & Greet", "Áo thun độc quyền"))
                        .requiresSeatSelection(true)
                        .build());

                ticketTypeRepository.save(TicketType.builder()
                        .event(event2)
                        .name("Vé Thường")
                        .description("Vé thường")
                        .price(800000)
                        .currency("VND")
                        .available(300)
                        .maxPerOrder(4)
                        .benefits(List.of("Xem concert trực tiếp"))
                        .requiresSeatSelection(true)
                        .build());

                // Event 3: Theater
                Event event3 = Event.builder()
                        .name("Vở kịch: Chuyện tình Romeo và Juliet")
                        .slug("vo-kich-chuyen-tinh-romeo-va-juliet")
                        .description("Vở kịch kinh điển được dàn dựng lại với phong cách hiện đại")
                        .longDescription("Vở kịch tình yêu bất hủ của Shakespeare được dàn dựng lại với phong cách hiện đại, mang đến trải nghiệm nghệ thuật độc đáo.")
                        .category(theaterCategory)
                        .thumbnail("https://example.com/images/theater.jpg")
                        .images(List.of("https://example.com/images/theater-1.jpg", "https://example.com/images/theater-2.jpg"))
                        .startDate(now.plusDays(20))
                        .endDate(now.plusDays(20).plusHours(2).plusMinutes(30))
                        .city(hanoiCity)
                        .venue(hanoiVenue)
                        .venueName(hanoiVenue != null ? hanoiVenue.getName() : "Trung tâm Hội nghị Quốc gia")
                        .venueAddress(hanoiVenue != null ? hanoiVenue.getAddress() : "57 Phạm Hùng, Mỹ Đình, Nam Từ Liêm, Hà Nội")
                        .currency("VND")
                        .isTrending(false)
                        .organizerName("Nhà hát Kịch Việt Nam")
                        .organizerLogo("https://example.com/logos/theater.png")
                        .terms("Vui lòng tắt điện thoại trong suốt buổi diễn. Trẻ em dưới 6 tuổi không được vào.")
                        .cancellationPolicy("Hủy vé trước 5 ngày: hoàn 100%. Hủy vé trước 2 ngày: hoàn 50%. Hủy vé sau 2 ngày: không hoàn tiền.")
                        .tags(List.of("kịch", "Shakespeare", "nghệ thuật", "văn hóa"))
                        .build();
                event3 = eventRepository.save(event3);

                ticketTypeRepository.save(TicketType.builder()
                        .event(event3)
                        .name("Vé VIP")
                        .description("Vé VIP với chỗ ngồi tốt nhất")
                        .price(600000)
                        .currency("VND")
                        .available(80)
                        .maxPerOrder(4)
                        .benefits(List.of("Chỗ ngồi tốt nhất", "Tài liệu chương trình"))
                        .requiresSeatSelection(true)
                        .build());

                ticketTypeRepository.save(TicketType.builder()
                        .event(event3)
                        .name("Vé Thường")
                        .description("Vé thường")
                        .price(300000)
                        .currency("VND")
                        .available(200)
                        .maxPerOrder(6)
                        .benefits(List.of("Xem vở kịch trực tiếp"))
                        .requiresSeatSelection(true)
                        .build());

                log.info("Seeded 3 events with ticket types");
            }

            // Seed seats for venues if empty (simple: just a few seats per venue for testing)
            if (seatRepository.count() == 0) {
                List<Venue> allVenues = venueRepository.findAll();

                for (Venue venue : allVenues) {
                    List<Seat> seats = new ArrayList<>();

                    // Simple: 2 sections, 2 rows each, 5 seats per row = 20 seats per venue
                    String[] sections = {"VIP Section", "Standard Section"};
                    for (String section : sections) {
                        for (int row = 1; row <= 2; row++) {
                            for (int seat = 1; seat <= 5; seat++) {
                                seats.add(Seat.builder()
                                        .venue(venue)
                                        .sectionName(section)
                                        .rowName(String.valueOf(row))
                                        .seatNumber(String.valueOf(seat))
                                        .build());
                            }
                        }
                    }

                    seatRepository.saveAll(seats);
                    log.info("Seeded {} seats for venue: {}", seats.size(), venue.getName());
                }

                log.info("Seat seeding completed");
            }

            log.info("Application initialization completed .....");
        };
    }
}
