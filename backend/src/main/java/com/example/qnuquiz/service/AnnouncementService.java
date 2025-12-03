package com.example.qnuquiz.service;

import com.example.qnuquiz.dto.announcement.AnnouncementDto;
import com.example.qnuquiz.dto.announcement.CreateAnnouncementDto;

public interface AnnouncementService {
    
    AnnouncementDto createAnnouncement(CreateAnnouncementDto dto);
    
    void deleteAnnouncement(Long id);
    
    void deleteAllAnnouncements();
}

