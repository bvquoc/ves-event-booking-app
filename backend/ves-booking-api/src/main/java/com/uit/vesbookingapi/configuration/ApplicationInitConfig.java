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

            // ===== COMPREHENSIVE SAMPLE DATA =====
            if (eventRepository.count() <= 3) { // Only seed if minimal data exists
                seedSampleEvents(eventRepository, ticketTypeRepository,
                        categoryRepository, cityRepository, venueRepository);

                seedSampleVouchers(voucherRepository, categoryRepository, eventRepository);

                seedSampleOrdersAndTickets(orderRepository, ticketRepository,
                        userRepository, eventRepository, ticketTypeRepository,
                        voucherRepository, seatRepository);

                seedSampleFavorites(favoriteRepository, userRepository, eventRepository);

                seedSampleNotifications(notificationRepository, userRepository,
                        eventRepository, orderRepository);

                seedSampleUserVouchers(userVoucherRepository, userRepository,
                        voucherRepository, orderRepository);

                log.info("Comprehensive sample data initialization completed");
            }

            log.info("Application initialization completed .....");
        };
    }

    // ===== PRIVATE HELPER METHODS FOR SAMPLE DATA =====

    private void seedSampleEvents(
            EventRepository eventRepository,
            TicketTypeRepository ticketTypeRepository,
            CategoryRepository categoryRepository,
            CityRepository cityRepository,
            VenueRepository venueRepository) {

        // Get references
        List<Category> categories = categoryRepository.findAll();
        Category sportsCat = categories.stream().filter(c -> c.getSlug().equals("the-thao")).findFirst().orElseThrow();
        Category musicCat = categories.stream().filter(c -> c.getSlug().equals("hoa-nhac")).findFirst().orElseThrow();
        Category theaterCat = categories.stream().filter(c -> c.getSlug().equals("san-khau-kich")).findFirst().orElseThrow();
        Category exhibitCat = categories.stream().filter(c -> c.getSlug().equals("trien-lam")).findFirst().orElseThrow();

        List<City> cities = cityRepository.findAll();
        City hcm = cities.stream().filter(c -> c.getSlug().equals("ho-chi-minh")).findFirst().orElseThrow();
        City hanoi = cities.stream().filter(c -> c.getSlug().equals("hanoi")).findFirst().orElseThrow();
        City danang = cities.stream().filter(c -> c.getSlug().equals("da-nang")).findFirst().orElseThrow();

        Venue hcmTheater = venueRepository.findAll().stream()
                .filter(v -> v.getName().contains("Hồ Chí Minh")).findFirst().orElseThrow();
        Venue myDinhStadium = venueRepository.findAll().stream()
                .filter(v -> v.getName().contains("Mỹ Đình")).findFirst().orElseThrow();
        Venue nationalCenter = venueRepository.findAll().stream()
                .filter(v -> v.getName().contains("Hội nghị")).findFirst().orElseThrow();

        LocalDateTime now = LocalDateTime.now();

        // ===== PAST EVENTS (completed) =====

        // Past Event 1: Music Concert (2 weeks ago)
        Event pastConcert = Event.builder()
                .name("[PAST] Liveshow Blackpink World Tour")
                .slug("past-blackpink-world-tour")
                .description("Liveshow quốc tế đã kết thúc")
                .longDescription("Concert quốc tế của Blackpink đã diễn ra thành công tại Việt Nam.")
                .category(musicCat)
                .thumbnail("https://example.com/images/blackpink.jpg")
                .images(List.of("https://example.com/images/blackpink-1.jpg"))
                .startDate(now.minusDays(14))
                .endDate(now.minusDays(14).plusHours(3))
                .city(hcm)
                .venue(hcmTheater)
                .venueName(hcmTheater.getName())
                .venueAddress(hcmTheater.getAddress())
                .currency("VND")
                .isTrending(false)
                .organizerName("YG Entertainment Vietnam")
                .tags(List.of("kpop", "blackpink", "concert"))
                .build();
        pastConcert = eventRepository.save(pastConcert);

        ticketTypeRepository.save(TicketType.builder()
                .event(pastConcert)
                .name("VIP Standing")
                .description("Standing area near stage")
                .price(5000000)
                .currency("VND")
                .available(0)
                .maxPerOrder(2)
                .benefits(List.of("Near stage", "Exclusive merchandise"))
                .requiresSeatSelection(false)
                .build());

        ticketTypeRepository.save(TicketType.builder()
                .event(pastConcert)
                .name("General Admission")
                .description("General standing area")
                .price(1500000)
                .currency("VND")
                .available(0)
                .maxPerOrder(4)
                .benefits(List.of("Concert access"))
                .requiresSeatSelection(false)
                .build());

        // Past Event 2: Sports Match (1 week ago)
        Event pastMatch = Event.builder()
                .name("[PAST] AFF Cup 2024 Final")
                .slug("past-aff-cup-final")
                .description("Trận chung kết AFF Cup 2024 đã kết thúc")
                .longDescription("Trận chung kết AFF Cup 2024 giữa Việt Nam và Indonesia.")
                .category(sportsCat)
                .thumbnail("https://example.com/images/aff-final.jpg")
                .images(List.of("https://example.com/images/aff-1.jpg"))
                .startDate(now.minusDays(7))
                .endDate(now.minusDays(7).plusHours(2))
                .city(hanoi)
                .venue(myDinhStadium)
                .venueName(myDinhStadium.getName())
                .venueAddress(myDinhStadium.getAddress())
                .currency("VND")
                .isTrending(false)
                .organizerName("VFF")
                .tags(List.of("bóng đá", "aff cup", "chung kết"))
                .build();
        pastMatch = eventRepository.save(pastMatch);

        ticketTypeRepository.save(TicketType.builder()
                .event(pastMatch)
                .name("Tribune A")
                .description("Best viewing angle")
                .price(800000)
                .currency("VND")
                .available(0)
                .maxPerOrder(4)
                .benefits(List.of("Best view", "Covered seating"))
                .requiresSeatSelection(true)
                .build());

        // ===== ONGOING EVENTS (today/tomorrow) =====

        Event ongoingTheater = Event.builder()
                .name("[ONGOING] Festival Kịch Nói 2024")
                .slug("ongoing-festival-kich-noi")
                .description("Festival kịch nói đang diễn ra")
                .longDescription("Festival kịch nói lớn nhất trong năm với nhiều vở diễn đặc sắc.")
                .category(theaterCat)
                .thumbnail("https://example.com/images/theater-fest.jpg")
                .images(List.of("https://example.com/images/theater-fest-1.jpg"))
                .startDate(now.minusHours(2))
                .endDate(now.plusHours(4))
                .city(hanoi)
                .venue(nationalCenter)
                .venueName(nationalCenter.getName())
                .venueAddress(nationalCenter.getAddress())
                .currency("VND")
                .isTrending(true)
                .organizerName("Nhà hát Kịch Việt Nam")
                .tags(List.of("kịch", "festival", "nghệ thuật"))
                .build();
        ongoingTheater = eventRepository.save(ongoingTheater);

        ticketTypeRepository.save(TicketType.builder()
                .event(ongoingTheater)
                .name("VIP Seat")
                .description("Front row seats")
                .price(400000)
                .currency("VND")
                .available(5)
                .maxPerOrder(2)
                .benefits(List.of("Front row", "Program booklet"))
                .requiresSeatSelection(true)
                .build());

        ticketTypeRepository.save(TicketType.builder()
                .event(ongoingTheater)
                .name("Standard Seat")
                .description("Regular seating")
                .price(200000)
                .currency("VND")
                .available(20)
                .maxPerOrder(4)
                .benefits(List.of("Reserved seating"))
                .requiresSeatSelection(true)
                .build());

        // ===== UPCOMING EVENTS - THIS WEEK (limited tickets) =====

        Event soonExhibit = Event.builder()
                .name("[SOON] Triển Lãm Nghệ Thuật Đương Đại")
                .slug("soon-trien-lam-duong-dai")
                .description("Triển lãm nghệ thuật đương đại - chỉ còn 3 ngày")
                .longDescription("Triển lãm quy tụ các tác phẩm nghệ thuật đương đại tiêu biểu.")
                .category(exhibitCat)
                .thumbnail("https://example.com/images/art-exhibit.jpg")
                .images(List.of("https://example.com/images/art-1.jpg"))
                .startDate(now.plusDays(3))
                .endDate(now.plusDays(3).plusHours(8))
                .city(hcm)
                .venue(hcmTheater)
                .venueName(hcmTheater.getName())
                .venueAddress(hcmTheater.getAddress())
                .currency("VND")
                .isTrending(true)
                .organizerName("HCMC Art Museum")
                .tags(List.of("nghệ thuật", "triển lãm", "đương đại"))
                .build();
        soonExhibit = eventRepository.save(soonExhibit);

        ticketTypeRepository.save(TicketType.builder()
                .event(soonExhibit)
                .name("Entrance Ticket")
                .description("General admission")
                .price(150000)
                .currency("VND")
                .available(15)
                .maxPerOrder(4)
                .benefits(List.of("Exhibition access", "Audio guide"))
                .requiresSeatSelection(false)
                .build());

        Event soonConcert = Event.builder()
                .name("[SOON] Monsoon Music Festival")
                .slug("soon-monsoon-festival")
                .description("Monsoon Music Festival - chỉ còn 5 ngày")
                .longDescription("Festival âm nhạc quốc tế lớn nhất mùa thu.")
                .category(musicCat)
                .thumbnail("https://example.com/images/monsoon.jpg")
                .images(List.of("https://example.com/images/monsoon-1.jpg"))
                .startDate(now.plusDays(5))
                .endDate(now.plusDays(5).plusHours(6))
                .city(hanoi)
                .venue(myDinhStadium)
                .venueName(myDinhStadium.getName())
                .venueAddress(myDinhStadium.getAddress())
                .currency("VND")
                .isTrending(true)
                .organizerName("Monsoon Entertainment")
                .tags(List.of("festival", "âm nhạc", "quốc tế"))
                .build();
        soonConcert = eventRepository.save(soonConcert);

        ticketTypeRepository.save(TicketType.builder()
                .event(soonConcert)
                .name("VIP Pass")
                .description("2-day VIP access")
                .price(2500000)
                .currency("VND")
                .available(8)
                .maxPerOrder(2)
                .benefits(List.of("VIP area", "Lounge access", "Free drinks"))
                .requiresSeatSelection(false)
                .build());

        ticketTypeRepository.save(TicketType.builder()
                .event(soonConcert)
                .name("General Pass")
                .description("General admission")
                .price(800000)
                .currency("VND")
                .available(50)
                .maxPerOrder(4)
                .benefits(List.of("Festival access"))
                .requiresSeatSelection(false)
                .build());

        // ===== SOLD OUT EVENT =====

        Event soldOutEvent = Event.builder()
                .name("[SOLD OUT] Taylor Swift Eras Tour Vietnam")
                .slug("soldout-taylor-swift-eras")
                .description("SOLD OUT - Taylor Swift Eras Tour")
                .longDescription("Concert quốc tế Taylor Swift đã bán hết vé.")
                .category(musicCat)
                .thumbnail("https://example.com/images/taylor.jpg")
                .images(List.of("https://example.com/images/taylor-1.jpg"))
                .startDate(now.plusDays(60))
                .endDate(now.plusDays(60).plusHours(3))
                .city(hcm)
                .venue(hcmTheater)
                .venueName(hcmTheater.getName())
                .venueAddress(hcmTheater.getAddress())
                .currency("VND")
                .isTrending(true)
                .organizerName("UMG Vietnam")
                .tags(List.of("taylor swift", "pop", "international"))
                .build();
        soldOutEvent = eventRepository.save(soldOutEvent);

        ticketTypeRepository.save(TicketType.builder()
                .event(soldOutEvent)
                .name("All Ticket Types")
                .description("SOLD OUT")
                .price(10000000)
                .currency("VND")
                .available(0)
                .maxPerOrder(2)
                .benefits(List.of("Concert access"))
                .requiresSeatSelection(true)
                .build());

        // ===== FUTURE EVENTS (3-4 weeks out, full inventory) =====

        Event futureEvent = Event.builder()
                .name("[FUTURE] SEA Games 2025 Opening")
                .slug("future-sea-games-opening")
                .description("Lễ khai mạc SEA Games 2025")
                .longDescription("Lễ khai mạc hoành tráng của SEA Games 2025 tại Việt Nam.")
                .category(sportsCat)
                .thumbnail("https://example.com/images/seagames.jpg")
                .images(List.of("https://example.com/images/seagames-1.jpg"))
                .startDate(now.plusDays(28))
                .endDate(now.plusDays(28).plusHours(4))
                .city(hanoi)
                .venue(myDinhStadium)
                .venueName(myDinhStadium.getName())
                .venueAddress(myDinhStadium.getAddress())
                .currency("VND")
                .isTrending(false)
                .organizerName("Vietnam Sports Authority")
                .tags(List.of("sea games", "thể thao", "khai mạc"))
                .build();
        futureEvent = eventRepository.save(futureEvent);

        ticketTypeRepository.save(TicketType.builder()
                .event(futureEvent)
                .name("VIP Tribune")
                .description("VIP seating with catering")
                .price(1500000)
                .currency("VND")
                .available(500)
                .maxPerOrder(6)
                .benefits(List.of("VIP tribune", "Catering", "Parking"))
                .requiresSeatSelection(true)
                .build());

        ticketTypeRepository.save(TicketType.builder()
                .event(futureEvent)
                .name("Standard Tribune")
                .description("Standard seating")
                .price(500000)
                .currency("VND")
                .available(2000)
                .maxPerOrder(8)
                .benefits(List.of("Reserved seating"))
                .requiresSeatSelection(true)
                .build());

        ticketTypeRepository.save(TicketType.builder()
                .event(futureEvent)
                .name("Standing Zone")
                .description("General standing area")
                .price(200000)
                .currency("VND")
                .available(5000)
                .maxPerOrder(10)
                .benefits(List.of("Event access"))
                .requiresSeatSelection(false)
                .build());

        log.info("Seeded 8 sample events covering all lifecycle stages");
    }

    private void seedSampleVouchers(
            VoucherRepository voucherRepository,
            CategoryRepository categoryRepository,
            EventRepository eventRepository) {

        if (voucherRepository.count() > 0) return;

        LocalDateTime now = LocalDateTime.now();

        voucherRepository.save(Voucher.builder()
                .code("GIAM20")
                .title("Giảm 20% toàn bộ")
                .description("Voucher giảm 20% áp dụng cho tất cả sự kiện")
                .discountType(VoucherDiscountType.PERCENTAGE)
                .discountValue(20)
                .maxDiscount(500000)
                .minOrderAmount(200000)
                .startDate(now.minusDays(10))
                .endDate(now.plusDays(30))
                .usageLimit(100)
                .usedCount(25)
                .applicableEvents(List.of())
                .applicableCategories(List.of())
                .isPublic(true)
                .build());

        voucherRepository.save(Voucher.builder()
                .code("GIAM100K")
                .title("Giảm 100.000đ")
                .description("Voucher giảm 100.000đ cho đơn hàng từ 500.000đ")
                .discountType(VoucherDiscountType.FIXED_AMOUNT)
                .discountValue(100000)
                .maxDiscount(null)
                .minOrderAmount(500000)
                .startDate(now.minusDays(5))
                .endDate(now.plusDays(60))
                .usageLimit(200)
                .usedCount(45)
                .applicableEvents(List.of())
                .applicableCategories(List.of())
                .isPublic(true)
                .build());

        Event targetEvent = eventRepository.findBySlug("soon-monsoon-festival").orElse(null);
        voucherRepository.save(Voucher.builder()
                .code("MONSOON50")
                .title("Monsoon Festival - Giảm 50%")
                .description("Voucher đặc biệt cho Monsoon Festival")
                .discountType(VoucherDiscountType.PERCENTAGE)
                .discountValue(50)
                .maxDiscount(1000000)
                .minOrderAmount(0)
                .startDate(now.minusDays(2))
                .endDate(now.plusDays(5))
                .usageLimit(20)
                .usedCount(5)
                .applicableEvents(targetEvent != null ? List.of(targetEvent.getId()) : List.of())
                .applicableCategories(List.of())
                .isPublic(false)
                .build());

        voucherRepository.save(Voucher.builder()
                .code("MUSIC30")
                .title("Âm nhạc - Giảm 30%")
                .description("Giảm 30% cho tất cả sự kiện âm nhạc")
                .discountType(VoucherDiscountType.PERCENTAGE)
                .discountValue(30)
                .maxDiscount(800000)
                .minOrderAmount(300000)
                .startDate(now.minusDays(15))
                .endDate(now.plusDays(45))
                .usageLimit(50)
                .usedCount(12)
                .applicableEvents(List.of())
                .applicableCategories(List.of("hoa-nhac"))
                .isPublic(true)
                .build());

        voucherRepository.save(Voucher.builder()
                .code("EXPIRED2024")
                .title("Voucher hết hạn")
                .description("Voucher đã hết hạn sử dụng")
                .discountType(VoucherDiscountType.PERCENTAGE)
                .discountValue(15)
                .maxDiscount(300000)
                .minOrderAmount(100000)
                .startDate(now.minusDays(60))
                .endDate(now.minusDays(30))
                .usageLimit(100)
                .usedCount(67)
                .applicableEvents(List.of())
                .applicableCategories(List.of())
                .isPublic(true)
                .build());

        voucherRepository.save(Voucher.builder()
                .code("LIMITED10")
                .title("Voucher giới hạn - Còn 2 lượt")
                .description("Voucher chỉ còn 2 lượt sử dụng")
                .discountType(VoucherDiscountType.FIXED_AMOUNT)
                .discountValue(200000)
                .maxDiscount(null)
                .minOrderAmount(400000)
                .startDate(now.minusDays(7))
                .endDate(now.plusDays(14))
                .usageLimit(10)
                .usedCount(8)
                .applicableEvents(List.of())
                .applicableCategories(List.of())
                .isPublic(true)
                .build());

        log.info("Seeded 6 sample vouchers covering all scenarios");
    }

    private void seedSampleOrdersAndTickets(
            OrderRepository orderRepository,
            TicketRepository ticketRepository,
            UserRepository userRepository,
            EventRepository eventRepository,
            TicketTypeRepository ticketTypeRepository,
            VoucherRepository voucherRepository,
            SeatRepository seatRepository) {

        if (orderRepository.count() > 0) return;

        LocalDateTime now = LocalDateTime.now();
        
        // Helper method to get available seats for an event
        java.util.function.Function<Event, List<Seat>> getAvailableSeats = (event) -> {
            if (event.getVenue() == null) return new ArrayList<>();
            return seatRepository.findByVenueId(event.getVenue().getId());
        };

        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();
        User user1 = userRepository.findByUsername("user1").orElseThrow();

        Event pastConcert = eventRepository.findBySlug("past-blackpink-world-tour").orElseThrow();
        Event pastMatch = eventRepository.findBySlug("past-aff-cup-final").orElseThrow();
        Event ongoingTheater = eventRepository.findBySlug("ongoing-festival-kich-noi").orElseThrow();
        Event soonExhibit = eventRepository.findBySlug("soon-trien-lam-duong-dai").orElseThrow();
        Event soonConcert = eventRepository.findBySlug("soon-monsoon-festival").orElseThrow();
        Event futureEvent = eventRepository.findBySlug("future-sea-games-opening").orElseThrow();

        Voucher percentVoucher = voucherRepository.findByCode("GIAM20").orElse(null);
        Voucher fixedVoucher = voucherRepository.findByCode("GIAM100K").orElse(null);

        AtomicInteger qrCounter = new AtomicInteger(1000);

        // ===== REGULAR USER ORDERS =====

        TicketType pastConcertVIP = ticketTypeRepository.findAll().stream()
                .filter(t -> t.getEvent().getId().equals(pastConcert.getId()) && t.getName().contains("VIP"))
                .findFirst().orElseThrow();

        Order regularOrder1 = orderRepository.save(Order.builder()
                .user(regularUser)
                .event(pastConcert)
                .ticketType(pastConcertVIP)
                .quantity(2)
                .subtotal(10000000)
                .discount(0)
                .total(10000000)
                .currency("VND")
                .voucher(null)
                .status(OrderStatus.COMPLETED)
                .paymentMethod(PaymentMethod.CREDIT_CARD)
                .expiresAt(now.minusDays(20))
                .completedAt(now.minusDays(20))
                .build());

        // Get seats for pastConcert if ticket type requires seat selection
        List<Seat> pastConcertSeats = pastConcertVIP.getRequiresSeatSelection() 
                ? getAvailableSeats.apply(pastConcert) 
                : new ArrayList<>();
        int seatIndex = 0; // Track seat index to avoid conflicts
        
        for (int i = 0; i < 2; i++) {
            Seat assignedSeat = pastConcertVIP.getRequiresSeatSelection() && !pastConcertSeats.isEmpty()
                    ? pastConcertSeats.get(seatIndex++ % pastConcertSeats.size())
                    : null;
            
            ticketRepository.save(Ticket.builder()
                    .order(regularOrder1)
                    .user(regularUser)
                    .event(pastConcert)
                    .ticketType(pastConcertVIP)
                    .seat(assignedSeat)
                    .qrCode("QR-PAST-" + qrCounter.incrementAndGet())
                    .qrCodeImage("https://example.com/qr/past-" + qrCounter.get() + ".png")
                    .status(TicketStatus.USED)
                    .purchaseDate(now.minusDays(20))
                    .checkedInAt(now.minusDays(14).plusHours(1))
                    .build());
        }

        TicketType soonExhibitTicket = ticketTypeRepository.findAll().stream()
                .filter(t -> t.getEvent().getId().equals(soonExhibit.getId()))
                .findFirst().orElseThrow();

        Order regularOrder2 = orderRepository.save(Order.builder()
                .user(regularUser)
                .event(soonExhibit)
                .ticketType(soonExhibitTicket)
                .quantity(2)
                .subtotal(300000)
                .discount(60000)
                .total(240000)
                .currency("VND")
                .voucher(percentVoucher)
                .status(OrderStatus.COMPLETED)
                .paymentMethod(PaymentMethod.E_WALLET)
                .expiresAt(now.minusDays(2))
                .completedAt(now.minusDays(2))
                .build());

        // Get seats for soonExhibit if ticket type requires seat selection
        List<Seat> soonExhibitSeats = soonExhibitTicket.getRequiresSeatSelection()
                ? getAvailableSeats.apply(soonExhibit)
                : new ArrayList<>();
        int soonExhibitSeatIndex = 0;
        
        for (int i = 0; i < 2; i++) {
            Seat assignedSeat = soonExhibitTicket.getRequiresSeatSelection() && !soonExhibitSeats.isEmpty()
                    ? soonExhibitSeats.get(soonExhibitSeatIndex++ % soonExhibitSeats.size())
                    : null;
            
            ticketRepository.save(Ticket.builder()
                    .order(regularOrder2)
                    .user(regularUser)
                    .event(soonExhibit)
                    .ticketType(soonExhibitTicket)
                    .seat(assignedSeat)
                    .qrCode("QR-SOON-" + qrCounter.incrementAndGet())
                    .qrCodeImage("https://example.com/qr/soon-" + qrCounter.get() + ".png")
                    .status(TicketStatus.ACTIVE)
                    .purchaseDate(now.minusDays(2))
                    .build());
        }

        // ===== VIP USER ORDERS =====

        TicketType pastMatchTribune = ticketTypeRepository.findAll().stream()
                .filter(t -> t.getEvent().getId().equals(pastMatch.getId()))
                .findFirst().orElseThrow();

        Order vipOrder1 = orderRepository.save(Order.builder()
                .user(vipUser)
                .event(pastMatch)
                .ticketType(pastMatchTribune)
                .quantity(4)
                .subtotal(3200000)
                .discount(100000)
                .total(3100000)
                .currency("VND")
                .voucher(fixedVoucher)
                .status(OrderStatus.COMPLETED)
                .paymentMethod(PaymentMethod.BANK_TRANSFER)
                .completedAt(now.minusDays(10))
                .build());

        // Get seats for pastMatch if ticket type requires seat selection
        List<Seat> pastMatchSeats = pastMatchTribune.getRequiresSeatSelection()
                ? getAvailableSeats.apply(pastMatch)
                : new ArrayList<>();
        int pastMatchSeatIndex = 0;
        
        for (int i = 0; i < 4; i++) {
            Seat assignedSeat = pastMatchTribune.getRequiresSeatSelection() && !pastMatchSeats.isEmpty()
                    ? pastMatchSeats.get(pastMatchSeatIndex++ % pastMatchSeats.size())
                    : null;
            
            ticketRepository.save(Ticket.builder()
                    .order(vipOrder1)
                    .user(vipUser)
                    .event(pastMatch)
                    .ticketType(pastMatchTribune)
                    .seat(assignedSeat)
                    .qrCode("QR-VIP-PAST-" + qrCounter.incrementAndGet())
                    .status(TicketStatus.USED)
                    .purchaseDate(now.minusDays(10))
                    .checkedInAt(now.minusDays(7).plusMinutes(30))
                    .build());
        }

        TicketType futureVIP = ticketTypeRepository.findAll().stream()
                .filter(t -> t.getEvent().getId().equals(futureEvent.getId()) && t.getName().contains("VIP"))
                .findFirst().orElseThrow();

        Order vipOrder2 = orderRepository.save(Order.builder()
                .user(vipUser)
                .event(futureEvent)
                .ticketType(futureVIP)
                .quantity(4)
                .subtotal(6000000)
                .discount(0)
                .total(6000000)
                .currency("VND")
                .status(OrderStatus.COMPLETED)
                .paymentMethod(PaymentMethod.CREDIT_CARD)
                .completedAt(now.minusDays(5))
                .build());

        // Get seats for futureEvent if ticket type requires seat selection
        List<Seat> futureEventSeats = futureVIP.getRequiresSeatSelection()
                ? getAvailableSeats.apply(futureEvent)
                : new ArrayList<>();
        int futureEventSeatIndex = 0;
        
        for (int i = 0; i < 4; i++) {
            Seat assignedSeat = futureVIP.getRequiresSeatSelection() && !futureEventSeats.isEmpty()
                    ? futureEventSeats.get(futureEventSeatIndex++ % futureEventSeats.size())
                    : null;
            
            ticketRepository.save(Ticket.builder()
                    .order(vipOrder2)
                    .user(vipUser)
                    .event(futureEvent)
                    .ticketType(futureVIP)
                    .seat(assignedSeat)
                    .qrCode("QR-VIP-FUTURE-" + qrCounter.incrementAndGet())
                    .status(TicketStatus.ACTIVE)
                    .purchaseDate(now.minusDays(5))
                    .build());
        }

        TicketType monsoonVIP = ticketTypeRepository.findAll().stream()
                .filter(t -> t.getEvent().getId().equals(soonConcert.getId()) && t.getName().contains("VIP"))
                .findFirst().orElseThrow();

        Order vipOrder3 = orderRepository.save(Order.builder()
                .user(vipUser)
                .event(soonConcert)
                .ticketType(monsoonVIP)
                .quantity(2)
                .subtotal(5000000)
                .discount(0)
                .total(5000000)
                .currency("VND")
                .status(OrderStatus.COMPLETED)
                .paymentMethod(PaymentMethod.E_WALLET)
                .completedAt(now.minusDays(3))
                .build());

        // Get seats for soonConcert if ticket type requires seat selection
        List<Seat> soonConcertSeats = monsoonVIP.getRequiresSeatSelection()
                ? getAvailableSeats.apply(soonConcert)
                : new ArrayList<>();
        int soonConcertSeatIndex = 0;
        
        for (int i = 0; i < 2; i++) {
            Seat assignedSeat = monsoonVIP.getRequiresSeatSelection() && !soonConcertSeats.isEmpty()
                    ? soonConcertSeats.get(soonConcertSeatIndex++ % soonConcertSeats.size())
                    : null;
            
            ticketRepository.save(Ticket.builder()
                    .order(vipOrder3)
                    .user(vipUser)
                    .event(soonConcert)
                    .ticketType(monsoonVIP)
                    .seat(assignedSeat)
                    .qrCode("QR-VIP-MONSOON-" + qrCounter.incrementAndGet())
                    .status(TicketStatus.ACTIVE)
                    .purchaseDate(now.minusDays(3))
                    .build());
        }

        // ===== PENDING ORDERS =====

        TicketType futureStandard = ticketTypeRepository.findAll().stream()
                .filter(t -> t.getEvent().getId().equals(futureEvent.getId()) && t.getName().contains("Standard"))
                .findFirst().orElseThrow();

        orderRepository.save(Order.builder()
                .user(user1)
                .event(futureEvent)
                .ticketType(futureStandard)
                .quantity(2)
                .subtotal(1000000)
                .discount(0)
                .total(1000000)
                .currency("VND")
                .status(OrderStatus.PENDING)
                .paymentMethod(PaymentMethod.BANK_TRANSFER)
                .paymentUrl("https://payment.example.com/pending-123")
                .expiresAt(now.plusMinutes(15))
                .build());

        orderRepository.save(Order.builder()
                .user(user1)
                .event(soonExhibit)
                .ticketType(soonExhibitTicket)
                .quantity(1)
                .subtotal(150000)
                .discount(0)
                .total(150000)
                .currency("VND")
                .status(OrderStatus.PENDING)
                .paymentMethod(PaymentMethod.E_WALLET)
                .paymentUrl("https://payment.example.com/expired-456")
                .expiresAt(now.minusHours(2))
                .build());

        // ===== CANCELLED ORDER WITH REFUND =====

        Order cancelledOrder = orderRepository.save(Order.builder()
                .user(regularUser)
                .event(pastConcert)
                .ticketType(pastConcertVIP)
                .quantity(1)
                .subtotal(5000000)
                .discount(0)
                .total(5000000)
                .currency("VND")
                .status(OrderStatus.REFUNDED)
                .paymentMethod(PaymentMethod.CREDIT_CARD)
                .completedAt(now.minusDays(25))
                .build());

        // Get seat for cancelled order if ticket type requires seat selection
        // Use a different seat index to avoid conflicts with regularOrder1
        Seat cancelledSeat = pastConcertVIP.getRequiresSeatSelection() && !pastConcertSeats.isEmpty()
                ? pastConcertSeats.get(2 % pastConcertSeats.size()) // Use seat index 2 (after regularOrder1's 2 seats)
                : null;
        
        ticketRepository.save(Ticket.builder()
                .order(cancelledOrder)
                .user(regularUser)
                .event(pastConcert)
                .ticketType(pastConcertVIP)
                .seat(cancelledSeat)
                .qrCode("QR-CANCELLED-" + qrCounter.incrementAndGet())
                .status(TicketStatus.REFUNDED)
                .purchaseDate(now.minusDays(25))
                .cancellationReason("Không thể tham dự")
                .refundAmount(5000000)
                .refundStatus(RefundStatus.COMPLETED)
                .cancelledAt(now.minusDays(22))
                .build());

        log.info("Seeded sample orders and tickets covering all states");
    }

    private void seedSampleFavorites(
            FavoriteRepository favoriteRepository,
            UserRepository userRepository,
            EventRepository eventRepository) {

        if (favoriteRepository.count() > 0) return;

        User newUser = userRepository.findByUsername("newuser").orElseThrow();
        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();
        User user1 = userRepository.findByUsername("user1").orElseThrow();

        Event soonExhibit = eventRepository.findBySlug("soon-trien-lam-duong-dai").orElse(null);
        Event soonConcert = eventRepository.findBySlug("soon-monsoon-festival").orElse(null);
        Event futureEvent = eventRepository.findBySlug("future-sea-games-opening").orElse(null);
        Event soldOut = eventRepository.findBySlug("soldout-taylor-swift-eras").orElse(null);

        if (soonExhibit != null) {
            favoriteRepository.save(Favorite.builder().user(newUser).event(soonExhibit).build());
        }
        if (soonConcert != null) {
            favoriteRepository.save(Favorite.builder().user(newUser).event(soonConcert).build());
        }
        if (soldOut != null) {
            favoriteRepository.save(Favorite.builder().user(newUser).event(soldOut).build());
        }

        if (futureEvent != null) {
            favoriteRepository.save(Favorite.builder().user(regularUser).event(futureEvent).build());
        }
        if (soonConcert != null) {
            favoriteRepository.save(Favorite.builder().user(regularUser).event(soonConcert).build());
        }

        if (soldOut != null) {
            favoriteRepository.save(Favorite.builder().user(vipUser).event(soldOut).build());
        }
        if (futureEvent != null) {
            favoriteRepository.save(Favorite.builder().user(vipUser).event(futureEvent).build());
        }

        if (soonExhibit != null) {
            favoriteRepository.save(Favorite.builder().user(user1).event(soonExhibit).build());
        }
        if (soldOut != null) {
            favoriteRepository.save(Favorite.builder().user(user1).event(soldOut).build());
        }

        log.info("Seeded sample favorites for trending data");
    }

    private void seedSampleNotifications(
            NotificationRepository notificationRepository,
            UserRepository userRepository,
            EventRepository eventRepository,
            OrderRepository orderRepository) {

        if (notificationRepository.count() > 0) return;

        User regularUser = userRepository.findByUsername("regularuser").orElseThrow();
        User vipUser = userRepository.findByUsername("vipuser").orElseThrow();
        User newUser = userRepository.findByUsername("newuser").orElseThrow();

        Event soonExhibit = eventRepository.findBySlug("soon-trien-lam-duong-dai").orElse(null);
        Event soonConcert = eventRepository.findBySlug("soon-monsoon-festival").orElse(null);

        notificationRepository.save(Notification.builder()
                .user(regularUser)
                .type(NotificationType.TICKET_PURCHASED)
                .title("Mua vé thành công")
                .message("Bạn đã mua 2 vé cho sự kiện 'Triển Lãm Nghệ Thuật Đương Đại'. Kiểm tra vé trong My Tickets.")
                .isRead(false)
                .data(Map.of(
                        "eventId", soonExhibit != null ? soonExhibit.getId() : "",
                        "eventName", "Triển Lãm Nghệ Thuật Đương Đại"
                ))
                .build());

        notificationRepository.save(Notification.builder()
                .user(regularUser)
                .type(NotificationType.EVENT_REMINDER)
                .title("Sự kiện sắp diễn ra!")
                .message("Triển lãm 'Triển Lãm Nghệ Thuật Đương Đại' sẽ diễn ra trong 3 ngày. Hãy chuẩn bị!")
                .isRead(true)
                .data(Map.of(
                        "eventId", soonExhibit != null ? soonExhibit.getId() : "",
                        "daysUntil", "3"
                ))
                .build());

        notificationRepository.save(Notification.builder()
                .user(vipUser)
                .type(NotificationType.TICKET_PURCHASED)
                .title("Mua vé thành công")
                .message("Bạn đã mua 2 vé VIP cho 'Monsoon Music Festival'. Hẹn gặp bạn tại sự kiện!")
                .isRead(true)
                .data(Map.of(
                        "eventId", soonConcert != null ? soonConcert.getId() : "",
                        "ticketType", "VIP Pass"
                ))
                .build());

        notificationRepository.save(Notification.builder()
                .user(vipUser)
                .type(NotificationType.PROMOTION)
                .title("Ưu đãi dành riêng cho VIP")
                .message("Bạn nhận được voucher MUSIC30 giảm 30% cho tất cả sự kiện âm nhạc. Sử dụng ngay!")
                .isRead(false)
                .data(Map.of(
                        "voucherCode", "MUSIC30",
                        "discount", "30%"
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

        log.info("Seeded sample notifications");
    }

    private void seedSampleUserVouchers(
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
        Voucher limitedVoucher = voucherRepository.findByCode("LIMITED10").orElse(null);

        LocalDateTime now = LocalDateTime.now();

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

        if (musicVoucher != null) {
            userVoucherRepository.save(UserVoucher.builder()
                    .user(regularUser)
                    .voucher(musicVoucher)
                    .isUsed(false)
                    .addedAt(now.minusDays(3))
                    .build());
        }

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
                    .usedAt(now.minusDays(10))
                    .order(order)
                    .addedAt(now.minusDays(12))
                    .build());
        }

        if (limitedVoucher != null) {
            userVoucherRepository.save(UserVoucher.builder()
                    .user(vipUser)
                    .voucher(limitedVoucher)
                    .isUsed(false)
                    .addedAt(now.minusDays(1))
                    .build());
        }

        if (percentVoucher != null) {
            userVoucherRepository.save(UserVoucher.builder()
                    .user(newUser)
                    .voucher(percentVoucher)
                    .isUsed(false)
                    .addedAt(now.minusHours(2))
                    .build());
        }

        log.info("Seeded sample user vouchers");
    }
}
