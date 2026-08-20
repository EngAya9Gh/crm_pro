import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_enums.dart';
import '../../domain/entities/status_entity.dart';
import '../../domain/entities/tag_entity.dart';
import '../../data/models/client_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/clients_bloc.dart';
import '../../presentation/bloc/clients_event.dart';
import '../../../../features/settings/presentation/bloc/lookups_bloc.dart';
import '../../../../features/settings/presentation/bloc/lookups_state.dart';
import '../../../../features/settings/presentation/bloc/lookups_event.dart';

import '../views/add_client_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColorScheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColorScheme.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            // Ensures the colored strip stretches
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored Status Strip (Right side in RTL)
                Container(width: 4, color: _parseColor(client.status.color)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name & Menu
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    client.name,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildCompactInfo(
                                        Icons.phone_outlined,
                                        client.phone,
                                      ),
                                      const SizedBox(width: 12),
                                      if (client.city.isNotEmpty)
                                        _buildCompactInfo(
                                          Icons.location_on_outlined,
                                          client.city,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Actions Row (Call, WA, Menu)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  icon: Icons.phone,
                                  color: AppColorScheme.primary,
                                  onTap: () => _makePhoneCall(client.phone),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.chat,
                                  color: Colors.green,
                                  onTap: () => _openWhatsApp(client.phone),
                                ),
                                _buildMenuButton(context),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(
                          height: 1,
                          color: AppColorScheme.surface,
                        ), // Added Divider
                        const SizedBox(height: 12),

                        // Info Row: Status, Priority, Rating, Date
                        Row(
                          children: [
                            _buildStatusBadge(client.status),
                            const SizedBox(width: 8),
                            _buildPriorityBadge(client.priority),

                            if (client.leadRating != null) ...[
                              const SizedBox(width: 8),
                              _buildRatingBadge(client.leadRating!),
                            ],

                            const Spacer(),
                            AppText(
                              _formatDate(client.createdAt),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColorScheme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),

                        // Tags Row (Only if exists)
                        if (client.tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 24,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: client.tags.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final tag = client.tags[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _parseColor(
                                      tag.color,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _parseColor(
                                        tag.color,
                                      ).withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: AppText(
                                      tag.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _parseColor(tag.color),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColorScheme.textMuted),
        const SizedBox(width: 4),
        AppText(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColorScheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert,
        size: 20,
        color: AppColorScheme.textMuted,
      ),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        _buildMenuItem('status', Icons.swap_horiz_rounded, 'تغيير الحالة'),
        _buildMenuItem('edit', Icons.edit_outlined, 'تعديل'),
        _buildMenuItem('assign', Icons.person_add_alt_1_outlined, 'إسناد'),
        _buildMenuItem('tag', Icons.sell_outlined, 'وسم'),
        _buildMenuItem(
          'delete',
          Icons.delete_outline,
          'حذف',
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? AppColorScheme.error : null,
          ),
          const SizedBox(width: 8),
          AppText(
            text,
            style: isDestructive
                ? const TextStyle(color: AppColorScheme.error)
                : null,
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'status') {
      _showStatusChangeDialog(context);
    } else if (value == 'assign') {
      _showAssignDialog(context);
    } else if (value == 'delete') {
      _confirmDelete(context);
    } else if (value == 'tag') {
      _showTagDialog(context);
    } else if (value == 'edit') {
      final clientsBloc = context.read<ClientsBloc>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: clientsBloc,
            child: AddClientScreen(client: client),
          ),
        ),
      );
    }
  }

  Widget _buildStatusBadge(StatusEntity status) {
    final color = _parseColor(status.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        status.name,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(ClientPriority priority) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.flag_rounded,
          size: 12,
          color: AppColorScheme.textMuted,
        ),
        const SizedBox(width: 4),
        AppText(
          EnumHelpers.getClientPriorityArabic(priority),
          style: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColorScheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBadge(ClientRating rating) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ), // Very compact
      decoration: BoxDecoration(
        color: AppColorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColorScheme.silverLight.withOpacity(0.5)),
      ),
      child: AppText(
        EnumHelpers.getClientRatingArabic(rating),
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColorScheme.textMain,
          fontSize: 9,
        ),
      ),
    );
  }

  // --- Helper Methods ---
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _parseColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    var phone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.startsWith('0')) {
      phone = '+966${phone.substring(1)}';
    }
    final uri = Uri.parse('https://wa.me/$phone');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // --- Dialogs ---
  void _showStatusChangeDialog(BuildContext context) {
    final clientsBloc = context.read<ClientsBloc>();
    final lookupsState = context.read<LookupsBloc>().state;
    if (lookupsState is! LookupsLoaded) return;

    final statuses = lookupsState.lookups.clientStatuses;
    int? selectedStatusId = client.status.id;

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: clientsBloc,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const AppText('تغيير الحالة'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: statuses.length,
                  itemBuilder: (context, index) {
                    final status = statuses[index];
                    return RadioListTile<int>(
                      value: status.id,
                      groupValue: selectedStatusId,
                      onChanged: (val) =>
                          setState(() => selectedStatusId = val),
                      title: AppText(status.name),
                      secondary: CircleAvatar(
                        backgroundColor: _parseColor(status.color),
                        radius: 6, // Small circle
                      ),
                      activeColor: AppColorScheme.primary,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const AppText('إلغاء'),
                ),
                ElevatedButton(
                  onPressed:
                      selectedStatusId == null ||
                          selectedStatusId == client.status.id
                      ? null
                      : () {
                          clientsBloc.add(
                            UpdateClientsBulkStatus([
                              client.id,
                            ], selectedStatusId!),
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.primary,
                  ),
                  child: const AppText(
                    'حفظ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    final clientsBloc = context.read<ClientsBloc>();
    final lookupsBloc = context.read<LookupsBloc>();
    lookupsBloc.add(LoadEmployees());
    String searchQuery = '';
    String? selectedEmployeeId;

    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: clientsBloc),
          BlocProvider.value(value: lookupsBloc),
        ],
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const AppText('إسناد إلى موظف'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      hintText: 'بحث عن موظف...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      onChanged: (val) => setState(() => searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: BlocBuilder<LookupsBloc, LookupsState>(
                        builder: (context, state) {
                          if (state is LookupsLoaded) {
                            if (state.isLoadingEmployees) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final employees = state.employees.where((e) {
                              return e.name.toLowerCase().contains(
                                    searchQuery.toLowerCase(),
                                  ) ||
                                  e.email.toLowerCase().contains(
                                    searchQuery.toLowerCase(),
                                  );
                            }).toList();
                            if (employees.isEmpty) {
                              return const Center(
                                child: AppText('لا يوجد موظفين'),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final emp = employees[index];
                                return RadioListTile<String>(
                                  value: emp.id.toString(),
                                  groupValue: selectedEmployeeId,
                                  onChanged: (val) =>
                                      setState(() => selectedEmployeeId = val),
                                  title: AppText(emp.name),
                                  subtitle: AppText(
                                    emp.email,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  secondary: CircleAvatar(
                                    backgroundColor: AppColorScheme.primary,
                                    child: AppText(
                                      emp.name.isNotEmpty
                                          ? emp.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  activeColor: AppColorScheme.primary,
                                );
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const AppText('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: selectedEmployeeId == null
                      ? null
                      : () {
                          clientsBloc.add(
                            AssignClientsBulk([client.id], selectedEmployeeId!),
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.primary,
                  ),
                  child: const AppText(
                    'إسناد',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف العميل'),
        content: AppText('هل أنت متأكد من حذف ${client.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<ClientsBloc>().add(DeleteClientEvent(client.id));
              Navigator.pop(ctx);
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

  void _showTagDialog(BuildContext context) {
    final clientsBloc = context.read<ClientsBloc>();
    final lookupsState = context.read<LookupsBloc>().state;
    if (lookupsState is! LookupsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('الرجاء الانتظار حتى تحميل البيانات')),
      );
      return;
    }
    final allTags = lookupsState.lookups.clientTags;
    List<TagEntity> selectedTags = List.from(client.tags);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const AppText('إدارة الوسوم'),
            content: SizedBox(
              width: double.maxFinite,
              child: allTags.isEmpty
                  ? const Center(child: AppText('لا توجد وسوم متاحة'))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTags.map((tag) {
                        final isSelected = selectedTags.any(
                          (t) => t.id == tag.id,
                        );
                        return FilterChip(
                          label: AppText(
                            tag.name,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColorScheme.textMain,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedTags.add(
                                  TagEntity(
                                    id: tag.id,
                                    name: tag.name,
                                    color: tag.color,
                                  ),
                                );
                              } else {
                                selectedTags.removeWhere((t) => t.id == tag.id);
                              }
                            });
                          },
                          selectedColor: AppColorScheme.primary,
                          checkmarkColor: Colors.white,
                          backgroundColor: AppColorScheme.silver.withOpacity(
                            0.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const AppText('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedClient = _createUpdatedClientModel(
                    client,
                    selectedTags,
                  );
                  clientsBloc.add(UpdateClientEvent(updatedClient));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorScheme.primary,
                ),
                child: const AppText(
                  'حفظ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ClientModel _createUpdatedClientModel(
    Client client,
    List<TagEntity> newTags,
  ) {
    return ClientModel(
      id: client.id,
      name: client.name,
      phone: client.phone,
      email: client.email,
      company: client.company,
      region: client.region,
      regionId: client.regionId,
      city: client.city,
      cityId: client.cityId,
      address: client.address,
      status: client.status,
      priority: client.priority,
      leadRating: client.leadRating,
      behaviorId: client.behaviorId,
      sourceId: client.sourceId,
      sourceName: client.sourceName,
      sourceStatus: client.sourceStatus,
      invalidReasonId: client.invalidReasonId,
      assignedTo: client.assignedTo,
      createdAt: client.createdAt,
      firstContactAt: client.firstContactAt,
      convertedAt: client.convertedAt,
      exclusionReason: client.exclusionReason,
      tags: newTags,
      files: client.files,
      comments: client.comments,
      invoices: client.invoices,
      appointments: client.appointments,
      timeline: client.timeline,
    );
  }
}
