package com.uit.vesbookingapi.utils;

import com.uit.vesbookingapi.entity.Event;
import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.List;

public class EventSpecification {
    
    public static Specification<Event> hasCategory(String categoryId) {
        return (root, query, cb) -> {
            if (categoryId == null || categoryId.isEmpty()) {
                return cb.conjunction();
            }
            return cb.equal(root.get("category").get("id"), categoryId);
        };
    }
    
    public static Specification<Event> hasCity(String cityId) {
        return (root, query, cb) -> {
            if (cityId == null || cityId.isEmpty()) {
                return cb.conjunction();
            }
            return cb.equal(root.get("city").get("id"), cityId);
        };
    }
    
    public static Specification<Event> isTrending(Boolean trending) {
        return (root, query, cb) -> {
            if (trending == null) {
                return cb.conjunction();
            }
            return cb.equal(root.get("isTrending"), trending);
        };
    }
    
    public static Specification<Event> inDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return (root, query, cb) -> {
            if (startDate == null && endDate == null) {
                return cb.conjunction();
            }
            Path<LocalDateTime> startDatePath = root.get("startDate");
            if (startDate != null && endDate != null) {
                return cb.between(startDatePath, startDate, endDate);
            } else if (startDate != null) {
                return cb.greaterThanOrEqualTo(startDatePath, startDate);
            } else {
                return cb.lessThanOrEqualTo(startDatePath, endDate);
            }
        };
    }
    
    public static Specification<Event> searchByKeyword(String keyword) {
        return (root, query, cb) -> {
            if (keyword == null || keyword.isEmpty()) {
                return cb.conjunction();
            }
            String searchPattern = "%" + keyword.toLowerCase() + "%";
            
            Predicate nameMatch = cb.like(cb.lower(root.get("name")), searchPattern);
            Predicate descriptionMatch = cb.like(cb.lower(root.get("description")), searchPattern);
            
            // Search in tags
            Join<Event, String> tagsJoin = root.join("tags", JoinType.LEFT);
            Predicate tagMatch = cb.like(cb.lower(tagsJoin), searchPattern);
            
            return cb.or(nameMatch, descriptionMatch, tagMatch);
        };
    }
    
    @SafeVarargs
    public static Specification<Event> combine(Specification<Event>... specs) {
        Specification<Event> combined = Specification.where(null);
        for (Specification<Event> spec : specs) {
            if (spec != null) {
                combined = combined.and(spec);
            }
        }
        return combined;
    }
}

