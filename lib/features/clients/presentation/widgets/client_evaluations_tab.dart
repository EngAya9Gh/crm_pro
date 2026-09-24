import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../evaluations/presentation/bloc/evaluations_cubit.dart';
import '../../../evaluations/presentation/bloc/evaluations_state.dart';
import '../../../evaluations/domain/entities/evaluation.dart';

class ClientEvaluationsTab extends StatefulWidget {
  final int clientId;
  
  const ClientEvaluationsTab({super.key, required this.clientId});

  @override
  State<ClientEvaluationsTab> createState() => _ClientEvaluationsTabState();
}

class _ClientEvaluationsTabState extends State<ClientEvaluationsTab> {
  late final EvaluationsCubit _evaluationsCubit;

  @override
  void initState() {
    super.initState();
    _evaluationsCubit = getIt<EvaluationsCubit>();
    _evaluationsCubit.getEvaluations(clientId: widget.clientId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _evaluationsCubit,
      child: BlocBuilder<EvaluationsCubit, EvaluationsState>(
        builder: (context, state) {
          if (state is EvaluationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EvaluationsError) {
            return Center(child: AppText(state.message, style: const TextStyle(color: AppColorScheme.error)));
          } else if (state is EvaluationsLoaded) {
            if (state.evaluations.isEmpty) {
              return const Center(child: AppText('لا توجد تقييمات لهذا العميل'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.evaluations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final evaluation = state.evaluations[index];
                return _buildEvaluationCard(evaluation);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEvaluationCard(Evaluation evaluation) {
    return Card(
      color: AppColorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColorScheme.border),
      ),
      child: ListTile(
        title: AppText('تقييم: ${evaluation.rating} نجوم', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: AppText(evaluation.notes ?? 'لا توجد ملاحظات'),
        trailing: AppText(evaluation.type?.name ?? ''),
      ),
    );
  }
}
