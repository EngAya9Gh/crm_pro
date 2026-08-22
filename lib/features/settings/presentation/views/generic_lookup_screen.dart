import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_dropdown.dart'; // Import AppDropdown
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../bloc/lookups_bloc.dart';
import '../bloc/lookups_event.dart';
import '../bloc/lookups_state.dart';
import '../bloc/settings_crud_bloc.dart';
import '../bloc/settings_crud_event.dart';
import '../bloc/settings_crud_state.dart';
import '../../domain/entities/lookup_entities.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_all_lookups_usecase.dart'; // Import AllLookups

enum LookupType {
  status,
  source,
  behavior,
  invalidReason,
  clientTag,
  invoiceTag,
  product,
  commentType,
  region,
  city,
}

class GenericLookupScreen extends StatelessWidget {
  final String title;
  final LookupType type;

  const GenericLookupScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<LookupsBloc>()..add(LoadAllLookups())),
        BlocProvider(create: (_) => getIt<SettingsCrudBloc>()),
      ],
      child: GenericLookupView(title: title, type: type),
    );
  }
}

class GenericLookupView extends StatelessWidget {
  final String title;
  final LookupType type;

  const GenericLookupView({super.key, required this.title, required this.type});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      actions: [
        IconButton(
          onPressed: () => _showAddEditDialog(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: AppColorScheme.primary),
          ),
        ),
      ],
      body: BlocListener<SettingsCrudBloc, SettingsCrudState>(
        listener: (context, state) {
          if (state is SettingsCrudSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColorScheme.success,
              ),
            );
            context.read<LookupsBloc>().add(LoadAllLookups());
          } else if (state is SettingsCrudFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<LookupsBloc, LookupsState>(
          builder: (context, state) {
            if (state is LookupsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LookupsLoaded) {
              final items = _getItems(state.lookups);

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 80,
                        color: AppColorScheme.textMuted.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'لا توجد بيانات بـ $title',
                        style: const TextStyle(color: AppColorScheme.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildCard(context, item);
                },
              );
            }
            return const Center(child: AppText('حدث خطأ في تحميل البيانات'));
          },
        ),
      ),
    );
  }

  List<dynamic> _getItems(AllLookups lookups) {
    switch (type) {
      case LookupType.status:
        return lookups.clientStatuses;
      case LookupType.source:
        return lookups.sources;
      case LookupType.behavior:
        return lookups.behaviors;
      case LookupType.invalidReason:
        return lookups.invalidReasons;
      case LookupType.clientTag:
        return lookups.clientTags;
      case LookupType.invoiceTag:
        return lookups.invoiceTags;
      case LookupType.product:
        return lookups.products;
      case LookupType.commentType:
        return lookups.commentTypes;
      case LookupType.region:
        return lookups.regions;
      case LookupType.city:
        return lookups.cities;
    }
  }

  Widget _buildCard(BuildContext context, dynamic item) {
    String name = '';
    String? subtitle;
    int id = 0;

    // Extract info based on type via reflection-like checks or explicit casting
    // Since dynamic is used, we assume fields exist.
    // Most entities have 'name', 'id'.
    // Status has 'color'. Region has 'cities'.
    try {
      name = item.name;
      id = item.id;
    } catch (_) {}

    if (item is StatusEntity) {
      // Assuming color is hex string? Or Color object? Entity usually has helper.
      // If it's a string like "#FFFFFF", we might need parsing.
      // Usually entities don't have Color objects but strings.
      // Let's assume it's just a string for now or ignored.
    }

    if (item is Product) {
      subtitle = 'السعر: ${item.price}';
    } else if (item is CityEntity) {
      subtitle = 'المنطقة: ${item.regionId}';
      // We can't easily get region name without lookup properly, keeping it simple.
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        title: AppText(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? AppText(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.circle,
            size: 12,
            color: AppColorScheme.primary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: AppColorScheme.info,
                size: 20,
              ),
              onPressed: () => _showAddEditDialog(context, item: item),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: AppColorScheme.error,
                size: 20,
              ),
              onPressed: () => _confirmDelete(context, id, name),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {dynamic item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final extraController =
        TextEditingController(); // For price, description, etc.
    final isEditing = item != null;

    // Special handling for City (Region dropdown)
    dynamic selectedRegion;
    List<RegionEntity> regions = [];
    if (type == LookupType.city) {
      final state = context.read<LookupsBloc>().state;
      if (state is LookupsLoaded) {
        regions = state.lookups.regions;
        if (isEditing && item is CityEntity) {
          try {
            selectedRegion = regions.firstWhere((r) => r.id == item.regionId);
          } catch (_) {}
        }
      }
    }

    if (item is Product) {
      extraController.text = item.price.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      isEditing ? 'تعديل $title' : 'إضافة $title',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: nameController,
                      label: 'الاسم',
                      hintText: 'أدخل الاسم',
                    ),
                    const SizedBox(height: 16),

                    if (type == LookupType.product)
                      AppTextField(
                        controller: extraController,
                        label: 'السعر',
                        hintText: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                    if (type == LookupType.city)
                      AppDropdown<RegionEntity>(
                        label: 'المنطقة',
                        hint: 'اختر المنطقة',
                        value: selectedRegion,
                        legacyItems: regions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        itemLabel: (region) => region.name,
                        onChanged: (val) {
                          setState(() {
                            selectedRegion = val;
                          });
                        },
                      ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty) return;

                        Map<String, dynamic> data = {
                          'name': nameController.text,
                        };

                        if (type == LookupType.product) {
                          data['price'] =
                              double.tryParse(extraController.text) ?? 0;
                        }
                        if (type == LookupType.city) {
                          if (selectedRegion == null) return;
                          data['region_id'] = selectedRegion.id;
                        }

                        final bloc = context.read<SettingsCrudBloc>();

                        if (isEditing) {
                          _dispatchUpdate(bloc, type, item.id, data);
                        } else {
                          _dispatchCreate(bloc, type, data);
                        }
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AppText(isEditing ? 'حفظ' : 'إضافة'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText('حذف $title'),
        content: AppText('هل أنت متأكد من حذف "$name"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _dispatchDelete(context.read<SettingsCrudBloc>(), type, id);
            },
            child: const AppText('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _dispatchCreate(
    SettingsCrudBloc bloc,
    LookupType type,
    Map<String, dynamic> data,
  ) {
    switch (type) {
      case LookupType.status:
        bloc.add(CreateStatusEvent(data));
        break;
      case LookupType.source:
        bloc.add(CreateSourceEvent(data));
        break;
      case LookupType.behavior:
        bloc.add(CreateBehaviorEvent(data));
        break;
      case LookupType.invalidReason:
        bloc.add(CreateInvalidReasonEvent(data));
        break;
      case LookupType.clientTag:
        bloc.add(CreateTagEvent(data));
        break;
      case LookupType.invoiceTag:
        bloc.add(CreateInvoiceTagEvent(data));
        break;
      case LookupType.product:
        bloc.add(CreateProductEvent(data));
        break; // Need CreateProductEvent
      case LookupType.commentType:
        bloc.add(CreateCommentTypeEvent(data));
        break;
      case LookupType.region:
        bloc.add(CreateRegionEvent(data));
        break;
      case LookupType.city:
        bloc.add(CreateCityEvent(data));
        break;
    }
  }

  void _dispatchUpdate(
    SettingsCrudBloc bloc,
    LookupType type,
    int id,
    Map<String, dynamic> data,
  ) {
    switch (type) {
      case LookupType.status:
        bloc.add(UpdateStatusEvent(id, data));
        break;
      case LookupType.source:
        bloc.add(UpdateSourceEvent(id, data));
        break;
      case LookupType.behavior:
        bloc.add(UpdateBehaviorEvent(id, data));
        break;
      case LookupType.invalidReason:
        bloc.add(UpdateInvalidReasonEvent(id, data));
        break;
      case LookupType.clientTag:
        bloc.add(UpdateTagEvent(id, data));
        break;
      case LookupType.invoiceTag:
        bloc.add(UpdateInvoiceTagEvent(id, data));
        break;
      case LookupType.product:
        bloc.add(UpdateProductEvent(id, data));
        break;
      case LookupType.commentType:
        bloc.add(UpdateCommentTypeEvent(id, data));
        break;
      case LookupType.region:
        bloc.add(UpdateRegionEvent(id, data));
        break;
      case LookupType.city:
        bloc.add(UpdateCityEvent(id, data));
        break;
    }
  }

  void _dispatchDelete(SettingsCrudBloc bloc, LookupType type, int id) {
    switch (type) {
      case LookupType.status:
        bloc.add(DeleteStatusEvent(id));
        break;
      case LookupType.source:
        bloc.add(DeleteSourceEvent(id));
        break;
      case LookupType.behavior:
        bloc.add(DeleteBehaviorEvent(id));
        break;
      case LookupType.invalidReason:
        bloc.add(DeleteInvalidReasonEvent(id));
        break;
      case LookupType.clientTag:
        bloc.add(DeleteTagEvent(id));
        break;
      case LookupType.invoiceTag:
        bloc.add(DeleteInvoiceTagEvent(id));
        break;
      case LookupType.product:
        bloc.add(DeleteProductEvent(id));
        break;
      case LookupType.commentType:
        bloc.add(DeleteCommentTypeEvent(id));
        break;
      case LookupType.region:
        bloc.add(DeleteRegionEvent(id));
        break;
      case LookupType.city:
        bloc.add(DeleteCityEvent(id));
        break;
    }
  }
}
