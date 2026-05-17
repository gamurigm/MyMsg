import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_msg/domain/entities/message.dart';
import 'package:my_msg/main.dart';
import 'package:my_msg/data/datasources/chat_remote_data_source.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  static const _neonCyan = Color(0xFF00E5FF);
  static const _darkBg = Color(0xFF121820);

  bool _isImage(String url) {
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  bool _isPdf(String url) => url.toLowerCase().endsWith('.pdf');

  String _fileExtension(String url) {
    final name = url.split('/').last.split('?').first;
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
  }

  IconData _iconForFile(String url) {
    final ext = _fileExtension(url).toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc', 'docx'].contains(ext)) return Icons.description_rounded;
    if (['xls', 'xlsx', 'csv'].contains(ext)) return Icons.table_chart_rounded;
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) return Icons.folder_zip_rounded;
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return Icons.videocam_rounded;
    if (['mp3', 'wav', 'ogg', 'm4a'].contains(ext)) return Icons.audiotrack_rounded;
    if (ext == 'txt') return Icons.text_snippet_rounded;
    if (ext == 'md') return Icons.article_rounded;
    if (['js', 'ts', 'py', 'dart', 'go', 'java', 'kt', 'swift', 'cpp', 'c', 'h'].contains(ext)) return Icons.code_rounded;
    if (['ppt', 'pptx'].contains(ext)) return Icons.slideshow_rounded;
    if (['apk', 'ipa', 'exe'].contains(ext)) return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _colorForFile(String url) {
    final ext = _fileExtension(url).toLowerCase();
    if (ext == 'pdf') return const Color(0xFFFF5252);
    if (['doc', 'docx'].contains(ext)) return const Color(0xFF2979FF);
    if (['xls', 'xlsx', 'csv'].contains(ext)) return const Color(0xFF00C853);
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) return const Color(0xFFFF6D00);
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return const Color(0xFFAA00FF);
    if (['mp3', 'wav', 'ogg', 'm4a'].contains(ext)) return const Color(0xFFFF6F00);
    if (ext == 'txt') return const Color(0xFFB0BEC5);
    if (ext == 'md') return const Color(0xFF80CBC4);
    if (['js', 'ts', 'py', 'dart', 'go', 'java', 'kt', 'swift', 'cpp', 'c', 'h'].contains(ext)) return const Color(0xFFFFD740);
    if (['ppt', 'pptx'].contains(ext)) return const Color(0xFFFF6E40);
    if (['apk', 'ipa', 'exe'].contains(ext)) return const Color(0xFF69F0AE);
    return _neonCyan;
  }

  Future<void> _downloadFile(BuildContext context, String url, String fileName) async {
    try {
      if (Platform.isAndroid) {
        // En Android 11+ (API 30+), Permission.storage suele fallar o ser insuficiente para carpetas globales.
        // Primero intentamos el normal, si no, pedimos el especial.
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          // Si estamos en Android 11+, pedimos MANAGE_EXTERNAL_STORAGE
          var manageStatus = await Permission.manageExternalStorage.status;
          if (!manageStatus.isGranted) {
            manageStatus = await Permission.manageExternalStorage.request();
          }
          
          if (!manageStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              _snackBar('⚠️ Permiso de almacenamiento denegado. Por favor acéptalo en Ajustes.', isError: true),
            );
            return;
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('⬇️ Descargando $fileName...'),
      );

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('❌ Error al descargar (${response.statusCode})', isError: true),
        );
        return;
      }

      Directory dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('✅ Guardado en Descargas/$fileName'),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('❌ Error: $e', isError: true),
      );
    }
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  SnackBar _snackBar(String msg, {bool isError = false}) {
    return SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? const Color(0xFFB71C1C) : const Color(0xFF121820),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isError ? const Color(0xFFFF5252) : _neonCyan, width: 1),
      ),
    );
  }

  // ── Widget: vista previa de imagen ──────────────────────────────────────────
  Widget _buildImagePreview(BuildContext context, String url, String fileName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openInBrowser(url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 160,
                      color: Colors.black38,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                          color: _neonCyan,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded, color: Colors.white54, size: 40),
                          SizedBox(height: 6),
                          Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Ver', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildDownloadRow(context, url, fileName, color: _neonCyan),
      ],
    );
  }

  // ── Widget: tarjeta de archivo genérico / PDF ──────────────────────────────
  Widget _buildFileCard(BuildContext context, String url, String fileName) {
    final fileColor = _colorForFile(url);
    final ext = _fileExtension(url);
    return GestureDetector(
      onTap: () => _downloadFile(context, url, fileName),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E14).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fileColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: fileColor.withOpacity(0.15), blurRadius: 12, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: fileColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fileColor.withOpacity(0.3)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(_iconForFile(url), color: fileColor, size: 28),
                  Positioned(
                    bottom: 4, right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        color: fileColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(ext, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Botón VER
                      GestureDetector(
                        onTap: () => _openInBrowser(url),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: fileColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: fileColor.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_rounded, color: fileColor, size: 14),
                              const SizedBox(width: 4),
                              Text('VER', style: TextStyle(color: fileColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón DESCARGAR
                      GestureDetector(
                        onTap: () => _downloadFile(context, url, fileName),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.file_download_outlined, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('BAJAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadRow(BuildContext context, String url, String fileName, {Color color = _neonCyan}) {
    return GestureDetector(
      onTap: () => _downloadFile(context, url, fileName),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.file_download_outlined, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            'Descargar imagen',
            style: TextStyle(color: color, fontSize: 12, decoration: TextDecoration.underline),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restUrl = sl<ChatRemoteDataSource>().restUrl;
    final fullFileUrl = message.fileUrl != null ? '$restUrl${message.fileUrl}' : null;
    final fileName = message.fileUrl?.split('/').last ?? 'archivo';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 5),
            bottomRight: Radius.circular(isMe ? 5 : 20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? _neonCyan.withOpacity(0.9) : _darkBg.withOpacity(0.85),
                border: Border.all(
                  color: isMe ? Colors.white.withOpacity(0.3) : _neonCyan.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        message.senderId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B8D4),
                        ),
                      ),
                    ),

                  // ── Contenido principal ──────────────────────────────────
                  if (message.isFile && fullFileUrl != null)
                    _isImage(fullFileUrl)
                        ? _buildImagePreview(context, fullFileUrl, fileName)
                        : _buildFileCard(context, fullFileUrl, fileName)
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                        fontSize: 15,
                        fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),

                  const SizedBox(height: 4),
                  Text(
                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
