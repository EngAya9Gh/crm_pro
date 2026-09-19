class EndPoints {
  // TODO: Update with real Base URL from Backend
  static const String baseUrl = 'https://app.wakeel.cc/api/v1';
  //honeydew-sheep-602146.hostingersite.com

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Clients
  static const String clients = '/clients';
  static const String clientsList = '/clients/list';
  static String client(String id) => '/clients/$id';
  static String clientStatus(String id) => '/clients/$id/status';
  static String clientAssign(String id) => '/clients/$id/assign';
  static String clientComments(String id) => '/clients/$id/comments';
  static String clientFiles(String id) => '/clients/$id/files';
  static String clientTimeline(String id) => '/clients/$id/timeline';
  static String clientRestore(String id) => '/clients/$id/restore';
  static String clientInvoices(String id) => '/clients/$id/invoices';
  static String clientAppointments(String id) => '/clients/$id/appointments';
  static String clientProcedures(String id) => '/clients/$id/procedures';
  static String clientProcedure(String clientId, int procedureId) =>
      '/clients/$clientId/procedures/$procedureId';
  static const String clientsBulkStatus = '/clients/bulk/status';
  static const String clientsBulkAssign = '/clients/bulk/assign';
  static const String clientsBulkDelete = '/clients/bulk';

  static const String clientsStats = '/clients/stats';
  static const String clientsKpis = '/clients/kpis';
  static String clientPdf(String id) => '/clients/$id/pdf';
  static const String clientsFilters = '/clients/filters';
  static const String clientsExport = '/clients/export';

  // Client AI Agent
  static String clientAiInsights(String id) => '/clients/$id/ai/insights';
  static String clientAiAsk(String id) => '/clients/$id/ai/ask';
  static String clientAiHistory(String id) => '/clients/$id/ai/history';
  static String clientAiSession(String clientId, int sessionId) => '/clients/$clientId/ai/sessions/$sessionId';

  // Invoices
  static const String invoices = '/invoices';
  static String invoice(String id) => '/invoices/$id';
  static String invoiceStatus(String id) => '/invoices/$id/status';
  static String invoiceSend(String id) => '/invoices/$id/send';
  static String invoicePdf(String id) => '/invoices/$id/pdf';

  // Appointments
  static const String appointments = '/appointments';
  static String appointment(String id) => '/appointments/$id';
  static String appointmentStatus(String id) => '/appointments/$id/status';

  // Users
  static const String users = '/users';
  static String user(String id) => '/users/$id';

  // Settings
  static const String settingsStatuses = '/settings/statuses';
  static String settingsStatus(String id) => '/settings/statuses/$id';

  static const String settingsSources = '/settings/sources';
  static String settingsSource(String id) => '/settings/sources/$id';

  static const String settingsBehaviors = '/settings/behaviors';
  static String settingsBehavior(String id) => '/settings/behaviors/$id';

  static const String settingsInvalidReasons = '/settings/invalid-reasons';
  static String settingsInvalidReason(String id) =>
      '/settings/invalid-reasons/$id';

  static const String settingsRegions = '/settings/regions';
  static String settingsRegion(String id) => '/settings/regions/$id';

  static const String settingsCities = '/settings/cities';
  static String settingsCity(String id) => '/settings/cities/$id';

  static const String settingsTags = '/settings/tags';
  static String settingsTag(String id) => '/settings/tags/$id';

  static const String settingsProducts = '/settings/products';
  static String settingsProduct(String id) => '/settings/products/$id';

  static const String settingsInvoiceTags = '/settings/invoice-tags';
  static String settingsInvoiceTag(String id) => '/settings/invoice-tags/$id';

  static const String settingsCommentTypes = '/settings/comment-types';
  static String settingsCommentType(String id) => '/settings/comment-types/$id';

  static const String settingsTeams = '/settings/teams';
  static String settingsTeam(String id) => '/settings/teams/$id';

  static const String settingsRoles = '/settings/roles';
  static String settingsRole(String id) => '/settings/roles/$id';

  static const String settingsPermissions = '/settings/permissions';

  static const String settingsIntegrations = '/settings/integrations';
  static String settingsIntegration(String platform) =>
      '/settings/integrations/$platform';

  // Stock
  static const String stockScan = '/stock/scan';
  static const String stockValidate = '/stock/validate';
  static const String productsSync = '/products/sync';
  static String stockProduct(String id) => '/stock/products/$id';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardCharts = '/dashboard/charts';
  static const String dashboardRecentActivities =
      '/dashboard/recent-activities';

  // WhatsApp & Chat
  static const String whatsappSend = '/whatsapp/send';
  static const String whatsappThreads = '/whatsapp/threads';
  static String whatsappThreadMessages(String threadId) =>
      '/whatsapp/threads/$threadId/messages';
  static String whatsappMediaUpload(String threadId) =>
      '/whatsapp/threads/$threadId/media-upload';
  static const String whatsappMedia = '/whatsapp/media';
}
