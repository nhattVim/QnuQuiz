package com.example.qnuquiz.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.qnuquiz.entity.Faqs;

public interface FaqRepository extends JpaRepository<Faqs, Long> {

}
