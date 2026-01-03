import 'package:flutter/material.dart';
import 'package:frontend/models/media_file_model.dart';
import 'package:frontend/widgets/media/media_viewer.dart';

class QuizQuestion extends StatefulWidget {
  final String questionText;
  final String? imageUrl; // Deprecated: Use mediaFiles instead
  final List<MediaFileModel>? mediaFiles;

  const QuizQuestion({
    super.key,
    required this.questionText,
    this.imageUrl,
    this.mediaFiles,
  });

  @override
  State<QuizQuestion> createState() => _QuizQuestionState();
}

class _QuizQuestionState extends State<QuizQuestion> {
  int _currentMediaIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaList = widget.mediaFiles ?? [];
    final hasMedia = mediaList.isNotEmpty || widget.imageUrl != null;
    final hasMultipleMedia = mediaList.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.questionText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 16),

        if (hasMedia && mediaList.isNotEmpty)
          _buildMediaCarousel(mediaList, hasMultipleMedia)
        else if (widget.imageUrl != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultImage();
                },
              ),
            ),
          )
        else
          _buildDefaultImage(),
      ],
    );
  }

  Widget _buildMediaCarousel(
    List<MediaFileModel> mediaList,
    bool hasMultipleMedia,
  ) {
    return Stack(
      children: [
        MediaViewer(
          media: mediaList[_currentMediaIndex],
          width: double.infinity,
          height: 200,
        ),

        if (hasMultipleMedia)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentMediaIndex > 0)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentMediaIndex--;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 40),

                if (_currentMediaIndex < mediaList.length - 1)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentMediaIndex++;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),

        if (hasMultipleMedia)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaList.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentMediaIndex == index
                        ? Colors.white
                        : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultImage() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Câu hỏi không có media',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
