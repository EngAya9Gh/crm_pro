import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/app_drawer.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/common/widgets/app_list_view.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../presentation/widgets/client_card.dart';
import '../../presentation/views/client_profile_screen.dart';
import '../../presentation/views/clients_stats_screen.dart';
import '../../presentation/views/add_client_screen.dart';
import '../../presentation/views/clients_filters_screen.dart';
import '../../presentation/bloc/clients_bloc.dart';
import '../../domain/entities/saved_filter.dart';
import '../../presentation/bloc/clients_event.dart';
import '../../presentation/bloc/clients_state.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/utils/permission_extension.dart';

import '../../../../features/settings/presentation/bloc/lookups_bloc.dart';
import '../../../../features/settings/presentation/bloc/lookups_state.dart';
import '../../../../features/settings/presentation/bloc/lookups_event.dart';

import 'package:flutter/foundation.dart'; // for kIsWeb

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late final ClientsBloc _clientsBloc;

  @override
  void initState() {
    super.initState();
    _clientsBloc = getIt<ClientsBloc>()
      ..add(const LoadClients())
      ..add(LoadSavedFilters());
  }

  @override
  void dispose() {
    _clientsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _clientsBloc, child: const ClientsView());
  }
}

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  final Set<String> _selectedClientIds = {};
  bool _isSelectionMode = false;
  late final ScrollController _scrollController;
  int? _currentStatusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ClientsBloc>().add(LoadMoreClients());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _isSelectionMode
          ? '${_selectedClientIds.length} محدد'
          : AppStrings.clients,
      actions: _isSelectionMode
          ? [
              IconButton(
                icon: const Icon(
                  Icons.select_all,
                  color: AppColorScheme.textMain,
                ),
                onPressed: _selectAll,
              ),
            ]
          : [
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () async {
                  final filter = await Navigator.push<ClientFilter>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ClientsBloc>(),
                        child: const ClientsFiltersScreen(),
                      ),
                    ),
                  );
                  if (filter != null && context.mounted) {
                    context.read<ClientsBloc>().add(
                      LoadClients(filter: filter),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.analytics_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientsStatsScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: AppColorScheme.textMain,
                ),
                onPressed: () => _showExportDialog(context),
              ),
            ],
      drawer: _isSelectionMode ? null : const AppDrawer(),
      body: Column(
          children: [
            if (!_isSelectionMode) ...[
              _buildStatusTabs(),
              _buildSearchRow(),
              _buildSavedFiltersShelf(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    if (state is ClientsLoaded) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppText(
                            'عرض ${state.clients.length} من أصل ${state.totalClients} عميل',
                            style: const TextStyle(
                              color: AppColorScheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],

            Expanded(
              child: BlocListener<ClientsBloc, ClientsState>(
                listenWhen: (previous, current) {
                  if (current is ClientsError) return previous != current;
                  if (previous is ClientsLoaded && current is ClientsLoaded) {
                    return previous.exportedFilePath != current.exportedFilePath &&
                        current.exportedFilePath != null;
                  }
                  return current is ClientsLoaded && current.exportedFilePath != null;
                },
                listener: (context, state) {
                  if (state is ClientsError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: AppText(state.message)));
                  } else if (state is ClientsLoaded &&
                      state.exportedFilePath != null) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: AppText('تم تصدير الملف بنجاح')),
                    );
                    // Open file logic
                    print('Opening exported file: ${state.exportedFilePath}');
                    // TODO: Use OpenFilex if needed for mobile. For Web, DownloadService handles it automatically.
                  }
                },
                child: BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    if (state is ClientsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientsError) {
                      return Center(child: AppText(state.message));
                    } else if (state is ClientsLoaded) {
                      if (state.clients.isEmpty) {
                        return _buildEmptyState();
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ClientsBloc>().add(RefreshClients());
                        },
                        child: AppListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.hasReachedMax
                              ? state.clients.length
                              : state.clients.length + 1,
                          itemBuilder: (context, index) {
                            if (index >= state.clients.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final client = state.clients[index];
                            final isSelected = _selectedClientIds.contains(
                              client.id,
                            );

                            return Stack(
                              children: [
                                ClientCard(
                                  client: client,
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      _toggleSelection(client.id);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) =>
                                                getIt<ClientsBloc>(),
                                            child: ClientProfileScreen(
                                              client: client,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_isSelectionMode) {
                                      setState(() {
                                        _isSelectionMode = true;
                                        _selectedClientIds.add(client.id);
                                      });
                                    }
                                  },
                                ),
                                if (_isSelectionMode)
                                  Positioned(
                                    left: 10,
                                    top: 10,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) =>
                                          _toggleSelection(client.id),
                                      activeColor: AppColorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      bottomNavigationBar: _isSelectionMode ? _buildBulkActionsBar() : null,
      floatingActionButton: _isSelectionMode
          ? null
          : (context.hasPermission('clients.create') 
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ClientsBloc>(),
                          child: const AddClientScreen(),
                        ),
                      ),
                    );
                  },
                  backgroundColor: AppColorScheme.primary,
                  child: const Icon(Icons.add, color: AppColorScheme.white),
                )
              : null),
    );
  }

  Widget _buildBulkActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            Icons.move_to_inbox_outlined,
            'نقل لـ',
            () => _showStatusDialog(context),
          ),

          _buildActionButton(Icons.person_add_alt_1_outlined, 'إسناد', () {
            _showAssignDialog(context);
          }),
          _buildActionButton(Icons.chat_outlined, 'بث', () {
            _showBroadcastDialog(context);
          }, color: Colors.green),
          _buildActionButton(Icons.delete_outline, 'حذف', () {
            _showDeleteConfirmation(context);
          }, color: AppColorScheme.error),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف العملاء'),
        content: AppText(
          'هل أنت متأكد من حذف ${_selectedClientIds.length} عميل؟ لا يمكن التراجع عن هذه العملية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ClientsBloc>().add(
                DeleteClientsBulk(_selectedClientIds.toList()),
              );
              _clearSelection();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorScheme.error,
            ),
            child: const AppText('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedClientIds.clear();
    });
  }

  void _selectAll() {
    final state = context.read<ClientsBloc>().state;
    if (state is ClientsLoaded) {
      setState(() {
        _selectedClientIds.addAll(state.clients.map((c) => c.id));
      });
    }
  }

  void _showStatusDialog(BuildContext context) {
    final clientsBloc = context.read<ClientsBloc>();
    final lookupsBloc = context.read<LookupsBloc>();
    final state = lookupsBloc.state;
    if (state is! LookupsLoaded) return;

    final statuses = state.lookups.clientStatuses;
    int? selectedStatusId;
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: clientsBloc),
              BlocProvider.value(value: lookupsBloc),
            ],
            child: BlocListener<ClientsBloc, ClientsState>(
              listener: (context, state) {
                if (state is ClientsLoaded && isProcessing) {
                  Navigator.pop(dialogContext);
                  _clearSelection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AppText('تم تغيير الحالة بنجاح'),
                      backgroundColor: AppColorScheme.success,
                    ),
                  );
                } else if (state is ClientsError) {
                  setState(() => isProcessing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(state.message),
                      backgroundColor: AppColorScheme.error,
                    ),
                  );
                }
              },
              child: AlertDialog(
                title: const AppText('تغيير الحالة'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'اختر الحالة الجديدة لـ ${_selectedClientIds.length} عميل',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isProcessing)
                        const Center(child: CircularProgressIndicator())
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: statuses.length,
                          itemBuilder: (context, index) {
                            final status = statuses[index];
                            return RadioListTile<int>(
                              value: status.id,
                              groupValue: selectedStatusId,
                              onChanged: (val) {
                                setState(() => selectedStatusId = val);
                              },
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(
                                      int.parse(
                                        status.color.replaceFirst('#', '0xff'),
                                      ),
                                    ),
                                    radius: 6,
                                  ),
                                  const SizedBox(width: 12),
                                  AppText(status.name),
                                ],
                              ),
                              activeColor: AppColorScheme.primary,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isProcessing
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const AppText('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: isProcessing || selectedStatusId == null
                        ? null
                        : () {
                            setState(() => isProcessing = true);
                            context.read<ClientsBloc>().add(
                              UpdateClientsBulkStatus(
                                _selectedClientIds.toList(),
                                selectedStatusId!,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.primary,
                    ),
                    child: const AppText(
                      'تأكيد',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    final clientsBloc = context.read<ClientsBloc>();
    final lookupsBloc = context.read<LookupsBloc>();

    lookupsBloc.add(LoadEmployees());

    String searchQuery = '';
    int? selectedEmployeeId;
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: clientsBloc),
              BlocProvider.value(value: lookupsBloc),
            ],
            child: BlocListener<ClientsBloc, ClientsState>(
              listener: (context, state) {
                if (state is ClientsLoaded && isProcessing) {
                  Navigator.pop(dialogContext);
                  _clearSelection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AppText('تم الإسناد بنجاح'),
                      backgroundColor: AppColorScheme.success,
                    ),
                  );
                } else if (state is ClientsError) {
                  setState(() => isProcessing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(state.message),
                      backgroundColor: AppColorScheme.error,
                    ),
                  );
                }
              },
              child: AlertDialog(
                title: const AppText('إسناد إلى موظف'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'اختر الموظف لإسناد ${_selectedClientIds.length} عميل',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isProcessing)
                        AppTextField(
                          hintText: 'بحث عن موظف...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColorScheme.textMuted,
                          ),
                          onChanged: (value) {
                            setState(() => searchQuery = value.toLowerCase());
                          },
                        ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<LookupsBloc, LookupsState>(
                          builder: (context, state) {
                            if (state is LookupsLoaded) {
                              if (state.isLoadingEmployees) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (state.employees.isEmpty) {
                                return const Center(
                                  child: AppText('لا يوجد موظفين متاحين'),
                                );
                              }

                              final filteredEmployees = state.employees
                                  .where(
                                    (emp) =>
                                        emp.name.toLowerCase().contains(
                                          searchQuery,
                                        ) ||
                                        emp.email.toLowerCase().contains(
                                          searchQuery,
                                        ),
                                  )
                                  .toList();

                              if (filteredEmployees.isEmpty) {
                                return const Center(
                                  child: AppText('لا توجد نتائج'),
                                );
                              }

                              if (isProcessing) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredEmployees.length,
                                itemBuilder: (context, index) {
                                  final emp = filteredEmployees[index];
                                  final isSelected =
                                      selectedEmployeeId == emp.id;
                                  return RadioListTile<int>(
                                    value: emp.id,
                                    groupValue: selectedEmployeeId,
                                    onChanged: (val) {
                                      setState(() => selectedEmployeeId = val);
                                    },
                                    title: AppText(emp.name),
                                    subtitle: AppText(
                                      emp.email,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    secondary: CircleAvatar(
                                      backgroundColor: AppColorScheme.primary,
                                      child: AppText(
                                        emp.name[0].toUpperCase(),
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
                            if (state is LookupsError) {
                              return Center(child: AppText(state.message));
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
                    onPressed: isProcessing
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const AppText('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: isProcessing || selectedEmployeeId == null
                        ? null
                        : () {
                            setState(() => isProcessing = true);
                            context.read<ClientsBloc>().add(
                              AssignClientsBulk(
                                _selectedClientIds.toList(),
                                selectedEmployeeId.toString(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorScheme.primary,
                    ),
                    child: const AppText(
                      'تأكيد',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColorScheme.primary, size: 24),
          const SizedBox(height: 4),
          AppText(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color ?? AppColorScheme.textMain,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedClientIds.contains(id)) {
        _selectedClientIds.remove(id);
        if (_selectedClientIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedClientIds.add(id);
      }
    });
  }

  Widget _buildStatusTabs() {
    return BlocBuilder<LookupsBloc, LookupsState>(
      builder: (context, state) {
        if (state is LookupsLoaded) {
          final statuses = state.lookups.clientStatuses;
          return Container(
            color: AppColorScheme.primary,
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabItem('الكل', null, ''),
                ...statuses.map(
                  (status) => _buildTabItem(status.name, status.id, ''),
                ),
              ],
            ),
          );
        }
        return Container(
          color: AppColorScheme.primary,
          height: 48,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(String label, int? statusId, String count) {
    bool isSelected = _currentStatusFilter == statusId;
    return GestureDetector(
      onTap: () {
        setState(() => _currentStatusFilter = statusId);
        context.read<ClientsBloc>().add(
          LoadClients(
            filter: ClientFilter(
              statusIds: statusId != null ? [statusId.toString()] : null,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                AppText(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (count.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText(
                      count,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppColorScheme.primary
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 3,
                width: 25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportClients(String format) async {
    final statusId = _currentStatusFilter;
    final filter = ClientFilter(
      statusIds: statusId != null ? [statusId.toString()] : null,
    );

    if (!mounted) return;
    context.read<ClientsBloc>().add(ExportClientsEvent(filter: filter, format: format));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AppText('جاري التصدير... سيتم إشعارك عند الانتهاء'),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppTextField(
        hintText: 'بحث عن عميل...',
        prefixIcon: const Icon(Icons.search, color: AppColorScheme.textMuted),
        onChanged: (query) {
          context.read<ClientsBloc>().add(SearchClients(query));
        },
      ),
    );
  }

  Widget _buildSavedFiltersShelf() {
    return BlocBuilder<ClientsBloc, ClientsState>(
      builder: (context, state) {
        if (state is! ClientsLoaded || state.savedFilters.isEmpty) {
          return const SizedBox.shrink();
        }

        final filters = state.savedFilters;
        return Container(
          height: 44,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final savedFilter = filters[index];
              return Container(
                margin: const EdgeInsets.only(left: 8),
                child: InputChip(
                  label: AppText(
                    savedFilter.name,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: AppColorScheme.surface,
                  side: const BorderSide(
                    color: AppColorScheme.primary,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: () {
                    context.read<ClientsBloc>().add(
                      LoadClients(filter: savedFilter.filter),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: AppText('تم تطبيق فلتر: ${savedFilter.name}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onDeleted: () {
                    _confirmDeleteFilter(context, savedFilter);
                  },
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppColorScheme.error,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDeleteFilter(BuildContext context, SavedFilter filter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('حذف الفلتر المحفوظ'),
        content: AppText('هل أنت متأكد من حذف الفلتر "${filter.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<ClientsBloc>().add(
                DeleteSavedFilterEvent(filter.id),
              );
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

  void _showBroadcastDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText(
          'بث رسالة WhatsApp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'سيتم إرسال رسالة لـ ${_selectedClientIds.length} عملاء',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب نص الرسالة هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearSelection();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AppText('تم بدء عملية البث بنجاح')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const AppText(
              'إرسال الآن',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'تصدير البيانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.table_view_outlined,
                color: Colors.green,
              ),
              title: const AppText('تصدير إلى Excel'),
              onTap: () {
                Navigator.pop(sheetContext);
                _exportClients('excel');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: Colors.blue,
              ),
              title: const AppText('تصدير إلى CSV'),
              onTap: () {
                Navigator.pop(sheetContext);
                _exportClients('csv');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Colors.red,
              ),
              title: const AppText('تصدير إلى PDF'),
              onTap: () {
                Navigator.pop(sheetContext);
                _exportClients('pdf');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: AppColorScheme.silver),
          const SizedBox(height: 16),
          AppText(
            'لا يوجد عملاء مضافين حالياً',
            style: AppTypography.titleMedium.copyWith(
              color: AppColorScheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
