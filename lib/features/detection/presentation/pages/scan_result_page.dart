
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:true_vision/core/responsive/app_responsive.dart';
// import 'package:true_vision/features/detection/core/detection_theme.dart';
// import 'package:true_vision/features/detection/core/detection_media_type.dart';
// import 'package:true_vision/features/detection/presentation/widgets/detection_app_bar.dart';
// import 'package:true_vision/features/detection/presentation/widgets/detection_bottom_nav.dart';
// import 'package:true_vision/features/detection/presentation/widgets/video_info_card.dart';
//
// import '../../../../core/theme/app_colors.dart';
//
// class ScanResultPage extends StatelessWidget {
//   const ScanResultPage({
//     super.key,
//     required this.result,
//     required this.file,
//     required this.mediaType,
//   });
//
//   final Map<String, dynamic> result;
//   final File file;
//   final DetectionMediaType mediaType;
//
//   @override
//   Widget build(BuildContext context) {
//
//     final Map<String, dynamic> data = result['result'] is Map ?
//     result['result'] : (result['Response body'] ?? result);
//     final String label = (data['result'] ?? data['label'] ??
//         data['predicted_label'] ?? 'Unknown').toString();
//     final String? heatmapBase64 = data['visual_result'];
//     final String? heatmapUrl = data['heatmap_url'];
//
//     double parseValue(dynamic val) {
//       if (val == null) return 0.0;
//       String cleanVal = val.toString().replaceAll('%', '').trim();
//       return double.tryParse(cleanVal) ?? 0.0;
//     }
//
//     double realValueRaw = parseValue(data['real_percentage'] ??
//         data['real_prob'] ?? data['real_probability']);
//     double fakeValueRaw = parseValue(data['fake_percentage'] ??
//         data['fake_prob'] ?? data['fake_probability']);
//
//     if (realValueRaw > 1.0) realValueRaw /= 100;
//     if (fakeValueRaw > 1.0) fakeValueRaw /= 100;
//
//     final String realPercentStr = "${(realValueRaw * 100).
//     toStringAsFixed(1)}%";
//     final String fakePercentStr = "${(fakeValueRaw * 100).
//     toStringAsFixed(1)}%";
//
//     final Color resultColor = label.toLowerCase().contains('fake') ?
//     DetectionTheme.cancelRed : Colors.greenAccent;
//
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: AppColors.navy500),
//       child: Scaffold(
//         backgroundColor: AppColors.navy500,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(AppResponsive.hp(context, 10)),
//           child: Padding(
//             padding: EdgeInsets.only(top: AppResponsive.hp(context, 3)),
//             child: DetectionAppBar(title: 'Scan Result', onBack: () => Navigator.of(context).pop(), trailingIcon: Icons.info_outline_rounded),
//           ),
//         ),
//         body: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.symmetric(horizontal: AppResponsive.wp(context, 4)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: AppResponsive.hp(context, 3)),
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   decoration: BoxDecoration(color: resultColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: resultColor, width: 1.5)),
//                   child: Text(label.toUpperCase(), style: TextStyle(color: resultColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
//                 ),
//               ),
//               SizedBox(height: AppResponsive.hp(context, 3)),
//
//               VideoInfoCard(
//                 fileName: file.path.split('/').last,
//                 scannedAt: 'Today at ${TimeOfDay.now().format(context)}',
//                 duration: mediaType == DetectionMediaType.image ? 'Static Image'
//                     : (mediaType == DetectionMediaType.video ? 'Video Content'
//                     : 'Audio Stream'),
//                 size: '${(file.lengthSync() / (1024 * 1024)).
//                 toStringAsFixed(2)} MB',
//                 mediaType: mediaType,
//               ),
//               SizedBox(height: AppResponsive.hp(context, 2)),
//               _buildMediaPreview(context, heatmapBase64, heatmapUrl),
//               SizedBox(height: AppResponsive.hp(context, 2.5)),
//               Row(
//                 children: [
//                   Expanded(child: _buildConfidenceBox("AI Fake",
//                       fakePercentStr, DetectionTheme.cancelRed)),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildConfidenceBox("Real Human",
//                       realPercentStr, Colors.greenAccent)),
//                 ],),
//               SizedBox(height: AppResponsive.hp(context, 3)),
//               _buildActionButtons(label, realPercentStr, fakePercentStr),
//               const SizedBox(height: 24),
//               Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
//               const SizedBox(height: 16),
//               const Text('Deepfake Probability Details', style:
//               TextStyle(color: DetectionTheme.primaryLight, fontSize: 16, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(mediaType == DetectionMediaType.image ?
//                   'Image Manipulation Analysis' : (mediaType == DetectionMediaType.video ?
//                   'Temporal Frame Analysis' : 'Voice Synthesis Analysis'), style:
//                   TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
//                   Text(label.toLowerCase().contains('fake') ? fakePercentStr :
//                   realPercentStr, style: TextStyle(color: resultColor, fontSize: 15, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(999),
//                 child: LinearProgressIndicator(value: label.toLowerCase().contains('fake') ? (fakeValueRaw) : (realValueRaw), minHeight: 10, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(resultColor)),
//               ),
//               const SizedBox(height: 6),
//               Align(alignment: Alignment.centerRight, child: Text(label.toLowerCase().contains('fake') ? 'FAKE' : 'REAL', style: TextStyle(color: label.toLowerCase().contains('fake') ? DetectionTheme.cancelRed.withValues(alpha: 0.6) : Colors.greenAccent.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.2))),
//               SizedBox(height: AppResponsive.hp(context, 10)),
//             ],
//           ),
//         ),
//         bottomNavigationBar: const BottomNav(activePage: 'scan'),
//       ),
//     );
//   }
//
//   Widget _buildMediaPreview(BuildContext context, String? heatmapBase64, String? heatmapUrl) {
//     if (mediaType == DetectionMediaType.audio) {
//       return _AudioPlayerWidget(audioFile: file);
//     }
//     if (mediaType == DetectionMediaType.video) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Video Preview", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           FutureBuilder<Uint8List?>(
//             future: VideoThumbnail.thumbnailData(video: file.path, imageFormat: ImageFormat.JPEG, maxWidth: 500, quality: 85),
//             builder: (context, snapshot) {
//               return _buildImageCard(context, snapshot.hasData ? Stack(alignment: Alignment.center, children: [Image.memory(snapshot.data!, fit: BoxFit.contain, width: double.infinity), const Icon(Icons.play_circle_outline, color: Colors.white70, size: 60)]) : const Center(child: Icon(Icons.video_library, color: Colors.white24, size: 50)));
//             },
//           ),
//         ],
//       );
//     }
//     return Column(
//       children: [
//         _buildImageCard(context, Image.file(file, fit: BoxFit.contain)),
//         if (heatmapUrl != null || heatmapBase64 != null) ...[
//           const SizedBox(height: 16),
//           const Align(alignment: Alignment.center, child: Text('Visual Analysis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
//           const SizedBox(height: 8),
//           _buildImageCard(context, heatmapUrl != null ? Image.network(heatmapUrl, fit: BoxFit.contain) : Image.memory(base64Decode(heatmapBase64!), fit: BoxFit.contain)),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildImageCard(BuildContext context, Widget imageWidget) {
//     return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black26, border: Border.all(color: Colors.white10, width: 1.2)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: SizedBox(width: double.infinity, height: AppResponsive.hp(context, 25), child: imageWidget)));
//   }
//
//   Widget _buildConfidenceBox(String title, String percent, Color color) {
//     return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: DetectionTheme.cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)), child: Column(children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 4), Text(percent, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))]));
//   }
//
//   Widget _buildActionButtons(String labelText, String realP, String fakeP) {
//     return Column(children: [
//       SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { Share.share('🛡️ TrueVision AI Result:\n📁 File: ${file.path.split('/').last}\n🎯 Verdict: ${labelText.toUpperCase()}\n📊 Confidence: $realP Real / $fakeP Fake'); }, icon: const Icon(Icons.share_rounded, size: 20), label: const Text('Share Result'), style: ElevatedButton.styleFrom(backgroundColor: DetectionTheme.primaryLight, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//       const SizedBox(height: 12),
//       SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 20, color: DetectionTheme.textOnDark), label: const Text('Download Full Report', style: TextStyle(color: DetectionTheme.textOnDark, fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: DetectionTheme.downloadBorder, width: 1.2), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
//     ]);
//   }
// }
//
//
// class _AudioPlayerWidget extends StatefulWidget {
//   const _AudioPlayerWidget({required this.audioFile});
//   final File audioFile;
//   @override
//   State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
// }
//
// class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> with TickerProviderStateMixin {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
//     _audioPlayer.onPlayerComplete.listen((_) {
//       if (mounted) {
//         setState(() {
//           isPlaying = false;
//           _animationController.stop();
//           _animationController.value = 0;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 120,
//       decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
//       child: Row(
//         children: [
//           const SizedBox(width: 20),
//           GestureDetector(
//             onTap: () async {
//               if (isPlaying) {
//                 await _audioPlayer.pause();
//                 _animationController.stop();
//               } else {
//                 await _audioPlayer.play(DeviceFileSource(widget.audioFile.path));
//                 _animationController.repeat(reverse: true);
//               }
//               setState(() => isPlaying = !isPlaying);
//             },
//             child: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 56, color: DetectionTheme.primaryLight),
//           ),
//           const SizedBox(width: 16),
//           const Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Audio Analyzed", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 4),
//                 Text("Click to play sample", style: TextStyle(color: Colors.white60, fontSize: 12)),
//               ],
//             ),
//           ),
//           _AnimatedWaveform(isAnimating: isPlaying, controller: _animationController),
//           const SizedBox(width: 20),
//         ],
//       ),
//     );
//   }
// }
//
// class _AnimatedWaveform extends StatelessWidget {
//   final bool isAnimating;
//   final AnimationController controller;
//   const _AnimatedWaveform({required this.isAnimating, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: List.generate(9, (index) {
//             double pulse = isAnimating ? (0.3 + 0.7 * (index % 2 == 0 ? controller.value : 1 - controller.value)) : 0.2;
//             final List<double> heights = [20, 35, 25, 45, 55, 45, 25, 35, 20];
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 50),
//               margin: const EdgeInsets.symmetric(horizontal: 2.5),
//               width: 3.5,
//               height: heights[index] * pulse,
//               decoration: BoxDecoration(
//                 color: isAnimating ? DetectionTheme.primaryLight : Colors.white10,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart'; // إضافة حزمة الحفظ
import 'package:true_vision/core/responsive/app_responsive.dart';
import 'package:true_vision/features/detection/core/detection_theme.dart';
import 'package:true_vision/features/detection/core/detection_media_type.dart';
import 'package:true_vision/features/detection/presentation/widgets/detection_app_bar.dart';
import 'package:true_vision/features/detection/presentation/widgets/detection_bottom_nav.dart';
import 'package:true_vision/features/detection/presentation/widgets/video_info_card.dart';

