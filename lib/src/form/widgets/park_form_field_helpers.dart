import 'package:flutter/material.dart';
import '../../../park_ui.dart';

/// 通过 options 解析当前值文案。
///
/// 使用 [optionLabelKey] 和 [optionValueKey]
/// 从选项中查找显示文本。
String resolveOptionLabel({
  required List<Map<String, dynamic>> options,
  required dynamic selectedValue,
  required String fallback,
  required String optionLabelKey,
  required String optionValueKey,
}) {
  for (final Map<String, dynamic> option in options) {
    if (option[optionValueKey] == selectedValue) {
      return option[optionLabelKey]?.toString() ?? fallback;
    }
  }
  return fallback;
}

/// 读取父节点的子节点集合。
///
/// 使用 [optionValueKey] 和 [optionChildrenKey]
/// 进行键名匹配。
List<Map<String, dynamic>> childrenOf(
  List<Map<String, dynamic>> source,
  dynamic selectedValue, {
  required String optionValueKey,
  required String optionChildrenKey,
}) {
  if (selectedValue == null) {
    return const <Map<String, dynamic>>[];
  }
  final Map<String, dynamic>? selected = source
      .cast<Map<String, dynamic>?>()
      .firstWhere(
        (Map<String, dynamic>? item) => item?[optionValueKey] == selectedValue,
        orElse: () => null,
      );
  if (selected == null || selected[optionChildrenKey] is! List<dynamic>) {
    return const <Map<String, dynamic>>[];
  }
  return (selected[optionChildrenKey] as List<dynamic>)
      .map((dynamic item) => Map<String, dynamic>.from(item as Map))
      .toList();
}

/// 弹出底部选项面板。
///
/// 使用 [optionLabelKey] 和 [optionValueKey]
/// 渲染选项列表。
Future<dynamic> showOptionBottomSheet(
  BuildContext context, {
  required String title,
  required List<Map<String, dynamic>> options,
  required dynamic selectedValue,
  required String optionLabelKey,
  required String optionValueKey,
}) async {
  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      final l10n = ParkLocalizations.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...options.map((Map<String, dynamic> item) {
                final bool selected = item[optionValueKey] == selectedValue;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(item[optionValueKey]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(item[optionLabelKey]?.toString() ?? '')),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              ParkButton(
                variant: ParkButtonVariant.text,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelText),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 弹出底部地区选择面板。
Future<Map<String, dynamic>?> showRegionBottomSheet({
  required BuildContext context,
  required List<Map<String, dynamic>> provinceOptions,
  required dynamic selectedProvince,
  required dynamic selectedCity,
  required dynamic selectedDistrict,
  required int level,
  required String provinceKey,
  required String cityKey,
  required String districtKey,
  required String labelName,
  required String optionLabelKey,
  required String optionValueKey,
  required String optionChildrenKey,
}) async {
  dynamic tempProvince = selectedProvince;
  dynamic tempCity = selectedCity;
  dynamic tempDistrict = selectedDistrict;

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          final l10n = ParkLocalizations.of(context);
          final List<Map<String, dynamic>> cityOptions = childrenOf(
            provinceOptions,
            tempProvince,
            optionValueKey: optionValueKey,
            optionChildrenKey: optionChildrenKey,
          );
          final List<Map<String, dynamic>> districtOptions = childrenOf(
            cityOptions,
            tempCity,
            optionValueKey: optionValueKey,
            optionChildrenKey: optionChildrenKey,
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.selectField(labelName),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ParkSelect(
                    items: provinceOptions
                        .map(
                          (Map<String, dynamic> item) => ParkSelectOption(
                            label: item['label']?.toString() ?? '',
                            value: item['value']?.toString() ?? '',
                          ),
                        )
                        .toList(),
                    value: tempProvince?.toString(),
                    hintText: l10n.selectProvince,
                    onChanged: (String? changed) {
                      setSheetState(() {
                        tempProvince = changed;
                        tempCity = null;
                        tempDistrict = null;
                      });
                    },
                  ),
                  if (level >= 2) ...<Widget>[
                    const SizedBox(height: 8),
                    ParkSelect(
                      items: cityOptions
                          .map(
                            (Map<String, dynamic> item) => ParkSelectOption(
                              label: item['label']?.toString() ?? '',
                              value: item['value']?.toString() ?? '',
                            ),
                          )
                          .toList(),
                      value: tempCity?.toString(),
                      hintText: l10n.selectCity,
                      enabled: tempProvince != null,
                      onChanged: tempProvince == null
                          ? null
                          : (String? changed) {
                              setSheetState(() {
                                tempCity = changed;
                                tempDistrict = null;
                              });
                            },
                    ),
                  ],
                  if (level >= 3) ...<Widget>[
                    const SizedBox(height: 8),
                    ParkSelect(
                      items: districtOptions
                          .map(
                            (Map<String, dynamic> item) => ParkSelectOption(
                              label: item['label']?.toString() ?? '',
                              value: item['value']?.toString() ?? '',
                            ),
                          )
                          .toList(),
                      value: tempDistrict?.toString(),
                      hintText: l10n.selectDistrict,
                      enabled: tempProvince != null && tempCity != null,
                      onChanged: (tempProvince == null || tempCity == null)
                          ? null
                          : (String? changed) {
                              setSheetState(() {
                                tempDistrict = changed;
                              });
                            },
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ParkButton(
                          variant: ParkButtonVariant.secondary,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancelText),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ParkButton(
                          variant: ParkButtonVariant.primary,
                          onPressed: () {
                            Navigator.of(context).pop(<String, dynamic>{
                              provinceKey: tempProvince,
                              cityKey: tempCity,
                              districtKey: tempDistrict,
                            });
                          },
                          child: Text(l10n.confirmText),
                        ),
                      ),
                    ],
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
