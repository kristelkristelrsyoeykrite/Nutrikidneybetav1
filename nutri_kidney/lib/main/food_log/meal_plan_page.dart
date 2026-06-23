import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/food_nutrient_normalizer.dart';
import '../food_log.dart';

/// A full-page view for displaying generated meal plans.
/// Not added to the nav bar — only navigated to when a meal plan is generated.
class MealPlanPage extends StatefulWidget {
  final Map<String, dynamic> mealPlan;
  final String? profileUserId;
  final String selectedDate;
  final Future<void> Function(Map<String, dynamic>) onAddMealPlan;

  const MealPlanPage({
    super.key,
    required this.mealPlan,
    this.profileUserId,
    required this.selectedDate,
    required this.onAddMealPlan,
  });

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  int _selectedDayIndex = 0;
  String? _expandedComponentKey;
  bool _isAddingPlan = false;

  List<Map<String, dynamic>> get _days => _mealPlanDays(widget.mealPlan);
  List<Map<String, dynamic>> get _meals => _mealPlanMeals(widget.mealPlan);

  Map<String, dynamic> get _profile => widget.mealPlan['nutritionProfile'] is Map
      ? Map<String, dynamic>.from(widget.mealPlan['nutritionProfile'] as Map)
      : const <String, dynamic>{};

  Map<String, dynamic> get _restrictions => widget.mealPlan['restrictions'] is Map
      ? Map<String, dynamic>.from(widget.mealPlan['restrictions'] as Map)
      : const <String, dynamic>{};

  String _nutrientDisplay(dynamic value) {
    final parsed = _doubleValue(value);
    if (parsed == null || parsed <= 0) return '—';
    if (parsed == parsed.roundToDouble()) return parsed.toInt().toString();
    return parsed.toStringAsFixed(1);
  }

  String _nutrientWithUnit(dynamic value, String unit) {
    final display = _nutrientDisplay(value);
    return display == '—' ? '—' : '$display $unit';
  }

  double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  Map<String, dynamic>? _fluidContributionMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  double? _fluidMlFromContribution(Map<String, dynamic>? fluidContribution) {
    if (fluidContribution == null) return null;
    return _doubleValue(
      fluidContribution['total_fluid_contribution_ml'] ??
          fluidContribution['totalFluidContributionMl'] ??
          fluidContribution['water_content_ml'] ??
          fluidContribution['waterContentMl'] ??
          fluidContribution['waterMl'] ??
          fluidContribution['water_ml'],
    );
  }

  double? _componentFluidMl(Map<String, dynamic> component) {
    final direct = _doubleValue(
      component['waterMl'] ?? component['water_ml'] ?? component['fluid_ml'],
    );
    if (direct != null && direct > 0) return direct;
    final fluidContribution = _fluidContributionMap(
      component['fluidContribution'] ?? component['fluid_contribution'],
    );
    final fromContribution = _fluidMlFromContribution(fluidContribution);
    return fromContribution != null && fromContribution > 0
        ? fromContribution
        : null;
  }

  double? _mealFluidMl(
    Map<String, dynamic> meal,
    List<Map<String, dynamic>> components,
  ) {
    final direct = _doubleValue(
      meal['waterMl'] ?? meal['water_ml'] ?? meal['fluid_ml'],
    );
    if (direct != null && direct > 0) return direct;
    double total = 0;
    for (final component in components) {
      total += _componentFluidMl(component) ?? 0;
    }
    return total > 0 ? total : null;
  }

