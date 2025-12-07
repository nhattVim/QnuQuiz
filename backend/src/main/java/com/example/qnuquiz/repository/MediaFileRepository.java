package com.example.qnuquiz.repository;

import com.example.qnuquiz.entity.MediaFiles;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MediaFileRepository extends JpaRepository<MediaFiles, Long> {
    List<MediaFiles> findByRelatedTableAndRelatedId(String relatedTable, String relatedId);
    Optional<MediaFiles> findByFileUrl(String fileUrl);
    void deleteByRelatedTableAndRelatedId(String relatedTable, String relatedId);
}

