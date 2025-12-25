package com.uit.vesbookingapi.configuration;

import com.uit.vesbookingapi.constant.PredefinedRole;
import com.uit.vesbookingapi.entity.*;
import com.uit.vesbookingapi.enums.*;
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

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

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

    @NonFinal
    static final String NORMAL_USER_NAME = "user1";

    @NonFinal
    static final String NORMAL_PASSWORD = "123456";

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
            SeatRepository seatRepository,
            VoucherRepository voucherRepository,
            OrderRepository orderRepository,
            TicketRepository ticketRepository,
            FavoriteRepository favoriteRepository,
            NotificationRepository notificationRepository,
            UserVoucherRepository userVoucherRepository) {
        log.info("Initializing application.....");
        return args -> {
            if (userRepository.findByUsername(ADMIN_USER_NAME).isEmpty()) {
                Role userRole = roleRepository.save(Role.builder()
                        .name(PredefinedRole.USER_ROLE)
                        .description("User role")
                        .build());

                Role adminRole = roleRepository.save(Role.builder()
                        .name(PredefinedRole.ADMIN_ROLE)
                        .description("Admin role")
                        .build());

                Role staffRole = roleRepository.save(Role.builder()
                        .name(PredefinedRole.STAFF_ROLE)
                        .description("Staff role - can check in tickets")
                        .build());

                Role organizerRole = roleRepository.save(Role.builder()
                        .name(PredefinedRole.ORGANIZER_ROLE)
                        .description("Organizer role - can check in tickets")
                        .build());

                var adminRoles = new HashSet<Role>();
                adminRoles.add(adminRole);

                User adminUser = User.builder()
                        .username(ADMIN_USER_NAME)
                        .password(passwordEncoder.encode(ADMIN_PASSWORD))
                        .email("admin@vesbooking.com")
                        .phone("0900000001")
                        .roles(adminRoles)
                        .build();

                userRepository.save(adminUser);
                log.warn("admin user has been created with default password: admin, please change it");

                // Create normal user
                var normalUserRoles = new HashSet<Role>();
                normalUserRoles.add(userRole);

                User normalUser = User.builder()
                        .username(NORMAL_USER_NAME)
                        .password(passwordEncoder.encode(NORMAL_PASSWORD))
                        .email("user1@vesbooking.com")
                        .phone("0900000002")
                        .roles(normalUserRoles)
                        .build();

                userRepository.save(normalUser);
                log.warn("normal user '{}' has been created with default password: {}, please change it",
                        NORMAL_USER_NAME, NORMAL_PASSWORD);

                // Create staff user
                var staffRoles = new HashSet<Role>();
                staffRoles.add(staffRole);

                User staffUser = User.builder()
                        .username("staff")
                        .password(passwordEncoder.encode("123456"))
                        .email("staff@vesbooking.com")
                        .phone("0900000010")
                        .firstName("Staff")
                        .lastName("User")
                        .roles(staffRoles)
                        .build();

                userRepository.save(staffUser);
                log.warn("staff user has been created with default password: 123456, please change it");

                // Create organizer user
                var organizerRoles = new HashSet<Role>();
                organizerRoles.add(organizerRole);

                User organizerUser = User.builder()
                        .username("organizer")
                        .password(passwordEncoder.encode("123456"))
                        .email("organizer@vesbooking.com")
                        .phone("0900000011")
                        .firstName("Organizer")
                        .lastName("User")
                        .roles(organizerRoles)
                        .build();

                userRepository.save(organizerUser);
                log.warn("organizer user has been created with default password: 123456, please change it");

                // ===== SAMPLE DATA: Additional Users =====
                // New User - exploring, no bookings
                User newUser = User.builder()
                        .username("newuser")
                        .password(passwordEncoder.encode("123456"))
                        .email("newuser@example.com")
                        .phone("0900000003")
                        .firstName("Minh")
                        .lastName("Nguyen")
                        .dob(LocalDate.of(2000, 5, 15))
                        .roles(normalUserRoles)
                        .build();
                userRepository.save(newUser);
                log.info("Created 'newuser' (Minh Nguyen) - New User scenario");

                // Regular User - moderate engagement
                User regularUser = User.builder()
                        .username("regularuser")
                        .password(passwordEncoder.encode("123456"))
                        .email("regularuser@example.com")
                        .phone("0900000004")
                        .firstName("Lan")
                        .lastName("Tran")
                        .dob(LocalDate.of(1995, 8, 22))
                        .roles(normalUserRoles)
                        .build();
                userRepository.save(regularUser);
                log.info("Created 'regularuser' (Lan Tran) - Regular User scenario");

                // VIP User - high engagement
                User vipUser = User.builder()
                        .username("vipuser")
                        .password(passwordEncoder.encode("123456"))
                        .email("vipuser@example.com")
                        .phone("0900000005")
                        .firstName("Hung")
                        .lastName("Le")
                        .dob(LocalDate.of(1988, 3, 10))
                        .roles(normalUserRoles)
                        .build();
                userRepository.save(vipUser);
                log.info("Created 'vipuser' (Hung Le) - VIP User scenario");
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
                        .thumbnail("https://media.vov.vn/sites/default/files/styles/large/public/2025-07/lich_thi_dau_va_truc_tiep_chung_ket_u23_dong_nam_a_giua_u23_viet_nam_vs_u23_indonesia.png.jpg?auto=format&fit=crop&w=800&q=80")
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
                // VIP: 20 seats available (matches VIP Section)
                ticketTypeRepository.save(TicketType.builder()
                        .event(event1)
                        .name("Vé VIP")
                        .description("Vé VIP với chỗ ngồi tốt nhất, bao gồm đồ uống miễn phí")
                        .price(500000)
                        .currency("VND")
                        .available(20) // Matches VIP Section seats
                        .maxPerOrder(4)
                        .benefits(List.of("Chỗ ngồi tốt nhất", "Đồ uống miễn phí", "Parking miễn phí"))
                        .requiresSeatSelection(true)
                        .build());

                // Standard: 80 seats available (matches Standard Section)
                ticketTypeRepository.save(TicketType.builder()
                        .event(event1)
                        .name("Vé Thường")
                        .description("Vé thường với giá hợp lý")
                        .price(200000)
                        .currency("VND")
                        .available(80) // Matches Standard Section seats
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
                        .thumbnail("https://cdn-www.vinid.net/9dd0f152-gia-ve-sky-tour.jpg?auto=format&fit=crop&w=800&q=80")
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

                // VIP: 20 seats available (matches VIP Section)
                ticketTypeRepository.save(TicketType.builder()
                        .event(event2)
                        .name("Vé VIP")
                        .description("Vé VIP với chỗ ngồi gần sân khấu nhất")
                        .price(3000000)
                        .currency("VND")
                        .available(20) // Matches VIP Section seats
                        .maxPerOrder(2)
                        .benefits(List.of("Chỗ ngồi gần sân khấu", "Meet & Greet", "Áo thun độc quyền"))
                        .requiresSeatSelection(true)
                        .build());

                // Standard: 80 seats available (matches Standard Section)
                ticketTypeRepository.save(TicketType.builder()
                        .event(event2)
                        .name("Vé Thường")
                        .description("Vé thường")
                        .price(800000)
                        .currency("VND")
                        .available(80) // Matches Standard Section seats
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
                        .thumbnail("https://www.ritafoldi.com/foto/wp-content/uploads/2023/11/NicoleJason-59-1.jpg?auto=format&fit=crop&w=800&q=80")
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

                // VIP: 20 seats available (matches VIP Section)
                ticketTypeRepository.save(TicketType.builder()
                        .event(event3)
                        .name("Vé VIP")
                        .description("Vé VIP với chỗ ngồi tốt nhất")
                        .price(600000)
                        .currency("VND")
                        .available(20) // Matches VIP Section seats
                        .maxPerOrder(4)
                        .benefits(List.of("Chỗ ngồi tốt nhất", "Tài liệu chương trình"))
                        .requiresSeatSelection(true)
                        .build());

                // Standard: 80 seats available (matches Standard Section)
                ticketTypeRepository.save(TicketType.builder()
                        .event(event3)
                        .name("Vé Thường")
                        .description("Vé thường")
                        .price(300000)
                        .currency("VND")
                        .available(80) // Matches Standard Section seats
                        .maxPerOrder(6)
                        .benefits(List.of("Xem vở kịch trực tiếp"))
                        .requiresSeatSelection(true)
                        .build());

                log.info("Seeded 3 events with ticket types");
            }

            // Seed seats for venues if empty
            // VIP Section: 20 seats (4 rows × 5 seats)
            // Standard Section: 80 seats (8 rows × 10 seats)
            // Total: 100 seats per venue
            if (seatRepository.count() == 0) {
                List<Venue> allVenues = venueRepository.findAll();

                for (Venue venue : allVenues) {
                    List<Seat> seats = new ArrayList<>();

                    // VIP Section: 4 rows (A-D), 5 seats per row = 20 seats
                    for (int row = 1; row <= 4; row++) {
                        String rowName = String.valueOf((char) ('A' + row - 1));
                        for (int seat = 1; seat <= 5; seat++) {
                            seats.add(Seat.builder()
                                    .venue(venue)
                                    .sectionName("VIP Section")
                                    .rowName(rowName)
                                    .seatNumber(String.valueOf(seat))
                                    .build());
                        }
                    }

                    // Standard Section: 8 rows (E-L), 10 seats per row = 80 seats
                    for (int row = 5; row <= 12; row++) {
                        String rowName = String.valueOf((char) ('A' + row - 1));
                        for (int seat = 1; seat <= 10; seat++) {
                            seats.add(Seat.builder()
                                    .venue(venue)
                                    .sectionName("Standard Section")
                                    .rowName(rowName)
                                    .seatNumber(String.valueOf(seat))
                                    .build());
                        }
                    }

                    seatRepository.saveAll(seats);
                    log.info("Seeded {} seats for venue: {} (VIP: 20, Standard: 80)", seats.size(), venue.getName());
                }

                log.info("Seat seeding completed");
            }

            // ===== DEMO SAMPLE DATA =====
            if (eventRepository.count() <= 3) { // Only seed if minimal data exists
                seedDemoEvents(eventRepository, ticketTypeRepository,
                        categoryRepository, cityRepository, venueRepository);

                seedDemoVouchers(voucherRepository, categoryRepository, eventRepository);

                seedDemoOrdersAndTickets(orderRepository, ticketRepository,
                        userRepository, eventRepository, ticketTypeRepository,
                        voucherRepository, seatRepository);

                seedDemoFavorites(favoriteRepository, userRepository, eventRepository);

                seedDemoNotifications(notificationRepository, userRepository,
                        eventRepository, orderRepository);

                seedDemoUserVouchers(userVoucherRepository, userRepository,
                        voucherRepository, orderRepository);

                log.info("Demo sample data initialization completed");
            }

            log.info("Application initialization completed .....");
        };
    }

    // ===== PRIVATE HELPER METHODS FOR DEMO DATA =====

    private void seedDemoEvents(
            EventRepository eventRepository,
            TicketTypeRepository ticketTypeRepository,
            CategoryRepository categoryRepository,
            CityRepository cityRepository,
            VenueRepository venueRepository) {

        // Get references
        List<Category> categories = categoryRepository.findAll();
        Category musicCat = categories.stream().filter(c -> c.getSlug().equals("hoa-nhac")).findFirst().orElseThrow();
        Category exhibitCat = categories.stream().filter(c -> c.getSlug().equals("trien-lam")).findFirst().orElseThrow();

        List<City> cities = cityRepository.findAll();
        City hcm = cities.stream().filter(c -> c.getSlug().equals("ho-chi-minh")).findFirst().orElseThrow();
        City hanoi = cities.stream().filter(c -> c.getSlug().equals("hanoi")).findFirst().orElseThrow();

        Venue hcmTheater = venueRepository.findAll().stream()
                .filter(v -> v.getName().contains("Hồ Chí Minh")).findFirst().orElseThrow();
        Venue myDinhStadium = venueRepository.findAll().stream()
                .filter(v -> v.getName().contains("Mỹ Đình")).findFirst().orElseThrow();

        LocalDateTime now = LocalDateTime.now();

        // ===== DEMO EVENT 1: Upcoming Music Festival (This Week) =====
        Event musicFestival = Event.builder()
                .name("Monsoon Music Festival 2025")
                .slug("monsoon-music-festival-2025")
                .description("Festival âm nhạc quốc tế lớn nhất mùa thu với nhiều nghệ sĩ nổi tiếng")
                .longDescription("Monsoon Music Festival quy tụ các nghệ sĩ hàng đầu trong nước và quốc tế. Trải nghiệm âm nhạc đa dạng từ pop, rock, EDM đến jazz trong không gian sôi động và đầy cảm hứng.")
                .category(musicCat)
                .thumbnail("https://plus.unsplash.com/premium_photo-1661306437817-8ab34be91e0c?auto=format&fit=crop&w=800&q=80")
                .images(List.of("https://example.com/images/monsoon-1.jpg", "https://example.com/images/monsoon-2.jpg"))
                .startDate(now.plusDays(5))
                .endDate(now.plusDays(5).plusHours(6))
                .city(hanoi)
                .venue(myDinhStadium)
                .venueName(myDinhStadium.getName())
                .venueAddress(myDinhStadium.getAddress())
                .currency("VND")
                .isTrending(true)
                .organizerName("Monsoon Entertainment")
                .organizerLogo("https://example.com/logos/monsoon.png")
                .terms("Vé không được hoàn lại. Cấm mang theo đồ uống có cồn. Trẻ em dưới 12 tuổi phải có người lớn đi kèm.")
                .cancellationPolicy("Hủy vé trước 7 ngày: hoàn 100%. Hủy vé trước 3 ngày: hoàn 50%. Hủy vé sau 3 ngày: không hoàn tiền.")
                .tags(List.of("festival", "âm nhạc", "quốc tế", "live music"))
                .build();
        musicFestival = eventRepository.save(musicFestival);

        ticketTypeRepository.save(TicketType.builder()
                .event(musicFestival)
                .name("VIP Pass")
                .description("Vé VIP 2 ngày với nhiều đặc quyền")
                .price(2500000)
                .currency("VND")
                .available(25)
                .maxPerOrder(2)
                .benefits(List.of("Khu vực VIP", "Lounge riêng", "Đồ uống miễn phí", "Parking VIP"))
                .requiresSeatSelection(false)
                .build());

        ticketTypeRepository.save(TicketType.builder()
                .event(musicFestival)
                .name("General Pass")
                .description("Vé thường cho 2 ngày")
                .price(800000)
                .currency("VND")
                .available(150)
                .maxPerOrder(4)
                .benefits(List.of("Tham gia festival", "Xem tất cả sân khấu"))
                .requiresSeatSelection(false)
                .build());

        // ===== DEMO EVENT 2: Art Exhibition (This Week) =====
        Event artExhibition = Event.builder()
                .name("Triển Lãm Nghệ Thuật Đương Đại")
                .slug("trien-lam-nghe-thuat-duong-dai")
                .description("Triển lãm quy tụ các tác phẩm nghệ thuật đương đại tiêu biểu từ các nghệ sĩ trong nước và quốc tế")
                .longDescription("Khám phá thế giới nghệ thuật đương đại qua hơn 100 tác phẩm độc đáo. Triển lãm mang đến góc nhìn mới về nghệ thuật hiện đại với các tác phẩm hội họa, điêu khắc và sắp đặt đặc sắc.")
                .category(exhibitCat)
                .thumbnail("https://www.elle.vn/wp-content/uploads/2015/12/07/trien-lam-nghe-thuat-duong-dai-quy-mo-lon-tai-frieze-london-Victoria-Miro-booth-Photo-Robert-Glowacki.jpg?auto=format&fit=crop&w=800&q=80")
                .images(List.of("https://example.com/images/art-1.jpg", "https://example.com/images/art-2.jpg"))
                .startDate(now.plusDays(3))
                .endDate(now.plusDays(10))
                .city(hcm)
                .venue(hcmTheater)
                .venueName(hcmTheater.getName())
                .venueAddress(hcmTheater.getAddress())
                .currency("VND")
                .isTrending(true)
                .organizerName("HCMC Art Museum")
                .organizerLogo("https://example.com/logos/art-museum.png")
                .terms("Vui lòng không chạm vào tác phẩm. Cấm chụp ảnh có đèn flash. Giữ yên lặng trong phòng triển lãm.")
                .cancellationPolicy("Vé có thể hoàn lại 100% nếu hủy trước ngày triển lãm.")
                .tags(List.of("nghệ thuật", "triển lãm", "đương đại", "văn hóa"))
                .build();
        artExhibition = eventRepository.save(artExhibition);

        ticketTypeRepository.save(TicketType.builder()
                .event(artExhibition)
                .name("Vé vào cửa")
                .description("Vé tham quan triển lãm")
                .price(150000)
                .currency("VND")
                .available(80)
                .maxPerOrder(6)
                .benefits(List.of("Tham quan triển lãm", "Audio guide miễn phí", "Tài liệu triển lãm"))
                .requiresSeatSelection(false)
                .build());

        log.info("Seeded 2 additional demo events");
    }

    private void seedDemoVouchers(
            VoucherRepository voucherRepository,
            CategoryRepository categoryRepository,
            EventRepository eventRepository) {

        if (voucherRepository.count() > 0) return;

        LocalDateTime now = LocalDateTime.now();

        // General voucher - 20% off
        voucherRepository.save(Voucher.builder()
                .code("GIAM20")
                .title("Giảm 20% cho đơn hàng")
                .description("Voucher giảm 20% áp dụng cho tất cả sự kiện, tối đa 500.000đ")
                .discountType(VoucherDiscountType.PERCENTAGE)
                .discountValue(20)
                .maxDiscount(500000)
                .minOrderAmount(200000)
                .startDate(now.minusDays(10))
                .endDate(now.plusDays(30))
                .usageLimit(100)
                .usedCount(15)
                .applicableEvents(List.of())
                .applicableCategories(List.of())
                .isPublic(true)
                .build());

        // Fixed amount voucher
        voucherRepository.save(Voucher.builder()
                .code("GIAM100K")
                .title("Giảm 100.000đ")
                .description("Voucher giảm 100.000đ cho đơn hàng từ 500.000đ trở lên")
                .discountType(VoucherDiscountType.FIXED_AMOUNT)
                .discountValue(100000)
                .maxDiscount(null)
                .minOrderAmount(500000)
                .startDate(now.minusDays(5))
                .endDate(now.plusDays(60))
                .usageLimit(200)
                .usedCount(28)
                .applicableEvents(List.of())
                .applicableCategories(List.of())
                .isPublic(true)
                .build());

        // Category-specific voucher
        voucherRepository.save(Voucher.builder()
                .code("MUSIC30")
                .title("Giảm 30% sự kiện âm nhạc")
                .description("Giảm 30% cho tất cả sự kiện âm nhạc, tối đa 800.000đ")
                .discountType(VoucherDiscountType.PERCENTAGE)
                .discountValue(30)
                .maxDiscount(800000)
                .minOrderAmount(300000)
                .startDate(now.minusDays(15))
                .endDate(now.plusDays(45))
                .usageLimit(50)
                .usedCount(8)
                .applicableEvents(List.of())
                .applicableCategories(List.of("hoa-nhac"))
                .isPublic(true)
                .build());

        log.info("Seeded 3 demo vouchers");
    }

    private void seedDemoOrdersAndTickets(
            OrderRepository orderRepository,
            TicketRepository ticketRepository,
            UserRepository userRepository,
            EventRepository eventRepository,
            TicketTypeRepository ticketTypeRepository,
            VoucherRepository voucherRepository,
            SeatRepository seatRepository) {

        if (orderRepository.count() > 0) return;

        LocalDateTime now = LocalDateTime.now();

        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();
        User user1 = userRepository.findByUsername("user1").orElseThrow();

        // Get events - use the main 3 events and demo events
        Event footballMatch = eventRepository.findBySlug("tran-dau-bong-da-viet-nam-vs-thai-lan").orElse(null);
        Event musicFestival = eventRepository.findBySlug("monsoon-music-festival-2025").orElse(null);
        Event artExhibition = eventRepository.findBySlug("trien-lam-nghe-thuat-duong-dai").orElse(null);

        Voucher percentVoucher = voucherRepository.findByCode("GIAM20").orElse(null);
        Voucher fixedVoucher = voucherRepository.findByCode("GIAM100K").orElse(null);

        AtomicInteger qrCounter = new AtomicInteger(1000);

        // ===== COMPLETED ORDER 1: Regular User with Voucher (Art Exhibition - no seat selection) =====
        if (artExhibition != null) {
            TicketType exhibitTicket = ticketTypeRepository.findAll().stream()
                    .filter(t -> t.getEvent().getId().equals(artExhibition.getId()))
                    .findFirst().orElse(null);

            if (exhibitTicket != null) {
                Order completedOrder1 = orderRepository.save(Order.builder()
                        .user(regularUser)
                        .event(artExhibition)
                        .ticketType(exhibitTicket)
                        .quantity(2)
                        .subtotal(300000)
                        .discount(60000)
                        .total(240000)
                        .currency("VND")
                        .voucher(percentVoucher)
                        .status(OrderStatus.COMPLETED)
                        .paymentMethod(PaymentMethod.E_WALLET)
                        .completedAt(now.minusDays(2))
                        .build());

                // Art exhibition doesn't require seat selection, so seat is null
                for (int i = 0; i < 2; i++) {
                    ticketRepository.save(Ticket.builder()
                            .order(completedOrder1)
                            .user(regularUser)
                            .event(artExhibition)
                            .ticketType(exhibitTicket)
                            .seat(null) // No seat selection required
                            .qrCode("QR-ART-" + qrCounter.incrementAndGet())
                            .status(TicketStatus.ACTIVE)
                            .purchaseDate(now.minusDays(2))
                            .build());
                }
            }
        }

        // ===== COMPLETED ORDER 2: VIP User (Music Festival - no seat selection) =====
        if (musicFestival != null) {
            TicketType festivalVIP = ticketTypeRepository.findAll().stream()
                    .filter(t -> t.getEvent().getId().equals(musicFestival.getId()) && t.getName().contains("VIP"))
                    .findFirst().orElse(null);

            if (festivalVIP != null) {
                Order completedOrder2 = orderRepository.save(Order.builder()
                        .user(vipUser)
                        .event(musicFestival)
                        .ticketType(festivalVIP)
                        .quantity(2)
                        .subtotal(5000000)
                        .discount(100000)
                        .total(4900000)
                        .currency("VND")
                        .voucher(fixedVoucher)
                        .status(OrderStatus.COMPLETED)
                        .paymentMethod(PaymentMethod.CREDIT_CARD)
                        .completedAt(now.minusDays(1))
                        .build());

                // Music festival doesn't require seat selection, so seat is null
                for (int i = 0; i < 2; i++) {
                    ticketRepository.save(Ticket.builder()
                            .order(completedOrder2)
                            .user(vipUser)
                            .event(musicFestival)
                            .ticketType(festivalVIP)
                            .seat(null) // No seat selection required
                            .qrCode("QR-FESTIVAL-" + qrCounter.incrementAndGet())
                            .status(TicketStatus.ACTIVE)
                            .purchaseDate(now.minusDays(1))
                            .build());
                }
            }
        }

        // ===== COMPLETED ORDER 3: Football Match with Seat Selection =====
        if (footballMatch != null && footballMatch.getVenue() != null) {
            TicketType matchTicket = ticketTypeRepository.findAll().stream()
                    .filter(t -> t.getEvent().getId().equals(footballMatch.getId()) && t.getName().contains("Thường"))
                    .findFirst().orElse(null);

            if (matchTicket != null && matchTicket.getRequiresSeatSelection()) {
                // Get available seats from Standard Section for this venue
                List<Seat> availableSeats = seatRepository.findByVenueId(footballMatch.getVenue().getId()).stream()
                        .filter(s -> s.getSectionName().equals("Standard Section"))
                        .limit(2) // Reserve 2 seats
                        .toList();

                if (!availableSeats.isEmpty()) {
                    Order completedOrder3 = orderRepository.save(Order.builder()
                            .user(user1)
                            .event(footballMatch)
                            .ticketType(matchTicket)
                            .quantity(2)
                            .subtotal(400000)
                            .discount(0)
                            .total(400000)
                            .currency("VND")
                            .status(OrderStatus.COMPLETED)
                            .paymentMethod(PaymentMethod.BANK_TRANSFER)
                            .completedAt(now.minusHours(3))
                            .build());

                    // Create tickets with assigned seats
                    for (int i = 0; i < 2 && i < availableSeats.size(); i++) {
                        ticketRepository.save(Ticket.builder()
                                .order(completedOrder3)
                                .user(user1)
                                .event(footballMatch)
                                .ticketType(matchTicket)
                                .seat(availableSeats.get(i)) // Assign seat
                                .qrCode("QR-FOOTBALL-" + qrCounter.incrementAndGet())
                                .status(TicketStatus.ACTIVE)
                                .purchaseDate(now.minusHours(3))
                                .build());
                    }
                }
            }
        }

        // ===== COMPLETED ORDER 4: VIP Football Match with Seat Selection =====
        if (footballMatch != null && footballMatch.getVenue() != null) {
            TicketType matchVIPTicket = ticketTypeRepository.findAll().stream()
                    .filter(t -> t.getEvent().getId().equals(footballMatch.getId()) && t.getName().contains("VIP"))
                    .findFirst().orElse(null);

            if (matchVIPTicket != null && matchVIPTicket.getRequiresSeatSelection()) {
                // Get available seats from VIP Section for this venue
                List<Seat> availableVIPSeats = seatRepository.findByVenueId(footballMatch.getVenue().getId()).stream()
                        .filter(s -> s.getSectionName().equals("VIP Section"))
                        .limit(1) // Reserve 1 VIP seat
                        .toList();

                if (!availableVIPSeats.isEmpty()) {
                    Order completedOrder4 = orderRepository.save(Order.builder()
                            .user(vipUser)
                            .event(footballMatch)
                            .ticketType(matchVIPTicket)
                            .quantity(1)
                            .subtotal(500000)
                            .discount(0)
                            .total(500000)
                            .currency("VND")
                            .status(OrderStatus.COMPLETED)
                            .paymentMethod(PaymentMethod.CREDIT_CARD)
                            .completedAt(now.minusDays(1))
                            .build());

                    // Create ticket with assigned VIP seat
                    ticketRepository.save(Ticket.builder()
                            .order(completedOrder4)
                            .user(vipUser)
                            .event(footballMatch)
                            .ticketType(matchVIPTicket)
                            .seat(availableVIPSeats.get(0)) // Assign VIP seat
                            .qrCode("QR-FOOTBALL-VIP-" + qrCounter.incrementAndGet())
                            .status(TicketStatus.ACTIVE)
                            .purchaseDate(now.minusDays(1))
                            .build());
                }
            }
        }

        log.info("Seeded demo orders and tickets");
    }

    private void seedDemoFavorites(
            FavoriteRepository favoriteRepository,
            UserRepository userRepository,
            EventRepository eventRepository) {

        if (favoriteRepository.count() > 0) return;

        User newUser = userRepository.findByUsername("newuser").orElseThrow();
        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();

        Event musicFestival = eventRepository.findBySlug("monsoon-music-festival-2025").orElse(null);
        Event artExhibition = eventRepository.findBySlug("trien-lam-nghe-thuat-duong-dai").orElse(null);
        Event concert = eventRepository.findBySlug("dem-nhac-son-tung-mtp").orElse(null);

        if (musicFestival != null) {
            favoriteRepository.save(Favorite.builder().user(newUser).event(musicFestival).build());
            favoriteRepository.save(Favorite.builder().user(vipUser).event(musicFestival).build());
        }
        if (artExhibition != null) {
            favoriteRepository.save(Favorite.builder().user(regularUser).event(artExhibition).build());
        }
        if (concert != null) {
            favoriteRepository.save(Favorite.builder().user(regularUser).event(concert).build());
        }

        log.info("Seeded demo favorites");
    }

    private void seedDemoNotifications(
            NotificationRepository notificationRepository,
            UserRepository userRepository,
            EventRepository eventRepository,
            OrderRepository orderRepository) {

        if (notificationRepository.count() > 0) return;

        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();
        User newUser = userRepository.findByUsername("newuser").orElseThrow();

        Event artExhibition = eventRepository.findBySlug("trien-lam-nghe-thuat-duong-dai").orElse(null);
        Event musicFestival = eventRepository.findBySlug("monsoon-music-festival-2025").orElse(null);

        notificationRepository.save(Notification.builder()
                .user(regularUser)
                .type(NotificationType.TICKET_PURCHASED)
                .title("Mua vé thành công")
                .message("Bạn đã mua 2 vé cho sự kiện 'Triển Lãm Nghệ Thuật Đương Đại'. Kiểm tra vé trong My Tickets.")
                .isRead(false)
                .data(Map.of(
                        "eventId", artExhibition != null ? artExhibition.getId() : "",
                        "eventName", "Triển Lãm Nghệ Thuật Đương Đại"
                ))
                .build());

        notificationRepository.save(Notification.builder()
                .user(vipUser)
                .type(NotificationType.TICKET_PURCHASED)
                .title("Mua vé thành công")
                .message("Bạn đã mua 2 vé VIP cho 'Monsoon Music Festival 2025'. Hẹn gặp bạn tại sự kiện!")
                .isRead(true)
                .data(Map.of(
                        "eventId", musicFestival != null ? musicFestival.getId() : "",
                        "ticketType", "VIP Pass"
                ))
                .build());

        notificationRepository.save(Notification.builder()
                .user(newUser)
                .type(NotificationType.SYSTEM)
                .title("Chào mừng bạn đến với VES Booking!")
                .message("Khám phá hàng trăm sự kiện hấp dẫn và đặt vé ngay hôm nay. Áp dụng voucher GIAM20 để giảm 20% cho đơn hàng đầu tiên!")
                .isRead(false)
                .data(Map.of(
                        "voucherCode", "GIAM20",
                        "type", "welcome"
                ))
                .build());

        log.info("Seeded demo notifications");
    }

    private void seedDemoUserVouchers(
            UserVoucherRepository userVoucherRepository,
            UserRepository userRepository,
            VoucherRepository voucherRepository,
            OrderRepository orderRepository) {

        if (userVoucherRepository.count() > 0) return;

        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();
        User newUser = userRepository.findByUsername("newuser").orElseThrow();

        Voucher percentVoucher = voucherRepository.findByCode("GIAM20").orElse(null);
        Voucher fixedVoucher = voucherRepository.findByCode("GIAM100K").orElse(null);
        Voucher musicVoucher = voucherRepository.findByCode("MUSIC30").orElse(null);

        LocalDateTime now = LocalDateTime.now();

        // Regular user - used voucher
        if (percentVoucher != null) {
            Order order = orderRepository.findAll().stream()
                    .filter(o -> o.getUser().getId().equals(regularUser.getId()) && o.getVoucher() != null)
                    .findFirst().orElse(null);

            userVoucherRepository.save(UserVoucher.builder()
                    .user(regularUser)
                    .voucher(percentVoucher)
                    .isUsed(true)
                    .usedAt(now.minusDays(2))
                    .order(order)
                    .addedAt(now.minusDays(5))
                    .build());
        }

        // Regular user - unused voucher
        if (musicVoucher != null) {
            userVoucherRepository.save(UserVoucher.builder()
                    .user(regularUser)
                    .voucher(musicVoucher)
                    .isUsed(false)
                    .addedAt(now.minusDays(3))
                    .build());
        }

        // VIP user - used voucher
        if (fixedVoucher != null) {
            Order order = orderRepository.findAll().stream()
                    .filter(o -> o.getUser().getId().equals(vipUser.getId()) &&
                            o.getVoucher() != null &&
                            o.getVoucher().getCode().equals("GIAM100K"))
                    .findFirst().orElse(null);

            userVoucherRepository.save(UserVoucher.builder()
                    .user(vipUser)
                    .voucher(fixedVoucher)
                    .isUsed(true)
                    .usedAt(now.minusDays(1))
                    .order(order)
                    .addedAt(now.minusDays(3))
                    .build());
        }

        // New user - unused voucher
        if (percentVoucher != null) {
            userVoucherRepository.save(UserVoucher.builder()
                    .user(newUser)
                    .voucher(percentVoucher)
                    .isUsed(false)
                    .addedAt(now.minusHours(2))
                    .build());
        }

        log.info("Seeded demo user vouchers");
    }
}
