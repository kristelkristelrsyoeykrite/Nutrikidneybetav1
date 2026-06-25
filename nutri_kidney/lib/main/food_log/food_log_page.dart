part of '../food_log.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({
    super.key,
    this.profileUserId,
    this.caregiverNoChildEmptyState = false,
  });

  final String? profileUserId;
  final bool caregiverNoChildEmptyState;

  @override
  State<FoodLogPage> createState() => _FoodLogPageState();
}

class _MealPlanLoadingDialog extends StatefulWidget {
  const _MealPlanLoadingDialog({required this.planDays});

  final int planDays;

  @override
  State<_MealPlanLoadingDialog> createState() =>
      _MealPlanLoadingDialogState();
}

class _MealPlanLoadingDialogState extends State<_MealPlanLoadingDialog> {
  static const _steps = <String>[
    'Creating breakfast meals...',
    'Searching for kidney-friendly foods...',
    'Balancing sodium and protein...',
    'Reviewing potassium and phosphorus...',
    'Adjusting portions for the profile...',
    'Planning lunches and dinners...',
    'Adding suitable snacks...',
    'Checking variety across the week...',
    'Putting the finishing touches together...',
  ];

  static const _infoCards = <Map<String, String>>[
    {
      'label': 'Trivia',
      'text': 'Herbs, citrus, and spices can add flavor without relying only on salt.',
    },
    {
      'label': 'FAQ',
      'text': 'Why are portions important? Portions help keep daily nutrients within the profile targets.',
    },
    {
      'label': 'Trivia',
      'text': 'Potassium and phosphorus needs can differ depending on laboratory results and CKD stage.',
    },
    {
      'label': 'FAQ',
      'text': 'Can meals be changed? Yes. Review the plan and choose suitable replacements when available.',
    },
    {
      'label': 'Trivia',
      'text': 'A varied plate can make a nutrition plan easier and more enjoyable to follow.',
    },
    {
      'label': 'FAQ',
      'text': "Is this a medical prescription? No. Use the plan with guidance from the child's healthcare team.",
    },
  ];

  final Random _random = Random();
  Timer? _rotationTimer;
  int _stepIndex = 0;
  int _infoIndex = 0;
  double _progress = 0.08;

