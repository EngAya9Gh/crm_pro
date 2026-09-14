class IntegrationData {
  final bool isActive;
  final bool hasCredentials;

  IntegrationData({required this.isActive, required this.hasCredentials});
}

class IntegrationsEntity {
  final String webhookToken;
  final String metaWebhookUrl;
  final String tiktokWebhookUrl;
  final IntegrationData metaIntegration;
  final IntegrationData tiktokIntegration;

  IntegrationsEntity({
    required this.webhookToken,
    required this.metaWebhookUrl,
    required this.tiktokWebhookUrl,
    required this.metaIntegration,
    required this.tiktokIntegration,
  });
}
