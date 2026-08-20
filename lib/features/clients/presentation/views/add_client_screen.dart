import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_elevated_button.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import 'package:crm_wakeel/core/utils/enum_helpers.dart';
import '../../domain/entities/client_enums.dart';
import '../../domain/entities/client.dart';
import '../../data/models/client_model.dart';
// Alias client entities to avoid conflict
import '../../domain/entities/status_entity.dart' as client_status;
import '../../domain/entities/tag_entity.dart' as client_tag;
import '../bloc/clients_bloc.dart';
import '../bloc/clients_event.dart';
import '../bloc/clients_state.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_bloc.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_event.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_state.dart';
// Alias settings entities
import 'package:crm_wakeel/features/settings/domain/entities/lookup_entities.dart'
    as settings;

class AddClientScreen extends StatefulWidget {
  final Client? client;
  const AddClientScreen({super.key, this.client});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();

  // Selected Values using Settings entities for selection where appropriate, or client entities
  // Regions, Cities, Sources come from Lookups (Settings)
  ClientPriority _priority = ClientPriority.medium;
  settings.RegionEntity? _selectedRegion;
  settings.CityEntity? _selectedCity;
  settings.SourceEntity? _selectedSource;
  ClientRating? _selectedRating;

  // Selected Tags must specificy which TagEntity. Since we submit ClientModel which uses client_tag.TagEntity.
  List<client_tag.TagEntity> _selectedTags = [];

