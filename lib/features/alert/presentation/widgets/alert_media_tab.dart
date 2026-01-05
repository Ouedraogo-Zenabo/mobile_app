import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

/// ============================================================
/// ONGLET MÉDIAS — VERSION STABLE & WEB SAFE
/// ============================================================

class AlertMediaTab extends StatefulWidget {
  final List<PlatformFile>? initialMedias;
  final bool canEdit; // 👈 IMPORTANT
  const AlertMediaTab({
    super.key,
    this.initialMedias,
    this.canEdit = true,
  });


  @override
  State<AlertMediaTab> createState() => _AlertMediaTabState();
}

class _AlertMediaTabState extends State<AlertMediaTab>
    with AutomaticKeepAliveClientMixin {
  final List<PlatformFile> _medias = [];
  List<PlatformFile> get newMedias =>
    _medias.where((m) => !_isRemoteMedia(m)).toList();

  List<String> get existingMediaUrls =>
    _medias
        .where(_isRemoteMedia)
        .map((m) => m.path!)
        .toList();


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.initialMedias != null) {
      _medias.addAll(widget.initialMedias!);
    }
  }

  /// ------------------------------------------------------------
  /// PICK MEDIA
  /// ------------------------------------------------------------
  Future<void> _pickMedia() async {
  if (!widget.canEdit) return;

  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.media,
    withData: kIsWeb,
  );

  if (result == null) return;

  setState(() {
    _medias.addAll(result.files);
  });
}


  bool _isVideo(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext);
  }

  bool _isRemoteMedia(PlatformFile file) {
  return file.path != null && file.path!.startsWith('http');
}


  /// ------------------------------------------------------------
  /// IMAGE PREVIEW SAFE (WEB + MOBILE)
  /// ------------------------------------------------------------
  Widget _buildImagePreview(PlatformFile media,
      {BoxFit fit = BoxFit.cover}) {
    if (kIsWeb) {
      if (media.bytes == null) {
        return const Center(child: Icon(Icons.broken_image));
      }
      return Image.memory(
        media.bytes as Uint8List,
        fit: fit,
      );
    } else {
      return Image.file(
        File(media.path!),
        fit: fit,
      );
    }
  }

  /// ------------------------------------------------------------
  /// SUPPRIMER
  /// ------------------------------------------------------------
  void _removeMedia(int index) {
    setState(() {
      _medias.removeAt(index);
    });
  }

  /// ------------------------------------------------------------
  /// VISUALISER
  /// ------------------------------------------------------------
  void _viewMedia(PlatformFile file) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: _isVideo(file)
            ? kIsWeb
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Icon(Icons.videocam, size: 80),
                  )
                : _VideoPlayerDialog(file: File(file.path!))
            : InteractiveViewer(
                child: _buildImagePreview(file, fit: BoxFit.contain),
              ),
      ),
    );
  }

  /// ------------------------------------------------------------
  /// TELECHARGER
  /// ------------------------------------------------------------
  Future<void> _downloadMedia(PlatformFile file) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Téléchargement non supporté sur Web")),
      );
      return;
    }

    final dir = await getDownloadsDirectory();
    if (dir == null) return;

    final newFile = File('${dir.path}/${file.name}');
    await File(file.path!).copy(newFile.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fichier téléchargé")),
    );
  }

  /// ------------------------------------------------------------
  /// UI
  /// ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final width = MediaQuery.of(context).size.width;
    final itemWidth = width < 600 ? width / 1.3 : 200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_medias.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _medias.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final media = _medias[index];

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: itemWidth.toDouble(),
                          color: Colors.grey.shade300,
                          child: _isVideo(media)
                              ? const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 50,
                                  ),
                                )
                              : _buildImagePreview(media),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<_MediaAction>(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white),
                          onSelected: (action) {
                            if (action == _MediaAction.view) {
                              _viewMedia(media);
                            } else if (action ==
                                _MediaAction.delete) {
                              _removeMedia(index);
                            } else {
                              _downloadMedia(media);
                            }
                          },
                          itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: _MediaAction.view,
                            child: ListTile(
                              leading: Icon(Icons.visibility),
                              title: Text("Visualiser"),
                            ),
                          ),
                            PopupMenuItem(
                              value: _MediaAction.download,
                              child: ListTile(
                                leading:
                                    Icon(Icons.download),
                                title: Text("Télécharger"),
                              ),
                            ),
                            if (!_isRemoteMedia(media))
                              const PopupMenuItem(
                                value: _MediaAction.delete,
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text("Supprimer"),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          if (widget.canEdit) ...[
          const SizedBox(height: 24),

          const Text(
            "Ajouter des médias",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: _pickMedia,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  const Icon(Icons.image_outlined, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "Glissez-déposez des photos ou vidéos",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _pickMedia,
                    child: const Text("Parcourir les fichiers"),
                  ),
                ],
              ),
            ),
          ),
        ],

        ],
      ),
    );
  }
}

/// ============================================================
/// VIDEO PLAYER DIALOG (MOBILE ONLY)
/// ============================================================
class _VideoPlayerDialog extends StatefulWidget {
  final File file;
  const _VideoPlayerDialog({required this.file});

  @override
  State<_VideoPlayerDialog> createState() =>
      _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
  }
}

enum _MediaAction { view, download, delete }
