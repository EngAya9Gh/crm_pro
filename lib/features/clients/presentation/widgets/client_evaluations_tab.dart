import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../evaluations/presentation/bloc/evaluations_cubit.dart';
import '../../../evaluations/presentation/bloc/evaluations_state.dart';
import '../../../evaluations/domain/entities/evaluation.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';

import '../../../../core/config/theme/typography.dart';
import 'package:intl/intl.dart';

class ClientEvaluationsTab extends StatefulWidget {
  final String clientId;
  
  const ClientEvaluationsTab({super.key, required this.clientId});

  @override
  State<ClientEvaluationsTab> createState() => _ClientEvaluationsTabState();
}

class _ClientEvaluationsTabState extends State<ClientEvaluationsTab> {
  late final EvaluationsCubit _evaluationsCubit;
  final ScrollController _scrollController = ScrollController();

  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _evaluationsCubit = getIt<EvaluationsCubit>();
    _evaluationsCubit.getEvaluations(clientId: int.tryParse(widget.clientId));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _evaluationsCubit.loadNextPage(
        clientId: int.tryParse(widget.clientId),
        rating: _selectedRating,
      );
    }
  }

  void _onRatingChanged(int? rating) {
    setState(() {
      _selectedRating = rating;
    });
    _evaluationsCubit.getEvaluations(
      clientId: int.tryParse(widget.clientId),
      rating: _selectedRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _evaluationsCubit,
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<EvaluationsCubit, EvaluationsState>(
              builder: (context, state) {
                if (state is EvaluationsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EvaluationsError) {
                  return Center(child: AppText(state.message, style: const TextStyle(color: AppColorScheme.error)));
                } else if (state is EvaluationsLoaded) {
                  if (state.evaluations.isEmpty) {
                    return const Center(child: AppText('لا توجد تقييمات حالياً'));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.evaluations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final evaluation = state.evaluations[index];
                            return _buildEvaluationCard(evaluation);
                          },
                        ),
                      ),
                      if (state.isFetchingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () {
                _showFilterSheet(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColorScheme.primary, size: 20),
              ),
            ),
          ),
          _buildRatingChip(null),
          for (int i = 5; i >= 1; i--) _buildRatingChip(i),
        ],
      ),
    );
  }

  Widget _buildRatingChip(int? rating) {
    final isSelected = _selectedRating == rating;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () => _onRatingChanged(rating),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: rating == null
              ? AppText('الكل', style: TextStyle(color: isSelected ? Colors.amber.shade700 : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13))
              : Row(
                  children: [
                    AppText('$rating', style: TextStyle(color: isSelected ? Colors.amber.shade700 : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 4),
                    Icon(Icons.star_rounded, size: 16, color: isSelected ? Colors.amber : Colors.grey.shade400),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(Evaluation evaluation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColorScheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < evaluation.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              Row(
                children: [
                  if (evaluation.channel != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100, 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.campaign_outlined, size: 12, color: Colors.grey.shade700),
                          const SizedBox(width: 4),
                          AppText(
                            evaluation.channel!, 
                            style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  if (evaluation.type != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(
                        evaluation.type!.name,
                        style: const TextStyle(fontSize: 12, color: AppColorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (evaluation.notes != null && evaluation.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppText(
              evaluation.notes!,
              style: const TextStyle(fontSize: 14, color: AppColorScheme.textMain, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColorScheme.grey200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 14, color: AppColorScheme.textMuted.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  AppText(
                    DateFormat('yyyy/MM/dd hh:mm a').format(evaluation.createdAt),
                    style: TextStyle(fontSize: 12, color: AppColorScheme.textMuted.withOpacity(0.8), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (evaluation.assignedUser != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColorScheme.grey200,
                      child: const Icon(Icons.person, size: 12, color: AppColorScheme.grey600),
                    ),
                    const SizedBox(width: 4),
                    AppText(
                      evaluation.assignedUser!.name,
                      style: const TextStyle(fontSize: 12, color: AppColorScheme.textMain, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  const AppText('فلاتر متقدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // Date Range
                  const AppText('تاريخ التقييم', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: AppTextField(hintText: 'من تاريخ', readOnly: true, prefixIcon: const Icon(Icons.date_range))),
                      const SizedBox(width: 10),
                      Expanded(child: AppTextField(hintText: 'إلى تاريخ', readOnly: true, prefixIcon: const Icon(Icons.date_range))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Apply Button
                  AppElevatedButton(
                    text: 'تطبيق الفلاتر',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Apply filters
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
