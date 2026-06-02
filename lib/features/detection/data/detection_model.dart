import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:true_vision/core/responsive/app_responsive.dart';
import 'package:true_vision/features/detection/core/detection_theme.dart';
import 'package:true_vision/features/detection/presentation/pages/media_type_page.dart';
import 'package:true_vision/features/detection/presentation/widgets/detection_app_bar.dart';
import 'package:true_vision/features/detection/presentation/widgets/detection_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';

// الموديل البسيط لتخزين البيانات
enum MediaType { image, video, audio }

class DetectionModel {
  final String id;
  final String fileName;
  final MediaType mediaType;
  final double aiProbability;
  final DateTime timestamp;
  final String? fileSize;
  final String? duration;
  final String? thumbnailPath;

  const DetectionModel({
    required this.id,
    required this.fileName,
    required this.mediaType,
    required this.aiProbability,
    required this.timestamp,
    this.fileSize,
    this.duration,
    this.thumbnailPath,
  });

  bool get isAiGenerated => aiProbability > 0.5;
}