import '../../../../core/theme/app_colors.dart';

class ScanResultPage extends StatefulWidget {
  const ScanResultPage({
    super.key,
    required this.result,
    this.file, // خليناه اختياري عشان لو جايين من الهيستوري والملف الأصلي مش متاح كـ File object
    required this.mediaType,
    this.savedFilePath, // مسار الملف النصي المخزن كدعم بديل للهيستوري
  });

  final Map<String, dynamic> result;
  final File? file;
  final DetectionMediaType mediaType;
  final String? savedFilePath;

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  @override
  void initState() {
    super.initState();
    // لو الفحص ده لسه حاصل جديد (يعني مش جايين بيه من شاشة الهيستوري)، احفظه تلقائياً فوراً
    if (widget.savedFilePath == null && widget.file != null) {
      _saveToHistory();
    }
  }

  // دالة الحفظ التلقائي في الخلفية بدون التأثير على الـ UI
  Future<void> _saveToHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> currentHistory = prefs.getStringList('true_vision_history_key') ?? [];

      final newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'result': widget.result,
        'mediaType': widget.mediaType.toString(), // حفظ الـ Enum كـ String
        'filePath': widget.file!.path,
        'timestamp': DateTime.now().toIso8601String(),
        'fileSize': '${(widget.file!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
      };

      currentHistory.insert(0, jsonEncode(newItem));
      await prefs.setStringList('true_vision_history_key', currentHistory);
    } catch (e) {
      debugPrint("Error saving history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // كل الكود القديم بتاعك الخاص بحساب الداتا والنسب يظل كما هو تماماً بدون تعديل
    final Map<String, dynamic> data = widget.result['result'] is Map ?
    widget.result['result'] : (widget.result['Response body'] ?? widget.result);

    final String label = (data['result'] ?? data['label'] ??
        data['predicted_label'] ?? 'Unknown').toString();
    final String? heatmapBase64 = data['visual_result'];
    final String? heatmapUrl = data['heatmap_url'];

    double parseValue(dynamic val) {
      if (val == null) return 0.0;
      String cleanVal = val.toString().replaceAll('%', '').trim();
      return double.tryParse(cleanVal) ?? 0.0;
    }

    double realValueRaw = parseValue(data['real_percentage'] ??
        data['real_prob'] ?? data['real_probability']);
    double fakeValueRaw = parseValue(data['fake_percentage'] ??
        data['fake_prob'] ?? data['fake_probability']);

    if (realValueRaw > 1.0) realValueRaw /= 100;
    if (fakeValueRaw > 1.0) fakeValueRaw /= 100;

    final String realPercentStr = "${(realValueRaw * 100).toStringAsFixed(1)}%";
    final String fakePercentStr = "${(fakeValueRaw * 100).toStringAsFixed(1)}%";

    final Color resultColor = label.toLowerCase().contains('fake') ?
    DetectionTheme.cancelRed : Colors.greenAccent;

    // استخراج اسم الملف وحجمه بشكل آمن يدعم الهيستوري والملفات المرفوعة
    final String fullPath = widget.file?.path ?? widget.savedFilePath ?? '/Unknown_file';
    final String fileName = fullPath.split('/').last;

    String fileSize = '0.00 MB';
    if (widget.file != null) {
      fileSize = '${(widget.file!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (widget.result['cached_size'] != null) {
      fileSize = widget.result['cached_size'];
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: AppColors.navy500),
      child: Scaffold(
        backgroundColor: AppColors.navy500,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppResponsive.hp(context, 10)),
          child: Padding(
            padding: EdgeInsets.only(top: AppResponsive.hp(context, 3)),
            child: DetectionAppBar(title: 'Scan Result', onBack: () => Navigator.of(context).pop(), trailingIcon: Icons.info_outline_rounded),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.wp(context, 4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppResponsive.hp(context, 3)),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: resultColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: resultColor, width: 1.5)),
                  child: Text(label.toUpperCase(), style: TextStyle(color: resultColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
              SizedBox(height: AppResponsive.hp(context, 3)),

              VideoInfoCard(
                fileName: fileName,
                scannedAt: 'Today at ${TimeOfDay.now().format(context)}',
                duration: widget.mediaType == DetectionMediaType.image ? 'Static Image'
                    : (widget.mediaType == DetectionMediaType.video ? 'Video Content'
                    : 'Audio Stream'),
                size: fileSize,
                mediaType: widget.mediaType,
              ),
              SizedBox(height: AppResponsive.hp(context, 2)),
              _buildMediaPreview(context, heatmapBase64, heatmapUrl, fullPath),
              SizedBox(height: AppResponsive.hp(context, 2.5)),
              Row(
                children: [
                  Expanded(child: _buildConfidenceBox("AI Fake",
                      fakePercentStr, DetectionTheme.cancelRed)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildConfidenceBox("Real Human",
                      realPercentStr, Colors.greenAccent)),
                ],),
              SizedBox(height: AppResponsive.hp(context, 3)),
              _buildActionButtons(label, realPercentStr, fakePercentStr, fileName),
              const SizedBox(height: 24),
              Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
              const SizedBox(height: 16),
              const Text('Deepfake Probability Details', style:
              TextStyle(color: DetectionTheme.primaryLight, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.mediaType == DetectionMediaType.image ?
                  'Image Manipulation Analysis' : (widget.mediaType == DetectionMediaType.video ?
                  'Temporal Frame Analysis' : 'Voice Synthesis Analysis'), style:
                  TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                  Text(label.toLowerCase().contains('fake') ? fakePercentStr :
                  realPercentStr, style: TextStyle(color: resultColor, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: label.toLowerCase().contains('fake') ? (fakeValueRaw) : (realValueRaw), minHeight: 10, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(resultColor)),
              ),
              const SizedBox(height: 6),
              Align(alignment: Alignment.centerRight, child: Text(label.toLowerCase().contains('fake') ? 'FAKE' : 'REAL', style: TextStyle(color: label.toLowerCase().contains('fake') ? DetectionTheme.cancelRed.withValues(alpha: 0.6) : Colors.greenAccent.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.2))),
              SizedBox(height: AppResponsive.hp(context, 10)),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNav(activePage: 'scan'),
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context, String? heatmapBase64, String? heatmapUrl, String filePath) {
    if (widget.mediaType == DetectionMediaType.audio) {
      return _AudioPlayerWidget(audioFile: File(filePath));
    }
    if (widget.mediaType == DetectionMediaType.video) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Video Preview", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<Uint8List?>(
            future: VideoThumbnail.thumbnailData(video: filePath, imageFormat: ImageFormat.JPEG, maxWidth: 500, quality: 85),
            builder: (context, snapshot) {
              return _buildImageCard(context, snapshot.hasData ? Stack(alignment: Alignment.center, children: [Image.memory(snapshot.data!, fit: BoxFit.contain, width: double.infinity), const Icon(Icons.play_circle_outline, color: Colors.white70, size: 60)]) : const Center(child: Icon(Icons.video_library, color: Colors.white24, size: 50)));
            },
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildImageCard(context, widget.file != null ? Image.file(widget.file!, fit: BoxFit.contain) : Image.file(File(filePath), fit: BoxFit.contain)),
        if (heatmapUrl != null || heatmapBase64 != null) ...[
          const SizedBox(height: 16),
          const Align(alignment: Alignment.center, child: Text('Visual Analysis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          _buildImageCard(context, heatmapUrl != null ? Image.network(heatmapUrl, fit: BoxFit.contain) : Image.memory(base64Decode(heatmapBase64!), fit: BoxFit.contain)),
        ],
      ],
    );
  }

  Widget _buildImageCard(BuildContext context, Widget imageWidget) {
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black26, border: Border.all(color: Colors.white10, width: 1.2)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: SizedBox(width: double.infinity, height: AppResponsive.hp(context, 25), child: imageWidget)));
  }

  Widget _buildConfidenceBox(String title, String percent, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: DetectionTheme.cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white10)), child: Column(children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 4), Text(percent, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))]));
  }

  Widget _buildActionButtons(String labelText, String realP, String fakeP, String fileName) {
    return Column(children: [
      SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { Share.share('🛡️ TrueVision AI Result:\n📁 File: $fileName\n🎯 Verdict: ${labelText.toUpperCase()}\n📊 Confidence: $realP Real / $fakeP Fake'); }, icon: const Icon(Icons.share_rounded, size: 20), label: const Text('Share Result'), style: ElevatedButton.styleFrom(backgroundColor: DetectionTheme.primaryLight, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 20, color: DetectionTheme.textOnDark), label: const Text('Download Full Report', style: TextStyle(color: DetectionTheme.textOnDark, fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: DetectionTheme.downloadBorder, width: 1.2), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
    ]);
  }
}

