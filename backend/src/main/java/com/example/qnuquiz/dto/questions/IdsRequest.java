package com.example.qnuquiz.dto.questions;

import java.util.List;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class IdsRequest {

    private List<Long> ids;
}
