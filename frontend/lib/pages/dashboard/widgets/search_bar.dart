import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _FullscreenSearchOverlay(onClose: () => Navigator.pop(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFullscreenSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Boxicons.bx_search, color: Colors.black54),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tìm kiếm câu hỏi',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenSearchOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const _FullscreenSearchOverlay({required this.onClose});

  @override
  State<_FullscreenSearchOverlay> createState() =>
      _FullscreenSearchOverlayState();
}

class _FullscreenSearchOverlayState extends State<_FullscreenSearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<String> _searchResults = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    // Ví dụ dữ liệu tìm kiếm (thay bằng API call thực tế)
    final allQuestions = [
      'Kỹ năng giao tiếp',
      'Quản lý thời gian',
      'Làm việc nhóm',
      'Giải quyết vấn đề',
      'Lập kế hoạch',
      'Tư duy phản biện',
    ];

    if (query.isEmpty) {
      setState(() => _searchResults = []);
    } else {
      setState(() {
        _searchResults = allQuestions
            .where((q) => q.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Boxicons.bx_arrow_back),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _performSearch,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm câu hỏi',
                      prefixIcon: const Icon(Boxicons.bx_search),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tìm kiếm',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Danh sách kết quả tìm kiếm
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _controller.text.isEmpty
                          ? 'Nhập để tìm kiếm'
                          : 'Không tìm thấy kết quả',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _searchResults[index],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            if (index < _searchResults.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Divider(
                                  color: Colors.grey.shade200,
                                  height: 1,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
