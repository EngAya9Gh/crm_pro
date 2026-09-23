import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/end_points.dart';
import '../../services/storage/token_storage.dart';
import '../../services/network/api_client.dart';
import '../../services/network/api_logger.dart';
import '../../services/network/pusher_service.dart';
import '../../../features/whatsapp/data/datasources/whatsapp_remote_datasource.dart';
import '../../../features/whatsapp/data/repositories/whatsapp_repository_impl.dart';
import '../../../features/whatsapp/domain/repositories/whatsapp_repository.dart';
import '../../../features/whatsapp/domain/usecases/get_threads_usecase.dart';
import '../../../features/whatsapp/domain/usecases/get_thread_messages_usecase.dart';
import '../../../features/whatsapp/domain/usecases/reply_to_thread_usecase.dart';
import '../../../features/whatsapp/domain/usecases/send_message_usecase.dart';
import '../../../features/whatsapp/presentation/bloc/whatsapp_threads_cubit.dart';
import '../../../features/whatsapp/presentation/bloc/whatsapp_chat_cubit.dart';
import '../../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/use_cases/login_use_case.dart';
import '../../../features/auth/domain/use_cases/get_me_use_case.dart';
import '../../../features/auth/domain/use_cases/logout_use_case.dart';
import '../../../features/auth/domain/use_cases/forgot_password_use_case.dart';
import '../../../features/auth/domain/use_cases/reset_password_use_case.dart';
import '../../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../../features/users/data/datasources/users_remote_datasource.dart';
import '../../../features/users/data/repositories/users_repository_impl.dart';
import '../../../features/users/domain/repositories/users_repository.dart';
import '../../../features/users/domain/usecases/get_users_usecase.dart';
import '../../../features/users/domain/usecases/create_user_usecase.dart';
import '../../../features/users/domain/usecases/get_user_details_usecase.dart';
import '../../../features/users/domain/usecases/update_user_usecase.dart';
import '../../../features/users/presentation/bloc/users_bloc.dart';
import '../../../features/clients/data/datasources/clients_remote_datasource.dart';
import '../../../features/clients/data/datasources/clients_remote_datasource_impl.dart';
import '../../../features/clients/data/repositories/clients_repository_impl.dart';
import '../../../features/clients/domain/repositories/clients_repository.dart';
import '../../../features/clients/domain/usecases/get_clients_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_details_usecase.dart';

import '../../../features/clients/domain/usecases/add_client_usecase.dart';
import '../../../features/clients/domain/usecases/update_client_usecase.dart';
import '../../../features/clients/domain/usecases/add_comment_usecase.dart';
import '../../../features/clients/domain/usecases/change_client_status_usecase.dart';

import '../../../features/clients/domain/usecases/upload_client_file_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_comments_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_timeline_usecase.dart';

import '../../../features/clients/domain/usecases/download_client_pdf.dart';
import '../../../features/clients/domain/usecases/save_filter_usecase.dart';

import '../../../features/clients/domain/usecases/get_client_stats_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_kpis_usecase.dart';
import '../../../features/clients/domain/usecases/update_clients_bulk_status_usecase.dart';
import '../../../features/clients/domain/usecases/assign_clients_bulk_usecase.dart';
import '../../../features/clients/domain/usecases/delete_clients_bulk_usecase.dart';
import '../../../features/clients/domain/usecases/delete_client_usecase.dart';
import '../../../features/clients/domain/usecases/get_saved_filters_usecase.dart';
import '../../../features/clients/domain/usecases/delete_saved_filter_usecase.dart';
import '../../../features/clients/domain/usecases/export_clients_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_invoices_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_appointments_usecase.dart';
import '../../../features/clients/domain/usecases/get_client_files_usecase.dart';
import '../../../features/clients/presentation/bloc/clients_bloc.dart';
import '../../../features/clients/presentation/bloc/cubits/client_invoices_cubit.dart';
import '../../../features/clients/presentation/bloc/cubits/client_appointments_cubit.dart';
import '../../../features/clients/presentation/bloc/cubits/client_files_cubit.dart';
import '../../../features/clients/presentation/bloc/cubits/client_procedures_cubit.dart';
import '../../../features/clients/domain/usecases/get_client_procedures_usecase.dart';
import '../../../features/clients/domain/usecases/add_procedure_usecase.dart';
import '../../../features/clients/domain/usecases/update_procedure_usecase.dart';
import '../../../features/clients/domain/usecases/delete_procedure_usecase.dart';

