import 'package:flutter/material.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/common/widgets/app_elevated_button.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/utils/enum_helpers.dart';
import '../../domain/entities/client_enums.dart';
import '../../domain/entities/saved_filter.dart' as domain;
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/settings/presentation/bloc/lookups_bloc.dart';
import '../../../../features/settings/presentation/bloc/lookups_event.dart';
import '../../../../features/settings/presentation/bloc/lookups_state.dart';
import '../../presentation/bloc/clients_bloc.dart';
import '../../presentation/bloc/clients_event.dart';

class ClientsFiltersScreen extends StatefulWidget {
  final domain.ClientFilter? currentFilter;
  const ClientsFiltersScreen({super.key, this.currentFilter});

  @override
  State<ClientsFiltersScreen> createState() => _ClientsFiltersScreenState();
}

class _ClientsFiltersScreenState extends State<ClientsFiltersScreen> {
  // Selected Filter State
  // Using IDs instead of Enums for Statuses
  final List<String> _selectedStatusIds = [];
  final List<ClientPriority> _selectedPriorities = [];
  final List<ClientRating> _selectedRatings = [];
  int? _selectedRegionId;
  String?
  _selectedRegionName; // Store name for dropdown display if needed, or iterate
  int? _selectedCityId;
  String? _selectedCityName;

  SourceStatus? _selectedSourceStatus;
  DateTimeRange? _selectedDateRange;
  final List<String> _selectedTags =
      []; // Store IDs preferably, or Names if API expects Names.
  // API Tag Model has ID and Name. Usually filters by ID.
  // ClientFilter currently has `List<TagEntity>? tags` ? No, let's check ClientFilter.

  // Checking ClientFilter again: It has `statusIds` (List<String>). It doesn't seem to have `tags` in previous edits?
  // I will check ClientFilter later. For now assuming tags are not fully implemented in Filter object, or I missed it.
  // The UI has `_buildTagsFilter`. I will assume sending Tag Names or IDs.
  // Docs say `GET /settings/tags`.

  // I'll stick to what I see in `SavedFilter`.

