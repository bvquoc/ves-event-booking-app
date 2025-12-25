package com.uit.vesbookingapi.dto.response;

import com.uit.vesbookingapi.enums.SeatStatus;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SeatResponse {
    String id;
    String sectionName;
    String rowName;
    String seatNumber;
    SeatStatus status;
}
