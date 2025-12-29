import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exam_model.dart';
import 'package:frontend/providers/service_providers.dart';
import 'package:frontend/screens/exam/exam_list_screen.dart';
import 'package:frontend/utils/vietnamese_helper.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFullscreenSearch() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _FullscreenSearchOverlay(onClose: () => Navigator.pop(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _openFullscreenSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Boxicons.bx_search,
              color: colorScheme.onSurface.withValues(alpha: 0.54),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tìm kiếm bài thi',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenSearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const _FullscreenSearchOverlay({required this.onClose});

  @override
  ConsumerState<_FullscreenSearchOverlay> createState() =>
      _FullscreenSearchOverlayState();
}

class _FullscreenSearchOverlayState
    extends ConsumerState<_FullscreenSearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<ExamModel> _searchResults = [];
  List<ExamModel> _allExams = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAllExams();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Tải tất cả bài thi từ API
  Future<void> _loadAllExams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final examService = ref.read(examServiceProvider);
      final exams = await examService.getAllExams();
      setState(() {
        _allExams = exams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Tìm kiếm trong danh sách bài thi đã tải
  void _performSearch(String query) {
    // Debounce để tránh tìm kiếm quá nhiều
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        setState(() => _searchResults = []);
      } else {
        setState(() {
          _searchResults = _allExams.where((exam) {
            return VietnameseHelper.containsIgnoreTones(exam.title, query) ||
                VietnameseHelper.containsIgnoreTones(exam.description, query);
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          // Header với search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(
                    Boxicons.bx_arrow_back,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _performSearch,
                    autofocus: true,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bài thi',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Boxicons.bx_search,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              onPressed: () {
                                _controller.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    final query = _controller.text.trim();
                    if (query.isNotEmpty) {
                      // Đóng search overlay
                      widget.onClose();

                      // Navigate đến ExamListScreen với search query
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExamListScreen(searchQuery: query),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Tìm kiếm',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Hiển thị trạng thái loading hoặc lỗi
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải dữ liệu',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadAllExams,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          // Danh sách kết quả tìm kiếm
          else
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _controller.text.isEmpty
                                ? Boxicons.bx_search
                                : Icons.search_off,
                            size: 48,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _controller.text.isEmpty
                                ? 'Nhập để tìm kiếm bài thi'
                                : 'Không tìm thấy kết quả',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 14,
                            ),
                          ),
                          if (_controller.text.isEmpty &&
                              _allExams.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Có ${_allExams.length} bài thi sẵn sàng',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final exam = _searchResults[index];
                        return _buildExamSearchItem(exam, index, colorScheme);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildExamSearchItem(
    ExamModel exam,
    int index,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        // Đóng search overlay
        widget.onClose();

        // Navigate đến trang danh sách bài thi của category này
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamListScreen(categoryId: exam.categoryId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      exam.computedStatus,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: _getStatusColor(exam.computedStatus),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exam.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      exam.computedStatus,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(exam.computedStatus),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(exam.computedStatus),
                    ),
                  ),
                ),
              ],
            ),
            if (index < _searchResults.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  height: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'unopened':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Đang mở';
      case 'unopened':
        return 'Chưa mở';
      case 'closed':
        return 'Đã đóng';
      default:
        return 'Không rõ';
    }
  }
}