// Client AI Agent Feature
import '../../../features/client_ai/data/datasources/client_ai_remote_datasource.dart';
import '../../../features/client_ai/data/datasources/client_ai_remote_datasource_impl.dart';
import '../../../features/client_ai/data/repositories/client_ai_repository_impl.dart';
import '../../../features/client_ai/domain/repositories/client_ai_repository.dart';
import '../../../features/client_ai/domain/usecases/client_ai_usecases.dart';
import '../../../features/client_ai/presentation/cubit/client_ai_cubit.dart';

import '../../../features/system_ai/data/datasources/system_ai_remote_datasource.dart';
import '../../../features/system_ai/data/datasources/system_ai_remote_datasource_impl.dart';
import '../../../features/system_ai/data/repositories/system_ai_repository_impl.dart';
import '../../../features/system_ai/domain/repositories/system_ai_repository.dart';
import '../../../features/system_ai/domain/usecases/system_ai_usecases.dart';
import '../../../features/system_ai/presentation/cubit/system_ai_cubit.dart';

import '../../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../../../features/settings/domain/usecases/get_all_lookups_usecase.dart';
import '../../../features/settings/domain/usecases/settings_usecases.dart';
import '../../../features/settings/domain/usecases/get_integrations_usecase.dart';
import '../../../features/settings/domain/usecases/update_integrations_usecase.dart';
import '../../../features/settings/presentation/bloc/lookups_bloc.dart';
import '../../../features/settings/presentation/bloc/settings_crud_bloc.dart';
import '../../../features/settings/presentation/bloc/cubits/integrations_cubit.dart';

import '../../../features/invoices/data/datasources/invoices_remote_datasource.dart';
import '../../../features/invoices/data/datasources/invoices_remote_datasource_impl.dart';
import '../../../features/invoices/data/repositories/invoices_repository_impl.dart';
import '../../../features/invoices/domain/repositories/invoices_repository.dart';
import '../../../features/invoices/domain/usecases/get_invoices_usecase.dart';
import '../../../features/invoices/domain/usecases/get_invoice_details_usecase.dart';
import '../../../features/invoices/domain/usecases/create_invoice_usecase.dart';
import '../../../features/invoices/domain/usecases/update_invoice_usecase.dart';
import '../../../features/invoices/domain/usecases/delete_invoice_usecase.dart';
import '../../../features/invoices/domain/usecases/change_invoice_status_usecase.dart';
import '../../../features/invoices/domain/usecases/assign_invoice_tags_usecase.dart';
import '../../../features/invoices/domain/usecases/send_invoice_usecase.dart';
import '../../../features/invoices/domain/usecases/download_invoice_pdf_usecase.dart';
import '../../../features/invoices/presentation/bloc/invoices_bloc.dart';
import '../../../features/invoices/data/datasources/invoice_payments_remote_datasource.dart';
import '../../../features/invoices/data/repositories/invoice_payments_repository_impl.dart';
import '../../../features/invoices/domain/repositories/invoice_payments_repository.dart';
import '../../../features/invoices/domain/usecases/get_invoice_payments_usecase.dart';
import '../../../features/invoices/domain/usecases/add_invoice_payment_usecase.dart';
import '../../../features/invoices/domain/usecases/update_invoice_payment_usecase.dart';
import '../../../features/invoices/domain/usecases/delete_invoice_payment_usecase.dart';
import '../../../features/invoices/presentation/bloc/cubits/invoice_payments_cubit.dart';
import '../../../features/clients/domain/usecases/get_clients_list_usecase.dart';