  String _fluidDisplay(dynamic value) {
    final parsed = _doubleValue(value);
    if (parsed == null || parsed <= 0) {
      return 'No fluid contribution available';
    }
    return '${_nutrientDisplay(parsed)} mL';
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _mealPlanDayLabel(String? date, int index) {
    if (date == widget.selectedDate) return 'Today';
    final parsed = DateTime.tryParse(date ?? '');
    if (parsed != null) {
      final tomorrow = DateFormat('yyyy-MM-dd').format(
        DateTime.now().add(const Duration(days: 1)),
      );
      if (date == tomorrow) return 'Tomorrow';
      return DateFormat('MMM d').format(parsed);
    }
    return 'Day ${index + 1}';
  }

  String _mealPlanDateSubtitle(String? date) {
    if (date == null) return '';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return DateFormat('EEEE, MMM d, yyyy').format(parsed);
  }

  List<Map<String, dynamic>> _mealPlanMeals(Map<String, dynamic> mealPlan) {
    final days = mealPlan['days'];
    if (days is List && days.isNotEmpty) {
      return days
          .whereType<Map>()
          .expand((rawDay) {
            final day = Map<String, dynamic>.from(rawDay);
            final date = day['date']?.toString();
            final meals = day['meals'];
            if (meals is! List) return const <Map<String, dynamic>>[];
            return meals.whereType<Map>().map((rawMeal) {
              return {
                if (date != null) 'date': date,
                ...Map<String, dynamic>.from(rawMeal),
              };
            });
          })
          .toList(growable: false);
    }
    final meals = mealPlan['meals'];
    if (meals is! List) return const <Map<String, dynamic>>[];
    return meals
        .whereType<Map>()
        .map((meal) => Map<String, dynamic>.from(meal))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _mealPlanDays(Map<String, dynamic> mealPlan) {
    final rawDays = mealPlan['days'];
    if (rawDays is List && rawDays.isNotEmpty) {
      return rawDays
          .whereType<Map>()
          .map((day) => Map<String, dynamic>.from(day))
          .toList(growable: false);
    }
    return [
      {
        'date': mealPlan['planDate'] ?? widget.selectedDate,
        'meals': mealPlan['meals'] ?? const [],
        'totals': mealPlan['totals'] ?? const <String, dynamic>{},
      }
    ];
  }

  String _avoidList() {
    final avoid = _restrictions['avoid'];
    if (avoid is List) return avoid.take(8).join(', ');
    return '';
  }

  String _recommendationLine() {
    final history = widget.mealPlan['historyRecommendations'];
    if (history is! Map) return '';
    final messages = history['messages'];
    if (messages is List && messages.isNotEmpty) {
      return messages.take(2).join(' ');
    }
    return '';
  }

  String _profileLine() {
    final parts = <String>[
      if (_profile['stage'] != null) 'CKD ${_profile['stage']}',
      if (_profile['egfr'] != null) 'eGFR ${_profile['egfr']}',
      'K ${_profile['potassiumStatus'] ?? 'Unknown'}',
      'Phos ${_profile['phosphorusStatus'] ?? 'Unknown'}',
      if (_profile['diabetesRisk'] == true) 'diabetes risk',
      'BMI ${_profile['bmiCategory'] ?? 'Unknown'}',
    ];
    return parts.join(' | ');
  }

  Future<void> _saveMealPlan() async {
    setState(() => _isAddingPlan = true);
    try {
      final response = await ApiService.saveMealPlan(
        profileUserId: widget.profileUserId,
        mealPlan: widget.mealPlan,
        date: widget.selectedDate,
      );
      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['awardUnlocked'] == true
                  ? 'Meal plan saved! Award unlocked: Meal Plan Ready.'
                  : 'Meal plan saved! It will appear on your dashboard.',
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception(response['error'] ?? 'Failed to save meal plan.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAddingPlan = false);
    }
  }

  String? get _mealPlanId {
    final explicitId =
        widget.mealPlan['id'] ?? widget.mealPlan['mealPlanId'];
    if (explicitId != null && explicitId.toString().trim().isNotEmpty) {
      return explicitId.toString().trim();
    }

    final ownerId = widget.profileUserId ?? ApiService.userId;
    if (ownerId == null || ownerId.trim().isEmpty) return null;
    final planDate =
        widget.mealPlan['planDate']?.toString().trim().isNotEmpty == true
            ? widget.mealPlan['planDate'].toString().trim()
            : widget.selectedDate;
    return '${ownerId.trim()}_$planDate';
  }

  Future<void> _deleteMealPlan() async {
    final mealPlanId = _mealPlanId;
    if (mealPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save this meal plan before deleting it.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete meal plan?'),
        content: const Text('This saved meal plan will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isAddingPlan = true);
    try {
      final response = await ApiService.deleteMealPlan(
        mealPlanId: mealPlanId,
        profileUserId: widget.profileUserId,
      );
      if (response['success'] == false) {
        throw Exception(response['error'] ?? 'Failed to delete meal plan.');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal plan deleted.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting meal plan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAddingPlan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planDays = _intValue(
      widget.mealPlan['planDays'] ?? _days.length,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF37474F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$planDays-Day Meal Plan',
          style: const TextStyle(
            color: Color(0xFF37474F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // Save Meal Plan Button
          _isAddingPlan
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton.icon(
                  onPressed: _saveMealPlan,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text(
                    'Save Meal Plan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00897B),
                  ),
                ),
          // Ellipsis menu
          PopupMenuButton<int>(
            tooltip: 'More options',
            itemBuilder: (context) => const [
              PopupMenuItem<int>(
                value: 1,
                child: Text('Regenerate Plan'),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text('Delete Meal Plan'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Color(0xFF37474F)),
            onSelected: (value) async {
              if (value == 1) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Go to Food Log to generate a new plan.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (value == 2) {
                await _deleteMealPlan();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile summary + restrictions bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profileLine(),
                  style: const TextStyle(
                    color: Color(0xFF37474F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_avoidList().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Avoid or limit: ${_avoidList()}',
                    style: const TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Day selector tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _days.asMap().entries.map((entry) {
                  final day = entry.value;
                  final isSelected = entry.key == _selectedDayIndex;
                  final date = day['date']?.toString();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedDayIndex = entry.key;
                        _expandedComponentKey = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00BFA5)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _mealPlanDayLabel(date, entry.key),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF37474F),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (date != null)
                              Text(
                                DateFormat('MMM d').format(
                                  DateTime.tryParse(date) ?? DateTime.now(),
                                ),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : const Color(0xFF90A4AE),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Main content
          Expanded(
            child: _days.isEmpty
                ? const Center(child: Text('No meal plan data'))
                : _buildDayContent(_days[_selectedDayIndex]),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(Map<String, dynamic> day) {
    final dayMeals = day['meals'] is List
        ? (day['meals'] as List)
            .whereType<Map>()
            .map((meal) => Map<String, dynamic>.from(meal))
            .toList(growable: false)
        : <Map<String, dynamic>>[];
    final dayTotals = day['totals'] is Map
        ? Map<String, dynamic>.from(day['totals'] as Map)
        : <String, dynamic>{};
    final date = day['date']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date subtitle
          if (date != null) ...[
            Text(
              _mealPlanDateSubtitle(date),
              style: const TextStyle(
                color: Color(0xFF00695C),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Meals
          if (dayMeals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.restaurant_outlined,
                      color: Color(0xFFB0BEC5), size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No meals planned for this day yet.',
                    style: TextStyle(color: Color(0xFF78909C), fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...dayMeals.map((meal) => _buildMealCard(meal, date)),
          // Day totals
          if (dayTotals.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTotalsCard(dayTotals, 'Day Totals'),
          ],
          // Weekly totals at bottom of last day
          if (_selectedDayIndex == _days.length - 1) ...[
            const SizedBox(height: 12),
            _buildTotalsCard(
              widget.mealPlan['weeklyTotals'] is Map
                  ? Map<String, dynamic>.from(
                      widget.mealPlan['weeklyTotals'] as Map)
                  : <String, dynamic>{},
              'Weekly Averages',
              isWeekly: true,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, String? plannedDate) {
    final mealType = meal['mealType']?.toString() ?? 'Meal';
    final name = meal['name']?.toString() ?? 'Food';
    final expansionKey = [
      plannedDate ?? widget.selectedDate,
      mealType,
      meal['foodId']?.toString() ?? name,
    ].join('|');
    final portion = meal['portion']?.toString() ?? '1 serving';
    final matchConfidence = meal['matchConfidence']?.toString() ?? '';
    final source = meal['source']?.toString() ?? '';
    final needsReview = meal['needsManualReview'] == true;
    final isUnresolved = matchConfidence == 'unresolved' || source == 'unresolved_guide_meal_plan';
    final calories = _doubleValue(meal['calories']);
    final protein = _doubleValue(meal['protein']);
    final sodium = _doubleValue(meal['sodium']);
    final potassium = _doubleValue(meal['potassium']);
    final phosphorus = _doubleValue(meal['phosphorus']);
    final components = meal['componentBreakdown'] is List
        ? (meal['componentBreakdown'] as List)
            .whereType<Map>()
            .map((c) => Map<String, dynamic>.from(c))
            .toList(growable: false)
        : <Map<String, dynamic>>[];
    final fluidMl = _mealFluidMl(meal, components);
    final validation = meal['recipeValidation'] is Map
        ? Map<String, dynamic>.from(meal['recipeValidation'] as Map)
        : null;
    final validationPassed = validation?['isAllowed'] == true;

    // Card color based on status
    Color cardBg = Colors.white;
    Color borderColor = const Color(0xFFE0F2F1);
    if (isUnresolved) {
      borderColor = const Color(0xFFFFE082);
      cardBg = const Color(0xFFFFFDF5);
    } else if (needsReview) {
      borderColor = const Color(0xFFFFCC80);
      cardBg = const Color(0xFFFFF8E1);
    } else if (validationPassed) {
      borderColor = const Color(0xFFC8E6C9);
      cardBg = const Color(0xFFF1F8E9);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: meal type + status pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mealType,
                  style: const TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isUnresolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Guide only',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (needsReview && !isUnresolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(
                      color: Color(0xFFF57F17),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (validationPassed && !isUnresolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Validated',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Name
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF37474F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          // Portion + calories
          Row(
            children: [
              if (!isUnresolved && calories != null && calories > 0) ...[
                Text(
                  '$portion',
                  style: const TextStyle(
                    color: Color(0xFF607D8B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  isUnresolved
                      ? 'No exact database match — use as a meal idea'
                      : '${_nutrientDisplay(calories)} kcal',
                  style: TextStyle(
                    color: isUnresolved
                        ? const Color(0xFFBF360C)
                        : const Color(0xFF78909C),
                    fontSize: 12,
                    fontStyle: isUnresolved ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
          // Nutrition row (only show if not unresolved and has data)
          if (!isUnresolved) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildMiniNutrientPill('Protein', _nutrientDisplay(protein), 'g'),
                _buildMiniNutrientPill('Sodium', _nutrientDisplay(sodium), 'mg'),
                _buildMiniNutrientPill('K', _nutrientDisplay(potassium), 'mg'),
                _buildMiniNutrientPill('Phos', _nutrientDisplay(phosphorus), 'mg'),
                _buildFluidContributionPill(fluidMl),
              ],
            ),
          ],
          // Match info
          if (matchConfidence.isNotEmpty && !isUnresolved) ...[
            const SizedBox(height: 8),
            Text(
              _matchLine(meal),
              style: const TextStyle(
                color: Color(0xFF78909C),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
          // Component breakdown expandable
          if (components.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _expandedComponentKey =
                      _expandedComponentKey == expansionKey ? null : expansionKey;
                });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.list_alt_outlined,
                    size: 16,
                    color: Color(0xFF00897B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${components.length} ingredients',
                    style: const TextStyle(
                      color: Color(0xFF00897B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expandedComponentKey == expansionKey
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                    color: const Color(0xFF00897B),
                  ),
                ],
              ),
            ),
            if (_expandedComponentKey == expansionKey) ...[
              const SizedBox(height: 8),
              ...components.map((component) {
                final compNutrients = component['nutrients'] is Map
                    ? Map<String, dynamic>.from(component['nutrients'] as Map)
                    : <String, dynamic>{};
                final compName = component['displayName']?.toString() ??
                    component['genericName']?.toString() ??
                    component['matchedName']?.toString() ??
                    component['component']?.toString() ??
                    'Food';
                final compFluidMl = _componentFluidMl(component);
                final compNutritionLine = compFluidMl != null
                    ? '${_nutrientDisplay(compNutrients['calories'])} kcal · ${_nutrientDisplay(compFluidMl)} mL fluid'
                    : '${_nutrientDisplay(compNutrients['calories'])} kcal · No fluid contribution available';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: Color(0xFFB0BEC5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              compName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Color(0xFF546E7A),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              compNutritionLine,
                              softWrap: true,
                              style: const TextStyle(
                                color: Color(0xFF78909C),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
          // Add to food log button inline
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
onPressed: _isAddingPlan
                  ? null
                  : (widget.mealPlan.isEmpty)
                      ? null
                      : (plannedDate != null && plannedDate != widget.selectedDate)
                          ? null
                          : () async {

                      setState(() => _isAddingPlan = true);
                      try {
                        final dayDate = plannedDate ?? widget.selectedDate;

                        // Expand the meal into its component ingredients so the food log
                        // contains each ingredient as a separate entry (e.g. "Cauliflower"
                        // then "Rice").
                        final expandedMeals = components.isNotEmpty
                            ? components
                                .map((component) {
                                  // Normalize nutrient payload across multiple backend shapes.
                                  // Goal: ensure protein/sodium/potassium/phosphorus are always
                                  // available at BOTH top-level keys and inside nutrientPreview.

                                  Map<String, dynamic> normalizedNutrients =
                                      <String, dynamic>{};

                                  Map<String, dynamic> extractFrom(dynamic source) {
                                    if (source is! Map) return const <String, dynamic>{};
                                    final map =
                                        Map<String, dynamic>.from(source as Map);

                                    // Common wrappers:
                                    // - { firstNormalized: { ... } }
                                    // - first_normalized / firstNormalized at component root
                                    if (map['firstNormalized'] is Map) {
                                      return Map<String, dynamic>.from(
                                        (map['firstNormalized'] as Map),
                                      );
                                    }
                                    if (map['first_normalized'] is Map) {
                                      return Map<String, dynamic>.from(
                                        (map['first_normalized'] as Map),
                                      );
                                    }

                                    return map;
                                  }

                                  // Try known nutrient sources on the component.
                                  normalizedNutrients =
                                      extractFrom(component['nutrients']);

                                  if (normalizedNutrients.isEmpty) {
                                    normalizedNutrients =
                                        extractFrom(component['nutrientPreview']);
                                  }

                                  // Also try nested normalized wrappers explicitly.
                                  final nuts = component['nutrients'];
                                  if (normalizedNutrients.isEmpty && nuts is Map) {
                                    normalizedNutrients = extractFrom(
                                      nuts['firstNormalized'] ??
                                          nuts['first_normalized'],
                                    );
                                  }

                                  // Final fallbacks at component root.
                                  if (normalizedNutrients.isEmpty) {
                                    normalizedNutrients = extractFrom(
                                      component['firstNormalized'] ??
                                          component['first_normalized'],
                                    );
                                  }

                                  // If still empty, allow a last-chance direct read in case the
                                  // backend already put nutrients at the expected keys.
                                  if (normalizedNutrients.isEmpty) {
                                    final direct = extractFrom(component);
                                    if (direct['protein'] != null ||
                                        direct['calories'] != null) {
                                      normalizedNutrients = direct;
                                    }
                                  }

                                  normalizedNutrients = normalizeFoodNutrients({
                                    ...component,
                                    'nutrientPreview': normalizedNutrients,
                                  });

                                  final fluidContribution = component['fluidContribution'] is Map
                                      ? Map<String, dynamic>.from(
                                          component['fluidContribution'] as Map,
                                        )
                                      : component['fluid_contribution'] is Map
                                          ? Map<String, dynamic>.from(
                                              component['fluid_contribution'] as Map,
                                            )
                                          : null;

                                  final compName =
                                      component['displayName']?.toString() ??
                                          component['genericName']?.toString() ??
                                          component['matchedName']?.toString() ??
                                          component['component']?.toString() ??
                                          'Ingredient';

                                  double? toNum(dynamic v) {
                                    if (v is num) return v.toDouble();
                                    if (v == null) return null;
                                    return double.tryParse(v.toString());
                                  }

                                  return <String, dynamic>{
                                    'mealType': meal['mealType'] ?? 'Meal',
                                    'name': compName,
                                    'foodId': component['foodId']?.toString(),
                                    'servingId': component['servingId']?.toString(),
                                    'servingDescription':
                                        component['servingDescription']?.toString() ??
                                            component['servingLabel']?.toString() ??
                                            '1 serving',
                                    'portion':
                                        component['displayAmount']?.toString() ??
                                            component['portion']?.toString() ??
                                            component['servingDescription']?.toString() ??
                                            component['servingLabel']?.toString() ??
                                            '1 serving',
                                    'numberOfServings': toNum(
                                      component['numberOfServings'] ??
                                          component['servings'],
                                    ),
                                    'quantity': toNum(
                                      component['numberOfServings'] ??
                                          component['servings'],
                                    ),
                                    'servingNutrients':
                                        component['servingNutrients'],
                                    'displayAmount':
                                        component['displayAmount']?.toString() ??
                                            component['portion']?.toString(),
                                    'servingMetadata':
                                        component['servingMetadata'],
                                    'matchConfidence': component['matchConfidence']?.toString() ?? '',
                                    'source': component['source']?.toString() ?? '',
                                    'needsManualReview':
                                        component['needsManualReview'] == true,

                                    // Top-level nutrients (used by FoodLogPage)
                                    'calories': toNum(normalizedNutrients['calories']),
                                    'protein': toNum(normalizedNutrients['protein']),
                                    'carbohydrate': toNum(
                                      normalizedNutrients['carbohydrate'] ??
                                          normalizedNutrients['carb'] ??
                                          normalizedNutrients['carbs'],
                                    ),
                                    'fat': toNum(normalizedNutrients['fat']),
                                    'sodium': toNum(normalizedNutrients['sodium']),
                                    'potassium': toNum(normalizedNutrients['potassium']),
                                    'phosphorus':
                                        toNum(normalizedNutrients['phosphorus']),
                                    'waterMl': toNum(
                                      normalizedNutrients['waterMl'] ??
                                      normalizedNutrients['water_ml'] ??
                                      component['waterMl'] ??
                                      component['water_ml'] ??
                                      fluidContribution?[
                                          'total_fluid_contribution_ml'] ??
                                      fluidContribution?[
                                          'totalFluidContributionMl'] ??
                                      fluidContribution?['water_content_ml'] ??
                                      fluidContribution?['waterContentMl'] ??
                                      fluidContribution?['waterMl'] ??
                                      fluidContribution?['water_ml'],
                                    ),
                                    'fluidContribution': fluidContribution,

                                    // Keep nutrient breakdown for downstream use
                                    'componentBreakdown':
                                        component['componentBreakdown'],

                                    // Ensure nutrientPreview matches the normalized nutrient map.
                                    'nutrientPreview':
                                        normalizedNutrients.isNotEmpty
                                            ? normalizedNutrients
                                            : (component['nutrientPreview'] ??
                                                normalizedNutrients),

                                    // Provide the raw ingredient name too
                                    'component':
                                        component['component']?.toString(),
                                  };
                                })
                                .toList(growable: false)
                            : [meal];

                        // Build totals by summing nutrients from each expanded ingredient.
                        // This ensures FoodLog receives protein/sodium/potassium/phosphorus,
                        // not just calories.
                        Map<String, dynamic> computedTotals = <String, dynamic>{};
                        double sumCalories = 0;
                        double sumProtein = 0;
                        double sumSodium = 0;
                        double sumPotassium = 0;
                        double sumPhosphorus = 0;
                        double sumWaterMl = 0;
                        for (final m in expandedMeals) {
                          if (m is Map<String, dynamic>) {
                            final c = m['calories'];
                            final p = m['protein'];
                            final so = m['sodium'];
                            final k = m['potassium'];
                            final ph = m['phosphorus'];
                            final water = m['waterMl'] ?? m['water_ml'];

                            double? toD(dynamic v) {
                              if (v is num) return v.toDouble();
                              return v == null ? null : double.tryParse(v.toString());
                            }

                            sumCalories += toD(c) ?? 0;
                            sumProtein += toD(p) ?? 0;
                            sumSodium += toD(so) ?? 0;
                            sumPotassium += toD(k) ?? 0;
                            sumPhosphorus += toD(ph) ?? 0;
                            sumWaterMl += toD(water) ?? 0;
                          }
                        }

                        computedTotals = <String, dynamic>{
                          'calories': sumCalories,
                          'protein': sumProtein,
                          'sodium': sumSodium,
                          'potassium': sumPotassium,
                          'phosphorus': sumPhosphorus,
                          'waterMl': sumWaterMl,
                        };

                        await widget.onAddMealPlan({
                          'planDate': dayDate,
                          'planDays': 1,
                          'days': [
                            {
                              'date': dayDate,
                              'meals': expandedMeals,
                              'totals': computedTotals,
                            }
                          ],
                          'meals': expandedMeals,
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name added to food log!'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unable to add: $e'),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isAddingPlan = false);
                      }
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00897B),
                side: const BorderSide(color: Color(0xFF80CBC4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.playlist_add_check, size: 18),
              label: const Text(
                'Add to Log',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _matchLine(Map<String, dynamic> meal) {
    final confidence = meal['matchConfidence']?.toString() ?? '';
    if (confidence == 'partial') {
      return 'Partial recipe match — nutrition may be estimated.';
    }
    if ((meal['recipeValidation'] is Map) &&
        Map<String, dynamic>.from(meal['recipeValidation'] as Map)['isAllowed'] == true) {
      return 'Recipe passed ingredient validation.';
    }
    if ((meal['componentBreakdown'] is List) &&
        (meal['componentBreakdown'] as List).isNotEmpty) {
      return 'Nutrition estimated from ingredient breakdown.';
    }
    if (meal['needsManualReview'] == true) {
      return 'Review before logging.';
    }
    return '';
  }

  Widget _buildMiniNutrientPill(String label, String value, String unit) {
    final hasValue = value != '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasValue
            ? const Color(0xFFFAFAFA)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasValue
              ? const Color(0xFFE0E0E0)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: hasValue
                  ? const Color(0xFF90A4AE)
                  : const Color(0xFFB0BEC5),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasValue ? '$value $unit' : '—',
            style: TextStyle(
              color: hasValue
                  ? const Color(0xFF37474F)
                  : const Color(0xFFBDBDBD),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFluidContributionPill(double? fluidMl) {
    final hasFluid = fluidMl != null && fluidMl > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasFluid
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasFluid
              ? const Color(0xFFBBDEFB)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fluid',
            style: TextStyle(
              color: hasFluid
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFB0BEC5),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasFluid
                ? '${_nutrientDisplay(fluidMl)} mL'
                : 'No fluid contribution available',
            style: TextStyle(
              color: hasFluid
                  ? const Color(0xFF0D47A1)
                  : const Color(0xFF78909C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(Map<String, dynamic> totals, String title,
      {bool isWeekly = false}) {
    final hasCalories = _doubleValue(totals['calories']) != null &&
        (_doubleValue(totals['calories']) ?? 0) > 0;
    final hasProtein = _doubleValue(totals['protein']) != null &&
        (_doubleValue(totals['protein']) ?? 0) > 0;
    final hasSodium = _doubleValue(totals['sodium']) != null &&
        (_doubleValue(totals['sodium']) ?? 0) > 0;
    final hasPotassium = _doubleValue(totals['potassium']) != null &&
        (_doubleValue(totals['potassium']) ?? 0) > 0;
    final hasPhosphorus = _doubleValue(totals['phosphorus']) != null &&
        (_doubleValue(totals['phosphorus']) ?? 0) > 0;
    final fluidMl = _doubleValue(
      totals['waterMl'] ?? totals['water_ml'] ?? totals['fluid_ml'],
    );
    final hasFluid = fluidMl != null && fluidMl > 0;
    final anyNutrient = hasCalories ||
        hasProtein ||
        hasSodium ||
        hasPotassium ||
        hasPhosphorus ||
        hasFluid;
    final prefix = isWeekly ? 'Avg ' : '';

    if (!anyNutrient) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWeekly
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWeekly
              ? const Color(0xFFC8E6C9)
              : const Color(0xFFDCEDC8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWeekly ? Icons.date_range : Icons.today,
                size: 18,
                color: isWeekly
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF558B2F),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isWeekly
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF33691E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasCalories)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${prefix}Calories: ${_nutrientDisplay(totals['calories'])} kcal',
                style: const TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 13,
                ),
              ),
            ),
          if (hasProtein)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${prefix}Protein: ${_nutrientDisplay(totals['protein'])} g',
                style: const TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 13,
                ),
              ),
            ),
          if (hasSodium)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${prefix}Sodium: ${_nutrientDisplay(totals['sodium'])} mg',
                style: const TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 13,
                ),
              ),
            ),
          if (hasPotassium)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${prefix}Potassium: ${_nutrientDisplay(totals['potassium'])} mg',
                style: const TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 13,
                ),
              ),
            ),
          if (hasPhosphorus)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${prefix}Phosphorus: ${_nutrientDisplay(totals['phosphorus'])} mg',
                style: const TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 13,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${prefix}Fluid: ${_fluidDisplay(fluidMl)}',
              style: const TextStyle(
                color: Color(0xFF37474F),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
