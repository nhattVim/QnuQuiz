import 'package:flutter/material.dart';
import 'package:frontend/models/faq_model.dart';
import 'package:frontend/services/faq_service.dart';
import 'package:frontend/services/api_service.dart';
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  late Future<List<FaqDto>> _faqFuture;
  late FaqService _faqService;
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _faqService = FaqService(ApiService());
    _faqFuture = _faqService.getAllFaqs();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Câu hỏi thường gặp'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.help_outline, size: 60, color: Colors.blue),
                  SizedBox(height: 12),
                  Text(
                    'Câu hỏi thường gặp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// SEARCH BOX
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm câu hỏi...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                              _faqFuture =
                                  _faqService.getAllFaqs();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isEmpty) return;
                  setState(() {
                    _isSearching = true;
                    _faqFuture =
                        _faqService.searchFaq(value.trim());
                  });
                },
              ),
            ),

            const SizedBox(height: 12),

            /// LIST FAQ
            Expanded(
              child: FutureBuilder<List<FaqDto>>(
                future: _faqFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Không thể tải FAQ'));
                  }

                  final faqs = snapshot.data!;

                  if (faqs.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy câu hỏi'),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: faqs.length,
                    itemBuilder: (context, index) {
                      final faq = faqs[index];
                      return ExpansionTile(
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(faq.answer),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
