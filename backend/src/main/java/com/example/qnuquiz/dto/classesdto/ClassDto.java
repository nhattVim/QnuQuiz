package com.example.qnuquiz.dto.classesdto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClassDto {
    private Long id;
    private String name;
    private Long departmentId;
}
