import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as picker;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/common/widgets/app_list_view.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../../domain/entities/client_file.dart';
import '../../domain/entities/client_enums.dart';
import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart' as client_state; // Alias to avoid conflicts
import '../bloc/cubits/client_files_cubit.dart';
import 'package:crm_wakeel/core/utils/end_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ClientFilesTab extends StatelessWidget {
  final String clientId;
  final List<ClientFile>? initialFiles;

  const ClientFilesTab({super.key, required this.clientId, this.initialFiles});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientFilesCubit>()..loadFiles(clientId),
      child: _ClientFilesView(clientId: clientId, initialFiles: initialFiles),
    );
  }
}

class _ClientFilesView extends StatefulWidget {
  final String clientId;
  final List<ClientFile>? initialFiles;

  const _ClientFilesView({required this.clientId, this.initialFiles});

  @override
  State<_ClientFilesView> createState() => _ClientFilesViewState();
}

class _ClientFilesViewState extends State<_ClientFilesView> {
  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      final result = await picker.FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        if (!context.mounted) return;

        // Show dialog to select file type
        final type = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const AppText('اختر نوع الملف'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'contract'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: AppText('عقد'),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'identity'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: AppText('هوية'),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'document'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: AppText('مستند'),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'image'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: AppText('صورة'),
                ),
              ),
            ],
          ),
        );

        if (type == null) return; // User cancelled selection

        final platformFile = result.files.single;
        if (context.mounted) {
          // Use the main ClientsBloc for uploading (which is provided in the parent screen)
          context.read<ClientsBloc>().add(
            UploadClientFileEvent(widget.clientId, platformFile, type),
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: AppText('جارٍ رفع الملف...')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: AppText('فشل اختيار الملف: $e')));
      }
    }
  }

  String _getFileUrl(ClientFile file) {
    final baseUrl = EndPoints.baseUrl;
    final domain = baseUrl.replaceAll('/api/v1', '');
    String fullUrl = file.url;
    if (!fullUrl.startsWith('http')) {
      final cleanPath = file.url.startsWith('/')
          ? file.url.substring(1)
          : file.url;
      fullUrl = '$domain/storage/$cleanPath';
    }
    return fullUrl;
  }

  Future<void> _downloadViaBrowser(ClientFile file) async {
    final fullUrl = _getFileUrl(file);
    final uri = Uri.tryParse(fullUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AppText('تعذر فتح رابط التحميل')),
        );
      }
    }
  }

  Future<void> _previewFile(ClientFile file) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: AppText('جارٍ تجهيز العرض...')));

    try {
      final fullUrl = _getFileUrl(file);
      final dir = await getApplicationDocumentsDirectory();
      final fileName = file.name.isNotEmpty
          ? file.name
          : 'file_${file.id}.${file.type.name}';

      final savePath = '${dir.path}/$fileName';

      // Check if file exists to avoid re-downloading?
      // Better redownload to ensure latest version.
      final dio = Dio();
      await dio.download(fullUrl, savePath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: AppText('تعذر عرض الملف: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: AppText('فشل العرض: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to parent ClientsBloc to know when upload finishes
    return BlocListener<ClientsBloc, client_state.ClientsState>(
      listener: (context, state) {
        // We can check if state just refreshed or something.
        // But since ClientsBloc triggers LoadClients on success,
        // and our UploadClientFile logic in ClientsBloc also triggers LoadClientFiles,
        // we might not catch it easily here unless we look for a specific success state or error.

        // Actually, we modified ClientsBloc to dispatch LoadClientFiles event.
        // But LoadClientFiles event is handled by ClientsBloc!
        // Wait, we are now using separate ClientFilesCubit.
        // So the event in ClientsBloc will update ClientsBloc state (which we are not displaying here anymore).

        // So we need to manually reload ClientFilesCubit when upload succeeds.
        // ClientsBloc currently doesn't emit a specific "UploadSuccess" state that persists long enough or it goes to Loading then Loaded.

        // A simple way: If ClientsBloc goes to ClientsLoading then ClientsLoaded, we can trigger refresh here.
        // OR better: Just rely on the user to refresh or simple delay.

        // Let's rely on manual refresh for now to avoid complexity,
        // OR add a specific listener for side-effects if needed.
        // For now, let's just trigger a reload after a short delay if we detect a change in ClientsBloc that implies success?
        // No, that's flaky.

        // Let's keep it simple. The user might pull to refresh.
        // But wait, if I upload, I want to see it.
        // The previous implementation in ClientsBloc of `_onUploadClientFile` calls `add(const LoadClients())` AND `add(LoadClientFiles(...))`.
        // Since we ignore `LoadClientFiles` in this new UI (we use Cubit), that second event is useless for UI update here.

        // We really should move Upload logic to ClientFilesCubit or ClientDetailsCubit eventually.
        // For now: Just let the user refresh.
      },
      child: BlocBuilder<ClientFilesCubit, ClientFilesState>(
        builder: (context, state) {
          List<ClientFile> files = widget.initialFiles ?? [];
          bool isLoading = false;

          if (state is ClientFilesLoading) {
            isLoading = true;
          }

          if (state is ClientFilesLoaded) {
            files = state.files;
            isLoading = false;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: () async {
                    await _pickAndUploadFile(context);
                    // Hacky: Wait a bit then reload. Ideally we listen to success.
                    await Future.delayed(const Duration(seconds: 3));
                    if (context.mounted) {
                      context.read<ClientFilesCubit>().loadFiles(
                        widget.clientId,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColorScheme.primary.withOpacity(0.2),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: AppColorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              'رفع ملف جديد',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'PDF, JPG, PNG, DOC (Max 10MB)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorScheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: isLoading && files.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state is ClientFilesError && files.isEmpty
                    ? Center(child: AppText(state.message))
                    : files.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          context.read<ClientFilesCubit>().loadFiles(
                            widget.clientId,
                          );
                        },
                        child: AppListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return _buildFileItem(file);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: AppColorScheme.silver,
            ),
          ),
          const SizedBox(height: 24),
          AppText(
            'لا توجد ملفات',
            style: AppTypography.titleMedium.copyWith(
              color: AppColorScheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(ClientFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorScheme.surface),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _previewFile(file),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getFileTypeColor(file.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFileTypeIcon(file.type),
                color: _getFileTypeColor(file.type),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => _previewFile(file),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    file.name,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    '${_formatSize(file.sizeBytes)} • ${file.uploadedBy} • ${_formatDate(file.uploadedAt)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColorScheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined, // Changed to visibility for preview
              color: AppColorScheme.textMuted,
              size: 20,
            ),
            onPressed: () => _previewFile(file),
          ),
          IconButton(
            icon: const Icon(
              Icons.download_rounded,
              color: AppColorScheme.textMuted,
              size: 20,
            ),
            // Usually same link triggers download on browser or open
            onPressed: () => _downloadViaBrowser(file),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(FileType type) {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf_outlined;
      case FileType.image:
        return Icons.image_outlined;
      case FileType.doc:
        return Icons.description_outlined;
      case FileType.contract:
        return Icons.assignment_outlined;
      case FileType.identity:
        return Icons.badge_outlined;
      case FileType.document:
        return Icons.article_outlined;
      case FileType.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileTypeColor(FileType type) {
    switch (type) {
      case FileType.pdf:
        return AppColorScheme.error;
      case FileType.image:
        return AppColorScheme.info;
      case FileType.doc:
        return Colors.blue;
      case FileType.contract:
        return AppColorScheme.primary;
      case FileType.identity:
        return AppColorScheme.secondary;
      case FileType.document:
        return AppColorScheme.success;
      case FileType.other:
        return AppColorScheme.silver;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
