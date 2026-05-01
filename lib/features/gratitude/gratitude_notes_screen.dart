import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/gratitude/gratitude_note_editor_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GratitudeNotesScreen extends StatefulWidget {
  const GratitudeNotesScreen({super.key});

  @override
  State<GratitudeNotesScreen> createState() => _GratitudeNotesScreenState();
}

class _GratitudeNotesScreenState extends State<GratitudeNotesScreen> {
  final DioClient _dio = inject<DioClient>();
  // DateTime _selectedDate = DateTime.now(); // Calendar olib tashlandi
  bool _animateIn = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorText;
  final List<_NoteItem> _notes = <_NoteItem>[];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C071A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.c842D5F,
        foregroundColor: Colors.white,
        onPressed: _isSaving ? null : () => _openEditor(),
        child: _isSaving
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(CupertinoIcons.add),
      ),
      body: Stack(
        children: [
          const _DecorativeBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(
                    notesCount: _notes.length,
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_errorText != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorText!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14w5.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: _fetchNotes,
              child: Text(
                "Qayta urinish",
                style: AppTextStyles.body14w6.copyWith(
                  color: AppColors.c842D5F,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_notes.isEmpty) {
      return _EmptyNotes(onCreate: () => _openEditor());
    }
    return RefreshIndicator(
      color: AppColors.c842D5F,
      onRefresh: () => _fetchNotes(showLoader: false),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _notes.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = _notes[index];
          return AnimatedSlide(
            duration: Duration(milliseconds: 280 + (index * 90)),
            curve: Curves.easeOutCubic,
            offset: _animateIn ? Offset.zero : const Offset(0, 0.18),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 280 + (index * 90)),
              opacity: _animateIn ? 1 : 0,
              child: Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _deleteGratitudeNote(item),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 18.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: const Color(0xFFFF3B30),
                  ),
                  child: const Icon(
                    CupertinoIcons.trash_fill,
                    color: Colors.white,
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _openEditor(editItem: item),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 13.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF302254).withValues(alpha: 0.94),
                          const Color(0xFF19102F).withValues(alpha: 0.96),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0x60130C26).withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.04),
                          blurRadius: 6,
                          spreadRadius: -1,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 28.w,
                              width: 28.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.c842D5F.withValues(alpha: 0.20),
                              ),
                              child: Icon(
                                CupertinoIcons.heart_fill,
                                color: AppColors.c842D5F,
                                size: 14.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item.isPrivate
                                    ? "Maxfiy shukrona"
                                    : "Shukrona yozuvi",
                                style: AppTextStyles.body12w6.copyWith(
                                  color: Colors.white.withValues(alpha: 0.76),
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(item.createdAt),
                              style: AppTextStyles.body11w5.copyWith(
                                color: Colors.white.withValues(alpha: 0.58),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          item.text,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body16w5.copyWith(
                            color: Colors.white.withValues(alpha: 0.96),
                            height: 1.35,
                          ),
                        ),
                        if (item.tags.isNotEmpty) ...[
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 7.w,
                            runSpacing: 6.h,
                            children: item.tags
                                .map(
                                  (tag) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 9.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40.r),
                                      color:
                                          Colors.white.withValues(alpha: 0.10),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.12),
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: AppTextStyles.body11w5.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.84),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openEditor({_NoteItem? editItem}) async {
    final editing = editItem != null;
    final result = await Navigator.of(context).push<GratitudeDraft>(
      MaterialPageRoute(
        builder: (_) => GratitudeNoteEditorScreen(
          initialText: editing ? editItem.text : null,
          initialIsPrivate: editing ? editItem.isPrivate : true,
        ),
      ),
    );
    if (result == null) return;
    if (result.deleteRequested && editing) {
      await _deleteGratitudeNote(editItem);
      return;
    }
    final text = result.content.trim();
    if (text.isEmpty) return;
    if (editing) {
      await _updateGratitudeNote(editItem, result);
    } else {
      await _createGratitudeNote(result);
    }
  }

  Future<void> _createGratitudeNote(GratitudeDraft draft) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _dio.post(
        ListAPI.clientGratitudeDiary,
        data: {
          'content': draft.content,
          'tags': draft.tags,
          'is_private': draft.isPrivate,
        },
      );
      if (!mounted) return;
      await _fetchNotes(showLoader: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shukrona muvaffaqiyatli saqlandi")),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Shukrona saqlanmadi")),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shukrona saqlanmadi")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _updateGratitudeNote(
      _NoteItem item, GratitudeDraft draft) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _dio.put(
        ListAPI.clientGratitudeDiaryById(item.idAsInt),
        data: {
          'content': draft.content,
          'tags': draft.tags,
          'is_private': draft.isPrivate,
        },
      );
      if (!mounted) return;
      await _fetchNotes(showLoader: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shukrona muvaffaqiyatli yangilandi")),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Shukrona yangilanmadi")),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shukrona yangilanmadi")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _fetchNotes({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorText = null;
      });
    } else {
      setState(() => _errorText = null);
    }
    try {
      final raw = await _dio.get(
        ListAPI.clientGratitudeDiaryList(
          limit: 50,
          offset: 0,
          // day: _toApiDay(_selectedDate), // Kun filteri olib tashlandi
        ),
      );
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        throw Exception('Javob formati noto‘g‘ri');
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! List) {
        throw Exception('Yozuvlar ro‘yxati topilmadi');
      }
      final notes = data
          .whereType<Map>()
          .map((e) => _NoteItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _notes
          ..clear()
          ..addAll(notes);
        _isLoading = false;
        _errorText = null;
        _animateIn = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _animateIn = true);
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      setState(() {
        _isLoading = false;
        _errorText = message ?? "Shukronalarni yuklab bo'lmadi";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = "Shukronalarni yuklab bo'lmadi";
      });
    }
  }

  Future<bool> _deleteGratitudeNote(_NoteItem item) async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);
    try {
      await _dio.delete(ListAPI.clientGratitudeDiaryById(item.idAsInt));
      if (!mounted) return false;
      await _fetchNotes(showLoader: false);
      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shukrona o'chirildi")),
      );
      return true;
    } on DioException catch (e) {
      if (!mounted) return false;
      final message = e.response?.data is Map
          ? Map<String, dynamic>.from(e.response!.data)['message']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Shukrona o'chirilmadi")),
      );
      return false;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shukrona o'chirilmadi")),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$d.$m.$y  $hh:$mm";
  }

  // Calendar funksiyalari olib tashlandi
}

