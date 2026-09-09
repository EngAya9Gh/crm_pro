import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/services/di/di_container.dart';
import '../../domain/entities/integrations_entity.dart';
import '../bloc/cubits/integrations_cubit.dart';
import '../bloc/cubits/integrations_state.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<IntegrationsCubit>()..loadIntegrations(),
      child: const _IntegrationsView(),
    );
  }
}

class _IntegrationsView extends StatefulWidget {
  const _IntegrationsView();

  @override
  State<_IntegrationsView> createState() => _IntegrationsViewState();
}

class _IntegrationsViewState extends State<_IntegrationsView> {
  final _metaTokenController = TextEditingController();

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: AppText('تم نسخ $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'إعدادات الربط',
      body: BlocConsumer<IntegrationsCubit, IntegrationsState>(
        listener: (context, state) {
          if (state is IntegrationUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText(state.message)),
            );
            _metaTokenController.clear();
          } else if (state is IntegrationUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(state.message),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is IntegrationsLoading ||
            current is IntegrationsLoaded ||
            current is IntegrationsError,
        builder: (context, state) {
          if (state is IntegrationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IntegrationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(state.message, style: const TextStyle(color: AppColorScheme.error)),
                  const SizedBox(height: 16),
                  AppElevatedButton(
                    onPressed: () => context.read<IntegrationsCubit>().loadIntegrations(),
                    text: 'إعادة المحاولة',
                  ),
                ],
              ),
            );
          }
          if (state is IntegrationsLoaded) {
            final data = state.integrations;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaSection(context, data),
                  const SizedBox(height: 32),
                  _buildTikTokSection(context, data),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMetaSection(BuildContext context, IntegrationsEntity data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.facebook, color: Colors.blue, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'الربط مع فيسبوك وإنستغرام (Meta)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCopyField('رابط Webhook الخاص بك', data.metaWebhookUrl),
          const SizedBox(height: 24),
          const AppText(
            'تعليمات الربط:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'انسخ رابط الـ Webhook أعلاه.'),
          _buildInstructionStep('2', 'اذهب إلى لوحة مطوري ميتا وقم بإنشاء تطبيق جديد أو اختر تطبيقك الحالي.'),
          _buildInstructionStep('3', 'من القائمة الجانبية، اختر Webhooks ثم Page واضغط على Subscribe to this object.'),
          _buildInstructionStep('4', 'الصق الرابط في خانة Callback URL واترك Verify Token فارغاً أو ضع أي كلمة.'),
          _buildInstructionStep('5', 'في قائمة الأحداث (Fields)، ابحث عن حدث leadgen واشترك فيه.'),
          _buildInstructionStep('6', 'أخيراً، قم بتوليد Page Access Token وضعه في الحقل أدناه.'),
          const SizedBox(height: 24),
          AppTextField(
            controller: _metaTokenController,
            label: 'Page Access Token',
            hintText: data.metaIntegration.hasCredentials ? 'تم الحفظ مسبقاً (أدخل رمزاً جديداً للتحديث)' : 'الصق الرمز السري هنا',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: BlocBuilder<IntegrationsCubit, IntegrationsState>(
              builder: (context, state) {
                final isLoading = state is IntegrationUpdateLoading;
                return AppElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_metaTokenController.text.isEmpty && !data.metaIntegration.hasCredentials) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: AppText('الرجاء إدخال الرمز السري')),
                            );
                            return;
                          }
                          context.read<IntegrationsCubit>().updateIntegration(
                            platform: 'meta',
                            isActive: true, // Always active upon save for simplicity
                            credentials: {
                              if (_metaTokenController.text.isNotEmpty) 'access_token': _metaTokenController.text,
                            },
                          );
                        },
                  text: data.metaIntegration.hasCredentials && _metaTokenController.text.isEmpty ? 'تم الربط (تحديث؟)' : 'حفظ وتفعيل',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokSection(BuildContext context, IntegrationsEntity data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tiktok, color: Colors.black, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: AppText(
                  'الربط مع تيك توك (TikTok)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCopyField('رابط Webhook الخاص بك', data.tiktokWebhookUrl),
          const SizedBox(height: 24),
          const AppText(
            'تعليمات الربط:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'انسخ رابط الـ Webhook الخاص بك أعلاه.'),
          _buildInstructionStep('2', 'اذهب إلى إدارة إعلانات تيك توك (TikTok Ads Manager).'),
          _buildInstructionStep('3', 'من القائمة العلوية، اذهب إلى Tools (الأدوات) > Events (الأحداث).'),
          _buildInstructionStep('4', 'تحت قسم Lead Generation، اختر Webhooks.'),
          _buildInstructionStep('5', 'أضف Webhook جديد، الصق الرابط المنسوخ، وتأكد من تفعيله.'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorScheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColorScheme.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColorScheme.success),
                SizedBox(width: 8),
                Expanded(
                  child: AppText(
                    'هكذا ستصلك جميع الطلبات (Leads) من تيك توك مباشرة إلى نظامنا. لا حاجة لمزيد من الإعدادات هنا!',
                    style: TextStyle(color: AppColorScheme.success, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: const TextStyle(color: AppColorScheme.textMuted, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColorScheme.silver),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  value,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _copyToClipboard(value, 'الرابط'),
                child: const Icon(Icons.copy, color: AppColorScheme.primary, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: AppText(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(text, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
