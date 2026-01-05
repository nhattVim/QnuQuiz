import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:frontend/models/media_file_model.dart';

class MediaViewer extends StatefulWidget {
  final MediaFileModel media;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MediaViewer({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isAudioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    if (widget.media.fileUrl == null || widget.media.fileUrl!.isEmpty) {
      return;
    }

    final mimeType = widget.media.mimeType?.toLowerCase() ?? '';
    
    if (mimeType.startsWith('video/')) {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.media.fileUrl!),
        );
        await _videoController!.initialize();
        
        _videoController!.addListener(() {
          if (mounted) {
            setState(() {
              _isVideoPlaying = _videoController!.value.isPlaying;
            });
          }
        });
        
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing video: $e');
      }
    } else if (mimeType.startsWith('audio/')) {
      try {
        _audioPlayer = AudioPlayer();
        await _audioPlayer!.setUrl(widget.media.fileUrl!);
        _audioDuration = _audioPlayer!.duration ?? Duration.zero;
        
        _audioPlayer!.positionStream.listen((position) {
          if (mounted) {
            setState(() {
              _audioPosition = position;
            });
          }
        });
        
        _audioPlayer!.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isAudioPlaying = state.playing;
            });
          }
        });
        
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error initializing audio: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.fileUrl == null || widget.media.fileUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    final mimeType = widget.media.mimeType?.toLowerCase() ?? '';
    
    if (mimeType.startsWith('image/')) {
      return _buildImage(context);
    } else if (mimeType.startsWith('video/')) {
      return _buildVideo(context);
    } else if (mimeType.startsWith('audio/')) {
      return _buildAudio(context);
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.media.fileUrl!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildVideo(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black87,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isVideoInitialized && _videoController != null)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black54,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            
            if (_isVideoInitialized)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                        _isVideoPlaying = false;
                      } else {
                        _videoController!.play();
                        _isVideoPlaying = true;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.media.fileName ?? 'Video',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudio(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.audiotrack,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.media.fileName ?? 'Audio file',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.media.sizeBytes != null)
                      Text(
                        _formatFileSize(widget.media.sizeBytes!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isAudioPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 40,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  if (_audioPlayer == null) return;
                  
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    if (_isAudioPlaying) {
                      await _audioPlayer!.pause();
                    } else {
                      await _audioPlayer!.play();
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Lỗi phát audio: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          
          if (_audioDuration.inSeconds > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatDuration(_audioPosition),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _audioPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _audioDuration.inSeconds.toDouble(),
                    onChanged: (value) async {
                      if (_audioPlayer != null) {
                        await _audioPlayer!.seek(Duration(seconds: value.toInt()));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_audioDuration),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Không có media',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

