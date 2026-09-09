import '../../domain/entities/integrations_entity.dart';

class IntegrationDataModel extends IntegrationData {
  IntegrationDataModel({
    required super.isActive,
    required super.hasCredentials,
  });

  factory IntegrationDataModel.fromJson(Map<String, dynamic> json) {
    return IntegrationDataModel(
      isActive: json['is_active'] ?? false,
      hasCredentials: json['has_credentials'] ?? false,
    );
  }
}

class IntegrationsModel extends IntegrationsEntity {
  IntegrationsModel({
    required super.webhookToken,
    required super.metaWebhookUrl,
    required super.tiktokWebhookUrl,
    required super.metaIntegration,
    required super.tiktokIntegration,
  });

  factory IntegrationsModel.fromJson(Map<String, dynamic> json) {
    final urls = json['webhook_urls'] as Map<String, dynamic>? ?? {};
    final integrations = json['integrations'] as Map<String, dynamic>? ?? {};

    return IntegrationsModel(
      webhookToken: json['webhook_token'] ?? '',
      metaWebhookUrl: urls['meta'] ?? '',
      tiktokWebhookUrl: urls['tiktok'] ?? '',
      metaIntegration: IntegrationDataModel.fromJson(
        integrations['meta'] as Map<String, dynamic>? ?? {},
      ),
      tiktokIntegration: IntegrationDataModel.fromJson(
        integrations['tiktok'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
