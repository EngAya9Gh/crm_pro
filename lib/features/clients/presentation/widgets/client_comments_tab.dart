import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import '../../../settings/presentation/bloc/lookups_bloc.dart';
import '../../../settings/presentation/bloc/lookups_event.dart';
import '../../../settings/presentation/bloc/lookups_state.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/client_enums.dart';
import '../../domain/entities/dynamic_field.dart';
import '../../domain/repositories/clients_repository.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart';
import 'comment_card.dart';

class ClientCommentsTab extends StatefulWidget {
  final String clientId;
  const ClientCommentsTab({super.key, required this.clientId});

  @override
  State<ClientCommentsTab> createState() => _ClientCommentsTabState();
}

class _ClientCommentsTabState extends State<ClientCommentsTab> {
  final TextEditingController _commentController = TextEditingController();
  CommentOutcome? _selectedOutcome;
  DateTime? _nextFollowUp;
  List<DynamicField> _commentTypes = [];
  String? _selectedTypeId;

  List<Comment> _comments = [];
  List<picker.PlatformFile> _selectedAttachments = [];
  final List<CommentMention> _selectedMentions = [];

  @override
  void initState() {
    super.initState();
    _loadCommentTypes();
    // Trigger load employees for mentions
    context.read<LookupsBloc>().add(LoadEmployees());
    // Trigger load comments
    context.read<ClientsBloc>().add(
      LoadClientComments(widget.clientId, refresh: true),
    );
  }

  void _showMentionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<LookupsBloc, LookupsState>(
          builder: (context, state) {
            if (state is LookupsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LookupsLoaded) {
              final employees = state.employees;
              if (employees.isEmpty) {
                return const Center(child: AppText('لا يوجد موظفين متاحين'));
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: AppText(
                      'إشارة إلى موظف',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        // check if already selected
                        bool added = _selectedMentions.any(
                          (m) => m.id == emp.id,
                        );
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: AppText(
                              emp.name.isNotEmpty ? emp.name[0] : '?',
                              style: const TextStyle(
                                color: AppColorScheme.primary,
                              ),
                            ),
                          ),
                          title: AppText(emp.name),
                          subtitle: AppText(emp.role?.name ?? ''),
                          trailing: added
                              ? const Icon(
                                  Icons.check,
                                  color: AppColorScheme.success,
                                )
                              : null,
                          onTap: () {
                            if (!added) {
                              setState(() {
                                _selectedMentions.add(
                                  CommentMention(id: emp.id, name: emp.name),
                                );
                              });
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: AppText('حدث خطأ في تحميل الموظفين'));
          },
        );
      },
    );
  }

  Future<void> _loadCommentTypes() async {
    print('Loading comment types...');
    final result = await getIt<ClientsRepository>().getDynamicFields(
      'comment_types',
    );
    result.fold(
      (failure) => print('Error loading comment types: ${failure.message}'),
      (types) {
        print('Loaded ${types.length} comment types');
        setState(() => _commentTypes = types);
      },
    );
  }

