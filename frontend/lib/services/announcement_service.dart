import 'package:dio/dio.dart';
import 'package:frontend/constants/api_constants.dart';
import 'package:frontend/models/announcement_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:logger/logger.dart';

class AnnouncementService {
  final _log = Logger();
  final ApiService _apiService;

  AnnouncementService(this._apiService);

  Dio get _dio => _apiService.dio;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      // Lấy thông báo từ API teacher notifications
      final response = await _dio.get('${ApiConstants.teachers}/me/notifications');
      final data = response.data;
      
      if (data is Map && data.containsKey('examAnnouncements')) {
        final announcements = data['examAnnouncements'] as List;
        return announcements
            .map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi lấy danh sách thông báo',
      );
    }
  }

  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    required String target, // ALL, DEPARTMENT, CLASS
    int? classId,
    int? departmentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
        'content': content,
        'target': target,
      };
      
      if (target == 'CLASS' && classId != null) {
        data['classId'] = classId;
      } else if (target == 'DEPARTMENT' && departmentId != null) {
        data['departmentId'] = departmentId;
      }
      
      final response = await _dio.post(
        ApiConstants.announcements,
        data: data,
      );
      return AnnouncementModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _log.e(e.response?.data ?? e.message);
      throw Exception(
        e.response?.data?['message'] ?? 'Lỗi tạo thông báo',
      );
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.announcements}/$id');
      if (response.statusCode == 204 || response.statusCode == 200) {
        _log.i('Đã xóa thông báo với ID: $id');
      }
    } on DioException catch (e) {
      _log.e('Lỗi xóa thông báo: ${e.response?.data ?? e.message}');
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Lỗi xóa thông báo'
          : e.message ?? 'Lỗi xóa thông báo';
      throw Exception(errorMessage);
    } catch (e) {
      _log.e('Lỗi không xác định: $e');
      throw Exception('Lỗi xóa thông báo: ${e.toString()}');
    }
  }

  Future<void> deleteAllAnnouncements() async {
    try {
      final response = await _dio.delete('${ApiConstants.announcements}');
      if (response.statusCode == 204 || response.statusCode == 200) {
        _log.i('Đã xóa tất cả thông báo');
      }
    } on DioException catch (e) {
      _log.e('Lỗi xóa tất cả thông báo: ${e.response?.data ?? e.message}');
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Lỗi xóa tất cả thông báo'
          : e.message ?? 'Lỗi xóa tất cả thông báo';
      throw Exception(errorMessage);
    } catch (e) {
      _log.e('Lỗi không xác định: $e');
      throw Exception('Lỗi xóa tất cả thông báo: ${e.toString()}');
    }
  }
}

