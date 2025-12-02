package com.example.qnuquiz.service;

import com.example.qnuquiz.dto.announcement.AnnouncementDto;
import com.example.qnuquiz.dto.announcement.CreateAnnouncementDto;

public interface AnnouncementService {
    
    AnnouncementDto createAnnouncementForClass(CreateAnnouncementDto dto);
    
    void deleteAnnouncement(Long id);
    
    void deleteAllAnnouncements();
}

