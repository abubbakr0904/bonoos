import 'package:bonoos/core/values/app_colors.dart';
import 'package:bonoos/core/values/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GratitudeNotesScreen extends StatefulWidget {
  const GratitudeNotesScreen({super.key});

  @override
  State<GratitudeNotesScreen> createState() => _GratitudeNotesScreenState();
}

class _GratitudeNotesScreenState extends State<GratitudeNotesScreen> {
  final List<_NoteItem> _notes = <_NoteItem>[
    _NoteItem(
      text: "Bugun sog'lom uyg'onganim uchun shukr.",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _NoteItem(
      text: "Oilam bilan vaqt o'tkazganim uchun shukr.",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B2A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.c842D5F,
        foregroundColor: Colors.white,
        onPressed: () => _openEditor(),
        child: const Icon(CupertinoIcons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Shukrona daftari",
                style: AppTextStyles.body24w7.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "${_notes.length} ta yozuv",
                style: AppTextStyles.body13w4.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: _notes.isEmpty
                    ? _EmptyNotes(onCreate: () => _openEditor())
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _notes.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final item = _notes[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteNote(index),
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
                              onTap: () => _openEditor(editIndex: index),
                              child: Container(
                                padding:
                                    EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  color: Colors.white.withValues(alpha: 0.06),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.text,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                AppTextStyles.body15w5.copyWith(
                                              color: Colors.white
                                                  .withValues(alpha: 0.95),
                                              height: 1.3,
                                            ),
                                          ),
                                          SizedBox(height: 7.h),
                                          Text(
                                            _formatDate(item.createdAt),
                                            style:
                                                AppTextStyles.body11w5.copyWith(
                                              color: Colors.white
                                                  .withValues(alpha: 0.55),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 16.sp,
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor({int? editIndex}) async {
    final editing = editIndex != null;
    String draftText = editing ? _notes[editIndex].text : '';
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1034),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            12.h,
            16.w,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16.h,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        editing ? "Yozuvni tahrirlash" : "Yangi yozuv",
                        style: AppTextStyles.body18w6.copyWith(
                          color: Colors.white.withValues(alpha: 0.94),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(),
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: Colors.white.withValues(alpha: 0.45),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    initialValue: draftText,
                    autofocus: true,
                    maxLines: 6,
                    minLines: 4,
                    onChanged: (value) =>
                        setModalState(() => draftText = value),
                    style: AppTextStyles.body15w5.copyWith(
                      color: Colors.white.withValues(alpha: 0.94),
                    ),
                    decoration: InputDecoration(
                      hintText: "Bugun nimaga shukr qildingiz?",
                      hintStyle: AppTextStyles.body14w4.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(draftText.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.c842D5F,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Saqlash",
                        style: AppTextStyles.body14w6.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (result == null) return;
    final text = result.trim();
    if (text.isEmpty) return;
    if (editing) {
      setState(() {
        _notes[editIndex] = _notes[editIndex].copyWith(text: text);
      });
    } else {
      setState(() {
        _notes.insert(0, _NoteItem(text: text, createdAt: DateTime.now()));
      });
    }
  }

  void _deleteNote(int index) {
    if (index < 0 || index >= _notes.length) return;
    setState(() => _notes.removeAt(index));
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$d.$m.$y  $hh:$mm";
  }
}

class _NoteItem {
  _NoteItem({
    required this.text,
    required this.createdAt,
    String? id,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  final String id;
  final String text;
  final DateTime createdAt;

  _NoteItem copyWith({
    String? text,
    DateTime? createdAt,
  }) {
    return _NoteItem(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 46.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          SizedBox(height: 10.h),
          Text(
            "Hozircha yozuv yo'q",
            style: AppTextStyles.body16w6.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Birinchi shukrona yozuvingizni yarating",
            style: AppTextStyles.body13w4.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onCreate,
            child: Text(
              "Yangi yozuv",
              style: AppTextStyles.body14w6.copyWith(
                color: AppColors.c842D5F,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