  bool _isEditing = false;
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.client != null;
    if (_isEditing) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _emailController.text = widget.client!.email ?? '';
      _companyController.text = widget.client!.company ?? '';
      _addressController.text = widget.client!.address ?? '';
      _priority = widget.client!.priority;
      _selectedRating = widget.client!.leadRating;
      _selectedTags = List.from(widget.client!.tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<LookupsBloc>()..add(LoadAllLookups()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColorScheme.surface,
        appBar: AppBar(
          title: AppText(
            _isEditing ? 'تعديل بيانات العميل' : 'إضافة عميل جديد',
            style: const TextStyle(color: AppColorScheme.white),
          ),
          backgroundColor: AppColorScheme.primary,
          iconTheme: const IconThemeData(color: AppColorScheme.white),
          elevation: 0,
          centerTitle: true,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ClientsBloc, ClientsState>(
              listener: (context, state) {
                if (state is ClientsLoaded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(
                        _isEditing
                            ? 'تم تحديث بيانات العميل بنجاح'
                            : 'تم إضافة العميل بنجاح',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColorScheme.success,
                    ),
                  );
                  Navigator.pop(context);
                } else if (state is ClientsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AppText(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: AppColorScheme.error,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              },
            ),
            BlocListener<LookupsBloc, LookupsState>(
              listener: (context, state) {
                if (state is LookupsLoaded &&
                    _isEditing &&
                    !_initialDataLoaded) {
                  try {
                    if (widget.client!.regionId != null) {
                      final matchedRegion = state.lookups.regions.where(
                        (r) => r.id == widget.client!.regionId,
                      );
                      if (matchedRegion.isNotEmpty) {
                        _selectedRegion = matchedRegion.first;
                        context.read<LookupsBloc>().add(
                          LoadCities(_selectedRegion!.id),
                        );
                      }
                    }
                    if (widget.client!.sourceId != null) {
                      final sId = int.tryParse(widget.client!.sourceId!);
                      if (sId != null) {
                        try {
                          _selectedSource = state.lookups.sources.firstWhere(
                            (s) => s.id == sId,
                          );
                        } catch (_) {}
                      }
                    }
                    setState(() {});
                  } catch (e) {
                    debugPrint('Error matching initial values: $e');
                  }
                  _initialDataLoaded = true;
                }

                if (state is LookupsLoaded &&
                    _isEditing &&
                    state.cities.isNotEmpty &&
                    _selectedCity == null &&
                    widget.client!.cityId != null) {
                  final matchedCity = state.cities.where(
                    (c) => c.id == widget.client!.cityId,
                  );
                  if (matchedCity.isNotEmpty) {
                    setState(() {
                      _selectedCity = matchedCity.first;
                    });
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<LookupsBloc, LookupsState>(
            builder: (context, state) {
              if (state is LookupsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<settings.RegionEntity> regions = [];
              List<settings.SourceEntity> sources = [];
              List<settings.CityEntity> cities = [];

              if (state is LookupsLoaded) {
                regions = state.lookups.regions;
                sources = state.lookups.sources;
                cities = state.cities;
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('المعلومات الأساسية'),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _nameController,
                        hintText: 'اسم العميل المباشر أو الشركة *',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColorScheme.primary,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        hintText: 'رقم الهاتف *',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColorScheme.primary,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        hintText: 'البريد الإلكتروني',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColorScheme.primary,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _companyController,
                        hintText: 'اسم الجهة / الشركة',
                        prefixIcon: const Icon(
                          Icons.business_outlined,
                          color: AppColorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle('الموقع'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<settings.RegionEntity>(
                              label: 'المنطقة *',
                              value: _selectedRegion,
                              items: regions,
                              itemLabel: (item) => item.name,
                              onChanged: (val) {
                                setState(() {
                                  _selectedRegion = val;
                                  _selectedCity = null;
                                });
                                if (val != null) {
                                  context.read<LookupsBloc>().add(
                                    LoadCities(val.id),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<settings.CityEntity>(
                              label: 'المدينة *',
                              value: _selectedCity,
                              items: cities,
                              itemLabel: (item) => item.name,
                              isLoading:
                                  state is LookupsLoaded &&
                                  state.isLoadingCities,
                              onChanged: (val) =>
                                  setState(() => _selectedCity = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _addressController,
                        hintText: 'العنوان بالتفصيل',
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 32),
                      _buildSectionTitle('التصنيف'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<settings.SourceEntity>(
                              label: 'المصدر *',
                              value: _selectedSource,
                              items: sources,
                              itemLabel: (item) => item.name,
                              onChanged: (val) =>
                                  setState(() => _selectedSource = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPrioritySelector()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRatingSelector(),

                      const SizedBox(height: 32),
                      _buildTagsSection(state),

                      const SizedBox(height: 48),
                      BlocBuilder<ClientsBloc, ClientsState>(
                        builder: (context, state) {
                          if (state is ClientsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return AppElevatedButton(
                            onPressed: () => _submitForm(context),
                            text: _isEditing ? 'حفظ التعديلات' : 'حفظ العميل ✓',
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedRegion == null) {
        _showToast(context, 'الرجاء اختيار المنطقة');
        return;
      }
      if (_selectedCity == null) {
        _showToast(context, 'الرجاء اختيار المدينة');
        return;
      }
      if (_selectedSource == null) {
        _showToast(context, 'الرجاء اختيار المصدر');
        return;
      }

      final newClient = ClientModel(
        id: _isEditing ? widget.client!.id : '0',
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        region: _selectedRegion!.name,
        regionId: _selectedRegion!.id,
        city: _selectedCity!.name,
        cityId: _selectedCity!.id,
        sourceId: _selectedSource!.id.toString(),
        priority: _priority,
        leadRating: _selectedRating,
        // Ensure status is client_status.StatusEntity
        status: _isEditing
            ? widget.client!.status
            : const client_status.StatusEntity(
                id: 1,
                name: 'جديد',
                color: '#000000',
              ),

        // Note: Default StatusEntity used above. Need to be sure constructor matches.
        // In client_status.StatusEntity, fields are: id, name, color.
        // Wait, client_status.StatusEntity (from clients/.../status_entity.dart) has id, name, color.
        // settings.StatusEntity (from lookup_entities.dart) has id, name, color, order, weight, isDefault.
        // If I use client_status, I should check its constructor.
        sourceStatus: _isEditing
            ? widget.client!.sourceStatus
            : SourceStatus.valid,
        createdAt: _isEditing ? widget.client!.createdAt : DateTime.now(),
        tags: _selectedTags,
        files: [],
        comments: [],
        invoices: [],
        appointments: [],
        timeline: [],
      );

      if (_isEditing) {
        context.read<ClientsBloc>().add(UpdateClientEvent(newClient));
      } else {
        context.read<ClientsBloc>().add(AddClientEvent(newClient));
      }
    }
  }

  Widget _buildTagsSection(LookupsState state) {
    if (state is! LookupsLoaded) return const SizedBox.shrink();
    final allTags = state.lookups.clientTags; // settings.TagEntity

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('الأوسمة (Tags)'),
        const SizedBox(height: 12),
        if (allTags.isEmpty)
          const AppText(
            'لا توجد أوسمة معرفة في الإعدادات',
            style: TextStyle(fontSize: 12, color: AppColorScheme.textMuted),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTags.map((tag) {
              final isSelected = _selectedTags.any((t) => t.id == tag.id);
              final tagName = tag.name;
              final tagColor = tag.color;

              return FilterChip(
                label: AppText(
                  tagName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColorScheme.textMain,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      // Map settings.TagEntity to client_tag.TagEntity
                      _selectedTags.add(
                        client_tag.TagEntity(
                          id: tag.id,
                          name: tagName,
                          color: tagColor,
                        ),
                      );
                    } else {
                      _selectedTags.removeWhere((t) => t.id == tag.id);
                    }
                  });
                },
                selectedColor: AppColorScheme.primary,
                checkmarkColor: Colors.white,
                backgroundColor: AppColorScheme.silver.withOpacity(0.3),
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
      ],
    );
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'تصنيف العميل (Rating)',
          style: TextStyle(fontSize: 12, color: AppColorScheme.textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          children: ClientRating.values.map((rating) {
            final isSelected = _selectedRating == rating;
            Color ratingColor = Colors.grey;
            switch (rating) {
              case ClientRating.hot:
                ratingColor = Colors.red;
                break;
              case ClientRating.warm:
                ratingColor = Colors.orange;
                break;
              case ClientRating.cold:
                ratingColor = Colors.blue;
                break;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRating = rating),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ratingColor.withOpacity(0.1)
                        : AppColorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? ratingColor : AppColorScheme.silver,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: isSelected ? ratingColor : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        EnumHelpers.getClientRatingArabic(rating),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? ratingColor
                              : AppColorScheme.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColorScheme.secondary,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required Function(T?) onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: const TextStyle(fontSize: 12, color: AppColorScheme.textMuted),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColorScheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColorScheme.silver),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    // Ensure the value exists in items or is null
                    items: items
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: AppText(
                              itemLabel(e),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                    hint: AppText(
                      'اختر...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'الأولوية *',
          style: TextStyle(fontSize: 12, color: AppColorScheme.textMuted),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColorScheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColorScheme.silver),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ClientPriority>(
              value: _priority,
              isExpanded: true,
              items: ClientPriority.values.map((e) {
                String text = '';
                switch (e) {
                  case ClientPriority.high:
                    text = 'عالية';
                    break;
                  case ClientPriority.medium:
                    text = 'متوسطة';
                    break;
                  case ClientPriority.low:
                    text = 'منخفضة';
                    break;
                }
                return DropdownMenuItem(
                  value: e,
                  child: AppText(text, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _priority = val!),
            ),
          ),
        ),
      ],
    );
  }
}