import '../../../features/appointments/data/datasources/appointments_remote_datasource.dart';
import '../../../features/appointments/data/datasources/appointments_remote_datasource_impl.dart';
import '../../../features/appointments/data/repositories/appointments_repository_impl.dart';
import '../../../features/appointments/domain/repositories/appointments_repository.dart';
import '../../../features/appointments/domain/usecases/get_appointments_usecase.dart';
import '../../../features/appointments/domain/usecases/get_appointment_details_usecase.dart';
import '../../../features/appointments/domain/usecases/create_appointment_usecase.dart';
import '../../../features/appointments/domain/usecases/update_appointment_usecase.dart';
import '../../../features/appointments/domain/usecases/delete_appointment_usecase.dart';
import '../../../features/appointments/domain/usecases/change_appointment_status_usecase.dart';
import '../../../features/appointments/domain/usecases/reschedule_appointment_usecase.dart';
import '../../../features/appointments/presentation/bloc/appointments_bloc.dart';

import '../../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../../features/dashboard/data/datasources/dashboard_remote_datasource_impl.dart';
import '../../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../../../features/dashboard/domain/usecases/get_dashboard_charts_usecase.dart';
import '../../../features/dashboard/domain/usecases/get_recent_activities_usecase.dart';
import '../../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/stock/data/datasources/stock_local_data_source.dart';
import '../../../features/stock/data/datasources/stock_remote_data_source.dart';
import '../../../features/stock/data/repositories/stock_repository_impl.dart';
import '../../../features/stock/domain/repositories/stock_repository.dart';
import '../../../features/stock/domain/usecases/scan_product_usecase.dart';
import '../../../features/stock/domain/usecases/sync_products_usecase.dart';
import '../../../features/stock/domain/usecases/validate_stock_usecase.dart';
import '../../../features/stock/presentation/cubit/stock_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDi() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: EndPoints.baseUrl,
      receiveDataWhenStatusError: true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  dio.interceptors.add(ApiLoggingInterceptor());

  getIt.registerLazySingleton(() => dio);

  // Core Services
  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorage(storage: getIt()),
  );

  getIt.registerLazySingleton<PusherService>(() => PusherService());

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: getIt(), tokenStorage: getIt()),
  );

  // --- Auth Feature ---
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), tokenStorage: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMeUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => ForgotPasswordUseCase(getIt()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt()));

  // Blocs / Cubits
  getIt.registerFactory(
    () => AuthCubit(
      loginUseCase: getIt(),
      getMeUseCase: getIt(),
      logoutUseCase: getIt(),
      forgotPasswordUseCase: getIt(),
      resetPasswordUseCase: getIt(),
    ),
  );

  // --- Users Feature ---
  // Data Sources
  getIt.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetUsersUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateUserUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUserDetailsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateUserUseCase(getIt()));

  // Blocs
  getIt.registerFactory(
    () => UsersBloc(
      getUsers: getIt(),
      createUser: getIt(),
      getUserDetails: getIt(),
      updateUser: getIt(),
    ),
  );

  // --- Clients Feature ---
  // Data Sources
  getIt.registerLazySingleton<ClientsRemoteDataSource>(
    () => ClientsRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ClientsRepository>(
    () => ClientsRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetClients(getIt()));
  getIt.registerLazySingleton(() => GetClientDetails(getIt()));

  getIt.registerLazySingleton(() => AddClient(getIt()));
  getIt.registerLazySingleton(() => UpdateClient(getIt()));
  getIt.registerLazySingleton(() => AddComment(getIt()));
  getIt.registerLazySingleton(() => ChangeClientStatus(getIt()));
  getIt.registerLazySingleton(() => UploadClientFile(getIt()));
  getIt.registerLazySingleton(() => GetClientStats(getIt()));

  getIt.registerLazySingleton(() => DownloadClientPdf(getIt()));
  getIt.registerLazySingleton(() => SaveFilterUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSavedFilters(getIt()));
  getIt.registerLazySingleton(() => DeleteSavedFilter(getIt()));

  getIt.registerLazySingleton(() => GetClientKPIs(getIt()));
  getIt.registerLazySingleton(() => UpdateClientsBulkStatus(getIt()));
  getIt.registerLazySingleton(() => AssignClientsBulk(getIt()));
  getIt.registerLazySingleton(() => DeleteClientsBulk(getIt()));
  getIt.registerLazySingleton(() => DeleteClient(getIt()));
  getIt.registerLazySingleton(() => GetClientCommentsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientTimelineUseCase(getIt()));
  getIt.registerLazySingleton(() => ExportClientsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientInvoicesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientAppointmentsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientFilesUseCase(getIt()));

  getIt.registerLazySingleton(() => GetClientProceduresUseCase(getIt()));
  getIt.registerLazySingleton(() => AddProcedureUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProcedureUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProcedureUseCase(getIt()));

  // Blocs / Cubits
  getIt.registerFactory(
    () => ClientsBloc(
      getClients: getIt(),
      getClientStats: getIt(),
      getClientKPIs: getIt(),
      addClient: getIt(),
      updateClient: getIt(),
      updateBulkStatus: getIt(),
      assignBulk: getIt(),
      deleteBulk: getIt(),
      deleteClient: getIt(),
      uploadFile: getIt(),
      downloadClientPdf: getIt(),
      saveFilter: getIt(),
      getSavedFilters: getIt(),
      deleteSavedFilter: getIt(),
      getClientComments: getIt(),
      getClientTimeline: getIt(),
      addComment: getIt(),
      exportClients: getIt(),
      getClientInvoices: getIt(),
      getClientAppointments: getIt(),
      getClientFiles: getIt(),
    ),
  );

  getIt.registerFactory(() => ClientInvoicesCubit(getIt()));
  getIt.registerFactory(() => ClientAppointmentsCubit(getIt()));
  getIt.registerFactory(() => ClientFilesCubit(getIt()));
  getIt.registerFactory(
    () => ClientProceduresCubit(
      getClientProcedures: getIt(),
      addProcedure: getIt(),
      updateProcedure: getIt(),
      deleteProcedure: getIt(),
    ),
  );

  // --- Client AI Agent Feature ---
  getIt.registerLazySingleton<ClientAiRemoteDataSource>(
    () => ClientAiRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<ClientAiRepository>(
    () => ClientAiRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton(() => GetClientAiInsightsUseCase(getIt()));
  getIt.registerLazySingleton(() => AskClientAiUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientAiHistoryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientAiSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => GetClientAiSuggestionsUseCase(getIt()));
  getIt.registerLazySingleton(() => SummarizeWhatsappChatUseCase(getIt()));

  getIt.registerFactory(
    () => ClientAiCubit(
      getInsightsUseCase: getIt(),
      askQuestionUseCase: getIt(),
      getHistoryUseCase: getIt(),
      getSessionUseCase: getIt(),
      getSuggestionsUseCase: getIt(),
      summarizeWhatsappChatUseCase: getIt(),
    ),
  );

  // --- System AI Agent Feature ---
  getIt.registerLazySingleton<SystemAiRemoteDataSource>(
    () => SystemAiRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<SystemAiRepository>(
    () => SystemAiRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton(() => AskSystemAiUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSystemAiHistoryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSystemAiSessionUseCase(getIt()));

  getIt.registerFactory(
    () => SystemAiCubit(
      askQuestionUseCase: getIt(),
      getHistoryUseCase: getIt(),
      getSessionUseCase: getIt(),
      getSuggestionsUseCase: getIt(),
    ),
  );

  // --- Invoices Feature ---
  // Data Sources
  getIt.registerLazySingleton<InvoicesRemoteDataSource>(
    () => InvoicesRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<InvoicesRepository>(
    () => InvoicesRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetInvoicesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetInvoiceDetailsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateInvoiceUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateInvoiceUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteInvoiceUseCase(getIt()));
  getIt.registerLazySingleton(() => ChangeInvoiceStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => SendInvoiceUseCase(getIt()));
  getIt.registerLazySingleton(() => DownloadInvoicePdfUseCase(getIt()));
  getIt.registerLazySingleton(() => AssignInvoiceTagsUseCase(getIt()));

  getIt.registerLazySingleton(() => GetClientsListUseCase(getIt()));

  // Blocs
  getIt.registerFactory(
    () => InvoicesBloc(
      getInvoices: getIt(),
      getInvoiceDetails: getIt(),
      createInvoice: getIt(),
      updateInvoice: getIt(),
      deleteInvoice: getIt(),
      changeStatus: getIt(),
      sendInvoice: getIt(),
      downloadPdf: getIt(),
      assignInvoiceTags: getIt(),
      getClientsList: getIt(),
      getProducts: getIt(),
    ),
  );

  // Invoice Payments
  getIt.registerLazySingleton<InvoicePaymentsRemoteDataSource>(
    () => InvoicePaymentsRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<InvoicePaymentsRepository>(
    () => InvoicePaymentsRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton(() => GetInvoicePaymentsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddInvoicePaymentUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateInvoicePaymentUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteInvoicePaymentUseCase(getIt()));

  getIt.registerFactory(
    () => InvoicePaymentsCubit(
      getPayments: getIt(),
      addPayment: getIt(),
      updatePayment: getIt(),
      deletePayment: getIt(),
    ),
  );

  // --- Appointments Feature ---
  // Data Sources
  getIt.registerLazySingleton<AppointmentsRemoteDataSource>(
    () => AppointmentsRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetAppointmentsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAppointmentDetailsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteAppointmentUseCase(getIt()));
  getIt.registerLazySingleton(() => ChangeAppointmentStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => RescheduleAppointmentUseCase(getIt()));

  // Blocs
  getIt.registerFactory(
    () => AppointmentsBloc(
      getAppointments: getIt(),
      getAppointmentDetails: getIt(),
      createAppointment: getIt(),
      updateAppointment: getIt(),
      deleteAppointment: getIt(),
      changeStatus: getIt(),
      rescheduleAppointment: getIt(),
      getClientsList: getIt(),
    ),
  );

  // --- Dashboard Feature ---
  // Data Sources
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetDashboardSummaryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDashboardChartsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRecentActivitiesUseCase(getIt()));

  // Blocs
  getIt.registerFactory(
    () => DashboardBloc(
      getSummary: getIt(),
      getCharts: getIt(),
      getRecentActivities: getIt(),
    ),
  );

  // --- Settings Feature ---
  // Data Sources
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(apiClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetAllLookupsUseCase(getIt()));

  // Registered from settings_usecases.dart
  getIt.registerLazySingleton(() => GetClientStatusesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateClientStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateClientStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteClientStatusUseCase(getIt()));

  getIt.registerLazySingleton(() => GetSourcesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateSourceUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateSourceUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteSourceUseCase(getIt()));

  getIt.registerLazySingleton(() => GetBehaviorsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateBehaviorUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateBehaviorUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteBehaviorUseCase(getIt()));

  getIt.registerLazySingleton(() => GetInvalidReasonsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateInvalidReasonUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateInvalidReasonUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteInvalidReasonUseCase(getIt()));

  getIt.registerLazySingleton(() => GetRegionsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateRegionUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateRegionUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteRegionUseCase(getIt()));

  getIt.registerLazySingleton(() => GetCitiesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCityUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCityUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCityUseCase(getIt()));

  getIt.registerLazySingleton(() => GetClientTagsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateClientTagUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateClientTagUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteClientTagUseCase(getIt()));

  getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProductUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteProductUseCase(getIt()));

  getIt.registerLazySingleton(() => GetInvoiceTagsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateInvoiceTagUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateInvoiceTagUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteInvoiceTagUseCase(getIt()));

  getIt.registerLazySingleton(() => GetCommentTypesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCommentTypeUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateCommentTypeUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteCommentTypeUseCase(getIt()));

  getIt.registerLazySingleton(() => GetTeamsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateTeamUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTeamUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteTeamUseCase(getIt()));

  getIt.registerLazySingleton(() => GetRolesUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateRoleUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateRoleUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteRoleUseCase(getIt()));

  getIt.registerLazySingleton(() => GetPermissionsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetEmployeesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetIntegrationsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateIntegrationUseCase(getIt()));

  // Blocs
  getIt.registerFactory(
    () => LookupsBloc(
      getAllLookups: getIt(),
      getCities: getIt(),
      getEmployees: getIt(),
    ),
  );

  getIt.registerFactory(
    () => SettingsCrudBloc(
      createTeam: getIt(),
      updateTeam: getIt(),
      deleteTeam: getIt(),
      createRole: getIt(),
      updateRole: getIt(),
      deleteRole: getIt(),
      createStatus: getIt(),
      updateStatus: getIt(),
      deleteStatus: getIt(),
      createSource: getIt(),
      updateSource: getIt(),
      deleteSource: getIt(),
      createBehavior: getIt(),
      updateBehavior: getIt(),
      deleteBehavior: getIt(),
      createInvalidReason: getIt(),
      updateInvalidReason: getIt(),
      deleteInvalidReason: getIt(),
      createTag: getIt(),
      updateTag: getIt(),
      deleteTag: getIt(),
      createProduct: getIt(),
      updateProduct: getIt(),
      deleteProduct: getIt(),
      createInvoiceTag: getIt(),
      updateInvoiceTag: getIt(),
      deleteInvoiceTag: getIt(),
      createCommentType: getIt(),
      updateCommentType: getIt(),
      deleteCommentType: getIt(),
      createRegion: getIt(),
      updateRegion: getIt(),
      deleteRegion: getIt(),
      createCity: getIt(),
      updateCity: getIt(),
      deleteCity: getIt(),
    ),
  );

  getIt.registerFactory(
    () => IntegrationsCubit(
      getIntegrationsUseCase: getIt(),
      updateIntegrationUseCase: getIt(),
    ),
  );

  // --- Stock Feature ---
  // Data Sources
  getIt.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<StockLocalDataSource>(
    () => StockLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => ScanProductUseCase(getIt()));
  getIt.registerLazySingleton(() => ValidateStockUseCase(getIt()));
  getIt.registerLazySingleton(() => SyncProductsUseCase(getIt()));

  // Blocs / Cubits
  getIt.registerFactory(
    () => StockCubit(
      scanProductUseCase: getIt(),
      validateStockUseCase: getIt(),
      syncProductsUseCase: getIt(),
    ),
  );

  // --- WhatsApp Feature ---
  getIt.registerLazySingleton<WhatsappRemoteDataSource>(
    () => WhatsappRemoteDataSourceImpl(apiClient: getIt()),
  );

  getIt.registerLazySingleton<WhatsappRepository>(
    () => WhatsappRepositoryImpl(remoteDataSource: getIt()),
  );

  getIt.registerLazySingleton(() => GetWhatsappThreadsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetThreadMessagesUseCase(getIt()));
  getIt.registerLazySingleton(() => SendWhatsappMessageUseCase(getIt()));
  getIt.registerLazySingleton(() => ReplyToThreadUseCase(getIt()));

  getIt.registerFactory(() => WhatsappThreadsCubit(getThreadsUseCase: getIt()));

  getIt.registerFactory(
    () => WhatsappChatCubit(
      getThreadMessagesUseCase: getIt(),
      replyToThreadUseCase: getIt(),
      pusherService: getIt(),
    ),
  );
}
