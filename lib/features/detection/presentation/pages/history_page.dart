import 'dart:convert';
import 'dart:io'; // ضروري للتعامل مع الفايل وتشيك الـ exists
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_vision/core/responsive/app_responsive.dart';
import 'package:true_vision/features/detection/core/detection_theme.dart';
import 'package:true_vision/features/detection/core/detection_media_type.dart';
import 'package:true_vision/features/detection/presentation/pages/media_type_page.dart';
import 'package:true_vision/features/detection/presentation/widgets/detection_app_bar.dart';
import 'package:true_vision/features/detection/presentation/widgets/detection_bottom_nav.dart';
import 'package:true_vision/features/detection/presentation/pages/scan_result_page.dart';

import '../../../../core/theme/app_colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // قراءة الهيستوري الحقيقي الفعلي من ذاكرة الهاتف تلقائياً
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedList = prefs.getStringList('true_vision_history_key') ?? [];
      setState(() {
        _historyList = savedList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // دالة الحذف الذكية بالأنيميشن القوي والواضح
  void _handleDeleteAnimation(Map<String, dynamic> item, int globalIndex) async {
    // 1. نبدأ في تصغير الحجم وإخفاء العناصر
    setState(() {
      item['isDeleting'] = true;
    });

    // 2. ننتظر 400 مللي ثانية عشان الأنيميشن يظهر كامل وواضح جداً للعين
    await Future.delayed(const Duration(milliseconds: 400));

    // 3. نمسح العنصر نهائياً من الـ List والـ SharedPreferences
    if (mounted) {
      _deleteItem(globalIndex);
    }
  }

  // حذف عنصر من الهيستوري
  Future<void> _deleteItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _historyList.removeAt(index);
    });
    final List<String> updatedList = _historyList.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('true_vision_history_key', updatedList);
  }

  void _startAnalysis(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MediaTypePage(),
      ),
    );
  }

  // دالة النفيجيشن السحرية
  void _navigateToResult(BuildContext context, Map<String, dynamic> item) {
    DetectionMediaType mType = DetectionMediaType.image;
    if (item['mediaType'] == 'DetectionMediaType.video') mType = DetectionMediaType.video;
    if (item['mediaType'] == 'DetectionMediaType.audio') mType = DetectionMediaType.audio;

    final Map<String, dynamic> resultData = Map<String, dynamic>.from(item['result']);
    resultData['cached_size'] = item['fileSize'];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanResultPage(
          result: resultData,
          mediaType: mType,
          savedFilePath: item['filePath'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayItems = _historyList.where((item) => _isToday(item['timestamp'])).toList();
    final yesterdayItems = _historyList.where((item) => _isYesterday(item['timestamp'])).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.navy500,
      ),
      child: Scaffold(
        backgroundColor: AppColors.navy500,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(AppResponsive.hp(context, 10)),
          child: Padding(
            padding: EdgeInsets.only(top: AppResponsive.hp(context, 4)),
            child: DetectionAppBar(
              title: 'History',
              onBack: () => Navigator.of(context).pop(),
              trailingIcon: Icons.search_rounded,
              onTrailingTap: () {},
            ),
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: DetectionTheme.primaryLight))
              : _historyList.isEmpty
              ? _buildEmptyState(context)
              : _buildHistoryList(context, todayItems, yesterdayItems),
        ),
        bottomNavigationBar: const BottomNav(activePage: 'history'),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<Map<String, dynamic>> today, List<Map<String, dynamic>> yesterday) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (today.isNotEmpty) ...[
          _buildSectionHeader('Today'),
          ...today.map((item) => _buildHistoryCard(context, item)),
        ],
        if (yesterday.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionHeader('Yesterday'),
          ...yesterday.map((item) => _buildHistoryCard(context, item)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    final Map<String, dynamic> data = item['result']['result'] is Map ?
    item['result']['result'] : (item['result']['Response body'] ?? item['result']);

    final String label = (data['result'] ?? data['label'] ?? data['predicted_label'] ?? 'Unknown').toString();

    double parseValue(dynamic val) {
      if (val == null) return 0.0;
      String cleanVal = val.toString().replaceAll('%', '').trim();
      return double.tryParse(cleanVal) ?? 0.0;
    }

    double fakeValueRaw = parseValue(data['fake_percentage'] ?? data['fake_prob'] ?? data['fake_probability']);
    if (fakeValueRaw > 1.0) fakeValueRaw /= 100;

    final bool isSuspicious = label.toLowerCase().contains('fake');
    final Color statusColor = isSuspicious ? const Color(0xFFE57373) : const Color(0xFF81C784);
    final String statusText = isSuspicious ? 'AI Generated' : 'Real / Authentic';
    final int percentage = (fakeValueRaw * 100).toInt();

    final String fullPath = item['filePath'] ?? '/file';
    final String fileName = fullPath.split('/').last;

    final int globalIndex = _historyList.indexOf(item);

    // هنا غيرنا الترتيب: الـ Padding هو الـ الخارجي، والـ Slidable واخد الـ Key مباشرة عشان الأيرور يختفي
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        // الـ Key اتنقل هنا وبقى إجباري للـ Slidable نفسه 🔑
        key: ValueKey(item['timestamp'] ?? globalIndex.toString()),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.25,
          dismissible: DismissiblePane(
            onDismissed: () {
              _deleteItem(globalIndex);
            },
          ),
          children: const [],
        ),
        child: Builder(
            builder: (slidableContext) {
              return Container(
                height: 122,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tvDB2,
                      AppColors.tvDB,
                    ],
                    center: const Alignment(-1, -0.9),
                    radius: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _navigateToResult(context, item),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLeadingIcon(item['mediaType'] ?? '', item['filePath'] ?? ''),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Probability: $percentage%',
                                style: TextStyle(color: statusColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.buttonV2,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Quick Report',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 4),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () {
                                Slidable.of(slidableContext)?.dismiss(
                                  ResizeRequest(
                                    const Duration(milliseconds: 300),
                                        () => _deleteItem(globalIndex),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(String mediaTypeStr, String filePath) {
    IconData iconData = Icons.image_rounded;
    if (mediaTypeStr.contains('video')) iconData = Icons.play_arrow_rounded;
    if (mediaTypeStr.contains('audio')) iconData = Icons.mic_rounded;

    final bool isImage = mediaTypeStr.contains('image');
    final bool fileExists = filePath.isNotEmpty && File(filePath).existsSync();

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.navy500,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: (isImage && fileExists)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(filePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(iconData, color: DetectionTheme.primaryLight, size: 22);
          },
        ),
      )
          : Icon(iconData, color: DetectionTheme.primaryLight, size: 22),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppResponsive.hp(context, 6)),
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: DetectionTheme.surfaceDark),
                  child: const Icon(Icons.history_rounded, color: DetectionTheme.primaryLight, size: 72),
                ),
                Positioned(
                  bottom: 18,
                  right: 42,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DetectionTheme.backgroundDark,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: DetectionTheme.primaryLight),
                      child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppResponsive.hp(context, 3)),
        const Text(
          'No analysis history yet',
          style: TextStyle(color: DetectionTheme.primaryLight, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your first file to see analysis results\nhere and track all your deepfake detections.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.5),
        ),
        SizedBox(height: AppResponsive.hp(context, 4)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.wp(context, 10)),
          child: GestureDetector(
            onTap: () => _startAnalysis(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: DetectionTheme.tealGradient),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text('Start Analysis', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: AppResponsive.hp(context, 5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppResponsive.wp(context, 4)),
          child: const Row(
            children: [
              Expanded(child: _HistoryFeatureCard(icon: Icons.bolt_rounded, title: 'Fast Detection', subtitle: 'Results in seconds')),
              SizedBox(width: 12),
              Expanded(child: _HistoryFeatureCard(icon: Icons.auto_graph_rounded, title: 'High Accuracy', subtitle: 'AI-powered analysis')),
            ],
          ),
        ),
      ],
    );
  }

  bool _isToday(String? dateStr) {
    if (dateStr == null) return false;
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  bool _isYesterday(String? dateStr) {
    if (dateStr == null) return false;
    final date = DateTime.parse(dateStr);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.day == yesterday.day && date.month == yesterday.month && date.year == yesterday.year;
  }
}

class _HistoryFeatureCard extends StatelessWidget {
  const _HistoryFeatureCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: DetectionTheme.cardDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: DetectionTheme.tealGradient),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
        ],
      ),
    );
  }
}