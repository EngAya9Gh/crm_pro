import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../../core/utils/permission_extension.dart';
import '../cubit/client_ai_cubit.dart';
import '../cubit/client_ai_state.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/ai_quick_actions.dart';
import '../widgets/ai_chat_box.dart';
import 'package:intl/intl.dart';

class ClientAiTab extends StatelessWidget {
  final String clientId;

  const ClientAiTab({super.key, required this.clientId});

  void _showHistoryBottomSheet(BuildContext context, ClientAiCubit cubit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    'سجل المحادثات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: cubit.history.isEmpty
                    ? const Center(child: AppText('لا توجد محادثات سابقة.'))
                    : ListView.separated(
                        itemCount: cubit.history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final session = cubit.history[index];
                          final isSelected = session.id == cubit.currentSessionId;
                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColorScheme.primary.withOpacity(0.05) : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColorScheme.primary.withOpacity(0.3) : Colors.grey[200]!,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColorScheme.primary : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              title: AppText(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColorScheme.primary : AppColorScheme.textMain,
                                ),
                              ),
                              subtitle: AppText(
                                DateFormat('yyyy-MM-dd hh:mm a').format(session.createdAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                cubit.loadSession(clientId, session.id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.hasFeature('ai_agent')) {
      return const _AiFeatureLockedView();
    }

    return BlocProvider(
      create: (_) => getIt<ClientAiCubit>()..loadInsightsAndHistory(clientId),
      child: BlocConsumer<ClientAiCubit, ClientAiState>(
        listener: (context, state) {
          if (state is ClientAiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(state.message, style: const TextStyle(color: Colors.white)),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ClientAiCubit>();

          if (state is ClientAiInitial || (state is ClientAiLoading && cubit.insights == null)) {
            return const Center(child: AppLoader());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: AiChatBox(
              clientId: clientId,
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (cubit.insights != null)
                    AiInsightsCard(insights: cubit.insights!)
                  else if (state is ClientAiError)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColorScheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              'عذراً، لم نتمكن من جلب التحليلات.\n${state.message}',
                              style: const TextStyle(color: AppColorScheme.error, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: AppColorScheme.error),
                            onPressed: () => cubit.loadInsightsAndHistory(clientId),
                            tooltip: 'إعادة المحاولة',
                          ),
                        ],
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showHistoryBottomSheet(context, cubit),
                        icon: const Icon(Icons.history),
                        label: const AppText('سجل المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColorScheme.primary,
                          backgroundColor: AppColorScheme.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (cubit.currentSessionId != null)
                        TextButton.icon(
                          onPressed: cubit.startNewSession,
                          icon: const Icon(Icons.add_comment),
                          label: const AppText('محادثة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  if (cubit.suggestions != null && cubit.suggestions!.clientSpecific.isNotEmpty) ...[
                      AiQuickActions(
                        suggestions: cubit.suggestions!.clientSpecific,
                        onActionSelected: (suggestion) {
                          if (suggestion.action == 'summarize_whatsapp' && suggestion.threadId != null) {
                            cubit.summarizeWhatsappChat(clientId, suggestion.threadId!);
                          } else {
                            cubit.askQuestion(clientId, suggestion.prompt, type: 'quick_action');
                          }
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiFeatureLockedView extends StatelessWidget {
  const _AiFeatureLockedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 64,
                color: AppColorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const AppText(
              'مساعد العميل الذكي (AI Agent) 🤖',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColorScheme.textMain,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const AppText(
              'اكتشف قوة الذكاء الاصطناعي في إدارة عملائك! احصل على تحليلات دقيقة لحالة العميل، نصائح فورية لزيادة المبيعات، وتوليد ردود احترافية بنقرة زر.',
              style: TextStyle(
                fontSize: 15,
                color: AppColorScheme.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildBenefitRow(Icons.analytics_outlined, 'تحليل ذكي لسلوك العميل واهتماماته'),
                  const SizedBox(height: 12),
                  _buildBenefitRow(Icons.chat_bubble_outline, 'محادثة تفاعلية لفهم احتياجات العميل'),
                  const SizedBox(height: 12),
                  _buildBenefitRow(Icons.lightbulb_outline, 'اقتراحات وتوصيات لموظفي المبيعات'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تواصل مع الدعم')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const AppText(
                  'رقي باقتك الآن',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColorScheme.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColorScheme.textMain,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
