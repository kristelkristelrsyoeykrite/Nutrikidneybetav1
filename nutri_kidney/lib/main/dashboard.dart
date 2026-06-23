import 'package:flutter/material.dart';
import 'package:nutri_kidney/services/api_service.dart';
import 'package:nutri_kidney/utils/food_nutrient_normalizer.dart';
import 'food_log.dart';
import 'analytics.dart';
import 'health_metrics.dart';
import 'profile.dart';
import 'caregiver_dashboard.dart';

import 'package:intl/intl.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLoadingDashboard = true;
  String? _dashboardError;
  Map<String, dynamic> _user = {};
  Map<String, dynamic> _viewer = {};
  Map<String, dynamic> _caregiverDashboardState = {};
  String? _dashboardOwnerId;
  Map<String, dynamic> _nutritionTargets = {};
  Map<String, dynamic> _medicalProfile = {};
  Map<String, dynamic> _phase2DecisionSupport = {};
  Map<String, dynamic> _gamification = {};
  Map<String, dynamic> _labResults = {};
  Map<String, dynamic> _anthropometrics = {};
  Map<String, dynamic>? _intakeData;
  Map<String, dynamic>? _medicationData;
  Map<String, dynamic>? _todayMealPlan;
  List<Map<String, dynamic>> _medications = [];

  // Animation controllers for alert blinking effects
  late AnimationController _nutritionAlertBlinkController;
  late AnimationController _waterAlertBlinkController;

  String? get _activeProfileUserId =>
      ApiService.selectedManagedChildProfileId ?? ApiService.activeChildProfileId;

  static const double _defaultSodiumTargetMg = 1500;
  static const double _defaultPotassiumTargetMg = 2000;

  int get _medicationTotalCount {
    return _medications.length > 0
        ? _medications.length
        : (_numberFrom(_medicationData?["count"]) ?? 0).toInt();
  }

  bool get _hasMedicationData => _medicationTotalCount > 0;
  bool get _hasNutritionData => _todayMealCount > 0;
  int get _currentStreak {
    final status = _asStringMap(_gamification["status"]);
    return (_numberFrom(status["currentStreak"] ?? status["displayStreak"]) ?? 0)
        .toInt();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize blinking animation controllers for alerts
    _nutritionAlertBlinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _waterAlertBlinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _initializeDashboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nutritionAlertBlinkController.dispose();
    _waterAlertBlinkController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardSummary(forceRefresh: true);
      _loadTodaysMealPlan();
    }
  }

  Future<void> _initializeDashboard() async {
    await _loadDashboardSummary();
    if (!mounted) return;
    await _loadTodaysMealPlan();
  }

  Future<void> _loadTodaysMealPlan() async {
    try {
      final response = await ApiService.getTodaysMealPlan(
        profileUserId: _activeProfileUserId,
        forceRefresh: true,
      );
      if (!mounted) return;

      final mealPlan = response["todaysMealPlan"] ?? response["mealPlan"];

      if (response["success"] == true && mealPlan != null) {
        setState(() {
          _todayMealPlan = _nullableStringMap(mealPlan);
        });
      } else {
        setState(() {
          _todayMealPlan = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading today\'s meal plan: $e');
      if (mounted) {
        setState(() {
          _todayMealPlan = null;
        });
      }
    }
  }

  Future<void> _loadDashboardSummary({bool forceRefresh = false}) async {
    try {
      final requestedProfileUserId = _activeProfileUserId;
      final response = await ApiService.getDashboardSummary(
        profileUserId: requestedProfileUserId,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      if (response["success"] != true) {
        throw Exception(response["error"] ?? "Failed to load dashboard");
      }

      final intakeData = _nullableStringMap(response["intakeData"]) ??
          <String, dynamic>{};
      final responseOwnerId = response["dashboardOwnerId"]?.toString();
      final viewer = _asStringMap(response["viewer"]);
      final viewerRole = (viewer["role"] ?? viewer["userRole"] ?? "")
          .toString()
          .toLowerCase();
      final isCaregiver = viewerRole == "caregiver" ||
          viewerRole == "parent_caregiver";
      // The backend resolves managed/link entry IDs to the adolescent's actual
      // profile owner ID. Keep that canonical ID for subsequent caregiver
      // writes so both accounts read the same nutrition record.
      final effectiveProfileUserId =
          isCaregiver && responseOwnerId != null && responseOwnerId.isNotEmpty
              ? responseOwnerId
              : requestedProfileUserId;

      if (isCaregiver && effectiveProfileUserId != null) {
        ApiService.setSelectedManagedChildProfileId(effectiveProfileUserId);
      }

      // The food-log list is the same source used by Food Log and is more
      // reliable than a cached/missing daily summary. Merge it into the
      // dashboard payload so today's totals cannot remain at zero while the
      // logged foods are already visible on the Food screen.
      try {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final foodLogResponse = await ApiService.getFoodLogs(
          profileUserId: effectiveProfileUserId,
          date: today,
          forceRefresh: forceRefresh,
        );
        final logs = foodLogResponse["logs"];
        if (foodLogResponse["success"] == true && logs is List) {
          intakeData["foodLogs"] = logs;
          intakeData["mealCount"] = logs.length;
          if (logs.isEmpty) {
            intakeData["totals"] = <String, dynamic>{
              "calories": 0,
              "protein": 0,
              "carbohydrate": 0,
              "fat": 0,
              "sodium": 0,
              "potassium": 0,
              "phosphorus": 0,
            };
          }
          debugPrint(
            'Dashboard merged ${logs.length} food logs for $today',
          );
        }
      } catch (error) {
        debugPrint('Dashboard food-log fallback failed: $error');
      }

      setState(() {
        _viewer = viewer;
        _user = _asStringMap(response["user"]);
        _caregiverDashboardState =
            _asStringMap(response["caregiverDashboardState"]);
        _dashboardOwnerId = responseOwnerId;
        if (_isCaregiverDashboard && _dashboardOwnerId != null) {
          final managedChildIds =
              _managedChildren.map((child) => child["id"]).toSet();
          if (!managedChildIds.contains(
            ApiService.selectedManagedChildProfileId,
          )) {
            ApiService.setSelectedManagedChildProfileId(_dashboardOwnerId);
          }
        }
        _nutritionTargets = _asStringMap(response["nutritionTargets"]);
        _medicalProfile = _asStringMap(response["medicalProfile"]);
        _phase2DecisionSupport =
            _asStringMap(response["phase2DecisionSupport"]);
        _gamification = _asStringMap(response["gamification"]);
        _labResults = _asStringMap(response["labResults"]);
        _anthropometrics = _asStringMap(response["anthropometrics"]);
        _intakeData = intakeData.isEmpty ? null : intakeData;
        _medicationData = _nullableStringMap(response["medicationData"]);
        _medications = _asStringMapList(response["medications"]);
        _isLoadingDashboard = false;
        _dashboardError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDashboard = false;
        _dashboardError = e.toString();
      });
    }
  }

  Future<void> _openFoodLogAndRefresh() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodLogPage(
          profileUserId: _activeProfileUserId,
        ),
      ),
    );
    if (!mounted) return;
    await _loadDashboardSummary(forceRefresh: true);
    await _loadTodaysMealPlan();
  }

  Map<String, dynamic> _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  Map<String, dynamic>? _nullableStringMap(dynamic value) {
    final map = _asStringMap(value);
    return map.isEmpty ? null : map;
  }

  List<Map<String, dynamic>> _asStringMapList(dynamic value) {
    if (value is! List) return [];
    return value.map(_asStringMap).where((map) => map.isNotEmpty).toList();
  }

  double? _numberFrom(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  // Parses fluid/weight values commonly sent as:
  // - 250
  // - "250"
  // - "250 mL"
  // - "250ml"
  // Returns the numeric portion as a double.
  double? _numberFromPossiblyUnitString(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final text = value.toString();
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    return match == null ? null : double.tryParse(match.group(1) ?? '');
  }


  String _formatNumber(double value, {int decimals = 0}) {
    final rounded = value.toStringAsFixed(decimals);
    return rounded.endsWith('.0')
        ? rounded.substring(0, rounded.length - 2)
        : rounded;
  }

  String _optionalText(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  String _medicationName(Map<String, dynamic> medication) {
    final name = _optionalText(
      medication["name"] ??
          medication["medicationName"] ??
          medication["medication_name"],
    );
    return name.isEmpty ? "Medication" : name;
  }

  List<String> _medicationTimes(Map<String, dynamic> medication) {
    final scheduledTimes = medication["scheduled_times"];
    if (scheduledTimes is List && scheduledTimes.isNotEmpty) {
      return scheduledTimes
          .map((time) => time.toString().trim())
          .where((time) => time.isNotEmpty)
          .toList();
    }

    final startTime = _optionalText(medication["start_time"]);
    if (RegExp(r"^\d{1,2}:\d{2}$").hasMatch(startTime)) {
      return [startTime];
    }

    return [];
  }

  DateTime? _dateTimeForMedicationTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Map<String, dynamic>? get _nextMedicationReminder {
    Map<String, dynamic>? nextReminder;
    DateTime? nextTime;

    for (final medication in _medications) {
      for (final time in _medicationTimes(medication)) {
        final scheduled = _dateTimeForMedicationTime(time);
        if (scheduled == null) continue;
        if (nextTime == null || scheduled.isBefore(nextTime)) {
          nextTime = scheduled;
          nextReminder = {
            "name": _medicationName(medication),
            "time": scheduled,
          };
        }
      }
    }

    return nextReminder;
  }

  String _formatClockTime(DateTime dateTime) {
    final hour12 = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  String _relativeReminderText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    if (difference.inDays >= 1) return 'Tomorrow';
    if (difference.inHours >= 1) return 'In ${difference.inHours} hours';
    final minutes = difference.inMinutes <= 0 ? 1 : difference.inMinutes;
    return 'In $minutes minutes';
  }

  String get _childName {
    return (_user["childFullName"] ??
            _user["child_name"] ??
            _nutritionTargets["child_name"] ??
            "there")
        .toString();
  }

  String get _childInitials {
    final parts = _childName
        .trim()
        .split(RegExp(r"\s+"))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty || _childName == "there") return "NK";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

  double get _sodiumTargetMg {
    return _numberFrom(
          _nutritionTargets["sodium_target_mg"] ??
              _nutritionTargets["sodiumTargetMg"],
        ) ??
        _defaultSodiumTargetMg;
  }

  double get _potassiumTargetMg {
    return _numberFrom(
          _nutritionTargets["potassium_target_mg"] ??
              _nutritionTargets["potassiumTargetMg"],
        ) ??
        _defaultPotassiumTargetMg;
  }

  double get _proteinTargetG {
    return _numberFrom(
          _nutritionTargets["protein_target_g"] ??
              _nutritionTargets["proteinTargetG"],
        ) ??
        0;
  }

  double get _phosphorusTargetMg {
    return _numberFrom(
          _nutritionTargets["phosphate_target_mg"] ??
              _nutritionTargets["phosphateTargetMg"] ??
              _nutritionTargets["phosphorus_target_mg"] ??
              _nutritionTargets["phosphorusTargetMg"],
        ) ??
        0;
  }

  Map<String, dynamic> get _todayNutritionTotals {
    final foodLogs = _intakeData?["foodLogs"];
    if (foodLogs is List && foodLogs.isNotEmpty) {
      final totals = <String, double>{
        for (final nutrient in foodNutrientAliases.keys) nutrient: 0,
      };
      for (final value in foodLogs.whereType<Map>()) {
        final nutrients = normalizeFoodNutrients(
          Map<String, dynamic>.from(value),
        );
        for (final nutrient in totals.keys) {
          totals[nutrient] = totals[nutrient]! +
              (parseFoodNutrientNumber(nutrients[nutrient]) ?? 0);
        }
      }
      return totals;
    }
    final totals = _intakeData?["totals"];
    return _asStringMap(totals);
  }

  double get _todayCalories =>
      _numberFrom(_todayNutritionTotals["calories"]) ?? 0;
  double get _todaySodiumMg =>
      _numberFrom(_todayNutritionTotals["sodium"]) ?? 0;
  double get _todayPotassiumMg =>
      _numberFrom(_todayNutritionTotals["potassium"]) ?? 0;
  double get _todayProteinG =>
      _numberFrom(_todayNutritionTotals["protein"]) ?? 0;
  double get _todayPhosphorusMg =>
      _numberFrom(_todayNutritionTotals["phosphorus"]) ?? 0;

  int get _todayMealCount {
    final foodLogs = _intakeData?["foodLogs"];
    if (foodLogs is List) return foodLogs.length;
    return (_numberFrom(
              _intakeData?["mealCount"] ?? _intakeData?["meal_count"],
            ) ??
            0)
        .toInt();
  }

  bool get _isCaregiverDashboard {
    if (_caregiverDashboardState["isCaregiver"] == true) return true;
    final role = (_viewer["role"] ?? _viewer["userRole"] ?? ApiService.userRole)
        ?.toString()
        .trim()
        .toLowerCase();
    return role == "caregiver" || role == "parent_caregiver";
  }

  List<Map<String, String>> get _managedChildren {
    final rawChildren = _caregiverDashboardState["linkedChildren"];
    if (rawChildren is! List) return const [];
    final children = <Map<String, String>>[];
    final seen = <String>{};
    for (final rawChild in rawChildren) {
      if (rawChild is! Map) continue;
      final child = Map<String, dynamic>.from(rawChild);
      final id = (child["userId"] ?? child["uid"] ?? child["id"])
          ?.toString()
          .trim();
      if (id == null || id.isEmpty || !seen.add(id)) continue;
      final name = (child["name"] ??
              child["fullName"] ??
              child["childFullName"] ??
              child["child_name"] ??
              "Child")
          .toString()
          .trim();
      children.add({"id": id, "name": name.isEmpty ? "Child" : name});
    }
    return children;
  }

  Future<void> _selectManagedChild(String? childId) async {
    if (childId == null ||
        childId.isEmpty ||
        childId == ApiService.selectedManagedChildProfileId) {
      return;
    }
    ApiService.setSelectedManagedChildProfileId(childId);
    setState(() {
      _isLoadingDashboard = true;
      _dashboardError = null;
      _todayMealPlan = null;
    });
    await _loadDashboardSummary(forceRefresh: true);
    await _loadTodaysMealPlan();
  }

  double get _todayWaterMl {
    // First try to get water/fluid data from backend response
    final waterMl = _numberFromPossiblyUnitString(
      _intakeData?["waterMl"] ??
          _intakeData?["water_ml"] ??
          _intakeData?["fluid_ml"],
    );
    if (waterMl != null && waterMl > 0) {
      return waterMl;
    }

    // Fallback: calculate from food logs if available
    try {
      final foodLogs = _intakeData?["foodLogs"];
      if (foodLogs is List) {
        double totalWaterMl = 0;
        for (final log in foodLogs) {
          if (log is Map) {
            final name = log['name']?.toString().toLowerCase() ?? '';
            final portion = log['portion']?.toString() ?? '';

            // Handle common variants like "water", "water (bottle)", etc.
            if (name.contains('water')) {
              final ml = _numberFromPossiblyUnitString(portion);
              if (ml != null) totalWaterMl += ml;
            }
          }
        }
        return totalWaterMl;
      }
    } catch (_) {
      // If parsing fails, just return 0
    }

    return waterMl ?? 0;
  }


  double get _todayWaterLiters => _todayWaterMl / 1000;

  bool get _hasHydrationLogged => _todayWaterMl > 0;

  double _progressFor(double value, double target) {
    if (target <= 0) return 0;
    return (value / target).clamp(0, 1).toDouble();
  }

  bool get _hasFluidRestriction {
    final status = (_medicalProfile["fluidRestrictionStatus"] ??
            _medicalProfile["fluid_restriction_status"])
        ?.toString()
        .trim()
        .toLowerCase();
    return status == "yes";
  }

  double? get _fluidLimitMl {
    return _numberFrom(
      _medicalProfile["fluidLimitMl"] ?? _medicalProfile["fluid_limit_ml"],
    );
  }

  double? get _fluidTargetLiters {
    final limitMl = _fluidLimitMl;
    if (limitMl == null || limitMl <= 0) return null;
    return limitMl / 1000;
  }

  // --- NEW: Notifications Pop-up Logic ---
  void _showNotificationsPanel() {
    final nextReminder = _nextMedicationReminder;
    final nextReminderTime = nextReminder?["time"] as DateTime?;
    final nextReminderName = nextReminder?["name"]?.toString() ?? "Medication";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FBFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF90A4AE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Notification Items
              if (nextReminderTime != null)
                _buildNotificationItem(
                  icon: Icons.medication_outlined,
                  color: const Color(0xFF9E86FF),
                  title: '$nextReminderName reminder',
                  message: 'Scheduled at ${_formatClockTime(nextReminderTime)}.',
                  time: _relativeReminderText(nextReminderTime),
                )
              else
                _buildNotificationItem(
                  icon: Icons.medication_outlined,
                  color: const Color(0xFF9E86FF),
                  title: 'No medication reminders',
                  message: 'Add medication details to enable reminders.',
                  time: 'Today',
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFB),
      body: SafeArea(
        child: _isLoadingDashboard
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C874)),
              )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_dashboardError != null) ...[
                _buildDashboardErrorCard(),
                const SizedBox(height: 16),
              ],
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStreakCard(),
              const SizedBox(height: 16),
              _buildMetricsRow(),
              const SizedBox(height: 16),
              _buildNutritionCard(),
              const SizedBox(height: 16),
              if (_todayMealPlan != null && _todayMealPlan!.isNotEmpty)
                _buildTodaysMealPlanCard(),
              if (_todayMealPlan != null && _todayMealPlan!.isNotEmpty)
                const SizedBox(height: 16),
              _buildAlertCard(),
              const SizedBox(height: 16),
              _buildQuickActionsCard(),
              const SizedBox(height: 16),
              _buildUpcomingCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              _openFoodLogAndRefresh();
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsPage(
                    profileUserId: _activeProfileUserId,
                  ),
                ),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthMetricsPage(
                    profileUserId: _activeProfileUserId,
                  ),
                ),
              );
            } else if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    profileUserId: _activeProfileUserId,
                  ),
                ),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00C874),
          unselectedItemColor: const Color(0xFFB0BEC5),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Health',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. Header Area ---
  Widget _buildDashboardErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Text(
        "Dashboard data could not be loaded: $_dashboardError",
        style: const TextStyle(
          color: Color(0xFF78909C),
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    profileUserId: _activeProfileUserId,
                  ),
                ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFD5F5E3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _childInitials,
                style: const TextStyle(
                  color: Color(0xFF009688),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isCaregiverDashboard ? 'Welcome!' : 'Good morning,',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
              ),
              if (_isCaregiverDashboard && _managedChildren.isNotEmpty)
                CaregiverManagedChildSelector(
                  children: _managedChildren,
                  selectedChildId:
                      ApiService.selectedManagedChildProfileId ??
                          _dashboardOwnerId,
                  onChanged: _selectManagedChild,
                )
              else
                Text(
                  _childName,
                  style: const TextStyle(
                    color: Color(0xFF37474F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        // --- UPDATED: Clickable Notifications Icon ---
        GestureDetector(
          onTap: _showNotificationsPanel,
          child: const Icon(
            Icons.notifications_none,
            color: Color(0xFF37474F),
            size: 28,
          ),
        ),
      ],
    );
  }

  // --- 2. Daily Logging Card ---
  Widget _buildStreakCard() {
    final hasStreak = _currentStreak >= 2;
    final title = hasStreak
        ? '$_currentStreak day streak'
        : 'Log for 2 days to get a streak';
    final calorieText = _hasNutritionData
        ? '${_formatNumber(_todayCalories)} kcal logged today'
        : '0 kcal logged today';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openFoodLogAndRefresh,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: hasStreak
                  ? const [Color(0xFFFF8A50), Color(0xFFD81B60)]
                  : const [Color(0xFF4DB6AC), Color(0xFF7E8CE0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (hasStreak
                        ? const Color(0xFFD81B60)
                        : const Color(0xFF7E8CE0))
                    .withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasStreak
                      ? Icons.local_fire_department_rounded
                      : Icons.flag_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      calorieText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. Metrics Row ---
  Widget _buildMetricsRow() {
    final medicationTotal = _medicationTotalCount;
    final medicationTaken = _medications
        .where(
          (medication) =>
              _optionalText(medication["status"]).toLowerCase() == "taken",
        )
        .length;
    final nextReminder = _nextMedicationReminder;
    final nextReminderTime = nextReminder?["time"] as DateTime?;

    return Row(
      children: [
        Expanded(
          child: _buildSmallMetricCard(
            title: 'Hydration',
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFF42A5F5),
            mainValue: '${_todayWaterLiters.toStringAsFixed(1)} L',
            subValue: _fluidTargetLiters == null
                ? 'No daily tracking target set'
                : 'of ${_formatLiters(_fluidTargetLiters!)} ${_hasFluidRestriction ? 'limit' : 'tracking target'}',
            hintText: _hasHydrationLogged ? null : 'No hydration logged yet',
            progressColor: const Color(0xFF42A5F5),
            progressValue: _fluidTargetLiters != null && _fluidTargetLiters! > 0
                ? (_todayWaterLiters / _fluidTargetLiters!).clamp(0, 1)
                : 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallMetricCard(
            title: 'Medication',
            icon: Icons.medication_outlined,
            iconColor: const Color(0xFFAB47BC),
            mainValue:
                _hasMedicationData ? '$medicationTaken/$medicationTotal' : 'Not set',
            subValue: nextReminderTime == null
                ? 'No medication logged yet'
                : 'Next: ${_formatClockTime(nextReminderTime)}',
            hintText: _hasMedicationData ? null : 'No medication logged yet',
            progressColor: const Color(0xFFAB47BC),
            progressValue:
                medicationTotal == 0 ? 0 : medicationTaken / medicationTotal,
          ),
        ),
      ],
    );
  }

  String _formatLiters(double value) {
    final text = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 1,
    );
    return '$text L';
  }

  Widget _buildSmallMetricCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String mainValue,
    required String subValue,
    required Color progressColor,
    required double progressValue,
    String? hintText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF78909C),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mainValue,
            style: const TextStyle(
              color: Color(0xFF37474F),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 11),
          ),
          if (hintText != null) ...[
            const SizedBox(height: 6),
            Text(
              hintText,
              style: const TextStyle(
                color: Color(0xFFB0BEC5),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: progressColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Today's Nutrition Card ---
  Widget _buildNutritionCard() {
    final sodiumAlert =
        _sodiumTargetMg > 0 && _todaySodiumMg > _sodiumTargetMg;
    final potassiumAlert =
        _potassiumTargetMg > 0 && _todayPotassiumMg > _potassiumTargetMg;
    final phosphorusAlert =
        _phosphorusTargetMg > 0 && _todayPhosphorusMg > _phosphorusTargetMg;

    final hasAnyNutritionAlert = sodiumAlert || potassiumAlert || phosphorusAlert;

    return AnimatedBuilder(
      animation: _nutritionAlertBlinkController,
      builder: (context, child) {
        // Calculate glow opacity for blinking effect
final double glowOpacity = hasAnyNutritionAlert
    ? (_nutritionAlertBlinkController.value * 0.6 + 0.4).toDouble()
    : 0.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasAnyNutritionAlert
                  ? Colors.red
                  : Colors.grey.shade200,
              width: hasAnyNutritionAlert ? 2 : 1,
            ),
            boxShadow: hasAnyNutritionAlert
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(glowOpacity),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Today's Nutrition",
                        style: TextStyle(
                          color: Color(0xFF37474F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasAnyNutritionAlert) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5F5E3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _hasNutritionData ? 'Today' : 'No data',
                      style: const TextStyle(
                        color: Color(0xFF009688),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildNutritionBar(
                label: "Sodium",
                valueText:
                    "${_formatNumber(_todaySodiumMg)} / ${_formatNumber(_sodiumTargetMg)} mg",
                progress: _progressFor(_todaySodiumMg, _sodiumTargetMg),
                color: const Color(0xFF00C874),
                isAlert: sodiumAlert,
              ),
              const SizedBox(height: 16),
              _buildNutritionBar(
                label: "Potassium",
                valueText:
                    "${_formatNumber(_todayPotassiumMg)} / ${_formatNumber(_potassiumTargetMg)} mg",
                progress: _progressFor(_todayPotassiumMg, _potassiumTargetMg),
                color: const Color(0xFFFFCA28),
                isAlert: potassiumAlert,
              ),
              const SizedBox(height: 16),
              _buildNutritionBar(
                label: "Protein",
                valueText:
                    "${_formatNumber(_todayProteinG, decimals: 1)} / ${_formatNumber(_proteinTargetG, decimals: 1)} g",
                progress: _progressFor(_todayProteinG, _proteinTargetG),
                color: const Color(0xFFEF5350),
              ),
              const SizedBox(height: 16),
              _buildNutritionBar(
                label: "Phosphorus",
                valueText:
                    "${_formatNumber(_todayPhosphorusMg)} / ${_formatNumber(_phosphorusTargetMg)} mg",
                progress: _progressFor(_todayPhosphorusMg, _phosphorusTargetMg),
                color: const Color(0xFFFF7043),
                isAlert: phosphorusAlert,
              ),
              if (!_hasNutritionData) ...[
                const SizedBox(height: 18),
                const Text(
                  "No nutrition data logged yet. Targets are based on your child's profile.",
                  style: TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionBar({
    required String label,
    required String valueText,
    required double progress,
    required Color color,
    bool isAlert = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF78909C),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: TextStyle(
                color: isAlert ? color : const Color(0xFF37474F),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isAlert) ...[
              const SizedBox(width: 4),
              Icon(Icons.warning_amber_rounded, color: color, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // --- 5. Today's Meal Plan Card ---
  Widget _buildTodaysMealPlanCard() {
    if (_todayMealPlan == null || _todayMealPlan!.isEmpty) {
      return const SizedBox.shrink();
    }

    final mealPlan = _todayMealPlan!;
    final mealItems = _mealPlanPreviewMeals(mealPlan);
    final mealCount = mealItems.length;
    final totals = mealPlan['totals'] is Map
        ? Map<String, dynamic>.from(mealPlan['totals'] as Map)
        : <String, dynamic>{};

    final calories = (_numberFrom(totals['calories']) ??
            mealItems.fold<double>(
              0,
              (total, meal) => total + (_numberFrom(meal['calories']) ?? 0),
            ))
        .round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDEFE1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C874),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Today's Meal Plan",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_formatNumber(calories.toDouble())} kcal',
                  style: const TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (mealCount > 0) ...[
            const SizedBox(height: 10),
            ...mealItems.map(_buildMealPlanPreviewRow),
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'No meals planned.',
              style: TextStyle(
                color: Color(0xFF78909C),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _mealPlanPreviewMeals(Map<String, dynamic> mealPlan) {
    final days = mealPlan['days'];
    if (days is List && days.isNotEmpty) {
      final dayMaps = days.whereType<Map>().map((d) => Map<String, dynamic>.from(d)).toList(growable: false);
      if (dayMaps.isEmpty) return const <Map<String, dynamic>>[];

      // Prefer the day whose `date` matches today. Fallback: first day in the plan.
      final todayIso = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayDay = dayMaps.cast<Map<String, dynamic>>().firstWhere(
        (d) => d['date']?.toString() == todayIso,
        orElse: () => dayMaps.first,
      );

      final meals = todayDay['meals'];
      if (meals is! List) return const <Map<String, dynamic>>[];
      return meals
          .whereType<Map>()
          .map((meal) => Map<String, dynamic>.from(meal))
          .toList(growable: false);
    }

    final meals = mealPlan['meals'];
    if (meals is! List) return const [];
    return meals
        .whereType<Map>()
        .map((meal) => Map<String, dynamic>.from(meal))
        .toList(growable: false);
  }


  DateTime? _parseFoodLogLoggedAt(dynamic loggedAt) {
    if (loggedAt is DateTime) return loggedAt;
    final text = loggedAt?.toString();
    if (text == null || text.trim().isEmpty) return null;
    return DateTime.tryParse(text);
  }

  bool _isMealLogged(String mealType) {
    final foodLogs = _intakeData?["foodLogs"];
    if (foodLogs is! List) return false;

    final target = mealType.trim().toLowerCase();
    for (final log in foodLogs.whereType<Map>()) {
      final logMealType = (log['mealType'] ?? log['type'])?.toString().trim().toLowerCase();
      if (logMealType != target) continue;
      // If backend stores mealType but loggedAt missing, we still consider it logged.
      final loggedAt = _parseFoodLogLoggedAt(log['loggedAt'] ?? log['logged_at'] ?? log['time'] ?? log['createdAt']);
      if (loggedAt != null || true) return true;
    }
    return false;
  }

  DateTime _scheduledDateTimeForMealType(String mealType) {
    final now = DateTime.now();
    final t = _mealTimeForType(mealType);
    final hour = t[0];
    final minute = t[1];
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // breakfast=08:00, lunch=12:00, am snack=10:00, pm snack=15:30, dinner=18:30
  List<int> _mealTimeForType(String mealType) {
    final key = mealType.trim().toLowerCase();
    switch (key) {
      case 'breakfast':
        return [8, 0];
      case 'lunch':
        return [12, 0];
      case 'am snack':
      case 'am_snack':
      case 'am snack ': // tolerate trailing spaces
        return [10, 0];
      case 'pm snack':
      case 'pm_snack':
      case 'pm snack ':
        return [15, 30];
      case 'dinner':
        return [18, 30];
      default:
        // Fallback: treat unknown meal types as not time-passed-driven.
        return [23, 59];
    }
  }

  bool _isMealTimePassed(String mealType) {
    final scheduled = _scheduledDateTimeForMealType(mealType);
    return DateTime.now().isAfter(scheduled);
  }

  // Dashboard: show icons only.
  // - ✅ logged
  // - ❌ only if missed (not logged AND time passed)
  // - nothing otherwise
  IconData? _mealStatusIcon(String mealType) {
    final logged = _isMealLogged(mealType);
    if (logged) return Icons.check_circle;
    if (_isMealTimePassed(mealType)) return Icons.close;
    return null;
  }

  Widget _buildMealPlanPreviewRow(Map<String, dynamic> meal) {
    final name = meal['name']?.toString().trim().isNotEmpty == true
        ? meal['name'].toString().trim()
        : meal['component']?.toString().trim().isNotEmpty == true
            ? meal['component'].toString().trim()
            : 'Planned meal';
    final mealType = meal['mealType']?.toString().trim() ??
        meal['type']?.toString().trim() ??
        '';
    final calories = _numberFrom(meal['calories']) ??
        (meal['nutrientPreview'] is Map
            ? _numberFrom(
                Map<String, dynamic>.from(meal['nutrientPreview'] as Map)[
                    'calories'],
              )
            : null);

    final title = mealType.isEmpty ? name : '$mealType: $name';
    final statusIcon = _mealStatusIcon(mealType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0F2F1)),
        ),
        child: Row(
          children: [
            if (statusIcon != null)
              Icon(
                statusIcon,
                size: 18,
                color: statusIcon == Icons.close
                    ? Colors.red
                    : const Color(0xFF2E7D32),
              ),
            if (statusIcon != null) const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (calories != null)
              Text(
                '${_formatNumber(calories)} kcal',
                style: const TextStyle(
                  color: Color(0xFF00A86B),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }



  List<String> _getMealTypesFromPlan(dynamic meals) {
    if (meals is! List) return [];
    final types = <String>{};
    for (final meal in meals) {
      if (meal is Map) {
        final mealType = meal['mealType']?.toString() ?? meal['type']?.toString();
        if (mealType != null && mealType.isNotEmpty) {
          types.add(mealType);
        }
      }
    }
    return types.toList();
  }

  // --- 6. Alert Card ---

  Widget _buildAlertCard() {
    final alerts = <String>[];
    if (_sodiumTargetMg > 0 && _todaySodiumMg > _sodiumTargetMg) {
      alerts.add('Sodium is above today\'s target.');
    }
    if (_potassiumTargetMg > 0 && _todayPotassiumMg > _potassiumTargetMg) {
      alerts.add('Potassium is above today\'s target.');
    }
    if (_phosphorusTargetMg > 0 && _todayPhosphorusMg > _phosphorusTargetMg) {
      alerts.add('Phosphorus is above today\'s target.');
    }

    if (!_hasNutritionData) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0F2ED)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFF00A86B),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'No nutrition data yet.',
                    style: TextStyle(
                      color: Color(0xFF37474F),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Log your meals to see insights and recommendations.',
                    style: TextStyle(
                      color: Color(0xFF78909C),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FAF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0F2ED)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.check_circle_outline, color: Color(0xFF00A86B), size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Today\'s logged meals are within the displayed nutrition targets.',
                style: TextStyle(
                  color: Color(0xFF78909C),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF7043), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nutrition target alert',
                  style: TextStyle(
                    color: Color(0xFF37474F),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alerts.join(' '),
                  style: const TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Quick Actions Card ---
  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Color(0xFF78909C),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionBtn(
            Icons.restaurant_menu,
            'Log Food',
            onTap: _openFoodLogAndRefresh,
          ),
          const SizedBox(height: 12),
          _buildQuickActionBtn(
            Icons.calendar_today_outlined,
            'View Growth Chart',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsPage(
                    initialCategory: 'Growth',
                    profileUserId: _activeProfileUserId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionBtn(
            Icons.trending_up,
            'Weekly Report',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsPage(
                    initialCategory: 'Nutrients',
                    profileUserId: _activeProfileUserId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF37474F), size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF37474F),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 8. Upcoming Card ---
  Widget _buildUpcomingCard() {
    final nextReminder = _nextMedicationReminder;
    final nextReminderName = nextReminder?["name"]?.toString() ?? "Medication";
    final nextReminderTime = nextReminder?["time"] as DateTime?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming',
            style: TextStyle(
              color: Color(0xFF78909C),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          if (nextReminderTime != null) ...[
            _buildUpcomingItem(
              icon: Icons.medication_outlined,
              iconColor: const Color(0xFF9E86FF),
              bgColor: const Color(0xFFF3E5F5),
              title: '$nextReminderName reminder',
              subtitle:
                  '${_formatClockTime(nextReminderTime)} - ${_relativeReminderText(nextReminderTime)}',
            ),
            const SizedBox(height: 20),
          ],
          _buildUpcomingItem(
            icon: Icons.event_available_outlined,
            iconColor: const Color(0xFF009688),
            bgColor: const Color(0xFFE0F2F1),
            title: nextReminderTime == null
                ? 'No upcoming items set'
                : 'No appointments set',
            subtitle: nextReminderTime == null
                ? 'Medication reminders and appointments will appear here.'
                : 'Appointments will appear here.',
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF78909C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper to build individual notification items ---
  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB0BEC5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78909C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