  @override
  void initState() {
    super.initState();
    _stepIndex = _random.nextInt(_steps.length);
    _infoIndex = _random.nextInt(_infoCards.length);
    _rotationTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      setState(() {
        _stepIndex = _differentIndex(_steps.length, _stepIndex);
        _infoIndex = _differentIndex(_infoCards.length, _infoIndex);
        _progress = (_progress + 0.05 + _random.nextDouble() * 0.08)
            .clamp(0.0, 0.92)
            .toDouble();
      });
    });
  }

  int _differentIndex(int length, int current) {
    if (length <= 1) return 0;
    var next = _random.nextInt(length);
    while (next == current) {
      next = _random.nextInt(length);
    }
    return next;
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _infoCards[_infoIndex];
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5F8EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: Color(0xFF00B86B),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Preparing Your Meal Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Building a personalized ${widget.planDays}-day plan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8F0EC),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00C874),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 650),
                    child: Text(
                      _steps[_stepIndex],
                      key: ValueKey(_stepIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF455A64),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 650),
                  child: Container(
                    key: ValueKey(_infoIndex),
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FAF7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCECE4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['label']!,
                          style: const TextStyle(
                            color: Color(0xFF00A86B),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          info['text']!,
                          style: const TextStyle(
                            color: Color(0xFF607D8B),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'This may take a little while. Please keep the app open.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodLogPageState extends State<FoodLogPage>
    with WidgetsBindingObserver {
  int _currentIndex = 1; // 1 corresponds to 'Food'
  String _selectedMealType = 'Breakfast';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isLoadingLogs = false;
  String? _foodLogError;
  final Set<String> _savingLogKeys = {};
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic>? _imageReviewFoodDetails;
  Map<String, dynamic>? _imageReviewSelectedServing;
  bool _isSavingImageReview = false;
  String? _quickAddLoadingName;
  final TextEditingController _imageReviewQuantityController =
      TextEditingController(text: '1');
  bool _isGeneratingMealPlan = false;
  int _currentStreak = 0;
  bool _mealPlanCompletionAwardUnlocked = false;
  bool _resolvedCaregiverNoChildEmptyState = false;
  bool _isCheckingCaregiverChildState = false;

  // Calorie target tracking
  double? _userWeightKg;
  double? _dailyCalorieTarget;
  bool _isLoadingProfileData = false;

  String? get _activeProfileUserId =>
      widget.profileUserId ??
      ApiService.selectedManagedChildProfileId ??
      ApiService.activeChildProfileId;

  final List<Map<String, String>> _allQuickAdds = [
    {'emoji': '\u{1F34C}', 'name': 'Banana'},
    {'emoji': '\u{1F4A7}', 'name': 'Water'},
    {'emoji': '\u{1F95A}', 'name': 'Egg'},
    {'emoji': '\u{1F35A}', 'name': 'Rice'},
  ];

  final Map<String, List<FoodItem>> _loggedMeals = {
    'Breakfast': [
      FoodItem(
        emoji: '\u{1F963}',
        name: 'Oatmeal with Berries',
        portion: '1 bowl (250g)',
        calories: 280,
        time: '8:30 AM',
      ),
    ],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resolvedCaregiverNoChildEmptyState = widget.caregiverNoChildEmptyState;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    if (!widget.caregiverNoChildEmptyState) {
      _isCheckingCaregiverChildState = true;
      _initializeFoodLog();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _imageReviewQuantityController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_resolvedCaregiverNoChildEmptyState) {
      _loadFoodLogs(forceRefresh: true);
      _loadCurrentStreak(forceRefresh: true);
    }
  }

  String get _selectedDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _initializeFoodLog() async {
    try {
      if (await _shouldShowCaregiverEmptyState()) {
        if (!mounted) return;
        setState(() {
          _resolvedCaregiverNoChildEmptyState = true;
          _isCheckingCaregiverChildState = false;
          _isLoadingLogs = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Food Log caregiver child-profile check failed: $e');
    }

    if (!mounted) return;
    setState(() {
      _isCheckingCaregiverChildState = false;
    });
    _loadFoodLogs(forceRefresh: true);
    _loadCurrentStreak(forceRefresh: true);
    _loadProfileDataForCalorieTarget();
  }

  Future<bool> _shouldShowCaregiverEmptyState() async {
    final response = await ApiService.getDashboardSummary(
      profileUserId: widget.profileUserId,
      forceRefresh: true,
    );
    final viewer = response['viewer'];
    final role = viewer is Map
        ? (viewer['role'] ?? viewer['userRole'] ?? '').toString().toLowerCase()
        : '';
    if (role != 'caregiver' && role != 'parent_caregiver') return false;
    final state = response['caregiverDashboardState'];
    final children = state is Map ? state['linkedChildren'] : null;
    return children is! List || children.isEmpty;
  }

  Future<void> _loadCurrentStreak({bool forceRefresh = false}) async {
    try {
      final response = await ApiService.getGamificationSummary(
        profileUserId: _activeProfileUserId,
        forceRefresh: forceRefresh,
      );
      final gamification = response['gamification'];
      final status = gamification is Map ? gamification['status'] : null;
      final rawStreak = status is Map
          ? status['currentStreak'] ?? status['displayStreak']
          : null;
      final streak = rawStreak is num
          ? rawStreak.toInt()
          : int.tryParse(rawStreak?.toString() ?? '') ?? 0;
      if (!mounted) return;
      setState(() {
        _currentStreak = streak < 0 ? 0 : streak;
      });
    } catch (e) {
      debugPrint('Error loading current streak: $e');
    }
  }

  String _foodLogSectionForMealType(dynamic value) {
    final mealType = value?.toString().trim() ?? '';
    final normalized = mealType.toLowerCase();
    if (normalized == 'am snack' ||
        normalized == 'pm snack' ||
        normalized == 'snack' ||
        normalized == 'snacks') {
      return 'Snacks';
    }
    return mealType.isEmpty ? 'Breakfast' : mealType;
  }

  Future<void> _loadFoodLogs({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoadingLogs = true;
      _foodLogError = null;
      for (final key in _loggedMeals.keys) {
        _loggedMeals[key] = [];
      }
    });

    try {
      final response = await ApiService.getFoodLogs(
        date: _selectedDate,
        profileUserId: _activeProfileUserId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      final logs = response['logs'];
      if (logs is List) {
        setState(() {
          for (final log in logs) {
            if (log is! Map) continue;
            final data = Map<String, dynamic>.from(log);
            final mealType = _foodLogSectionForMealType(data['mealType']);
            final food = FoodItem.fromLog(data);
            _loggedMeals.putIfAbsent(mealType, () => []);
            _loggedMeals[mealType]!.add(food);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _foodLogError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLogs = false;
        });
      }
    }
  }

  Future<void> _loadProfileDataForCalorieTarget() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfileData = true;
    });

    try {
      // Fetch health summary to get weight and nutrition target info.
      final healthResponse = await ApiService.getHealthSummary(
        profileUserId: _activeProfileUserId,
      );

      if (!mounted) return;

      final health = healthResponse['health'] is Map
          ? Map<String, dynamic>.from(healthResponse['health'] as Map)
          : <String, dynamic>{};
      final anthropometrics = healthResponse['anthropometrics'] is Map
          ? Map<String, dynamic>.from(healthResponse['anthropometrics'] as Map)
          : <String, dynamic>{};
      final nutritionTargets = healthResponse['nutritionTargets'] is Map
          ? Map<String, dynamic>.from(healthResponse['nutritionTargets'] as Map)
          : <String, dynamic>{};

      double? numberFrom(dynamic value) {
        if (value is num) return value.toDouble();
        if (value == null) return null;
        final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(value.toString());
        return match == null ? null : double.tryParse(match.group(0) ?? '');
      }

      final targetFromProfile = numberFrom(
        nutritionTargets['energy_target_kcal'] ??
            nutritionTargets['calorieTarget'] ??
            nutritionTargets['calorie_target'] ??
            nutritionTargets['calories'],
      );

      final weightKg = numberFrom(
        health['weight'] ??
            health['weightKg'] ??
            health['weight_kg'] ??
            health['currentWeight'] ??
            health['current_weight'] ??
            anthropometrics['weight_kg'] ??
            anthropometrics['weightKg'] ??
            anthropometrics['weight'],
      );

      double? calorieTarget = targetFromProfile;
      if ((calorieTarget == null || calorieTarget <= 0) &&
          weightKg != null &&
          weightKg > 0) {
        calorieTarget = weightKg * 32.5;
      }

      if (mounted) {
        setState(() {
          _userWeightKg = weightKg;
          _dailyCalorieTarget = calorieTarget;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userWeightKg = null;
          _dailyCalorieTarget = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfileData = false;
        });
      }
    }
  }

  String _normalizeFoodSearchQuery(String query) {
    final trimmed = query.trim();
    final compact = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    const joinedFoodNames = {
      'friedchicken': 'fried chicken',
      'chickenbreast': 'chicken breast',
      'chickenwings': 'chicken wings',
      'frenchfries': 'french fries',
      'icecream': 'ice cream',
      'hotdog': 'hot dog',
      'friedrice': 'fried rice',
      'boiledegg': 'boiled egg',
      'scrambledegg': 'scrambled egg',
      'whiterice': 'white rice',
      'brownrice': 'brown rice',
    };

    return joinedFoodNames[compact] ?? trimmed;
  }

  String _foodSearchRankText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _foodSearchRank(FoodItem food, String query, int index) {
    final normalizedQuery = _foodSearchRankText(query);
    final compactQuery = normalizedQuery.replaceAll(' ', '');
    final normalizedName = _foodSearchRankText(food.name);
    final compactName = normalizedName.replaceAll(' ', '');
    final words = normalizedName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    final firstWord = words.isEmpty ? '' : words.first;
    var score = 0;

    if (normalizedName == normalizedQuery) score += 1000;
    if (compactName == compactQuery) score += 900;
    if (normalizedName.startsWith(normalizedQuery)) score += 700;
    if (compactName.startsWith(compactQuery)) score += 650;
    if (words.any((word) => word == normalizedQuery)) score += 550;
    if (words.any((word) => word.startsWith(normalizedQuery))) score += 500;
    if (normalizedName.contains(' $normalizedQuery')) score += 350;
    if (compactName.contains(compactQuery)) score += 250;
    if (firstWord.startsWith(normalizedQuery)) {
      final extraLetters = (firstWord.length - normalizedQuery.length).clamp(0, 999);
      score += (180 - extraLetters * 20).clamp(0, 180);
    }
    if (words.length == 1 && compactName.startsWith(compactQuery)) score += 120;
    if (words.length > 2) score -= ((words.length - 2) * 20).clamp(0, 80);
    if (RegExp(r'\b(sauce|juice|pie|cake|bar|snack|flavored|with)\b')
        .hasMatch(normalizedName)) {
      score -= 45;
    }

    return score - index;
  }

  List<FoodItem> _rankFoodSearchSuggestions(
    List<FoodItem> foods,
    String query,
  ) {
    final indexed = foods.asMap().entries.toList();
    indexed.sort(
      (a, b) => _foodSearchRank(b.value, query, b.key)
          .compareTo(_foodSearchRank(a.value, query, a.key)),
    );
    return indexed.map((entry) => entry.value).toList(growable: false);
  }

  FoodItem _foodWithEmoji(FoodItem food, String emoji) {
    return FoodItem(
      id: food.id,
      foodId: food.foodId,
      servingId: food.servingId,
      emoji: emoji,
      name: food.name,
      portion: food.portion,
      quantity: food.quantity,
      calories: food.calories,
      time: food.time,
      protein: food.protein,
      carbohydrate: food.carbohydrate,
      fat: food.fat,
      sodium: food.sodium,
      potassium: food.potassium,
      phosphorus: food.phosphorus,
      source: food.source,
      needsManualReview: food.needsManualReview,
      raw: food.raw,
    );
  }

  Future<void> _handleQuickAdd(String emoji, String name) async {
    if (_quickAddLoadingName != null) return;

    // Handle water specially - just ask for ML amount
    if (name.toLowerCase() == 'water') {
      await _showWaterDialog(emoji);
      return;
    }

    setState(() {
      _quickAddLoadingName = name;
    });

    try {
      final response = await ApiService.searchFoods(_normalizeFoodSearchQuery(name));
      if (!mounted) return;
      final foods = response['foods'];
      final suggestions = foods is List
          ? foods
              .whereType<Map>()
              .map(
                (food) => _foodWithEmoji(
                  FoodItem.fromCatalog(Map<String, dynamic>.from(food)),
                  emoji,
                ),
              )
              .toList(growable: false)
          : <FoodItem>[];

      if (suggestions.isEmpty) {
        throw Exception('No FatSecret matches found for $name.');
      }

      final exactName = name.trim().toLowerCase();
      final selected = suggestions.firstWhere(
        (food) => food.name.toLowerCase() == exactName,
        orElse: () => suggestions.first,
      );

      if (!mounted) return;
      await _showFoodServingDialog(selected);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to quick add $name: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _quickAddLoadingName = null;
        });
      }
    }
  }

  Future<void> _showWaterDialog(String emoji) async {
    final mlController = TextEditingController(text: '250');
    bool isSavingWater = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text('Log Water'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How much water did you drink?',
                    style: TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mlController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. 250, 500, 1000',
                      suffixText: 'mL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSavingWater ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSavingWater
                      ? null
                      : () async {
                          final mlAmount = int.tryParse(mlController.text.trim());
                          if (mlAmount == null || mlAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                              ),
                            );
                            return;
                          }

                          setStateDialog(() {
                            isSavingWater = true;
                          });

                          try {
                            final waterItem = FoodItem(
                              emoji: emoji,
                              name: 'Water',
                              portion: '$mlAmount mL',
                              quantity: 1,
                              calories: 0,
                              protein: 0,
                              carbohydrate: 0,
                              fat: 0,
                              sodium: 0,
                              potassium: 0,
                              phosphorus: 0,
                              time: DateFormat('h:mm a')
                                  .format(DateTime.now()),
                              source: 'manual_entry',
                              needsManualReview: false,
                            );

                            if (mounted) {
                              setState(() {
                                _loggedMeals[_selectedMealType]?.add(waterItem);
                              });

                              // Try to save to backend
                              try {
                                await _addFoodLogWithAllergyConfirmation(
                                  mealType: _selectedMealType,
                                  date: _selectedDate,
                                  name: 'Water',
                                  portion: '$mlAmount mL',
                                  quantity: 1,
                                  calories: 0,
                                  protein: 0,
                                  carbohydrate: 0,
                                  fat: 0,
                                  sodium: 0,
                                  potassium: 0,
                                  phosphorus: 0,
                                  source: 'manual_entry',
                                );
                              } catch (_) {
                                // Continue even if backend save fails
                              }

                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error logging water: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setStateDialog(() {
                                isSavingWater = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                  ),
                  child: isSavingWater
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Log Water',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _logKeyFor({
    required String mealType,
    required String name,
    required String portion,
    required String date,
  }) {
    return [
      mealType.trim().toLowerCase(),
      name.trim().toLowerCase(),
      portion.trim().toLowerCase(),
      date,
    ].join('|');
  }

  bool _hasDuplicateLog(FoodItem food, {String? exceptId}) {
    final key = _logKeyFor(
      mealType: _selectedMealType,
      name: food.name,
      portion: food.portion,
      date: _selectedDate,
    );
    return (_loggedMeals[_selectedMealType] ?? []).any((existing) {
      if (exceptId != null && existing.id == exceptId) return false;
      return _logKeyFor(
            mealType: _selectedMealType,
            name: existing.name,
            portion: existing.portion,
            date: _selectedDate,
          ) ==
          key;
    });
  }

  Future<Map<String, dynamic>> _addFoodLogWithAllergyConfirmation({
    required String mealType,
    required String name,
    required String portion,
    required int calories,
    String? date,
    String? foodId,
    double? protein,
    double? carbohydrate,
    double? fat,
    double? sodium,
    double? potassium,
    double? phosphorus,
    String? servingId,
    double? quantity,
    String source = 'manual_entry',
    bool needsManualReview = false,
    Map<String, dynamic>? raw,
    double? waterMl,
    Map<String, dynamic>? fluidContribution,
  }) async {
    Future<Map<String, dynamic>> submit(bool confirmed) {
      return ApiService.addFoodLog(
        profileUserId: _activeProfileUserId,
        mealType: mealType,
        name: name,
        portion: portion,
        calories: calories,
        date: date,
        foodId: foodId,
        protein: protein,
        carbohydrate: carbohydrate,
        fat: fat,
        sodium: sodium,
        potassium: potassium,
        phosphorus: phosphorus,
        servingId: servingId,
        quantity: quantity,
        source: source,
        needsManualReview: needsManualReview,
        raw: raw,
        waterMl: waterMl,
        fluidContribution: fluidContribution,
        userConfirmedAllergyWarning: confirmed,
      );
    }

    var response = await submit(false);
    if (response['requiresAllergyConfirmation'] != true || !mounted) {
      return response;
    }

    final matched = (response['matchedAllergens'] as List?)
            ?.map((allergen) => allergen.toString())
            .where((allergen) => allergen.isNotEmpty)
            .toList() ??
        const <String>[];
    final allergenText = matched.isEmpty ? 'a listed allergen' : matched.join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Allergy warning'),
        content: Text(
          '$name may contain $allergenText, which is listed in the child profile. '
          'Do you still want to log this food?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log anyway'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      response = await submit(true);
    }
    return response;
  }

  Future<void> _saveFoodItem(FoodItem food) async {
    final logKey = _logKeyFor(
      mealType: _selectedMealType,
      name: food.name,
      portion: food.portion,
      date: _selectedDate,
    );
    if (_savingLogKeys.contains(logKey) || _hasDuplicateLog(food)) {
      throw Exception('This food is already logged for $_selectedMealType.');
    }

    if (!mounted) return;
    setState(() {
      _savingLogKeys.add(logKey);
    });

    try {
    final response = await _addFoodLogWithAllergyConfirmation(
      mealType: _selectedMealType,
      date: _selectedDate,
      foodId: food.foodId,
      servingId: food.servingId,
      quantity: (food.quantity ?? 1),
      name: food.name,
      portion: food.portion,
      calories: (food.calories ?? 0),
      protein: (food.protein ?? 0),
      carbohydrate: (food.carbohydrate ?? 0),
      fat: (food.fat ?? 0),
      sodium: (food.sodium ?? 0),
      potassium: (food.potassium ?? 0),
      phosphorus: (food.phosphorus ?? 0),
      source: food.source,
      needsManualReview: food.needsManualReview,
      raw: food.raw,
      waterMl: food.waterMl,
      fluidContribution: food.fluidContribution,
    );

    if (response['success'] == false) {
      throw Exception(
        response['error'] ?? response['message'] ?? 'Food was not logged.',
      );
    }

    final log = response['log'];
    final savedFood = log is Map
        ? FoodItem.fromLog(Map<String, dynamic>.from(log))
        : food;

    if (mounted) {
      setState(() {
        _loggedMeals[_selectedMealType]?.add(savedFood);
      });
    }
    await _loadCurrentStreak(forceRefresh: true);
    } finally {
      if (mounted) {
        setState(() {
          _savingLogKeys.remove(logKey);
        });
      }
    }
  }

  double _mealPlanNumber(Map<String, dynamic> meal, String key) {
    if (foodNutrientAliases.containsKey(key)) {
      return _asDouble(normalizeFoodNutrients(meal)[key]);
    }
    // 1) Top-level numeric value (what FoodLogPage expects)
    final direct = meal[key];
    if (direct is num) return direct.toDouble();
    final directParsed = double.tryParse(direct?.toString() ?? '');
    if (directParsed != null) return directParsed;

    // 2) nutrientPreview wrapper
    final preview = meal['nutrientPreview'];
    if (preview is Map) {
      final value = preview[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    // 3) raw -> nutrientPreview (how MealPlanPage sometimes normalizes)
    final raw = meal['raw'];
    if (raw is Map) {
      final rawPreview = raw['nutrientPreview'];
      if (rawPreview is Map) {
        final value = rawPreview[key];
        if (value is num) return value.toDouble();
        return double.tryParse(value?.toString() ?? '') ?? 0;
      }
      final rawFinalNutrients = raw['finalNutrients'] ?? raw['final_nutrients'];
      if (rawFinalNutrients is Map) {
        final value = rawFinalNutrients[key];
        if (value is num) return value.toDouble();
        return double.tryParse(value?.toString() ?? '') ?? 0;
      }
    }

    return 0;
  }


  Future<int> _addMealPlanToFoodLog(Map<String, dynamic> mealPlan) async {
    _mealPlanCompletionAwardUnlocked = false;
    final days = mealPlan['days'];
    final day = days is List && days.whereType<Map>().isNotEmpty
        ? Map<String, dynamic>.from(days.whereType<Map>().first)
        : <String, dynamic>{
            'date': mealPlan['planDate'] ?? _selectedDate,
            'meals': mealPlan['meals'] ?? const [],
          };
    final date = day['date']?.toString() ?? _selectedDate;
    final meals = day['meals'];
    if (meals is! List || meals.isEmpty) {
      throw Exception('No meals were found in this meal plan.');
    }

    var addedCount = 0;
    for (final rawMeal in meals.whereType<Map>()) {
      final meal = Map<String, dynamic>.from(rawMeal);
      final mealType = _foodLogSectionForMealType(
        meal['mealType'] ?? _selectedMealType,
      );
      final name = meal['name']?.toString().trim().isNotEmpty == true
          ? meal['name'].toString().trim()
          : meal['component']?.toString().trim().isNotEmpty == true
              ? meal['component'].toString().trim()
              : 'Meal plan item';
      final portion = meal['portion']?.toString().trim().isNotEmpty == true
          ? meal['portion'].toString().trim()
          : '1 serving';
      final logKey = _logKeyFor(
        mealType: mealType,
        name: name,
        portion: portion,
        date: date,
      );

      final alreadyLogged = (_loggedMeals[mealType] ?? []).any((existing) {
        return _logKeyFor(
              mealType: mealType,
              name: existing.name,
              portion: existing.portion,
              date: date,
            ) ==
            logKey;
      });
      if (_savingLogKeys.contains(logKey) || alreadyLogged) continue;

      if (mounted) {
        setState(() {
          _savingLogKeys.add(logKey);
        });
      }

      try {
        final fluidContribution = meal['fluidContribution'] is Map
            ? Map<String, dynamic>.from(meal['fluidContribution'] as Map)
            : meal['fluid_contribution'] is Map
                ? Map<String, dynamic>.from(meal['fluid_contribution'] as Map)
                : null;
        final response = await _addFoodLogWithAllergyConfirmation(
          mealType: mealType,
          date: date,
          foodId: meal['foodId']?.toString(),
          servingId: meal['servingId']?.toString(),
          quantity: _asDouble(
            meal['numberOfServings'] ?? meal['quantity'] ?? 1,
          ),
          name: name,
          portion: portion,
          calories: _mealPlanNumber(meal, 'calories').round(),
          protein: _mealPlanNumber(meal, 'protein'),
          carbohydrate: _mealPlanNumber(meal, 'carbohydrate'),
          fat: _mealPlanNumber(meal, 'fat'),
          sodium: _mealPlanNumber(meal, 'sodium'),
          potassium: _mealPlanNumber(meal, 'potassium'),
          phosphorus: _mealPlanNumber(meal, 'phosphorus'),
          source: meal['source']?.toString().trim().isNotEmpty == true
              ? meal['source'].toString()
              : 'meal_plan',
          needsManualReview: meal['needsManualReview'] == true,
          raw: meal,
          waterMl: _mealPlanNumber(meal, 'waterMl'),
          fluidContribution: fluidContribution,
        );
        if (response['success'] == false) {
          throw Exception(
            response['error'] ?? response['message'] ?? 'Food was not logged.',
          );
        }
        final unlockedAwards = response['gamificationAwardsUnlocked'];
        if (unlockedAwards is List &&
            unlockedAwards.contains('first_meal_plan_completed')) {
          _mealPlanCompletionAwardUnlocked = true;
        }

        final savedFood = response['log'] is Map
            ? FoodItem.fromLog(Map<String, dynamic>.from(response['log'] as Map))
            : FoodItem(
                emoji: '\u{1F37D}\u{FE0F}',
                name: name,
                portion: portion,
                calories: _mealPlanNumber(meal, 'calories').round(),
                time: DateFormat('h:mm a').format(DateTime.now()),
                protein: _mealPlanNumber(meal, 'protein'),
                carbohydrate: _mealPlanNumber(meal, 'carbohydrate'),
                fat: _mealPlanNumber(meal, 'fat'),
                sodium: _mealPlanNumber(meal, 'sodium'),
                potassium: _mealPlanNumber(meal, 'potassium'),
                phosphorus: _mealPlanNumber(meal, 'phosphorus'),
                waterMl: _mealPlanNumber(meal, 'waterMl'),
                fluidContribution: fluidContribution,
                source: 'meal_plan',
                needsManualReview: meal['needsManualReview'] == true,
                raw: meal,
              );

        if (mounted) {
          setState(() {
            _loggedMeals.putIfAbsent(mealType, () => []).add(savedFood);
          });
        }
        addedCount += 1;
      } finally {
        if (mounted) {
          setState(() {
            _savingLogKeys.remove(logKey);
          });
        }
      }
    }

    if (addedCount == 0) {
      throw Exception('These meal plan items are already in the food log.');
    }
    await _loadCurrentStreak(forceRefresh: true);
    return addedCount;
  }

  Future<void> _updateFoodItem(FoodItem original, FoodItem updated) async {
    if (original.id == null || original.id!.isEmpty) {
      throw Exception('This food log cannot be edited yet.');
    }

    if (_hasDuplicateLog(updated, exceptId: original.id)) {
      throw Exception('This food is already logged for $_selectedMealType.');
    }

    final response = await ApiService.updateFoodLog(
      profileUserId: _activeProfileUserId,
      foodLogId: original.id!,
      mealType: _selectedMealType,
      date: _selectedDate,
      name: updated.name,
      portion: updated.portion,
      calories: updated.calories,
      servingId: updated.servingId,
      quantity: updated.quantity,
      protein: updated.protein,
      carbohydrate: updated.carbohydrate,
      fat: updated.fat,
      sodium: updated.sodium,
      potassium: updated.potassium,
      phosphorus: updated.phosphorus,
      waterMl: updated.waterMl,
      fluidContribution: updated.fluidContribution,
      raw: updated.raw,
    );

    if (response['success'] == false) {
      throw Exception(response['error'] ?? 'Database update failed.');
    }

    final log = response['log'];
    final savedFood = log is Map
        ? FoodItem.fromLog(Map<String, dynamic>.from(log))
        : updated;

    if (mounted) {
      setState(() {
        final foods = _loggedMeals[_selectedMealType] ?? [];
        final index = foods.indexWhere((item) => item.id == original.id);
        if (index >= 0) {
          foods[index] = savedFood;
        }
      });
    }
    await _loadCurrentStreak(forceRefresh: true);
  }

  Future<void> _deleteFoodItem(FoodItem food) async {
    if (food.id == null || food.id!.isEmpty) {
      if (mounted) {
        setState(() {
          _loggedMeals[_selectedMealType]?.remove(food);
        });
      }
      return;
    }

    final response = await ApiService.deleteFoodLog(
      food.id!,
      profileUserId: _activeProfileUserId,
    );
    if (response['success'] == false) {
      throw Exception(response['error'] ?? 'Database delete failed.');
    }

    if (mounted) {
      setState(() {
        _loggedMeals[_selectedMealType]
            ?.removeWhere((item) => item.id == food.id);
      });
    }
    await _loadCurrentStreak(forceRefresh: true);
  }

  Future<void> _confirmDeleteFoodItem(FoodItem food) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete food log?'),
        content: Text('Remove ${food.name} from $_selectedMealType?'),
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

    if (shouldDelete != true) return;

    try {
      await _deleteFoodItem(food);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food log deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete food: $e')),
        );
      }
    }
  }

  Future<void> _editFoodItem(FoodItem food) async {
    final rawDetails = food.raw;
    if (food.foodId != null &&
        food.foodId!.isNotEmpty &&
        rawDetails != null &&
        rawDetails['servings'] is List) {
      await _showFoodServingDialog(
        food,
        preloadedDetails: {'food': rawDetails},
        existingLog: food,
      );
      return;
    }

    final savedServingDetails = _savedServingDetails(food);
    if (savedServingDetails != null) {
      await _showFoodServingDialog(
        food,
        preloadedDetails: {'food': savedServingDetails},
        existingLog: food,
      );
      return;
    }

    if (food.foodId != null && food.foodId!.isNotEmpty) {
      await _showFoodServingDialog(food, existingLog: food);
      return;
    }

    _showAddFoodDialog(food.emoji, food.name, food: food);
  }

  Map<String, dynamic>? _fluidContributionFromPreview(
    Map<String, dynamic> preview,
  ) {
    final value = preview['fluid_contribution'] ??
        preview['fluidContribution'] ??
        preview['fluidContributionPreview'];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  double? _fluidMlFromPreview(
    Map<String, dynamic> preview, [
    Map<String, dynamic>? fluidContribution,
  ]) {
    final fluid = fluidContribution ?? _fluidContributionFromPreview(preview);
    return parseFoodNutrientNumber(
      fluid?['total_fluid_contribution_ml'] ??
          fluid?['totalFluidContributionMl'] ??
          fluid?['water_content_ml'] ??
          fluid?['waterContentMl'] ??
          preview['total_fluid_contribution_ml'] ??
          preview['totalFluidContributionMl'] ??
          preview['water_content_ml'] ??
          preview['waterContentMl'] ??
          preview['waterMl'] ??
          preview['water_ml'],
    );
  }

  bool _fluidDataAvailable(
    Map<String, dynamic> preview,
    Map<String, dynamic>? fluidContribution,
    double? fluidMl,
  ) {
    final available = fluidContribution?['water_data_available'] ??
        fluidContribution?['waterDataAvailable'] ??
        preview['water_data_available'] ??
        preview['waterDataAvailable'];
    if (available is bool) return available;
    return fluidMl != null;
  }

  Map<String, dynamic>? _savedServingDetails(FoodItem food) {
    final foodId = food.foodId?.trim() ?? '';
    final servingId = food.servingId?.trim() ?? '';
    final quantity = food.quantity;
    if (foodId.isEmpty || servingId.isEmpty || quantity <= 0) return null;

    double perServing(double total) => total / quantity;
    final savedBaseNutrients = food.raw?['servingNutrients'] is Map
        ? Map<String, dynamic>.from(food.raw!['servingNutrients'] as Map)
        : const <String, dynamic>{};
    double baseNutrient(String key, double total) {
      final saved = parseFoodNutrientNumber(savedBaseNutrients[key]);
      return saved ?? perServing(total);
    }
    final servingDescription = food.raw?['servingDescription']?.toString() ??
        food.raw?['servingLabel']?.toString() ??
        food.portion;
    final servingMetadata = food.raw?['servingMetadata'] is Map
        ? Map<String, dynamic>.from(food.raw!['servingMetadata'] as Map)
        : const <String, dynamic>{};
    final serving = <String, dynamic>{
      'serving_id': servingId,
      'serving_description': servingDescription,
      'display_text': servingDescription,
      'number_of_units': servingMetadata['numberOfUnits'],
      'measurement_description': servingMetadata['measurementDescription'],
      'metric_serving_amount': servingMetadata['metricServingAmount'],
      'metric_serving_unit': servingMetadata['metricServingUnit'],
      'servingMetadata': servingMetadata,
      'nutrients': <String, dynamic>{
        'calories': baseNutrient('calories', food.calories.toDouble()),
        'protein': baseNutrient('protein', food.protein),
        'carbohydrate': baseNutrient('carbohydrate', food.carbohydrate),
        'fat': baseNutrient('fat', food.fat),
        'sodium': baseNutrient('sodium', food.sodium),
        'potassium': baseNutrient('potassium', food.potassium),
        'phosphorus': baseNutrient('phosphorus', food.phosphorus),
      },
    };

    return <String, dynamic>{
      'food_id': foodId,
      'food_name': food.name,
      'servings': [serving],
    };
  }

  Future<void> _showImageInputOptions() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Food Image',
                style: TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF00BFA5),
                ),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.upload_file_outlined,
                  color: Color(0xFF00BFA5),
                ),
                title: const Text('Upload File'),
                onTap: () => Navigator.pop(dialogContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final pickedImage = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (pickedImage == null) return;

    if (!mounted) return;
    bool processingDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C874)),
      ),
    );

    try {
      final imageBytes = await pickedImage.readAsBytes();
      final response = await ApiService.recognizeFoodImage(
        imageBytes: imageBytes,
        contentType: _contentTypeForImage(pickedImage.path),
      );
      if (!mounted) return;
      if (processingDialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        processingDialogOpen = false;
      }

      if (response['success'] == false) {
        throw Exception(
          response['error'] ?? 'The image could not be identified as food.',
        );
      }

      final foodDetails = _extractRecognizedFoodDetails(response);
      final recognizedName =
          foodDetails['food_name'] ?? foodDetails['foodName'] ?? 'unknown';
      final recognizedServingCount = foodDetails['servings'] is List
          ? (foodDetails['servings'] as List).length
          : 0;
      debugPrint(
        'IMAGE_RECOGNITION_NODE_RESULT food=$recognizedName servings=$recognizedServingCount',
      );

      if (foodDetails.isEmpty) {
        throw Exception('No FatSecret nutrition match was returned.');
      }
      if (foodDetails['servings'] is! List) {
        throw Exception('Recognized food has no serving options to review.');
      }

      final food = FoodItem.fromCatalog({
        'foodId': foodDetails['food_id'] ?? foodDetails['foodId'],
        'name': foodDetails['food_name'] ?? foodDetails['foodName'],
        'brandName': foodDetails['brand_name'] ?? foodDetails['brandName'],
        'foodType': foodDetails['food_type'] ?? foodDetails['foodType'],
        'servingDescription': 'Select serving',
        'source': response['source'] ?? 'image_recognition',
        'raw': foodDetails,
      });
      if (mounted) {
        final rawServings = foodDetails['servings'] is List
            ? List<dynamic>.from(foodDetails['servings'] as List)
            : <dynamic>[];
        final firstServing = rawServings.whereType<Map>().isNotEmpty
            ? Map<String, dynamic>.from(rawServings.whereType<Map>().first)
            : <String, dynamic>{};
        setState(() {
          _imageReviewFoodDetails = {
            ...foodDetails,
            'display_food_name': food.name,
            'display_food_id': food.foodId,
          };
          _imageReviewSelectedServing = firstServing;
          _imageReviewQuantityController.text = '1';
        });
        debugPrint('IMAGE_RECOGNITION_INLINE_REVIEW_READY');
      }
    } catch (e) {
      if (processingDialogOpen) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        processingDialogOpen = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to recognize food image: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _extractRecognizedFoodDetails(
    Map<String, dynamic> response,
  ) {
    final directFood = response['food'];
    if (directFood is Map) {
      return Map<String, dynamic>.from(directFood);
    }

    final recognizedFood = response['recognizedFood'];
    if (recognizedFood is Map) {
      return Map<String, dynamic>.from(recognizedFood);
    }

    final result = response['result'];
    if (result is Map && result['food'] is Map) {
      return Map<String, dynamic>.from(result['food'] as Map);
    }

    final data = response['data'];
    if (data is Map && data['food'] is Map) {
      return Map<String, dynamic>.from(data['food'] as Map);
    }

    return <String, dynamic>{};
  }

  String _contentTypeForImage(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }

  Future<void> _generateMealPlan() async {
    int selectedDays = 7;

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate Meal Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many days would you like to plan for?',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ...[3, 7, 14].map((days) {
                    final isSelected = selectedDays == days;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('$days days'),
                          selected: isSelected,
                          showCheckmark: false,
                          onSelected: (_) {
                            setDialogState(() {
                              selectedDays = days;
                            });
                          },
                          selectedColor: const Color(0xFF00C874),
                          backgroundColor: const Color(0xFFF3F7F5),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF00A86B)
                                : const Color(0xFFDDE7E2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF455A64),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, selectedDays),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C874),
              ),
              child: const Text(
                'Generate',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    if (!mounted) return;
    setState(() {
      _isGeneratingMealPlan = true;
    });

    var loadingDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MealPlanLoadingDialog(planDays: result),
    ).then((_) {
      loadingDialogOpen = false;
    });

    void closeLoadingDialog() {
      if (!loadingDialogOpen || !mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      loadingDialogOpen = false;
    }

    try {
      final response = await ApiService.generateMealPlan(
        profileUserId: _activeProfileUserId,
        date: _selectedDate,
        days: result,
      );

      if (response['success'] == false) {
        throw Exception(response['error'] ?? 'Failed to generate meal plan.');
      }

      if (!mounted) return;
      final mealPlan = response['mealPlan'] ?? response;
      closeLoadingDialog();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealPlanPage(
            mealPlan: mealPlan is Map ? Map<String, dynamic>.from(mealPlan) : {},
            profileUserId: _activeProfileUserId,
            selectedDate: _selectedDate,
            onAddMealPlan: (plan) async {
              final addedCount = await _addMealPlanToFoodLog(plan);
              final completedFirstPlan =
                  _mealPlanCompletionAwardUnlocked;
              await _loadFoodLogs(forceRefresh: true);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      completedFirstPlan
                          ? 'Yay! You completed your first meal plan!'
                          : '$addedCount meal plan item(s) added.',
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      closeLoadingDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate meal plan: $e')),
        );
      }
    } finally {
      closeLoadingDialog();
      if (mounted) {
        setState(() {
          _isGeneratingMealPlan = false;
        });
      }
    }
  }


  Future<void> _viewTodaysMealPlan() async {
    if (!mounted) return;
    setState(() {
      _isGeneratingMealPlan = true;
    });

    try {
      final response = await ApiService.getTodaysMealPlan(
        profileUserId: _activeProfileUserId,
      );

      final mealPlan = response['todaysMealPlan'] ?? response['mealPlan'];

      if (response['success'] == false || mealPlan == null) {
        throw Exception('No saved meal plan found for today.');
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealPlanPage(
            mealPlan: mealPlan is Map ? Map<String, dynamic>.from(mealPlan) : {},
            profileUserId: _activeProfileUserId,
            selectedDate: _selectedDate,
            onAddMealPlan: (plan) async {
              final addedCount = await _addMealPlanToFoodLog(plan);
              final completedFirstPlan =
                  _mealPlanCompletionAwardUnlocked;
              await _loadFoodLogs(forceRefresh: true);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      completedFirstPlan
                          ? 'Yay! You completed your first meal plan!'
                          : '$addedCount meal plan item(s) added.',
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meal plan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingMealPlan = false;
        });
      }
    }
  }

  void _showAddFoodDialog(String emoji, String defaultName, {FoodItem? food}) {
    final TextEditingController nameController = TextEditingController(
      text: food?.name ?? defaultName,
    );
    final TextEditingController portionController = TextEditingController(
      text: food?.portion ?? '1 serving',
    );
    List<FoodItem> dialogSuggestions = [];
    bool isSearchingDialogSuggestions = false;
    bool isSavingDialogFood = false;
    String latestDialogQuery = '';
    Timer? suggestionDebounce;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            bool isFormValid =
                nameController.text.trim().isNotEmpty &&
                portionController.text.trim().isNotEmpty;
            void onFieldChanged(String _) {
              setStateDialog(() {});
            }
            void searchDialogSuggestions(String value) {
              final requestedQuery = value.trim();
              latestDialogQuery = requestedQuery;
              suggestionDebounce?.cancel();

              if (requestedQuery.length < 2) {
                setStateDialog(() {
                  dialogSuggestions = [];
                  isSearchingDialogSuggestions = false;
                });
                return;
              }

              setStateDialog(() {
                isSearchingDialogSuggestions = true;
              });

              suggestionDebounce = Timer(
                const Duration(milliseconds: 650),
                () async {
                  try {
                    final response = await ApiService.searchFoods(
                      _normalizeFoodSearchQuery(requestedQuery),
                    );
                    if (latestDialogQuery != requestedQuery) return;
                    final foods = response['foods'];
                    final parsedSuggestions = foods is List
                        ? foods
                            .whereType<Map>()
                            .map(
                              (food) => FoodItem.fromCatalog(
                                Map<String, dynamic>.from(food),
                              ),
                            )
                            .toList()
                        : <FoodItem>[];
                    setStateDialog(() {
                      dialogSuggestions = _rankFoodSearchSuggestions(
                        parsedSuggestions,
                        requestedQuery,
                      );
                    });
                  } catch (_) {
                    if (latestDialogQuery != requestedQuery) return;
                    setStateDialog(() {
                      dialogSuggestions = [];
                    });
                  } finally {
                    if (latestDialogQuery != requestedQuery) return;
                    setStateDialog(() {
                      isSearchingDialogSuggestions = false;
                    });
                  }
                },
              );
            }

            void closeDialog() {
              suggestionDebounce?.cancel();
              Navigator.pop(context);
            }

            Future<void> openSuggestion(FoodItem suggestion) async {
              suggestionDebounce?.cancel();
              Navigator.pop(context);
              await _showFoodServingDialog(suggestion);
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add to $_selectedMealType',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF37474F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      label: "Food Name",
                      controller: nameController,
                      onChanged: (value) {
                        onFieldChanged(value);
                        searchDialogSuggestions(value);
                      },
                    ),
                    if (isSearchingDialogSuggestions)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(
                          color: Color(0xFF00C874),
                          minHeight: 2,
                        ),
                      ),
                    if (dialogSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FBFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFE0E0E0)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: dialogSuggestions.take(5).length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = dialogSuggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                suggestion.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                suggestion.portion,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF00C874),
                              ),
                              onTap: () => openSuggestion(suggestion),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildDialogTextField(
                      label: "Portion Size",
                      controller: portionController,
                      hint: "e.g. 1 medium, 100g",
                      onChanged: onFieldChanged,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isSavingDialogFood
                                ? null
                                : closeDialog,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF37474F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isFormValid && !isSavingDialogFood
                                ? () async {
                                    final foodToSave = FoodItem(
                                      foodId: food?.foodId,
                                      emoji: emoji,
                                      name: nameController.text.trim(),
                                      portion: portionController.text.trim(),
                                      calories: food?.calories ?? 0,
                                      time: DateFormat(
                                        'h:mm a',
                                      ).format(DateTime.now()),
                                      protein: food?.protein ?? 0,
                                      carbohydrate: food?.carbohydrate ?? 0,
                                      fat: food?.fat ?? 0,
                                      sodium: food?.sodium ?? 0,
                                      potassium: food?.potassium ?? 0,
                                      phosphorus: food?.phosphorus ?? 0,
                                      source: food?.source ?? 'manual_entry',
                                      needsManualReview:
                                          food?.needsManualReview ?? false,
                                      raw: food?.raw,
                                    );

                                    try {
                                      setStateDialog(() {
                                        isSavingDialogFood = true;
                                      });
                                      if (food?.id == null) {
                                        await _saveFoodItem(foodToSave);
                                      } else {
                                        await _updateFoodItem(food!, foodToSave);
                                      }
                                      if (context.mounted) {
                                        suggestionDebounce?.cancel();
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Unable to save food: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setStateDialog(() {
                                          isSavingDialogFood = false;
                                        });
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C874),
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: isSavingDialogFood
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    food?.id == null ? 'Add Food' : 'Update',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showFoodServingDialog(
    FoodItem food, {
    Map<String, dynamic>? preloadedDetails,
    FoodItem? existingLog,
  }) async {
    if (food.foodId == null || food.foodId!.isEmpty) {
      _showAddFoodDialog(food.emoji, food.name, food: food);
      return;
    }

    if (preloadedDetails == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C874)),
        ),
      );
    }

    Map<String, dynamic> details = preloadedDetails ?? {};
    try {
      if (preloadedDetails == null) {
        details = await ApiService.getFoodDetails(food.foodId!);
      }
    } catch (e) {
      if (mounted && preloadedDetails == null) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load serving options: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    if (preloadedDetails == null) Navigator.pop(context);

    final Map<String, dynamic> foodDetails = details['food'] is Map
        ? Map<String, dynamic>.from(details['food'] as Map)
        : Map<String, dynamic>.from(details);
    final List<dynamic> rawServings = foodDetails['servings'] is List
        ? List<dynamic>.from(foodDetails['servings'] as List)
        : details['servings'] is List
            ? List<dynamic>.from(details['servings'] as List)
            : <dynamic>[];
    final List<Map<String, dynamic>> servings = rawServings
        .whereType<Map>()
        .map<Map<String, dynamic>>(
          (serving) => Map<String, dynamic>.from(serving),
        )
        .toList(growable: false);

    if (servings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No serving options found for this food.')),
      );
      return;
    }

    Map<String, dynamic> selectedServing = servings.firstWhere(
      (serving) =>
          food.servingId != null &&
          serving['serving_id']?.toString() == food.servingId,
      orElse: () => servings.first,
    );
    final initialQuantity = (existingLog ?? food).quantity;
    double selectedQuantity = initialQuantity > 0 ? initialQuantity : 1;
    final quantityController = TextEditingController(
      text: initialQuantity % 1 == 0
          ? initialQuantity.toInt().toString()
          : initialQuantity.toString(),
    );
    bool isSavingServing = false;
    final isEditing = existingLog != null;
    Timer? fluidPreviewDebounce;
    String? fluidPreviewRequestKey;
    String? fluidPreviewFutureKey;
    Future<Map<String, dynamic>>? fluidPreviewFuture;
    Map<String, dynamic>? fluidPreviewPayload;
    Map<String, dynamic>? ckdSafetyAssessment;
    bool fluidPreviewLoading = false;
    bool fluidPreviewResolved = false;
    bool fluidPreviewAvailable = existingLog?.waterMl != null &&
        existingLog!.waterMl >= 0 &&
        (existingLog.waterMl > 0 || existingLog.fluidContribution != null);
    double? fluidPreviewMl = existingLog?.waterMl;
    Map<String, dynamic>? fluidPreviewContribution =
        existingLog?.fluidContribution;
    bool fluidPanelOpen = true;
    bool isClosingServingPanel = false;

    void stopFluidPreview() {
      isClosingServingPanel = true;
      fluidPanelOpen = false;
      fluidPreviewRequestKey = null;
      fluidPreviewDebounce?.cancel();
      fluidPreviewDebounce = null;
    }

    void queueFluidPreview(
      StateSetter setStateDialog,
      Map<String, dynamic> serving,
      double quantity,
    ) {
      final servingId = serving['serving_id']?.toString();
      if (servingId == null || servingId.isEmpty || quantity <= 0) return;
      final requestKey = '${food.foodId}|$servingId|$quantity';
      if (fluidPreviewRequestKey == requestKey) return;
      fluidPreviewRequestKey = requestKey;
      fluidPreviewDebounce?.cancel();
      fluidPreviewDebounce = Timer(const Duration(milliseconds: 300), () async {
        if (!fluidPanelOpen) return;
        setStateDialog(() {
          fluidPreviewLoading = true;
        });
        try {
          fluidPreviewFutureKey = requestKey;
          fluidPreviewFuture = ApiService.previewFoodLog(
            profileUserId: _activeProfileUserId,
            mealType: _selectedMealType,
            foodId: food.foodId!,
            servingId: servingId,
            quantity: quantity,
          );
          final response = await fluidPreviewFuture!;
          if (!fluidPanelOpen || fluidPreviewRequestKey != requestKey) return;
          final preview = response['preview'] is Map
              ? Map<String, dynamic>.from(response['preview'] as Map)
              : <String, dynamic>{};
          final safety = response['ckdSafety'] is Map
              ? Map<String, dynamic>.from(response['ckdSafety'] as Map)
              : null;
          final contribution = _fluidContributionFromPreview(preview);
          final fluidMl = _fluidMlFromPreview(preview, contribution);
          setStateDialog(() {
            fluidPreviewPayload = preview;
            ckdSafetyAssessment = safety;
            fluidPreviewMl = fluidMl;
            fluidPreviewContribution = contribution;
            fluidPreviewAvailable =
                _fluidDataAvailable(preview, contribution, fluidMl);
            fluidPreviewResolved = true;
            fluidPreviewLoading = false;
          });
        } catch (error) {
          if (!fluidPanelOpen || fluidPreviewRequestKey != requestKey) return;
          debugPrint('Food fluid preview unavailable: $error');
          setStateDialog(() {
            fluidPreviewPayload = null;
            ckdSafetyAssessment = null;
            fluidPreviewMl = null;
            fluidPreviewContribution = null;
            fluidPreviewAvailable = false;
            fluidPreviewResolved = true;
            fluidPreviewLoading = false;
          });
        }
      });
    }

    debugPrint('FOOD_REVIEW_PANEL_SHOW servings=${servings.length}');
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final quantity = selectedQuantity;
            final nutrients = normalizeFoodNutrients(
              Map<String, dynamic>.from(selectedServing),
              multiplier: quantity,
            );
            final calories = _asDouble(nutrients['calories']).round();
            final protein = _asDouble(nutrients['protein']);
            final carbohydrate = _asDouble(nutrients['carbohydrate']);
            final fat = _asDouble(nutrients['fat']);
            final sodium = _asDouble(nutrients['sodium']);
            final potassium = _asDouble(nutrients['potassium']);
            final phosphorus = _asDouble(nutrients['phosphorus']);
            final safetyTargets = ckdSafetyAssessment?['targets'] is Map
                ? Map<String, dynamic>.from(
                    ckdSafetyAssessment!['targets'] as Map,
                  )
                : const <String, dynamic>{};
            final nutrientImpacts = <Map<String, dynamic>>[];
            void addNutrientImpact(
              String name,
              double amount,
              dynamic rawTarget,
              String unit,
            ) {
              final target = parseFoodNutrientNumber(rawTarget);
              if (target == null || target <= 0 || amount <= 0) return;
              nutrientImpacts.add({
                'name': name,
                'amount': amount,
                'target': target,
                'percent': amount / target * 100,
                'unit': unit,
              });
            }
            addNutrientImpact(
              'Sodium',
              sodium,
              safetyTargets['sodium'] ?? 2000,
              'mg',
            );
            addNutrientImpact(
              'Potassium',
              potassium,
              safetyTargets['potassium'],
              'mg',
            );
            addNutrientImpact(
              'Phosphorus',
              phosphorus,
              safetyTargets['phosphorus'],
              'mg',
            );
            addNutrientImpact(
              'Protein',
              protein,
              safetyTargets['protein'],
              'g',
            );
            nutrientImpacts.sort(
              (a, b) => (b['percent'] as double)
                  .compareTo(a['percent'] as double),
            );
            final highestImpact =
                nutrientImpacts.isEmpty ? null : nutrientImpacts.first;
            final highestPercent =
                highestImpact?['percent'] as double? ?? 0;
            final portionRiskColor = highestPercent >= 50
                ? const Color(0xFFD32F2F)
                : highestPercent >= 20
                    ? const Color(0xFFF9A825)
                    : const Color(0xFF2E7D32);
            final portionRiskLabel = highestPercent >= 50
                ? 'High risk'
                : highestPercent >= 20
                    ? 'Moderate'
                    : 'Safe range';
            final isRestrictedFood =
                ckdSafetyAssessment?['isRestricted'] == true;
            final restrictedFoodWarning =
                ckdSafetyAssessment?['warning']?.toString();
            final servingText = selectedServing['display_text']?.toString() ??
                selectedServing['serving_description']?.toString() ??
                'Serving';
            queueFluidPreview(setStateDialog, selectedServing, quantity);
            final fluidPreviewText = fluidPreviewLoading &&
                    !fluidPreviewResolved
                ? 'Checking...'
                : fluidPreviewAvailable
                    ? '${(fluidPreviewMl ?? 0).toStringAsFixed(1)} mL'
                    : fluidPreviewLoading
                        ? 'Updating...'
                        : 'No fluid contribution available';
            final fluidLimitMl = parseFoodNutrientNumber(
              fluidPreviewContribution?['daily_fluid_limit_ml'] ??
                  fluidPreviewContribution?['dailyFluidLimitMl'],
            );
            final updatedFluidMl = parseFoodNutrientNumber(
              fluidPreviewContribution?['updated_daily_fluid_consumed_ml'] ??
                  fluidPreviewContribution?['updatedDailyFluidConsumedMl'],
            );
            final fluidPercent = parseFoodNutrientNumber(
              fluidPreviewContribution?['fluid_contribution_percent'] ??
                  fluidPreviewContribution?['fluidContributionPercent'],
            );
            final backendFluidWarning =
                fluidPreviewContribution?['show_fluid_warning'] == true ||
                    fluidPreviewContribution?['showFluidWarning'] == true;
            final fluidLimitExceeded = fluidLimitMl != null &&
                updatedFluidMl != null &&
                updatedFluidMl > fluidLimitMl;
            final fluidLimitApproaching = fluidLimitMl != null &&
                updatedFluidMl != null &&
                updatedFluidMl >= fluidLimitMl * 0.8;
            final showFluidWarning = backendFluidWarning ||
                fluidLimitApproaching ||
                fluidLimitExceeded;
            final backendWarningText =
                fluidPreviewContribution?['warning']?.toString().trim();
            final fluidWarningText = fluidLimitExceeded
                ? 'This would exceed the daily fluid limit.'
                : fluidLimitApproaching
                    ? 'This would bring today\'s fluid intake close to the daily limit.'
                    : backendWarningText?.isNotEmpty == true
                        ? backendWarningText!
                        : 'This food contributes a large portion of the daily fluid allowance.';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing
                          ? 'Review the serving and nutrients before updating.'
                          : 'Review the serving and nutrients before adding.',
                      style: const TextStyle(
                        color: Color(0xFF90A4AE),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Serving option',
                      style: TextStyle(
                        color: Color(0xFF90A4AE),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 160),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: servings.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final serving = servings[index];
                          final label =
                              serving['display_text']?.toString() ??
                                  serving['serving_description']?.toString() ??
                                  'Serving';
                          final isSelected =
                              serving['serving_id']?.toString() ==
                                  selectedServing['serving_id']?.toString();
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF00C874),
                                  )
                                : const Icon(
                                    Icons.radio_button_unchecked,
                                    color: Color(0xFFB0BEC5),
                                  ),
                            onTap: () {
                              setStateDialog(() {
                                selectedServing = serving;
                                fluidPreviewPayload = null;
                                ckdSafetyAssessment = null;
                                fluidPreviewContribution = null;
                                fluidPreviewResolved = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isRestrictedFood) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEF9A9A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFC62828),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CKD restricted food',
                                    style: TextStyle(
                                      color: Color(0xFFC62828),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    restrictedFoodWarning ??
                                        'This food may be highly processed or high in sodium.',
                                    style: const TextStyle(
                                      color: Color(0xFFB71C1C),
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'You may still continue after reviewing the portion risk below.',
                                    style: TextStyle(
                                      color: Color(0xFFB71C1C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _portionFieldLabel(selectedServing),
                            style: const TextStyle(
                              color: Color(0xFF90A4AE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          quantity.toStringAsFixed(
                            quantity % 1 == 0 ? 0 : 2,
                          ),
                          style: TextStyle(
                            color: portionRiskColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: portionRiskColor,
                        inactiveTrackColor: portionRiskColor.withOpacity(0.2),
                        thumbColor: portionRiskColor,
                        overlayColor: portionRiskColor.withOpacity(0.12),
                        valueIndicatorColor: portionRiskColor,
                      ),
                      child: Slider(
                        min: 0.25,
                        max: 20,
                        divisions: 79,
                        value: quantity.clamp(0.25, 20).toDouble(),
                        label: quantity.toStringAsFixed(
                          quantity % 1 == 0 ? 0 : 2,
                        ),
                        onChanged: isSavingServing
                            ? null
                            : (value) {
                                setStateDialog(() {
                                  selectedQuantity = value;
                                  quantityController.text = value.toString();
                                  fluidPreviewPayload = null;
                                  ckdSafetyAssessment = null;
                                  fluidPreviewContribution = null;
                                  fluidPreviewResolved = false;
                                });
                              },
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: portionRiskColor),
                        const SizedBox(width: 6),
                        Text(
                          portionRiskLabel,
                          style: TextStyle(
                            color: portionRiskColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_loggedPortionLabel(selectedServing, quantity)} • $calories kcal',
                      style: const TextStyle(
                        color: Color(0xFF546E7A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showFluidWarning) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFB74D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFE65100),
                              size: 21,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fluidPercent != null
                                    ? '$fluidWarningText (${fluidPercent.toStringAsFixed(1)}% of the daily limit)'
                                    : fluidWarningText,
                                style: const TextStyle(
                                  color: Color(0xFFE65100),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FBF7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0F2E9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nutrients for selected amount',
                            style: TextStyle(
                              color: Color(0xFF37474F),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildNutrientLine('Calories', '$calories kcal'),
                          _buildNutrientLine(
                            'Protein',
                            '${protein.toStringAsFixed(1)} g',
                          ),
                          _buildNutrientLine(
                            'Carbs',
                            '${carbohydrate.toStringAsFixed(1)} g',
                          ),
                          _buildNutrientLine(
                            'Fat',
                            '${fat.toStringAsFixed(1)} g',
                          ),
                          _buildNutrientLine(
                            'Sodium',
                            '${sodium.round()} mg',
                          ),
                          _buildNutrientLine(
                            'Potassium',
                            potassium > 0
                                ? '${potassium.round()} mg (estimate)'
                                : 'Not provided',
                          ),
                          _buildNutrientLine(
                            'Phosphorus',
                            phosphorus > 0
                                ? '${phosphorus.round()} mg (guide)'
                                : 'Not available',
                          ),
                          _buildNutrientLine(
                            'Fluid contribution',
                            fluidPreviewText,
                          ),
                        ],
                      ),
                    ),
                    if (nutrientImpacts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: portionRiskColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: portionRiskColor.withOpacity(0.45),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              highestPercent >= 50
                                  ? 'Warning: high nutrient impact'
                                  : 'Nutrient impact on daily targets',
                              style: TextStyle(
                                color: portionRiskColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...nutrientImpacts.map((impact) {
                              final isHighest =
                                  impact['name'] == highestImpact?['name'];
                              final percent = impact['percent'] as double;
                              final amount = impact['amount'] as double;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  '${impact['name']}: ${amount.toStringAsFixed(1)} ${impact['unit']} '
                                  '(${percent.toStringAsFixed(1)}% of daily target)',
                                  style: TextStyle(
                                    color: isHighest
                                        ? portionRiskColor
                                        : const Color(0xFF546E7A),
                                    fontSize: 12,
                                    fontWeight: isHighest
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }),
                            if (highestImpact != null && highestPercent >= 20)
                              Text(
                                'This serving uses a ${highestPercent >= 50 ? 'large' : 'meaningful'} portion '
                                'of the daily ${highestImpact['name'].toString().toLowerCase()} allowance.',
                                style: TextStyle(
                                  color: portionRiskColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isSavingServing
                                ? null
                                : () {
                                    stopFluidPreview();
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    Navigator.pop(dialogContext);
                                  },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: quantity > 0 &&
                                    !isSavingServing &&
                                    fluidPreviewResolved
                                ? () async {
                                    final pendingFood = FoodItem(
                                      foodId: food.foodId,
                                      servingId: selectedServing['serving_id']
                                          ?.toString(),
                                      emoji: food.emoji,
                                      name: food.name,
                                      portion: _loggedPortionLabel(
                                        selectedServing,
                                        quantity,
                                      ),
                                      quantity: quantity,
                                      calories: calories,
                                      time: DateFormat(
                                        'h:mm a',
                                      ).format(DateTime.now()),
                                      protein: protein,
                                      carbohydrate: carbohydrate,
                                      fat: fat,
                                      sodium: sodium,
                                      potassium: potassium,
                                      phosphorus: phosphorus,
                                      source: food.source == 'manual_entry'
                                          ? 'fatsecret'
                                          : food.source,
                                      raw: foodDetails,
                                    );
                                    final logKey = _logKeyFor(
                                      mealType: _selectedMealType,
                                      name: pendingFood.name,
                                      portion: pendingFood.portion,
                                      date: _selectedDate,
                                    );
                                    try {
                                      if (_savingLogKeys.contains(logKey) ||
                                          _hasDuplicateLog(
                                            pendingFood,
                                            exceptId: existingLog?.id,
                                          )) {
                                        throw Exception(
                                          'This food is already logged for $_selectedMealType.',
                                        );
                                      }
                                      setStateDialog(() {
                                        isSavingServing = true;
                                      });
                                      if (mounted) {
                                        setState(() {
                                          _savingLogKeys.add(logKey);
                                        });
                                      }
                                      var savedCalories = calories.toDouble();
                                      var savedProtein = protein;
                                      var savedCarbohydrate = carbohydrate;
                                      var savedFat = fat;
                                      var savedSodium = sodium;
                                      var savedPotassium = potassium;
                                      var savedPhosphorus = phosphorus;
                                      double? savedWaterMl;
                                      Map<String, dynamic>? savedFluidContribution;
                                      Map<String, dynamic> savedRaw =
                                          Map<String, dynamic>.from(foodDetails);
                                      final selectedServingId =
                                          selectedServing['serving_id']
                                              ?.toString();

                                      if (food.foodId != null &&
                                          food.foodId!.isNotEmpty &&
                                          selectedServingId != null &&
                                          selectedServingId.isNotEmpty) {
                                        try {
                                          final previewRequestKey =
                                              '${food.foodId}|$selectedServingId|$quantity';
                                          Map<String, dynamic> previewResponse;
                                          if (fluidPreviewFutureKey ==
                                                  previewRequestKey &&
                                              fluidPreviewFuture != null) {
                                            previewResponse =
                                                await fluidPreviewFuture!;
                                          } else if (fluidPreviewRequestKey ==
                                                  previewRequestKey &&
                                              fluidPreviewPayload != null) {
                                            previewResponse = {
                                              'preview': fluidPreviewPayload,
                                            };
                                          } else {
                                            fluidPreviewDebounce?.cancel();
                                            fluidPreviewFutureKey =
                                                previewRequestKey;
                                            fluidPreviewFuture =
                                                ApiService.previewFoodLog(
                                              profileUserId:
                                                  _activeProfileUserId,
                                              mealType: _selectedMealType,
                                              foodId: food.foodId!,
                                              servingId: selectedServingId,
                                              quantity: quantity,
                                            );
                                            previewResponse =
                                                await fluidPreviewFuture!;
                                          }
                                          final preview =
                                              previewResponse['preview'] is Map
                                                  ? Map<String, dynamic>.from(
                                                      previewResponse['preview']
                                                          as Map,
                                                    )
                                                  : <String, dynamic>{};
                                          if (preview.isNotEmpty) {
                                            final previewNutrients =
                                                normalizeFoodNutrients(preview);
                                            savedCalories =
                                                parseFoodNutrientNumber(
                                                      previewNutrients[
                                                          'calories'],
                                                    ) ??
                                                    savedCalories;
                                            savedProtein =
                                                parseFoodNutrientNumber(
                                                      previewNutrients[
                                                          'protein'],
                                                    ) ??
                                                    savedProtein;
                                            savedCarbohydrate =
                                                parseFoodNutrientNumber(
                                                      previewNutrients[
                                                          'carbohydrate'],
                                                    ) ??
                                                    savedCarbohydrate;
                                            savedFat =
                                                parseFoodNutrientNumber(
                                                      previewNutrients['fat'],
                                                    ) ??
                                                    savedFat;
                                            savedSodium =
                                                parseFoodNutrientNumber(
                                                      previewNutrients[
                                                          'sodium'],
                                                    ) ??
                                                    savedSodium;
                                            savedPotassium =
                                                parseFoodNutrientNumber(
                                                      previewNutrients[
                                                          'potassium'],
                                                    ) ??
                                                    savedPotassium;
                                            savedPhosphorus =
                                                parseFoodNutrientNumber(
                                                      previewNutrients[
                                                          'phosphorus'],
                                                    ) ??
                                                    savedPhosphorus;
                                            savedFluidContribution =
                                                _fluidContributionFromPreview(
                                              preview,
                                            );
                                            savedWaterMl =
                                                _fluidMlFromPreview(
                                              preview,
                                              savedFluidContribution,
                                            );
                                            savedRaw = {
                                              ...savedRaw,
                                              'mealLoggingPreview': preview,
                                            };
                                          }
                                        } catch (e) {
                                          debugPrint(
                                            'Food preview unavailable; using local nutrients: $e',
                                          );
                                        }
                                      }
                                      final response = isEditing
                                            ? await ApiService.updateFoodLog(
                                              profileUserId: _activeProfileUserId,
                                              foodLogId: existingLog.id!,
                                              mealType: _selectedMealType,
                                              date: _selectedDate,
                                              servingId:
                                                  selectedServingId,
                                              quantity: quantity,
                                              name: food.name,
                                              portion: pendingFood.portion,
                                              calories:
                                                  savedCalories.round(),
                                              protein: savedProtein,
                                              carbohydrate:
                                                  savedCarbohydrate,
                                              fat: savedFat,
                                              sodium: savedSodium,
                                              potassium: savedPotassium,
                                              phosphorus: savedPhosphorus,
                                              waterMl: savedWaterMl,
                                              fluidContribution:
                                                  savedFluidContribution,
                                              raw: savedRaw,
                                            )
                                            : await _addFoodLogWithAllergyConfirmation(
                                              mealType: _selectedMealType,
                                              date: _selectedDate,
                                              foodId: food.foodId,
                                              servingId: selectedServingId,
                                              quantity: quantity,
                                              name: food.name,
                                              portion: pendingFood.portion,
                                              calories:
                                                  savedCalories.round(),
                                              protein: savedProtein,
                                              carbohydrate:
                                                  savedCarbohydrate,
                                              fat: savedFat,
                                              sodium: savedSodium,
                                              potassium: savedPotassium,
                                              phosphorus: savedPhosphorus,
                                              waterMl: savedWaterMl,
                                              fluidContribution:
                                                  savedFluidContribution,
                                              source: 'fatsecret',
                                              raw: savedRaw,
                                            );
                                      if (response['success'] == false) {
                                        throw Exception(
                                          response['error'] ??
                                              response['message'] ??
                                              'Food was not logged.',
                                        );
                                      }
                                      final log = response['log'];
                                      final savedFood = log is Map
                                          ? FoodItem.fromLog(
                                              Map<String, dynamic>.from(log),
                                            )
                                          : pendingFood;

                                      if (mounted) {
                                        setState(() {
                                          if (isEditing) {
                                            final foods =
                                                _loggedMeals[_selectedMealType] ??
                                                    [];
                                            final index = foods.indexWhere(
                                              (item) =>
                                                  item.id == existingLog.id,
                                            );
                                            if (index >= 0) {
                                              foods[index] = savedFood;
                                            }
                                          } else {
                                            _loggedMeals[_selectedMealType]
                                                ?.add(savedFood);
                                          }
                                        });
                                      }
                                      await _loadCurrentStreak(
                                        forceRefresh: true,
                                      );
                                      if (dialogContext.mounted) {
                                        stopFluidPreview();
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        Navigator.pop(dialogContext);
                                      }
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Unable to save food: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        if (isClosingServingPanel) {
                                          _savingLogKeys.remove(logKey);
                                        } else {
                                          setState(() {
                                            _savingLogKeys.remove(logKey);
                                          });
                                        }
                                      }
                                      if (dialogContext.mounted &&
                                          !isClosingServingPanel) {
                                        setStateDialog(() {
                                          isSavingServing = false;
                                        });
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C874),
                            ),
                            child: isSavingServing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    !fluidPreviewResolved
                                        ? 'Checking safety...'
                                        : isEditing
                                            ? 'Update'
                                            : 'Add',
                                    style: const TextStyle(color: Colors.white),
                                  ),
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
    stopFluidPreview();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingCaregiverChildState) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF00C874)),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    if (_resolvedCaregiverNoChildEmptyState) {
      return _buildCaregiverNoChildScaffold();
    }

    final filteredQuickAdds = _allQuickAdds
        .where((item) => item['name']!.toLowerCase().contains(_searchQuery))
        .toList();
    final allCurrentFoods = _loggedMeals[_selectedMealType] ?? [];
    final currentFoods = _searchQuery.isEmpty
        ? allCurrentFoods
        : allCurrentFoods
              .where((food) => food.name.toLowerCase().contains(_searchQuery))
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadFoodLogs(forceRefresh: true);
            await _loadCurrentStreak(forceRefresh: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Food Log',
                style: TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your meals and nutrition',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (_foodLogError != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Food logs are offline: $_foodLogError',
                    style: const TextStyle(
                      color: Color(0xFFE65100),
                      fontSize: 12,
                    ),
                  ),
                ),

              // --- Date & Streak Card ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: const TextStyle(
                            color: Color(0xFF37474F),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_totalCalories()} kcal logged',
                          style: const TextStyle(
                            color: Color(0xFF90A4AE),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7043), Color(0xFFD81B60)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentStreak day${_currentStreak == 1 ? '' : 's'} streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Camera Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FBF7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Take a Photo of Your Meal',
                      style: TextStyle(
                        color: Color(0xFF37474F),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AI-powered food recognition',
                      style: TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showImageInputOptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Open Camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildMealPlanActionsCard(),
              const SizedBox(height: 20),
              if (_imageReviewFoodDetails != null) ...[
                _buildImageReviewCard(),
                const SizedBox(height: 20),
              ],

              // --- Search Bar ---
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search logged foods...",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Quick Add ---
              const Text(
                'Quick Add',
                style: TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              filteredQuickAdds.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No quick add foods found.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filteredQuickAdds
                          .map(
                            (item) => _buildQuickAddItem(
                              item['emoji']!,
                              item['name']!,
                            ),
                          )
                          .toList(),
                    ),
              const SizedBox(height: 24),

              // --- Category Tabs ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('Breakfast'),
                    const SizedBox(width: 12),
                    _buildTab('Lunch'),
                    const SizedBox(width: 12),
                    _buildTab('Dinner'),
                    const SizedBox(width: 12),
                    _buildTab('Snacks'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Dynamic Meals Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedMealType Meals',
                    style: const TextStyle(
                      color: Color(0xFF37474F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddFoodDialog('\u{1F37D}\u{FE0F}', '');
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF66BB6A),
                      size: 18,
                    ),
                    label: const Text(
                      'Add Food',
                      style: TextStyle(color: Color(0xFF66BB6A), fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoadingLogs
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C874),
                        ),
                      ),
                    )
                  : currentFoods.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? "No matching foods found in $_selectedMealType."
                              : "No foods logged for $_selectedMealType yet.\nClick Quick Add to log a meal!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: currentFoods
                          .map((food) => _buildMealItemCard(food))
                          .toList(),
                    ),
              const SizedBox(height: 24),

              // --- Today's Summary Card ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Summary",
                      style: TextStyle(
                        color: Color(0xFF546E7A),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          'Protein',
                          '${_totalNutrient((food) => food.protein).round()}g',
                        ),
                        _buildSummaryItem(
                          'Carbs',
                          '${_totalNutrient((food) => food.carbohydrate).round()}g',
                        ),
                        _buildSummaryItem(
                          'Fat',
                          '${_totalNutrient((food) => food.fat).round()}g',
                        ),
                      ],
                    ),
                    // Calorie target circular chart (only if available)
                    if (_dailyCalorieTarget != null && _dailyCalorieTarget! > 0)
                      ...[
                        const SizedBox(height: 20),
                        _buildCalorieTargetChart(),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
            ),
          ),
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCaregiverNoChildScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Food Log',
                style: TextStyle(
                  color: Color(0xFF37474F),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0F2ED)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No child profile yet',
                      style: TextStyle(
                        color: Color(0xFF37474F),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add or link a child profile from Profile before logging food.',
                      style: TextStyle(
                        color: Color(0xFF607D8B),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
        onTap: _handleNavigationTap,
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
            activeIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleNavigationTap(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnalyticsPage(
            profileUserId: _activeProfileUserId,
            caregiverNoChildEmptyState: _resolvedCaregiverNoChildEmptyState,
          ),
        ),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HealthMetricsPage(
            profileUserId: _activeProfileUserId,
            caregiverNoChildEmptyState: _resolvedCaregiverNoChildEmptyState,
          ),
        ),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            profileUserId: _activeProfileUserId,
            caregiverNoChildEmptyState: _resolvedCaregiverNoChildEmptyState,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // --- UI Helpers ---
  Iterable<FoodItem> get _allLoggedFoods =>
      _loggedMeals.values.expand((foods) => foods);

  int _totalCalories() =>
      _allLoggedFoods.fold(0, (total, food) => total + food.calories);

  double _totalNutrient(double Function(FoodItem food) select) =>
      _allLoggedFoods.fold(0, (total, food) => total + select(food));

  Widget _buildMealPlanActionsCard() {
    final isBusy = _isGeneratingMealPlan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FFFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCDEFE1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7EE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFF00A86B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Meal plan',
                  style: TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'CKD guided',
                  style: TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMealPlanActionButton(
                  label: 'Generate plan',
                  icon: Icons.auto_awesome,
                  color: const Color(0xFF00C874),
                  onPressed: isBusy ? null : _generateMealPlan,
                  isBusy: isBusy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMealPlanActionButton(
                  label: 'View saved',
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFF00BFA5),
                  onPressed: isBusy ? null : _viewTodaysMealPlan,
                  isBusy: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required bool isBusy,
  }) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isBusy
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
          : Icon(icon, size: 16),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _servingsFromFoodDetails(
    Map<String, dynamic>? foodDetails,
  ) {
    if (foodDetails == null || foodDetails['servings'] is! List) {
      return [];
    }
    return List<dynamic>.from(foodDetails['servings'] as List)
        .whereType<Map>()
        .map<Map<String, dynamic>>(
          (serving) => Map<String, dynamic>.from(serving),
        )
        .toList(growable: false);
  }

  String _portionUnitFromServing(Map<String, dynamic> serving) {
    final rawMeasurement =
        serving['measurement_description']?.toString().trim() ?? '';
    final rawDescription = serving['display_text']?.toString().trim() ??
        serving['serving_description']?.toString().trim() ??
        'serving';
    final source = rawMeasurement.isNotEmpty ? rawMeasurement : rawDescription;
    final match = RegExp(r'[A-Za-z]+').firstMatch(source);
    return (match?.group(0) ?? 'serving').toLowerCase();
  }

  String _portionFieldLabel(Map<String, dynamic> serving) {
    return 'Portion size (${_portionUnitFromServing(serving)}):';
  }

  String _loggedPortionLabel(
    Map<String, dynamic> serving,
    double quantity,
  ) {
    final servingText = serving['display_text']?.toString() ??
        serving['serving_description']?.toString() ??
        'serving';
    final metadata = serving['servingMetadata'] is Map
        ? Map<String, dynamic>.from(serving['servingMetadata'] as Map)
        : const <String, dynamic>{};
    final numberOfUnits = _asDouble(
      serving['number_of_units'] ??
          serving['numberOfUnits'] ??
          metadata['numberOfUnits'] ??
          1,
    );
    final measurement = (serving['measurement_description'] ??
            serving['measurementDescription'] ??
            metadata['measurementDescription'])
        ?.toString()
        .trim();
    final metricAmount = _asDouble(
      serving['metric_serving_amount'] ??
          serving['metricServingAmount'] ??
          metadata['metricServingAmount'],
    );
    final metricUnit = (serving['metric_serving_unit'] ??
            serving['metricServingUnit'] ??
            metadata['metricServingUnit'])
        ?.toString()
        .trim();

    String amountText(double value, {int decimals = 2}) {
      if (value % 1 == 0) return value.toInt().toString();
      return value
          .toStringAsFixed(decimals)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }

    final parts = <String>[];
    final parsedMeasurement = RegExp(r'^\s*(\d+(?:\.\d+)?)\s+(.+)$')
        .firstMatch(measurement ?? '');
    final measurementAmount = parsedMeasurement == null
        ? numberOfUnits
        : double.tryParse(parsedMeasurement.group(1) ?? '') ?? numberOfUnits;
    final measurementUnit = parsedMeasurement?.group(2)?.trim() ?? measurement;
    final measurementIsMetric = RegExp(
      r'^(g|gram|grams|kg|ml|milliliters?)$',
      caseSensitive: false,
    ).hasMatch(measurementUnit ?? '');
    if (measurementUnit != null &&
        measurementUnit.isNotEmpty &&
        !measurementIsMetric) {
      parts.add(
        '${amountText(measurementAmount * quantity)} $measurementUnit',
      );
    }
    if (metricAmount > 0 &&
        metricUnit != null &&
        metricUnit.isNotEmpty) {
      parts.add(
        '${amountText(metricAmount * quantity, decimals: 1)} $metricUnit',
      );
    }
    if (parts.isEmpty) {
      final metricDescription = RegExp(
        r'^\s*(\d+(?:\.\d+)?)\s*(g|gram|grams|kg|ml|milliliters?)\s*$',
        caseSensitive: false,
      ).firstMatch(servingText);
      if (metricDescription != null) {
        final baseAmount =
            double.tryParse(metricDescription.group(1) ?? '') ?? 0;
        final unit = metricDescription.group(2) ?? '';
        return '${amountText(baseAmount * quantity)} $unit';
      }
      return '${amountText(quantity, decimals: 3)} × $servingText';
    }
    if (parts.length == 1) return parts.first;
    return '${parts.first} (${parts.skip(1).join(', ')})';
  }

  String _portionDisplayLabel(FoodItem food) {
    final match = RegExp(r'^\s*[\d.]+\s+([A-Za-z]+)').firstMatch(food.portion);
    final unit = match?.group(1)?.toLowerCase() ?? 'serving';
    return 'Portion size ($unit): ${food.portion}';
  }

  Future<void> _saveImageReviewFood() async {
    final foodDetails = _imageReviewFoodDetails;
    final selectedServing = _imageReviewSelectedServing;
    if (foodDetails == null || selectedServing == null) return;

    final quantity =
        double.tryParse(_imageReviewQuantityController.text.trim()) ?? 1.0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0.')),
      );
      return;
    }

    final nutrients = selectedServing['nutrients'] is Map
        ? Map<String, dynamic>.from(selectedServing['nutrients'])
        : const <String, dynamic>{};
    final name = foodDetails['display_food_name']?.toString() ??
        foodDetails['food_name']?.toString() ??
        'Recognized food';
    final foodId = foodDetails['display_food_id']?.toString() ??
        foodDetails['food_id']?.toString();
    final servingText = selectedServing['display_text']?.toString() ??
        selectedServing['serving_description']?.toString() ??
        'Serving';
    final portionLabel = _loggedPortionLabel(selectedServing, quantity);
    final calories = (_asDouble(nutrients['calories']) * quantity).round();
    final protein = _asDouble(nutrients['protein']) * quantity;
    final carbohydrate = _asDouble(nutrients['carbohydrate']) * quantity;
    final fat = _asDouble(nutrients['fat']) * quantity;
    final sodium = _asDouble(nutrients['sodium']) * quantity;
    final potassium = _asDouble(nutrients['potassium']) * quantity;
    final phosphorus = _asDouble(nutrients['phosphorus']) * quantity;

    final pendingFood = FoodItem(
      foodId: foodId,
      servingId: selectedServing['serving_id']?.toString(),
      emoji: '\u{1F37D}\u{FE0F}',
      name: name,
      portion: portionLabel,
      quantity: quantity,
      calories: calories,
      time: DateFormat('h:mm a').format(DateTime.now()),
      protein: protein,
      carbohydrate: carbohydrate,
      fat: fat,
      sodium: sodium,
      potassium: potassium,
      phosphorus: phosphorus,
      source: 'fatsecret_image',
      raw: foodDetails,
    );
    final logKey = _logKeyFor(
      mealType: _selectedMealType,
      name: pendingFood.name,
      portion: pendingFood.portion,
      date: _selectedDate,
    );

    try {
      if (_savingLogKeys.contains(logKey) || _hasDuplicateLog(pendingFood)) {
        throw Exception('This food is already logged for $_selectedMealType.');
      }
      setState(() {
        _isSavingImageReview = true;
        _savingLogKeys.add(logKey);
      });

      final response = await _addFoodLogWithAllergyConfirmation(
        mealType: _selectedMealType,
        date: _selectedDate,
        foodId: foodId,
        servingId: selectedServing['serving_id']?.toString(),
        quantity: quantity,
        name: name,
        portion: portionLabel,
        calories: calories,
        protein: protein,
        carbohydrate: carbohydrate,
        fat: fat,
        sodium: sodium,
        potassium: potassium,
        phosphorus: phosphorus,
        source: 'fatsecret_image',
        raw: foodDetails,
      );
      if (response['success'] == false) {
        throw Exception(
          response['error'] ?? response['message'] ?? 'Food was not logged.',
        );
      }

      final log = response['log'];
      final savedFood = log is Map
          ? FoodItem.fromLog(Map<String, dynamic>.from(log))
          : pendingFood;
      setState(() {
        _loggedMeals[_selectedMealType]?.add(savedFood);
        _imageReviewFoodDetails = null;
        _imageReviewSelectedServing = null;
        _imageReviewQuantityController.text = '1';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save recognized food: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingImageReview = false;
          _savingLogKeys.remove(logKey);
        });
      }
    }
  }

  Widget _buildImageReviewCard() {
    final foodDetails = _imageReviewFoodDetails!;
    final servings = _servingsFromFoodDetails(foodDetails);
    final selectedServing = _imageReviewSelectedServing ??
        (servings.isNotEmpty ? servings.first : <String, dynamic>{});
    final nutrients = selectedServing['nutrients'] is Map
        ? Map<String, dynamic>.from(selectedServing['nutrients'])
        : const <String, dynamic>{};
    final quantity =
        double.tryParse(_imageReviewQuantityController.text.trim()) ?? 1.0;
    final name = foodDetails['display_food_name']?.toString() ??
        foodDetails['food_name']?.toString() ??
        'Recognized food';
    final servingText = selectedServing['display_text']?.toString() ??
        selectedServing['serving_description']?.toString() ??
        'Serving';
    final portionLabel = _loggedPortionLabel(selectedServing, quantity);
    final calories = (_asDouble(nutrients['calories']) * quantity).round();
    final protein = _asDouble(nutrients['protein']) * quantity;
    final carbohydrate = _asDouble(nutrients['carbohydrate']) * quantity;
    final fat = _asDouble(nutrients['fat']) * quantity;
    final sodium = _asDouble(nutrients['sodium']) * quantity;
    final potassium = _asDouble(nutrients['potassium']) * quantity;
    final phosphorus = _asDouble(nutrients['phosphorus']) * quantity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_search, color: Color(0xFF00BFA5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF37474F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Cancel',
                onPressed: _isSavingImageReview
                    ? null
                    : () {
                        setState(() {
                          _imageReviewFoodDetails = null;
                          _imageReviewSelectedServing = null;
                          _imageReviewQuantityController.text = '1';
                        });
                      },
                icon: const Icon(Icons.close, color: Color(0xFF90A4AE)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Review the recognized food before adding it to the log.',
            style: TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
          ),
          const SizedBox(height: 14),
          const Text(
            'Serving option',
            style: TextStyle(
              color: Color(0xFF90A4AE),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: servings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final serving = servings[index];
                final label = serving['display_text']?.toString() ??
                    serving['serving_description']?.toString() ??
                    'Serving';
                final isSelected = serving['serving_id']?.toString() ==
                    selectedServing['serving_id']?.toString();
                return ListTile(
                  dense: true,
                  title: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? const Color(0xFF00C874)
                        : const Color(0xFFB0BEC5),
                  ),
                  onTap: _isSavingImageReview
                      ? null
                      : () {
                          setState(() {
                            _imageReviewSelectedServing =
                                Map<String, dynamic>.from(serving);
                          });
                        },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildDialogTextField(
            label: _portionFieldLabel(selectedServing),
            controller: _imageReviewQuantityController,
            isNumber: true,
            hint: 'e.g. 1, 0.5, 2',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
            '$portionLabel • $calories kcal',
            style: const TextStyle(
              color: Color(0xFF546E7A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FBF7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0F2E9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nutrients for selected amount',
                  style: TextStyle(
                    color: Color(0xFF37474F),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNutrientLine('Calories', '$calories kcal'),
                _buildNutrientLine('Protein', '${protein.toStringAsFixed(1)} g'),
                _buildNutrientLine(
                  'Carbs',
                  '${carbohydrate.toStringAsFixed(1)} g',
                ),
                _buildNutrientLine('Fat', '${fat.toStringAsFixed(1)} g'),
                _buildNutrientLine('Sodium', '${sodium.round()} mg'),
                _buildNutrientLine(
                  'Potassium',
                  potassium > 0
                      ? '${potassium.round()} mg (estimate)'
                      : 'Not provided',
                ),
                _buildNutrientLine(
                  'Phosphorus',
                  phosphorus > 0
                      ? '${phosphorus.round()} mg (guide)'
                      : 'Not available',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isSavingImageReview
                      ? null
                      : () {
                          setState(() {
                            _imageReviewFoodDetails = null;
                            _imageReviewSelectedServing = null;
                            _imageReviewQuantityController.text = '1';
                          });
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingImageReview ? null : _saveImageReviewFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C874),
                  ),
                  child: _isSavingImageReview
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF546E7A), fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF37474F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogFoodItem(FoodItem food) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showFoodServingDialog(food),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FBF7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(food.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF37474F),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${food.portion} • ${food.calories} kcal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF90A4AE),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle, color: Color(0xFF00C874)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddItem(String emoji, String title) {
    final isLoading = _quickAddLoadingName == title;
    return GestureDetector(
      onTap: () {
        _handleQuickAdd(emoji, title);
      },
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            isLoading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00C874),
                    ),
                  )
                : Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isActive = _selectedMealType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMealType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF7043) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF37474F),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMealItemCard(FoodItem food) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(food.emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF37474F),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _portionDisplayLabel(food),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFF37474F),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${food.calories} kcal',
                              style: const TextStyle(
                                color: Color(0xFF37474F),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        food.time,
                        style: const TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF90A4AE)),
              onSelected: (value) {
                if (value == 'edit') {
                  _editFoodItem(food);
                } else if (value == 'delete') {
                  _confirmDeleteFoodItem(food);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF66BB6A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieTargetChart() {
    final currentCalories = _totalNutrient((food) => food.calories.toDouble()).toInt();
    final targetCalories = (_dailyCalorieTarget ?? 0).toInt();
    final percentageOfTarget =
        targetCalories > 0 ? (currentCalories / targetCalories) : 0.0;
    final cappedPercentage = (percentageOfTarget).clamp(0.0, 1.0);
    final isExceeded = currentCalories > targetCalories;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Calorie Target',
              style: TextStyle(
                color: Color(0xFF546E7A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${((cappedPercentage * 100).toStringAsFixed(0))}%',
              style: TextStyle(
                color: isExceeded ? Colors.orange : const Color(0xFF00C874),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: cappedPercentage,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE8F5E9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isExceeded ? Colors.orange : const Color(0xFF4CAF50),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$currentCalories',
                    style: const TextStyle(
                      color: Color(0xFF37474F),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ $targetCalories kcal',
                    style: const TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Target: profile kcal goal or 30-35 kcal/kg estimate',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTextField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    String hint = "",
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF90A4AE),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
