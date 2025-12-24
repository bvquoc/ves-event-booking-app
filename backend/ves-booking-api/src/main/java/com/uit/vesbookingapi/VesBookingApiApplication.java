package com.uit.vesbookingapi;

import jakarta.annotation.PostConstruct;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.util.TimeZone;

@SpringBootApplication
@EnableScheduling
public class VesBookingApiApplication {

    @PostConstruct
    void init() {
        // Set default timezone to GMT+7 (Asia/Ho_Chi_Minh) for the entire application
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
    }
    
    public static void main(String[] args) {
        SpringApplication.run(VesBookingApiApplication.class, args);
    }
}
