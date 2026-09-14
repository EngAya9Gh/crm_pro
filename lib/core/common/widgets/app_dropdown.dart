import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../config/theme/color_scheme.dart';
import '../../config/theme/typography.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;

  /// Smart items: list of [AppDropdownItem] for full search support.
  final List<AppDropdownItem<T>>? items;

  /// Legacy compatibility: pass [DropdownMenuItem]s from old code.
  final List<DropdownMenuItem<T>>? legacyItems;

  /// Required when [legacyItems] is used — extracts the display string for each item.
  final String Function(T)? itemLabel;

  final String? label;
  final String? hint;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  /// Set to false to disable the search box (for small lists like status dropdowns).
  final bool showSearchBox;

  const AppDropdown({
    super.key,
    this.value,
    this.items,
    this.legacyItems,
    this.itemLabel,
    this.label,
    this.hint,
    this.onChanged,
    this.validator,
    this.showSearchBox = true,
  }) : assert(
         items != null || legacyItems != null,
         'Either items or legacyItems must be provided',
       );

  List<AppDropdownItem<T>> _resolveItems() {
    if (items != null) return items!;
    return legacyItems!.map((item) {
      String displayLabel = '';
      if (itemLabel != null && item.value != null) {
        displayLabel = itemLabel!(item.value as T);
      } else {
        final child = item.child;
        if (child is Text && child.data != null) {
          displayLabel = child.data!;
        } else if (child is Padding) {
          final inner = child.child;
          if (inner is Text && inner.data != null) displayLabel = inner.data!;
        }
      }
      return AppDropdownItem<T>(label: displayLabel, value: item.value as T);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedItems = _resolveItems();
    final selectedItem = value != null
        ? resolvedItems.where((i) => i.value == value).firstOrNull
        : null;

    PopupProps<AppDropdownItem<T>> popupProps;

    final itemBuilderFn =
        (
          BuildContext ctx,
          AppDropdownItem<T> item,
          bool isDisabled,
          bool isSelected,
        ) {
          return ListTile(
            dense: true,
            title: Text(
              item.label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? AppColorScheme.primary
                    : AppColorScheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedTileColor: AppColorScheme.primary.withOpacity(0.08),
          );
        };

    if (showSearchBox) {
      popupProps = PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: const TextFieldProps(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'ابحث...',
            prefixIcon: Icon(Icons.search, size: 20),
            isDense: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        constraints: const BoxConstraints(maxHeight: 320),
        menuProps: const MenuProps(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        itemBuilder: itemBuilderFn,
      );
    } else {
      popupProps = PopupProps.menu(
        showSearchBox: false,
        constraints: const BoxConstraints(maxHeight: 280),
        menuProps: const MenuProps(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        itemBuilder: itemBuilderFn,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownSearch<AppDropdownItem<T>>(
          selectedItem: selectedItem,
          items: (filter, loadProps) {
            if (filter.isEmpty) return resolvedItems;
            final words = filter.trim().toLowerCase().split(RegExp(r'\s+'));
            return resolvedItems.where((item) {
              final lbl = item.label.toLowerCase();
              return words.every((word) => lbl.contains(word));
            }).toList();
          },
          compareFn: (a, b) => a.value == b.value,
          itemAsString: (item) => item.label,
          onSelected: (item) => onChanged?.call(item?.value),
          validator: validator != null
              ? (item) => validator!(item?.value)
              : null,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: null, // Used in dropdownBuilder instead
              filled: true,
              fillColor: AppColorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColorScheme.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColorScheme.error, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down_circle_outlined),
            ),
          ),
          dropdownBuilder: (context, selectedItem) {
            if (selectedItem == null) {
              return Text(
                hint ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColorScheme.textMuted,
                ),
              );
            }
            return Text(selectedItem.label, style: AppTypography.bodyMedium);
          },
          popupProps: popupProps,
        ),
      ],
    );
  }
}

class AppDropdownItem<T> {
  final String label;
  final T value;

  const AppDropdownItem({required this.label, required this.value});
}
