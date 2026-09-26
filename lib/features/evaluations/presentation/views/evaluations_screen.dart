import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_dropdown.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/evaluations_cubit.dart';
import '../bloc/evaluations_state.dart';
import '../bloc/evaluation_types_cubit.dart';
import '../../../tickets/presentation/bloc/tickets_cubit.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/evaluation_stats.dart';
import '../../../clients/presentation/bloc/clients_bloc.dart';
import '../../../clients/presentation/bloc/clients_event.dart';
import '../../../clients/presentation/bloc/clients_state.dart';
import '../../../users/presentation/bloc/users_bloc.dart';
import '../../../users/presentation/bloc/users_event.dart';
import '../../../users/presentation/bloc/users_state.dart';
import '../../../users/presentation/bloc/users_state.dart';
import '../../data/models/evaluation_model.dart';
import '../../../clients/presentation/views/client_profile_screen.dart';
import 'package:intl/intl.dart';

class _EvaluationRequest extends EvaluationModel {
  final int? reqClientId;
  final int? reqAssignedUserId;
  final int? reqTypeId;

  _EvaluationRequest({
    required super.rating,
    super.notes,
    this.reqClientId,
    this.reqAssignedUserId,
    this.reqTypeId,
  }) : super(
          id: 0,
          channel: 'manual',
          createdAt: DateTime.now(),
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'notes': notes,
      'channel': channel,
      'client_id': reqClientId,
      'assigned_user_id': reqAssignedUserId,
      'type_id': reqTypeId,
    };
  }
}

