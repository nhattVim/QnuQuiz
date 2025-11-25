package com.example.qnuquiz;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class QnuQuizApplication {

	public static void main(String[] args) {
		SpringApplication.run(QnuQuizApplication.class, args);
	}

}
