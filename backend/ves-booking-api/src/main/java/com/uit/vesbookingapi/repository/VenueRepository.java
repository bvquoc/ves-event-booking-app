package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Venue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VenueRepository extends JpaRepository<Venue, String> {
}
