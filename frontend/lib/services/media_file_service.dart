import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/constants/appwrite_constants.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/appwrite_service.dart';
import 'package:logger/logger.dart';

/// Service for managing media files (images, videos, audio)
/// Handles file upload to Appwrite and metadata storage in backend
class MediaFileService {
  final _log = Logger();
  final ApiService _apiService;
  final AppwriteService _appwriteService;

  MediaFileService(this._apiService, this._appwriteService);

  Dio get _dio => _apiService.dio;

  /// Upload file to Appwrite and save metadata to backend
  /// 
  /// [file] - The file to upload
  /// [questionId] - ID of the question this file is associated with
  /// [description] - Optional description for the file
  /// 
  /// Returns the created MediaFileDto from backend
  /// 
  /// Throws [AppwriteException] if Appwrite upload fails
  /// Throws [DioException] if backend save fails
  Future<Map<String, dynamic>> uploadAndSaveMediaFile({
    required File file,
    required int questionId,
    String? description,
  }) async {
    try {
      // Step 1: Upload file to Appwrite
      _log.i('Step 1: Uploading file to Appwrite...');
      final fileUrl = await _appwriteService.uploadFile(
        file: file,
      );
      _log.i('File uploaded to Appwrite successfully: $fileUrl');

      // Step 2: Get file info
      // Use path.basename to handle both Windows (\) and Unix (/) paths
      final fileName = path.basename(file.path);
      final fileSize = await file.length();
      final mimeType = _getMimeType(fileName);
      
      _log.d('File info - Name: $fileName, Size: $fileSize bytes, MIME: $mimeType');

      // Step 3: Save metadata to backend
      _log.i('Step 2: Saving media file metadata to backend...');
      // Ensure fileUrl is a string before sending to backend
      final fileUrlString = fileUrl.toString();
      _log.d('File URL type: ${fileUrlString.runtimeType}, value: $fileUrlString');
      
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/api/media-files',
        data: {
          'fileUrl': fileUrlString,
          'fileName': fileName,
          'mimeType': mimeType,
          'sizeBytes': fileSize,
          'questionId': questionId,
          'description': description,
        },
      );

      _log.i('Media file saved successfully. ID: ${response.data['id']}');
      return response.data as Map<String, dynamic>;
    } on AppwriteException catch (e) {
      _log.e('Appwrite error: ${e.message} (Code: ${e.code})');
      // Check for platform registration error
      if (_isPlatformRegistrationError(e)) {
        throw Exception(
          'Lỗi: Platform chưa được đăng ký trong Appwrite Dashboard.\n\n'
          'Vui lòng đăng ký platform:\n'
          '1. Vào Appwrite Console > Settings > Platforms\n'
          '2. Click "Add Platform" > Chọn platform tương ứng (Windows/Linux/Android/iOS)\n'
          '3. Nhập tên và tạo platform\n\n'
          'Xem hướng dẫn chi tiết trong file: APPWRITE_PLATFORM_SETUP.md'
        );
      }
      throw Exception('Lỗi Appwrite: ${e.message ?? "Unknown error"}');
    } on DioException catch (e) {
      _log.e('Backend error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data?['message'] ?? 'Lỗi lưu thông tin file vào backend');
    } catch (e) {
      _log.e('Unexpected error: $e');
      rethrow;
    }
  }