class EvaluationsScreen extends StatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  State<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends State<EvaluationsScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _selectedClientId;
  int? _selectedAssignedUserId;
  int? _selectedTypeId;
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    context.read<EvaluationsCubit>().getEvaluations(fetchStats: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<EvaluationsCubit>().loadNextPage(
        clientId: _selectedClientId,
        assignedUserId: _selectedAssignedUserId,
        typeId: _selectedTypeId,
        rating: _selectedRating,
      );
    }
  }

  void _applyFilters(int? clientId, int? assignedUserId, int? typeId, int? rating) {
    setState(() {
      _selectedClientId = clientId;
      _selectedAssignedUserId = assignedUserId;
      _selectedTypeId = typeId;
      _selectedRating = rating;
    });
    context.read<EvaluationsCubit>().getEvaluations(
      clientId: _selectedClientId,
      assignedUserId: _selectedAssignedUserId,
      typeId: _selectedTypeId,
      rating: _selectedRating,
      fetchStats: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إدارة التقييمات',
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: (_selectedClientId != null || _selectedAssignedUserId != null || _selectedTypeId != null || _selectedRating != null) 
                ? AppColorScheme.primary 
                : AppColorScheme.textMuted,
          ),
          onPressed: _showFiltersBottomSheet,
        ),
      ],
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manual_eval',
            onPressed: () => _showAddManualEvaluationDialog(context),
            backgroundColor: Colors.white,
            icon: const Icon(Icons.add, color: AppColorScheme.primary),
            label: const AppText('إضافة يدوية', style: TextStyle(color: AppColorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'send_link',
            onPressed: () => _showSendEvaluationDialog(context),
            backgroundColor: AppColorScheme.primary,
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: const AppText('إرسال رابط', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: BlocConsumer<EvaluationsCubit, EvaluationsState>(
        listener: (context, state) {
          if (state is EvaluationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: AppText(state.message, style: const TextStyle(color: Colors.white))),
                  ],
                ),
                backgroundColor: AppColorScheme.success,
                action: state.message.contains('http') ? SnackBarAction(
                  label: 'نسخ الرابط',
                  textColor: Colors.white,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: state.message));
                  },
                ) : null,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is EvaluationsError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is EvaluationsLoading) {
            return const Center(child: AppLoader());
          } else if (state is EvaluationsError) {
            return Center(child: AppText(state.message, style: const TextStyle(color: AppColorScheme.error)));
          } else if (state is EvaluationsLoaded) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildStatsSection(state.stats)),
                if (state.meta != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: AppText(
                        '${state.meta!.total} تقييم - صفحة ${state.currentPage} من ${state.meta!.lastPage}',
                        style: AppTypography.labelSmall.copyWith(color: AppColorScheme.textMuted),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: state.evaluations.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildEvaluationCard(state.evaluations[index]),
                            ),
                            childCount: state.evaluations.length,
                          ),
                        ),
                ),
                if (state.isFetchingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: AppLoader()),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsSection(EvaluationStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorScheme.primary, AppColorScheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('متوسط التقييم', style: AppTypography.titleMedium.copyWith(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        stats.average.toStringAsFixed(1),
                        style: AppTypography.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(Icons.star, color: Colors.amber, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    AppText(stats.total.toString(), style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    AppText('تقييم', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDistributionBars(stats.distribution, stats.total),
        ],
      ),
    );
  }

  Widget _buildDistributionBars(Map<int, int> distribution, int total) {
    if (total == 0) return const SizedBox.shrink();
    return Column(
      children: [
        for (int i = 5; i >= 1; i--)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(width: 16, child: AppText(i.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: distribution[i] == null || total == 0 ? 0 : distribution[i]! / total,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 28, child: AppText((distribution[i] ?? 0).toString(), style: const TextStyle(color: Colors.white70), textAlign: TextAlign.end)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border_rounded, size: 80, color: AppColorScheme.grey300),
          const SizedBox(height: 16),
          AppText('لا توجد تقييمات حالياً', style: AppTypography.titleLarge.copyWith(color: AppColorScheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(Evaluation evaluation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < evaluation.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber, size: 28,
                      )),
                    ),
                    Row(
                      children: [
                        if (evaluation.channel != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100, 
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.campaign_outlined, size: 14, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                AppText(
                                  _getChannelLabel(evaluation.channel!), 
                                  style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        if (evaluation.type != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColorScheme.primary.withOpacity(0.1), 
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColorScheme.primary.withOpacity(0.2)),
                            ),
                            child: AppText(
                              evaluation.type!.name, 
                              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColorScheme.primary),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: AppText(
                    evaluation.notes ?? 'العميل لم يضف أي ملاحظات.',
                    style: TextStyle(
                      color: evaluation.notes == null ? AppColorScheme.textMuted : AppColorScheme.textMain,
                      height: 1.5,
                      fontStyle: evaluation.notes == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColorScheme.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, size: 16, color: AppColorScheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              evaluation.client?.name ?? 'عميل مجهول', 
                              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (evaluation.assignedUser != null)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.purple.shade50,
                              child: Icon(Icons.support_agent_rounded, size: 14, color: Colors.purple.shade300),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AppText(
                                evaluation.assignedUser!.name, 
                                style: AppTypography.labelSmall.copyWith(color: Colors.purple.shade700, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColorScheme.textMuted),
                        const SizedBox(width: 4),
                        AppText(
                          DateFormat('MM/dd HH:mm').format(evaluation.createdAt), 
                          style: AppTypography.labelSmall.copyWith(color: AppColorScheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarFilterButton(BuildContext context, int? rating, int? selectedRating, ValueChanged<int?> onSelect) {
    final isSelected = rating == selectedRating;
    return GestureDetector(
      onTap: () => onSelect(rating),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: rating == null
            ? AppText('الكل', style: TextStyle(color: isSelected ? Colors.amber.shade700 : Colors.grey, fontWeight: FontWeight.bold))
            : Row(
                children: [
                  AppText('$rating', style: TextStyle(color: isSelected ? Colors.amber.shade700 : Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.star_rounded, size: 16, color: isSelected ? Colors.amber : Colors.grey.shade400),
                ],
              ),
      ),
    );
  }

  void _showAddManualEvaluationDialog(BuildContext context) {
    int? selectedTypeId;
    String? selectedClientId;
    int? selectedUserId;
    int rating = 5;
    final noteController = TextEditingController();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<EvaluationTypesCubit>()..getTypes()),
            BlocProvider(create: (_) => getIt<ClientsBloc>()..add(LoadClients())),
            BlocProvider(create: (_) => getIt<UsersBloc>()..add(LoadUsers())),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'إضافة تقييم يدوياً',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<EvaluationTypesCubit, EvaluationsState>(
                        builder: (context, typeState) {
                          if (typeState is EvaluationsLoading) {
                            return const Center(child: AppLoader());
                          }
                          
                          final types = context.read<EvaluationTypesCubit>().types;
                          return AppDropdown<int>(
                            label: 'نوع التقييم',
                            value: selectedTypeId,
                            items: types.map((t) => AppDropdownItem(value: t.id, label: t.name)).toList(),
                            onChanged: (val) => setState(() => selectedTypeId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ClientsBloc, ClientsState>(
                        builder: (context, state) {
                          List<AppDropdownItem<String?>> items = [
                            const AppDropdownItem(value: null, label: 'بدون تحديد')
                          ];
                          if (state is ClientsLoaded) {
                            items.addAll(state.clients.map((c) => AppDropdownItem(value: c.id, label: c.name)));
                          }
                          return AppDropdown<String?>(
                            label: 'العميل (اختياري)',
                            value: selectedClientId,
                            items: items,
                            onChanged: (val) => setState(() => selectedClientId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, state) {
                          List<AppDropdownItem<int?>> items = [
                            const AppDropdownItem(value: null, label: 'بدون تحديد')
                          ];
                          if (state.status == UsersStatus.success) {
                            items.addAll(state.users.map((u) => AppDropdownItem(value: u.id, label: u.name)));
                          }
                          return AppDropdown<int?>(
                            label: 'الموظف المسؤول (اختياري)',
                            value: selectedUserId,
                            items: items,
                            onChanged: (val) => setState(() => selectedUserId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const AppText('التقييم (عدد النجوم)'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () => setState(() => rating = index + 1),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: noteController,
                        label: 'ملاحظات العميل',
                        hintText: 'اكتب انطباع العميل أو أي ملاحظات...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      AppElevatedButton(
                        text: 'حفظ التقييم',
                        onPressed: () {
                          if (selectedTypeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار نوع التقييم', style: TextStyle(color: Colors.white))));
                            return;
                          }
                          
                          parentContext.read<EvaluationsCubit>().createEvaluation(
                            _EvaluationRequest(
                              reqTypeId: selectedTypeId,
                              rating: rating,
                              reqClientId: selectedClientId != null ? int.tryParse(selectedClientId!) : null,
                              reqAssignedUserId: selectedUserId,
                              notes: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                            )
                          );
                          
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSendEvaluationDialog(BuildContext context) {
    int? selectedTypeId;
    String? selectedClientId;
    int? selectedUserId;
    String channel = 'whatsapp';
    final noteController = TextEditingController();
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<EvaluationTypesCubit>()..getTypes()),
            BlocProvider(create: (_) => getIt<ClientsBloc>()..add(const LoadClients())),
            BlocProvider(create: (_) => getIt<UsersBloc>()..add(const LoadUsers())),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'إرسال رابط تقييم',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<EvaluationTypesCubit, EvaluationsState>(
                        builder: (context, typeState) {
                          if (typeState is EvaluationsLoading) {
                            return const Center(child: AppLoader());
                          }
                          
                          final types = context.read<EvaluationTypesCubit>().types;
                          return AppDropdown<int>(
                            label: 'نوع التقييم',
                            value: selectedTypeId,
                            items: types.map((t) => AppDropdownItem(value: t.id, label: t.name)).toList(),
                            onChanged: (val) => setState(() => selectedTypeId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ClientsBloc, ClientsState>(
                        builder: (context, state) {
                          List<AppDropdownItem<String?>> items = [
                            const AppDropdownItem(value: null, label: 'بدون تحديد')
                          ];
                          if (state is ClientsLoaded) {
                            items.addAll(state.clients.map((c) => AppDropdownItem(value: c.id, label: c.name)));
                          }
                          return AppDropdown<String?>(
                            label: 'العميل (اختياري)',
                            value: selectedClientId,
                            items: items,
                            onChanged: (val) => setState(() => selectedClientId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, state) {
                          List<AppDropdownItem<int?>> items = [
                            const AppDropdownItem(value: null, label: 'بدون تحديد')
                          ];
                          if (state.status == UsersStatus.success) {
                            items.addAll(state.users.map((u) => AppDropdownItem(value: u.id, label: u.name)));
                          }
                          return AppDropdown<int?>(
                            label: 'الموظف المسؤول (اختياري)',
                            value: selectedUserId,
                            items: items,
                            onChanged: (val) => setState(() => selectedUserId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      AppDropdown<String>(
                        label: 'قناة الإرسال',
                        value: channel,
                        items: const [
                          AppDropdownItem(value: 'whatsapp', label: 'واتساب'),
                          AppDropdownItem(value: 'email', label: 'البريد الإلكتروني'),
                          AppDropdownItem(value: 'sms', label: 'SMS'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => channel = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: noteController,
                        label: 'ملاحظة للعميل (اختياري)',
                        hintText: 'اكتب رسالة مخصصة مع الرابط...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      AppElevatedButton(
                        text: 'إنشاء وإرسال الرابط',
                        onPressed: () {
                          if (selectedTypeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار نوع التقييم', style: TextStyle(color: Colors.white))));
                            return;
                          }
                          
                          parentContext.read<EvaluationsCubit>().createEvaluationLink(
                            selectedTypeId!,
                            clientId: selectedClientId != null ? int.tryParse(selectedClientId!) : null,
                            assignedUserId: selectedUserId,
                            channel: channel,
                            noteForClient: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                          );
                          
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFiltersBottomSheet() {
    int? tempClientId = _selectedClientId;
    int? tempAssignedUserId = _selectedAssignedUserId;
    int? tempTypeId = _selectedTypeId;
    int? tempRating = _selectedRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ClientsBloc>()..add(const LoadClients())),
            BlocProvider(create: (_) => getIt<UsersBloc>()..add(const LoadUsers())),
            BlocProvider(create: (_) => getIt<EvaluationTypesCubit>()..getTypes()),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 24,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppText(
                                'تصفية التقييمات',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    tempClientId = null;
                                    tempAssignedUserId = null;
                                    tempTypeId = null;
                                    tempRating = null;
                                  });
                                },
                                child: const AppText('إعادة ضبط', style: TextStyle(color: AppColorScheme.error)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          BlocBuilder<ClientsBloc, ClientsState>(
                            builder: (context, state) {
                              List<AppDropdownItem<int?>> items = [
                                const AppDropdownItem(value: null, label: 'الكل')
                              ];
                              if (state is ClientsLoaded) {
                                items.addAll(state.clients.map((c) => AppDropdownItem(value: int.tryParse(c.id), label: c.name)));
                              }
                              return AppDropdown<int?>(
                                label: 'العميل',
                                value: tempClientId,
                                items: items,
                                onChanged: (val) => setState(() => tempClientId = val),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<UsersBloc, UsersState>(
                            builder: (context, state) {
                              List<AppDropdownItem<int?>> items = [
                                const AppDropdownItem(value: null, label: 'الكل')
                              ];
                              if (state.status == UsersStatus.success) {
                                items.addAll(state.users.map((u) => AppDropdownItem(value: u.id, label: u.name)));
                              }
                              return AppDropdown<int?>(
                                label: 'الموظف المسؤول',
                                value: tempAssignedUserId,
                                items: items,
                                onChanged: (val) => setState(() => tempAssignedUserId = val),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<EvaluationTypesCubit, EvaluationsState>(
                            builder: (context, state) {
                              List<AppDropdownItem<int?>> items = [
                                const AppDropdownItem(value: null, label: 'الكل')
                              ];
                              final types = context.read<EvaluationTypesCubit>().types;
                              items.addAll(types.map((t) => AppDropdownItem(value: t.id, label: t.name)));
                              
                              return AppDropdown<int?>(
                                label: 'نوع التقييم',
                                value: tempTypeId,
                                items: items,
                                onChanged: (val) => setState(() => tempTypeId = val),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const AppText('تاريخ التقييم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // TODO: Show date picker for From
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColorScheme.grey300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: AppColorScheme.grey600),
                                        const SizedBox(width: 8),
                                        AppText('من تاريخ', style: TextStyle(color: AppColorScheme.grey600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // TODO: Show date picker for To
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColorScheme.grey300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: AppColorScheme.grey600),
                                        const SizedBox(width: 8),
                                        AppText('إلى تاريخ', style: TextStyle(color: AppColorScheme.grey600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const AppText('عدد النجوم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStarFilterButton(context, null, tempRating, (val) => setState(() => tempRating = val)),
                              for (int i = 5; i >= 1; i--)
                                _buildStarFilterButton(context, i, tempRating, (val) => setState(() => tempRating = val)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AppElevatedButton(
                            text: 'تطبيق الفلاتر',
                            onPressed: () {
                              _applyFilters(tempClientId, tempAssignedUserId, tempTypeId, tempRating);
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getChannelLabel(String channel) {
    const map = {
      'whatsapp': 'واتساب',
      'phone': 'هاتف',
      'email': 'بريد إلكتروني',
      'manual': 'يدوي',
      'system': 'النظام',
    };
    return map[channel.toLowerCase()] ?? channel;
  }
}
