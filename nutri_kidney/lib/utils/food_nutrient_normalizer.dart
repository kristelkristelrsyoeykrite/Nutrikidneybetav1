const Map<String, List<String>> foodNutrientAliases = {
  'calories': ['calories', 'calorie', 'energy', 'energy_kcal', 'energyKcal'],
  'protein': ['protein', 'protein_g', 'proteinG'],
  'carbohydrate': [
    'carbohydrate', 'carbohydrates', 'carbs', 'carb',
    'carbohydrate_g', 'carbohydrateG',
  ],
  'fat': ['fat', 'total_fat', 'totalFat', 'fat_g', 'fatG'],
  'sodium': ['sodium', 'sodium_mg', 'sodiumMg'],
  'potassium': ['potassium', 'potassium_mg', 'potassiumMg'],
  'phosphorus': [
    'phosphorus', 'phosphorous', 'phosphorus_mg', 'phosphorusMg',
  ],
  'calcium': ['calcium', 'calcium_mg', 'calciumMg'],
};

double? parseFoodNutrientNumber(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is Map) {
    return parseFoodNutrientNumber(
      value['value'] ?? value['amount'] ?? value['total'],
    );
  }
  final match = RegExp(r'-?\d+(?:\.\d+)?')
      .firstMatch((value?.toString() ?? '').replaceAll(',', ''));
  return double.tryParse(match?.group(0) ?? '');
}

Map<String, dynamic>? _nutrientMap(dynamic value) {
  if (value is! Map) return null;
  final map = Map<String, dynamic>.from(value);
  final nested = map['firstNormalized'] ?? map['first_normalized'] ?? map['nutrients'];
  return nested is Map ? Map<String, dynamic>.from(nested) : map;
}

double? _nutrientValue(Map<String, dynamic> source, String nutrient) {
  for (final alias in foodNutrientAliases[nutrient]!) {
    if (!source.containsKey(alias) || source[alias] == null) continue;
    final parsed = parseFoodNutrientNumber(source[alias]);
    if (parsed != null) return parsed;
  }
  return null;
}

Map<String, dynamic> normalizeFoodNutrients(
  Map<String, dynamic> payload, {
  double multiplier = 1,
  bool includeComponents = true,
}) {
  final raw = payload['raw'] is Map
      ? Map<String, dynamic>.from(payload['raw'] as Map)
      : <String, dynamic>{};
  final candidates = <Map<String, dynamic>>[];
  for (final value in [
    payload['finalNutrients'], payload['final_nutrients'],
    payload['nutrientPreview'], payload['nutrient_preview'], payload['nutrients'],
    payload,
    raw['finalNutrients'], raw['final_nutrients'], raw['nutrientPreview'],
    raw['nutrient_preview'], raw['nutrients'], raw['firstNormalized'],
    raw['first_normalized'],
  ]) {
    final map = _nutrientMap(value);
    if (map != null) candidates.add(map);
  }

  if (includeComponents) {
    final componentValue = payload['componentBreakdown'] ??
        payload['component_breakdown'] ?? payload['components'] ??
        raw['componentBreakdown'] ?? raw['component_breakdown'] ?? raw['components'];
    if (componentValue is List) {
      final totals = <String, dynamic>{
        for (final key in foodNutrientAliases.keys) key: 0.0,
      };
      var found = false;
      for (final value in componentValue.whereType<Map>()) {
        final normalized = normalizeFoodNutrients(
          Map<String, dynamic>.from(value),
          includeComponents: false,
        );
        if (normalized.values.any((value) => (parseFoodNutrientNumber(value) ?? 0) != 0)) {
          found = true;
        }
        for (final key in totals.keys) {
          totals[key] = (parseFoodNutrientNumber(totals[key]) ?? 0) +
              (parseFoodNutrientNumber(normalized[key]) ?? 0);
        }
      }
      if (found) candidates.add(totals);
    }
  }

  final result = <String, dynamic>{};
  for (final nutrient in foodNutrientAliases.keys) {
    final values = candidates
        .map((source) => _nutrientValue(source, nutrient))
        .whereType<double>()
        .toList(growable: false);
    final nonZero = values.where((value) => value != 0);
    final selected = nonZero.isNotEmpty
        ? nonZero.first
        : values.isNotEmpty
            ? values.first
            : 0.0;
    result[nutrient] = selected * multiplier;
  }
  return result;
}