// حافظنا على _AudioPlayerWidget و _AnimatedWaveform بالكامل تحت بدون أي لمس للفانكشناليتي القديمة
class _AudioPlayerWidget extends StatefulWidget {
  const _AudioPlayerWidget({required this.audioFile});
  final File audioFile;
  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          _animationController.stop();
          _animationController.value = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () async {
              if (isPlaying) {
                await _audioPlayer.pause();
                _animationController.stop();
              } else {
                await _audioPlayer.play(DeviceFileSource(widget.audioFile.path));
                _animationController.repeat(reverse: true);
              }
              setState(() => isPlaying = !isPlaying);
            },
            child: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 56, color: DetectionTheme.primaryLight),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Audio Analyzed", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Click to play sample", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          _AnimatedWaveform(isAnimating: isPlaying, controller: _animationController),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _AnimatedWaveform extends StatelessWidget {
  final bool isAnimating;
  final AnimationController controller;
  const _AnimatedWaveform({required this.isAnimating, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(9, (index) {
            double pulse = isAnimating ? (0.3 + 0.7 * (index % 2 == 0 ? controller.value : 1 - controller.value)) : 0.2;
            final List<double> heights = [20, 35, 25, 45, 55, 45, 25, 35, 20];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3.5,
              height: heights[index] * pulse,
              decoration: BoxDecoration(
                color: isAnimating ? DetectionTheme.primaryLight : Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        );
      },
    );
  }
}