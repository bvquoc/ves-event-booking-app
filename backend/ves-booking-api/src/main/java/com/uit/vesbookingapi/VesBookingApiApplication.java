package com.uit.vesbookingapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class VesBookingApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(VesBookingApiApplication.class, args);
    }
}