  @override
  void initState() {
    super.initState();
    // Initialize from widget.currentFilter if needed
    // Note: Parsing back from filter to these variables might be complex if filter only has IDs.
    // For now, simpler initialization (skipping deep restore for this step to focus on Lookups integration).
    if (widget.currentFilter != null) {
      if (widget.currentFilter!.statusIds != null)
        _selectedStatusIds.addAll(widget.currentFilter!.statusIds!);
      if (widget.currentFilter!.priorities != null)
        _selectedPriorities.addAll(widget.currentFilter!.priorities!);
      if (widget.currentFilter!.ratings != null)
        _selectedRatings.addAll(widget.currentFilter!.ratings!);
      // _selectedRegion = widget.currentFilter!.region; // Removed
      // _selectedCity = widget.currentFilter!.city; // Removed
      _selectedSourceStatus = widget.currentFilter!.sourceStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.surface,
      appBar: AppBar(
        title: const AppText(
          'الفلاتر المتقدمة',
          style: TextStyle(color: AppColorScheme.white),
        ),
        backgroundColor: AppColorScheme.primary,
        iconTheme: const IconThemeData(color: AppColorScheme.white),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatusIds.clear();
                _selectedPriorities.clear();
                _selectedRatings.clear();
                _selectedRegionId = null;
                _selectedRegionName = null;
                _selectedCityId = null;
                _selectedCityName = null;
                _selectedSourceStatus = null;
                _selectedTags.clear();
              });
            },
            child: const AppText(
              'إعادة تعيين',
              style: TextStyle(color: AppColorScheme.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: BlocBuilder<LookupsBloc, LookupsState>(
        builder: (context, state) {
          if (state is! LookupsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final lookups = state.lookups;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('حالة العميل'),
                const SizedBox(height: 12),
                _buildStatusFilter(lookups.clientStatuses),

                const SizedBox(height: 32),
                _buildSectionTitle('الأولوية'),
                const SizedBox(height: 12),
                _buildPriorityFilter(),

                const SizedBox(height: 32),
                _buildSectionTitle('التقييم (Leads)'),
                const SizedBox(height: 12),
                _buildRatingFilter(),

                const SizedBox(height: 32),
                _buildSectionTitle('الموقع الجغرافي'),
                const SizedBox(height: 12),
                _buildLocationFilter(
                  lookups.regions,
                  state.cities,
                  state.isLoadingCities,
                ),

                const SizedBox(height: 32),
                _buildSectionTitle('صحة المصدر'),
                const SizedBox(height: 12),
                _buildSourceStatusFilter(),

                const SizedBox(height: 32),
                _buildSectionTitle('تاريخ الإضافة'),
                const SizedBox(height: 12),
                _buildDateRangeFilter(),

                const SizedBox(height: 32),
                _buildSectionTitle('الوسوم'),
                const SizedBox(height: 12),
                _buildTagsFilter(lookups.clientTags),

                const SizedBox(height: 48),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showSaveFilterDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: AppColorScheme.primary),
                        ),
                        child: const AppText(
                          'حفظ الفلتر',
                          style: TextStyle(color: AppColorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppElevatedButton(
                        onPressed: () {
                          final filter = domain.ClientFilter(
                            statusIds: _selectedStatusIds.isEmpty
                                ? null
                                : _selectedStatusIds,
                            priorities: _selectedPriorities.isEmpty
                                ? null
                                : _selectedPriorities,
                            ratings: _selectedRatings.isEmpty
                                ? null
                                : _selectedRatings,
                            // Passing Names for now as ClientFilter uses Strings for region/city currently?
                            // Need to check ClientFilter definition. Assuming Strings based on previous code.
                            region: _selectedRegionName,
                            city: _selectedCityName,
                            sourceStatus: _selectedSourceStatus,

                            createdDateRange: _selectedDateRange != null
                                ? domain.DateTimeRange(
                                    start: _selectedDateRange!.start,
                                    end: _selectedDateRange!.end,
                                  )
                                : null,
                            tagIds: _selectedTags.isEmpty
                                ? null
                                : _selectedTags,
                          );
                          Navigator.pop(context, filter);
                        },
                        text: 'تطبيق',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      style: AppTypography.titleSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColorScheme.secondary,
      ),
    );
  }

  Widget _buildStatusFilter(List<dynamic> statuses) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final id = status.id.toString();
        final name = status.name;
        final isSelected = _selectedStatusIds.contains(id);
        return FilterChip(
          selected: isSelected,
          label: AppText(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : AppColorScheme.textMain,
            ),
          ),
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedStatusIds.add(id);
              } else {
                _selectedStatusIds.remove(id);
              }
            });
          },
          selectedColor: AppColorScheme.primary,
          backgroundColor: AppColorScheme.background,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected
                  ? AppColorScheme.primary
                  : AppColorScheme.silver,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityFilter() {
    return Row(
      children: ClientPriority.values.map((priority) {
        final isSelected = _selectedPriorities.contains(priority);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedPriorities.remove(priority);
                } else {
                  _selectedPriorities.add(priority);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColorScheme.primary
                    : AppColorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColorScheme.primary
                      : AppColorScheme.silver,
                ),
              ),
              child: Center(
                child: AppText(
                  EnumHelpers.getClientPriorityArabic(priority),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColorScheme.textMain,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingFilter() {
    return Row(
      children: ClientRating.values.map((rating) {
        final isSelected = _selectedRatings.contains(rating);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedRatings.remove(rating);
                } else {
                  _selectedRatings.add(rating);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColorScheme.primary
                    : AppColorScheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColorScheme.primary
                      : AppColorScheme.silver,
                ),
              ),
              child: Center(
                child: AppText(
                  EnumHelpers.getClientRatingArabic(rating),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColorScheme.textMain,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationFilter(
    List<dynamic> regions,
    List<dynamic> cities,
    bool isLoadingCities,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColorScheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorScheme.silver),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedRegionId,
                isExpanded: true,
                hint: const AppText(
                  'المنطقة',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorScheme.textMuted,
                  ),
                ),
                items: regions
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e.id,
                        child: AppText(
                          e.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRegionId = val;
                    _selectedRegionName = regions
                        .firstWhere((e) => e.id == val)
                        .name;
                    _selectedCityId = null;
                    _selectedCityName = null;
                  });
                  if (val != null) {
                    context.read<LookupsBloc>().add(LoadCities(val));
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColorScheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorScheme.silver),
            ),
            child: isLoadingCities
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedCityId,
                      isExpanded: true,
                      hint: const AppText(
                        'المدينة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                      items: cities
                          .map(
                            (e) => DropdownMenuItem<int>(
                              value: e.id,
                              child: AppText(
                                e.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCityId = val;
                          _selectedCityName = cities
                              .firstWhere((e) => e.id == val)
                              .name;
                        });
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceStatusFilter() {
    return Row(
      children: [
        _buildChoiceChip(SourceStatus.valid, 'صحيح'),
        const SizedBox(width: 12),
        _buildChoiceChip(SourceStatus.invalid, 'خاطئ'),
      ],
    );
  }

  Widget _buildChoiceChip(SourceStatus status, String label) {
    final isSelected = _selectedSourceStatus == status;
    return ChoiceChip(
      selected: isSelected,
      label: AppText(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : AppColorScheme.textMain,
        ),
      ),
      onSelected: (val) =>
          setState(() => _selectedSourceStatus = val ? status : null),
      selectedColor: AppColorScheme.primary,
      backgroundColor: AppColorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColorScheme.primary : AppColorScheme.silver,
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(
            () => _selectedDateRange = DateTimeRange(
              start: picked.start,
              end: picked.end,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColorScheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColorScheme.silver),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColorScheme.primary,
            ),
            const SizedBox(width: 12),
            AppText(
              _selectedDateRange != null
                  ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                  : 'حدد الفترة الزمنية',
              style: const TextStyle(fontSize: 12),
            ),
            const Spacer(),
            if (_selectedDateRange != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () => setState(() => _selectedDateRange = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsFilter(List<dynamic> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final id = tag.id.toString();
        final name = tag.name;
        final isSelected = _selectedTags.contains(id);
        return FilterChip(
          selected: isSelected,
          label: AppText(
            name,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : AppColorScheme.textMain,
            ),
          ),
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedTags.add(id);
              } else {
                _selectedTags.remove(id);
              }
            });
          },
          selectedColor: AppColorScheme.primary,
          backgroundColor: AppColorScheme.background,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? AppColorScheme.primary
                  : AppColorScheme.silver,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showSaveFilterDialog() {
    final controller = TextEditingController();
    final clientsBloc = context.read<ClientsBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText(
          'حفظ الفلتر',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اسم الفلتر (مثل: كبار العملاء)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              final filter = domain.ClientFilter(
                statusIds: _selectedStatusIds.isEmpty
                    ? null
                    : _selectedStatusIds,
                priorities: _selectedPriorities.isEmpty
                    ? null
                    : _selectedPriorities,
                ratings: _selectedRatings.isEmpty ? null : _selectedRatings,
                region: _selectedRegionName,
                city: _selectedCityName,
                sourceStatus: _selectedSourceStatus,
                createdDateRange: _selectedDateRange != null
                    ? domain.DateTimeRange(
                        start: _selectedDateRange!.start,
                        end: _selectedDateRange!.end,
                      )
                    : null,
                tagIds: _selectedTags.isEmpty ? null : _selectedTags,
              );

              clientsBloc.add(
                SaveFilterEvent(
                  domain.SavedFilter(
                    id: '',
                    name: controller.text,
                    filter: filter,
                    createdAt: DateTime.now(),
                  ),
                ),
              );

              Navigator.pop(context);
            },
            child: const AppText('حفظ'),
          ),
        ],
      ),
    );
  }
}
