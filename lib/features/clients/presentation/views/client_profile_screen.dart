import 'package:flutter/material.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import 'package:crm_wakeel/core/utils/permission_extension.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import '../../domain/entities/client.dart';
import '../widgets/client_appointments_tab.dart';
import '../widgets/client_comments_tab.dart';
import '../widgets/client_info_tab.dart';
import '../widgets/client_invoices_tab.dart';
import '../widgets/client_files_tab.dart';
import '../widgets/client_timeline_tab.dart';

import '../widgets/client_procedures_tab.dart';
import '../widgets/client_tickets_tab.dart';
import '../widgets/client_evaluations_tab.dart';
import '../../../client_ai/presentation/views/client_ai_tab.dart'; // Add AI Tab
import 'add_client_screen.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart'; // Added
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';

class ClientProfileScreen extends StatelessWidget {
  final Client client;

  const ClientProfileScreen({super.key, required this.client});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف العميل'),
        content: const AppText('هل أنت متأكد من حذف هذا العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<ClientsBloc>().add(DeleteClientEvent(client.id));
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const AppText(
              'حذف',
              style: TextStyle(color: AppColorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // Basic sanitization
    var phone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.startsWith('0')) {
      phone = '+966${phone.substring(1)}'; // Assuming KSA default
    }
    // Alternatively just use the raw number if it's already international format or let user handle it.
    // Let's just strip non-digits for now.

    // Using wa.me
    final uri = Uri.parse('https://wa.me/$phone');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _downloadPdf(BuildContext context) async {
    context.read<ClientsBloc>().add(DownloadClientPdfEvent(client.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientsBloc, ClientsState>(
      listenWhen: (previous, current) {
        if (current is ClientsError) return true;
        if (current is ClientPdfDownloaded) return true;
        if (previous is ClientsLoaded &&
            current is ClientsLoaded &&
            previous.downloadedPdfPath != current.downloadedPdfPath &&
            current.downloadedPdfPath != null) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is ClientsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: AppText(state.message)));
        } else if (state is ClientPdfDownloaded) {
          if (!kIsWeb) OpenFilex.open(state.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: AppText('تم تحميل الملف بنجاح')),
          );
        } else if (state is ClientsLoaded && state.downloadedPdfPath != null) {
          if (!kIsWeb) OpenFilex.open(state.downloadedPdfPath!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: AppText('تم تحميل الملف بنجاح')),
          );
        }
      },
      builder: (context, state) {
        Client currentClient = client;
        if (state is ClientsLoaded) {
          try {
            currentClient = state.clients.firstWhere((c) => c.id == client.id);
          } catch (e) {
            // Keep initial client if not found
          }
        }

        return DefaultTabController(
          length: 10,
          child: AppScaffold(
            backgroundColor: AppColorScheme.surface,
            title: currentClient.name,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.phone_in_talk_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () => _makePhoneCall(currentClient.phone),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chat_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () => _openWhatsApp(currentClient.phone),
              ),
              IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () => _downloadPdf(context),
              ),
            if (context.hasPermission('appointments.create'))
              IconButton(
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () {
                  // Navigate to Add Appointment Screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم إضافة شاشة حجز موعد قريباً'),
                    ),
                  );
                },
              ),
            if (context.hasPermission('clients.update'))
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () {
                  final clientsBloc = context.read<ClientsBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: clientsBloc,
                        child: AddClientScreen(client: currentClient),
                      ),
                    ),
                  );
                },
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColorScheme.error),
                      SizedBox(width: 8),
                      AppText(
                        'حذف العميل',
                        style: TextStyle(color: AppColorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColorScheme.primary,
            unselectedLabelColor: AppColorScheme.textMuted,
            indicatorColor: AppColorScheme.primary,
            indicatorWeight: 3,
            labelStyle: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTypography.labelMedium,
            tabs: const [
              Tab(text: AppStrings.clientInfo),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16),
                    SizedBox(width: 4),
                    Text(AppStrings.clientAiAgent),
                  ],
                ),
              ),
              Tab(text: AppStrings.clientComments),
              Tab(text: AppStrings.clientInvoices),
              Tab(text: AppStrings.clientAppointments),
              Tab(text: 'الملفات'),
              Tab(text: 'الإجراءات'),
              Tab(text: AppStrings.tickets),
              Tab(text: AppStrings.evaluations),
              Tab(text: 'Timeline'),
            ],
          ),
          showAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              color: AppColorScheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            margin: const EdgeInsets.only(top: 8),
            child: TabBarView(
              children: [
                ClientInfoTab(client: currentClient),
                ClientAiTab(clientId: currentClient.id),
                ClientCommentsTab(clientId: currentClient.id),
                ClientInvoicesTab(
                  clientId: currentClient.id,
                  initialInvoices: currentClient.invoices,
                ),
                ClientAppointmentsTab(
                  clientId: currentClient.id,
                  initialAppointments: currentClient.appointments,
                ),
                ClientFilesTab(clientId: currentClient.id, initialFiles: currentClient.files),
                ClientProceduresTab(clientId: currentClient.id),
                ClientTicketsTab(clientId: currentClient.id),
                ClientEvaluationsTab(clientId: currentClient.id),
                ClientTimelineTab(clientId: currentClient.id),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}