  /// Upload file from file picker (cross-platform)
  /// 
  /// [questionId] - ID of the question this file is associated with
  /// [description] - Optional description for the file
  /// 
  /// Returns the created MediaFileDto from backend
  /// 
  /// Throws [Exception] if file picker is cancelled or file is invalid
  /// Throws [AppwriteException] if Appwrite upload fails
  /// Throws [DioException] if backend save fails
  Future<Map<String, dynamic>> uploadMediaFileFromPicker({
    required int questionId,
    String? description,
  }) async {
    try {
      _log.d('Opening file picker...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'webm', 'mp3', 'wav'],
      );

      if (result == null || result.files.isEmpty) {
        _log.w('File picker cancelled or no file selected');
        throw Exception('Không có file được chọn');
      }

      final platformFile = result.files.single;
      
      if (platformFile.path == null) {
        _log.e('Platform file path is null');
        throw Exception('Không thể đọc đường dẫn file');
      }

      final file = File(platformFile.path!);
      
      // Validate file size
      final fileSize = await file.length();
      if (fileSize > AppwriteConstants.maxVideoSize) {
        const maxSizeMB = AppwriteConstants.maxVideoSize ~/ (1024 * 1024);
        _log.w('File too large: $fileSize bytes (max: ${AppwriteConstants.maxVideoSize} bytes)');
        throw Exception('File quá lớn. Tối đa $maxSizeMB MB');
      }

      _log.i('File selected: ${platformFile.name} ($fileSize bytes)');
      return await uploadAndSaveMediaFile(
        file: file,
        questionId: questionId,
        description: description,
      );
    } on AppwriteException catch (e) {
      _log.e('Appwrite error: ${e.message} (Code: ${e.code})');
      if (_isPlatformRegistrationError(e)) {
        throw Exception(
          'Lỗi: Platform chưa được đăng ký trong Appwrite Dashboard.\n\n'
          'Vui lòng đăng ký platform:\n'
          '1. Vào Appwrite Console > Settings > Platforms\n'
          '2. Click "Add Platform" > Chọn platform tương ứng (Windows/Linux/Android/iOS)\n'
          '3. Nhập tên và tạo platform\n\n'
          'Xem hướng dẫn chi tiết trong file: APPWRITE_PLATFORM_SETUP.md'
        );
      }
      throw Exception('Lỗi Appwrite: ${e.message ?? "Unknown error"}');
    } catch (e) {
      _log.e('Error picking/uploading file: $e');
      rethrow;
    }
  }

  /// Get media files by question ID
  /// 
  /// [questionId] - ID of the question
  /// 
  /// Returns list of media file metadata
  /// 
  /// Throws [DioException] if request fails
  Future<List<Map<String, dynamic>>> getMediaFilesByQuestionId(int questionId) async {
    try {
      _log.d('Fetching media files for question: $questionId');
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/media-files/question/$questionId',
      );
      
      if (response.data is List) {
        final files = (response.data as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _log.d('Found ${files.length} media files for question $questionId');
        return files;
      }
      _log.w('Unexpected response format: ${response.data.runtimeType}');
      return [];
    } on DioException catch (e) {
      _log.e('Error getting media files: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data?['message'] ?? 'Lỗi lấy danh sách file');
    }
  }

  /// Delete media file by ID
  /// 
  /// [mediaFileId] - ID of the media file to delete
  /// 
  /// Throws [DioException] if deletion fails
  Future<void> deleteMediaFile(int mediaFileId) async {
    try {
      _log.d('Deleting media file: $mediaFileId');
      await _dio.delete(
        '${ApiConstants.baseUrl}/api/media-files/$mediaFileId',
      );
      _log.i('Media file deleted successfully: $mediaFileId');
    } on DioException catch (e) {
      _log.e('Error deleting media file: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data?['message'] ?? 'Lỗi xóa file');
    }
  }

  /// Delete all media files for a question
  /// 
  /// [questionId] - ID of the question
  /// 
  /// Throws [DioException] if deletion fails
  Future<void> deleteMediaFilesByQuestionId(int questionId) async {
    try {
      _log.d('Deleting all media files for question: $questionId');
      await _dio.delete(
        '${ApiConstants.baseUrl}/api/media-files/question/$questionId',
      );
      _log.i('All media files deleted for question: $questionId');
    } on DioException catch (e) {
      _log.e('Error deleting media files: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data?['message'] ?? 'Lỗi xóa files');
    }
  }

  /// Check if AppwriteException is related to platform registration
  bool _isPlatformRegistrationError(AppwriteException e) {
    return e.message?.contains('Invalid Origin') == true || 
           e.message?.contains('unknown_origin') == true ||
           e.code == 403;
  }

  /// Get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }
}

