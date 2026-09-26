import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/common/widgets/app_dropdown.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/tickets_cubit.dart';
import '../bloc/tickets_state.dart';
import '../bloc/ticket_categories_cubit.dart';
import '../../data/models/ticket_model.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_category.dart';
import '../../../clients/presentation/bloc/clients_bloc.dart';
import '../../../clients/presentation/bloc/clients_event.dart';
import '../../../clients/presentation/bloc/clients_state.dart';
import '../../../users/presentation/bloc/users_bloc.dart';
import '../../../users/presentation/bloc/users_event.dart';
import '../../../users/presentation/bloc/users_state.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../users/domain/entities/user.dart';

class CreateTicketScreen extends StatelessWidget {
  final Ticket? ticket;
  final String? clientId; // Used if we're creating from client profile

  const CreateTicketScreen({super.key, this.ticket, this.clientId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ClientsBloc>()..add(const LoadClients())),
        BlocProvider(create: (_) => getIt<UsersBloc>()..add(const LoadUsers(isRefresh: true))),
        BlocProvider(create: (_) => getIt<TicketCategoriesCubit>()..getCategories()),
      ],
      child: _CreateTicketView(ticket: ticket, initialClientId: clientId),
    );
  }
}

class _CreateTicketView extends StatefulWidget {
  final Ticket? ticket;
  final String? initialClientId; // Changed to String?
  const _CreateTicketView({this.ticket, this.initialClientId});

  @override
  State<_CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<_CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedPriority = 'medium';
  String _selectedSource = 'manual';
  
