part of '../food_log.dart';

class FoodItem {
  final String? id;
  final String? foodId;
  final String? servingId;
  final String emoji;
  final String name;
  final String portion;
  final double quantity;
  final int calories;
  final String time;
  final double protein;
  final double carbohydrate;
  final double fat;
  final double sodium;
  final double potassium;
  final double phosphorus;
  final double calcium;
  final double waterMl;
  final Map<String, dynamic>? fluidContribution;
  final String source;
  final bool needsManualReview;
  final Map<String, dynamic>? raw;

  FoodItem({
    this.id,
    this.foodId,
    this.servingId,
    required this.emoji,
    required this.name,
    required this.portion,
    this.quantity = 1,
    required this.calories,
    required this.time,
    this.protein = 0,
    this.carbohydrate = 0,
    this.fat = 0,
    this.sodium = 0,
    this.potassium = 0,
    this.phosphorus = 0,
    this.calcium = 0,
    this.waterMl = 0,
    this.fluidContribution,
    this.source = 'manual_entry',
    this.needsManualReview = false,
    this.raw,
  });

  factory FoodItem.fromLog(Map<String, dynamic> data) {
    final nutrients = normalizeFoodNutrients(data);
    final raw = data['raw'] is Map
        ? Map<String, dynamic>.from(data['raw'] as Map)
        : null;
    final fluidContribution = data['fluidContribution'] is Map
      ? Map<String, dynamic>.from(data['fluidContribution'] as Map)
      : data['fluid_contribution'] is Map
        ? Map<String, dynamic>.from(data['fluid_contribution'] as Map)
        : null;
    return FoodItem(
      id: data['id']?.toString(),
      foodId: (data['foodId'] ?? raw?['foodId'])?.toString(),
      servingId: (data['servingId'] ??
              data['selectedServingId'] ??
              raw?['servingId'])
          ?.toString(),
      emoji: '\u{1F37D}\u{FE0F}',
      name: data['name']?.toString() ?? 'Food',
      portion: (data['servingDescription'] ??
              data['portion'] ??
              raw?['servingDescription'])
          ?.toString() ??
          '1 serving',
      quantity: _asDouble(
        data['numberOfServings'] ??
            data['quantity'] ??
            data['selectedQuantity'] ??
            raw?['numberOfServings'] ??
            1,
      ),
      calories: _asInt(nutrients['calories']),
      time: _formatDisplayTime(data['createdAt']),
      protein: _asDouble(nutrients['protein']),
      carbohydrate: _asDouble(nutrients['carbohydrate']),
      fat: _asDouble(nutrients['fat']),
      sodium: _asDouble(nutrients['sodium']),
      potassium: _asDouble(nutrients['potassium']),
      phosphorus: _asDouble(nutrients['phosphorus']),
      calcium: _asDouble(nutrients['calcium']),
      waterMl: _asDouble(data['waterMl'] ?? data['water_ml']),
      fluidContribution: fluidContribution,
      source: data['source']?.toString() ?? 'manual_entry',
      needsManualReview: data['needsManualReview'] == true,
      raw: raw,
    );
  }

  factory FoodItem.fromCatalog(Map<String, dynamic> data) {
    final nutrients = normalizeFoodNutrients(data);
    return FoodItem(
      foodId: data['foodId']?.toString(),
      servingId: data['servingId']?.toString(),
      emoji: '\u{1F37D}\u{FE0F}',
      name: data['name']?.toString() ?? 'Food',
      portion: data['servingDescription']?.toString() ?? '1 serving',
      quantity: _asDouble(data['quantity'] ?? 1),
      calories: _asInt(nutrients['calories']),
      time: DateFormat('h:mm a').format(DateTime.now()),
      protein: _asDouble(nutrients['protein']),
      carbohydrate: _asDouble(nutrients['carbohydrate']),
      fat: _asDouble(nutrients['fat']),
      sodium: _asDouble(nutrients['sodium']),
      potassium: _asDouble(nutrients['potassium']),
      phosphorus: _asDouble(nutrients['phosphorus']),
      calcium: _asDouble(nutrients['calcium']),
      waterMl: _asDouble(data['waterMl'] ?? data['water_ml']),
      fluidContribution: data['fluidContribution'] is Map
          ? Map<String, dynamic>.from(data['fluidContribution'] as Map)
          : data['fluid_contribution'] is Map
            ? Map<String, dynamic>.from(data['fluid_contribution'] as Map)
            : null,
      source: data['source']?.toString() ?? 'fatsecret',
      needsManualReview: data['needsManualReview'] == true,
      raw: data,
    );
  }
}

double _asDouble(dynamic value) {
  return parseFoodNutrientNumber(value) ?? 0;
}

int _asInt(dynamic value) => _asDouble(value).round();

String _formatDisplayTime(dynamic value) {
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  if (parsed == null) return DateFormat('h:mm a').format(DateTime.now());
  return DateFormat('h:mm a').format(parsed.toLocal());
}
