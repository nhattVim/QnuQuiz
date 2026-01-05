import 'package:flutter/material.dart';
import 'package:frontend/models/media_file_model.dart';
import 'package:frontend/widgets/media/media_viewer.dart';

class MediaListViewer extends StatelessWidget {
  final List<MediaFileModel> mediaFiles;
  final bool showDeleteButton;
  final Function(MediaFileModel)? onDelete;

  const MediaListViewer({
    super.key,
    required this.mediaFiles,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Media files (${mediaFiles.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...mediaFiles.map((media) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMediaCard(context, media),
            )),
      ],
    );
  }

  Widget _buildMediaCard(BuildContext context, MediaFileModel media) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: MediaViewer(
              media: media,
              width: double.infinity,
              height: 200,
            ),
          ),
          // Media info and actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media.fileName ?? 'Unknown file',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (media.mimeType != null)
                        Text(
                          media.mimeType!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (showDeleteButton && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => onDelete!(media),
                    tooltip: 'Xóa file',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