class _NoteItem {
  _NoteItem({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.tags,
    required this.isPrivate,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final List<String> tags;
  final bool isPrivate;
  int get idAsInt => int.tryParse(id) ?? 0;

  factory _NoteItem.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return _NoteItem(
      id: (json['id'] as num?)?.toInt().toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      text: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      tags: rawTags is List
          ? rawTags.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      isPrivate: json['is_private'] == true,
    );
  }

  _NoteItem copyWith({
    String? text,
    DateTime? createdAt,
    List<String>? tags,
    bool? isPrivate,
  }) {
    return _NoteItem(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 58.w,
              width: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.c842D5F.withValues(alpha: 0.18),
              ),
              child: Icon(
                CupertinoIcons.heart_fill,
                size: 24.sp,
                color: AppColors.c842D5F,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Hozircha yozuv yo'q",
              style: AppTextStyles.body16w6.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Birinchi shukrona yozuvingizni yarating\nva kuningizni ijobiy yakunlang",
              textAlign: TextAlign.center,
              style: AppTextStyles.body13w4.copyWith(
                color: Colors.white.withValues(alpha: 0.58),
                height: 1.35,
              ),
            ),
            // SizedBox(height: 14.h),
            // SizedBox(
            //   width: 160.w,
            //   child: ElevatedButton(
            //     onPressed: onCreate,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.c842D5F,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12.r),
            //       ),
            //       padding: EdgeInsets.symmetric(vertical: 10.h),
            //       elevation: 0,
            //     ),
            //     child: Text(
            //       "Yangi yozuv",
            //       style: AppTextStyles.body14w6,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.notesCount,
  });

  final int notesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shukrona daftari",
            style: AppTextStyles.body24w7.copyWith(
              color: Colors.white.withValues(alpha: 0.96),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Har bir kichik yaxshilik - katta baxtning boshlanishi",
            style: AppTextStyles.body13w4.copyWith(
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // _InfoBadge(
              //   icon: CupertinoIcons.doc_text_fill,
              //   label: "$notesCount ta yozuv",
              // ),
              SizedBox(width: 8.w),
              // Calendar olib tashlandi
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.r),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13.sp, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.body11w5.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeBackground extends StatelessWidget {
  const _DecorativeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1034),
            Color(0xFF110923),
            Color(0xFF090512),
          ],
        ),
      ),
    );
  }
}

// _DateSelector widget olib tashlandi