  Future<void> _pickAttachments() async {
    try {
      final result = await picker.FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );
      if (result != null) {
        setState(() {
          _selectedAttachments.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل اختيار الملف: $e')));
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _selectedAttachments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientsBloc, ClientsState>(
      listener: (context, state) {
        if (state is ClientCommentsLoaded) {
          setState(() {
            if (state.page == 1) {
              _comments = state.comments;
            } else {
              // Append only if not already present to avoid dups if any logic fails
              // simplified append:
              _comments.addAll(state.comments);
            }
          });
        }
      },
      child: Column(
        children: [
          // Comments List
          Expanded(
            child: BlocBuilder<ClientsBloc, ClientsState>(
              buildWhen: (previous, current) =>
                  current is ClientCommentsLoaded ||
                  (current is ClientsLoading &&
                      previous is! ClientCommentsLoaded) ||
                  current is ClientsError,
              builder: (context, state) {
                // Determine what to show
                // If loading initial page and no comments yet
                if (state is ClientsLoading && _comments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ClientsError && _comments.isEmpty) {
                  return Center(child: AppText(state.message));
                }

                if (_comments.isEmpty) {
                  // If not loading, not error, and empty -> No result
                  if (state is ClientCommentsLoaded && state.comments.isEmpty) {
                    return const Center(
                      child: AppText(
                        'لا توجد تعليقات بعد',
                        style: TextStyle(color: AppColorScheme.textMuted),
                      ),
                    );
                  }
                  // Initial state
                  return const Center(child: CircularProgressIndicator());
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      // Trigger load more
                      // Check state to avoid spamming
                      if (state is ClientCommentsLoaded &&
                          !state.hasReachedMax) {
                        // We should probably check if we are already loading more
                        // The Bloc handles ignoring if state is loading, but here we only check Loaded
                        context.read<ClientsBloc>().add(
                          LoadMoreClientComments(widget.clientId),
                        );
                      }
                    }
                    return false;
                  },
                  child: AppListView.builder(
                    padding: const EdgeInsets.all(20),
                    // Add +1 for loader if not reached max
                    itemCount:
                        _comments.length +
                        (state is ClientCommentsLoaded && !state.hasReachedMax
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index >= _comments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return CommentCard(comment: _comments[index]);
                    },
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColorScheme.background,
              border: const Border(
                top: BorderSide(color: AppColorScheme.surface, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.black.withValues(alpha: 0.01),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mentions Preview
                if (_selectedMentions.isNotEmpty)
                  Container(
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedMentions.length,
                      itemBuilder: (context, index) {
                        final mention = _selectedMentions[index];
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.alternate_email,
                                size: 12,
                                color: AppColorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                mention.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _selectedMentions.removeAt(index),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Attachments Preview
                if (_selectedAttachments.isNotEmpty)
                  Container(
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedAttachments.length,
                      itemBuilder: (context, index) {
                        final file = _selectedAttachments[index];
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.attach_file,
                                size: 12,
                                color: AppColorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              AppText(
                                file.name.length > 15
                                    ? '...${file.name.substring(file.name.length - 12)}'
                                    : file.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeAttachment(index),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Extra Options Row
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildTypeSelector(),
                          _buildOutcomeTag(
                            CommentOutcome.positive,
                            'إيجابي',
                            AppColorScheme.success,
                          ),
                          _buildOutcomeTag(
                            CommentOutcome.neutral,
                            'محايد',
                            AppColorScheme.silver,
                          ),
                          _buildOutcomeTag(
                            CommentOutcome.negative,
                            'سلبي',
                            AppColorScheme.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.event_repeat,
                            color: _nextFollowUp != null
                                ? AppColorScheme.primary
                                : AppColorScheme.textMuted,
                            size: 20,
                          ),
                          onPressed: () => _selectDate(context),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.alternate_email,
                            color: _selectedMentions.isNotEmpty
                                ? AppColorScheme.secondary
                                : AppColorScheme.textMuted,
                            size: 20,
                          ),
                          onPressed: _showMentionPicker,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: _selectedAttachments.isNotEmpty
                                ? AppColorScheme.primary
                                : AppColorScheme.textMuted,
                            size: 20,
                          ),
                          onPressed: _pickAttachments,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _commentController,
                        hintText: 'اكتب تعليقك...',
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: AppColorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          if (_commentController.text.trim().isEmpty) return;

                          if (_selectedTypeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء اختيار نوع التعليق'),
                              ),
                            );
                            return;
                          }

                          final newComment = Comment(
                            id: '', // Backend handles ID
                            content: _commentController.text,
                            typeId: _selectedTypeId,
                            outcome: _selectedOutcome,
                            nextFollowUp: _nextFollowUp,
                            createdAt:
                                DateTime.now(), // Backend likely overwrites
                            createdBy: '', // Backend uses token
                          );

                          context.read<ClientsBloc>().add(
                            AddClientCommentEvent(
                              clientId: widget.clientId,
                              comment: newComment,
                              attachments: List.from(
                                _selectedAttachments,
                              ), // Send a copy
                              mentionIds: _selectedMentions
                                  .map((m) => m.id.toString())
                                  .toList(),
                            ),
                          );

                          // Clear input immediately for better UX
                          _commentController.clear();
                          setState(() {
                            _selectedAttachments.clear();
                            _selectedMentions.clear();
                            _selectedOutcome = null;
                            _selectedTypeId = null;
                            _nextFollowUp = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.send_rounded,
                            color: AppColorScheme.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_nextFollowUp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        AppText(
                          'متابعة مجدولة: ${_nextFollowUp!.day}/${_nextFollowUp!.month}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _nextFollowUp = null),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: AppColorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeTag(CommentOutcome outcome, String label, Color color) {
    bool isSelected = _selectedOutcome == outcome;
    return GestureDetector(
      onTap: () =>
          setState(() => _selectedOutcome = isSelected ? null : outcome),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColorScheme.surface,
          ),
        ),
        child: AppText(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColorScheme.textMuted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return PopupMenuButton<String>(
      onSelected: (id) => setState(() => _selectedTypeId = id),
      itemBuilder: (context) {
        if (_commentTypes.isEmpty) {
          return [
            const PopupMenuItem(
              value: '1', // Dummy ID
              child: AppText('عام'),
            ),
          ];
        }
        return _commentTypes
            .map(
              (type) => PopupMenuItem(
                value: type.id,
                child: AppText(
                  type.name,
                  style: TextStyle(color: _parseColor(type.color)),
                ),
              ),
            )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              _selectedTypeId != null
                  ? (_commentTypes.isEmpty
                        ? 'عام'
                        : _commentTypes
                              .firstWhere((e) => e.id == _selectedTypeId)
                              .name)
                  : 'النوع',
              style: const TextStyle(
                fontSize: 10,
                color: AppColorScheme.textMain,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: AppColorScheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _nextFollowUp) {
      setState(() {
        _nextFollowUp = picked;
      });
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      // Handle #RRGGBB
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xff')));
      }
      // Handle simple names (fallback)
      switch (colorString.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'gold':
          return Colors.amber;
        default:
          return AppColorScheme.primary;
      }
    } catch (_) {
      return AppColorScheme.primary;
    }
  }
}
