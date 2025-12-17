package com.uit.vesbookingapi.repository;

import com.uit.vesbookingapi.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface CategoryRepository extends JpaRepository<Category, String> {
    @Query("SELECT c.id as categoryId, COUNT(e.id) as eventCount FROM Category c LEFT JOIN Event e ON e.category.id = c.id GROUP BY c.id")
    List<Map<String, Object>> countEventsByAllCategories();

    @Query("SELECT COUNT(e) FROM Event e WHERE e.category.id = :categoryId")
    Long countEventsByCategory(@Param("categoryId") String categoryId);
}