  String? _selectedClientId; // Changed to String?
  int? _selectedUserId;
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.initialClientId;
    if (widget.ticket != null) {
      _titleController.text = widget.ticket!.title;
      _descriptionController.text = widget.ticket!.description ?? '';
      _selectedPriority = widget.ticket!.priority;
      _selectedSource = widget.ticket!.source;
      _selectedClientId = widget.ticket!.client?.id ?? widget.initialClientId;
      _selectedUserId = widget.ticket!.assignedTo?.id;
      _selectedCategoryId = widget.ticket!.category?.id;
      _selectedSubCategoryId = widget.ticket!.subCategory?.id;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final ticket = TicketModel(
      id: widget.ticket?.id ?? 0,
      ticketNumber: widget.ticket?.ticketNumber ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      status: widget.ticket?.status ?? 'open',
      priority: _selectedPriority,
      source: _selectedSource,
      clientIdStr: _selectedClientId,
      assignedToId: _selectedUserId,
      categoryId: _selectedCategoryId,
      subCategoryId: _selectedSubCategoryId,
      createdAt: widget.ticket?.createdAt ?? DateTime.now(),
    );

    if (widget.ticket != null) {
      context.read<TicketsCubit>().updateTicket(widget.ticket!.id, ticket);
    } else {
      context.read<TicketsCubit>().createTicket(ticket);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TicketsCubit, TicketsState>(
      listener: (context, state) {
        if (state is TicketOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AppText(state.message)));
          Navigator.pop(context);
        } else if (state is TicketsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: AppText(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: AppColorScheme.error),
          );
        }
      },
      child: AppScaffold(
        title: widget.ticket != null ? 'تعديل التذكرة' : 'تذكرة جديدة',
        backgroundColor: AppColorScheme.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('المعلومات الأساسية'),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _titleController,
                  label: 'عنوان التذكرة',
                  hintText: 'أدخل عنواناً واضحاً للمشكلة',
                  prefixIcon: const Icon(Icons.title),
                  validator: (val) => val == null || val.isEmpty ? 'الرجاء إدخال عنوان التذكرة' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'الوصف',
                  hintText: 'اشرح المشكلة بالتفصيل...',
                  maxLines: 5,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('الارتباطات (العميل والموظف)'),
                const SizedBox(height: 12),
                BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    List<AppDropdownItem<String?>> items = [
                      const AppDropdownItem(value: null, label: 'بدون عميل')
                    ];
                    if (state is ClientsLoaded) {
                      items.addAll(state.clients.map((c) => AppDropdownItem(value: c.id, label: c.name)));
                    }
                    return AppDropdown<String?>(
                      label: 'العميل',
                      value: _selectedClientId,
                      items: items,
                      onChanged: (val) => setState(() => _selectedClientId = val),
                    );
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<UsersBloc, UsersState>(
                  builder: (context, state) {
                    List<AppDropdownItem<int?>> items = [
                      const AppDropdownItem(value: null, label: 'غير مسند')
                    ];
                    if (state.status == UsersStatus.success) {
                      items.addAll(state.users.map((u) => AppDropdownItem(value: u.id, label: u.name)));
                    }
                    return AppDropdown<int?>(
                      label: 'إسناد إلى موظف',
                      value: _selectedUserId,
                      items: items,
                      onChanged: (val) => setState(() => _selectedUserId = val),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('التصنيف والأولوية'),
                const SizedBox(height: 12),
                BlocBuilder<TicketCategoriesCubit, TicketsState>(
                  builder: (context, state) {
                    final categories = context.read<TicketCategoriesCubit>().categories;
                    final mainCategories = categories.where((c) => c.parentId == null).toList();
                    TicketCategory? selectedMain = mainCategories.where((c) => c.id == _selectedCategoryId).firstOrNull;
                    
                    return Column(
                      children: [
                        AppDropdown<int?>(
                          label: 'التصنيف الرئيسي',
                          value: _selectedCategoryId,
                          items: [
                            const AppDropdownItem(value: null, label: 'اختر التصنيف'),
                            ...mainCategories.map((c) => AppDropdownItem(value: c.id, label: c.name)),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedCategoryId = val;
                              _selectedSubCategoryId = null; // Reset sub-category when main changes
                            });
                          },
                        ),
                        if (_selectedCategoryId != null) ...[
                          Builder(
                            builder: (context) {
                              final subCategories = categories.where((c) => c.parentId == _selectedCategoryId).toList();
                              if (subCategories.isEmpty) return const SizedBox.shrink();
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  AppDropdown<int?>(
                                    label: 'التصنيف الفرعي',
                                    value: _selectedSubCategoryId,
                                    items: [
                                      const AppDropdownItem(value: null, label: 'اختر التصنيف الفرعي'),
                                      ...subCategories.map((c) => AppDropdownItem(value: c.id, label: c.name)),
                                    ],
                                    onChanged: (val) => setState(() => _selectedSubCategoryId = val),
                                  ),
                                ],
                              );
                            },
                          ),
                        ]
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'الأولوية',
                        value: _selectedPriority,
                        items: const [
                          AppDropdownItem(value: 'low', label: 'منخفضة'),
                          AppDropdownItem(value: 'medium', label: 'متوسطة'),
                          AppDropdownItem(value: 'high', label: 'عالية'),
                          AppDropdownItem(value: 'critical', label: 'حرجة'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPriority = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'المصدر',
                        value: _selectedSource,
                        items: const [
                          AppDropdownItem(value: 'manual', label: 'يدوي'),
                          AppDropdownItem(value: 'whatsapp', label: 'واتساب'),
                          AppDropdownItem(value: 'email', label: 'بريد إلكتروني'),
                          AppDropdownItem(value: 'chat_widget', label: 'محادثة'),
                          AppDropdownItem(value: 'phone', label: 'هاتف'),
                          AppDropdownItem(value: 'api', label: 'API'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSource = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                BlocBuilder<TicketsCubit, TicketsState>(
                  builder: (context, state) {
                    final isLoading = state is TicketsLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: AppElevatedButton(
                        text: widget.ticket != null ? 'تحديث التذكرة' : 'إنشاء التذكرة',
                        onPressed: isLoading ? () {} : _save,
                        isLoading: isLoading,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColorScheme.primary,
      ),
    );
  }
}
