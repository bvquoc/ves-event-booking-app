package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.City;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface CityRepository extends JpaRepository<City, String> {
    @Query("SELECT c.id as cityId, COUNT(e.id) as eventCount FROM City c LEFT JOIN Event e ON e.city.id = c.id GROUP BY c.id")
    List<Map<String, Object>> countEventsByAllCities();

    @Query("SELECT COUNT(e) FROM Event e WHERE e.city.id = :cityId")
    Long countEventsByCity(@Param("cityId") String cityId);
}
