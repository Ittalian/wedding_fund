import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assets_data.dart';
import '../models/basic_info_data.dart';

part 'app_state_provider.g.dart';

@riverpod
class AssetsDataNotifier extends _$AssetsDataNotifier {
  @override
  Stream<AssetsData> build() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('my_user_data')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('assetsData')) {
        return AssetsData.fromJson(snapshot.data()!['assetsData']);
      }
      return const AssetsData();
    });
  }

  Future<void> updateAssets(AssetsData data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('my_user_data')
        .set({'assetsData': data.toJson()}, SetOptions(merge: true));
  }
}

@riverpod
class BasicInfoDataNotifier extends _$BasicInfoDataNotifier {
  @override
  Stream<BasicInfoData> build() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('my_user_data')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('basicInfoData')) {
        final json = Map<String, dynamic>.from(
            snapshot.data()!['basicInfoData'] as Map);
        return BasicInfoData.fromJson(json);
      }
      return const BasicInfoData();
    });
  }

  Future<void> updateBasicInfo(BasicInfoData data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('my_user_data')
        .set({'basicInfoData': data.toJson()}, SetOptions(merge: true));
  }
}

/// forecastStartDate (yyyy/mm/dd) を DateTime に変換
DateTime? _parseStartDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  final parts = dateStr.split('/');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null || month < 1 || month > 12) return null;
  return DateTime(year, month, day);
}

/// targetDate (yyyy/mm) を DateTime に変換（目標時期用なのでその月の収入を含めるために月末日）
DateTime? _parseTargetMonth(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  final parts = dateStr.split('/');
  if (parts.length != 2) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null || month < 1 || month > 12) return null;
  return DateTime(year, month + 1, 0);
}

/// 期間内の収入回数を計算するヘルパー。
/// 現実の「今月」以前の収入はすでに現在の貯金に含まれているとみなし、カウントしない。
int _calculateIncomeCount(DateTime startDate, DateTime targetDate, int incomeDate, {required bool isBonus, List<int>? bonusMonths}) {
  final now = DateTime.now();
  int count = 0;
  
  DateTime current = DateTime(startDate.year, startDate.month, 1);
  final end = DateTime(targetDate.year, targetDate.month, 1);

  while (!current.isAfter(end)) {
    int year = current.year;
    int month = current.month;
    int day = incomeDate;
    
    DateTime eventDate = DateTime(year, month, day);
    if (eventDate.month != month) {
      eventDate = DateTime(year, month + 1, 0); 
    }

    if (isBonus && bonusMonths != null && !bonusMonths.contains(month)) {
      // ボーナス月でないならスキップ
    } else {
      if (!eventDate.isBefore(startDate) && !eventDate.isAfter(targetDate)) {
        bool alreadyInSavings = false;
        if (year == now.year && month == now.month) {
          if (now.day >= incomeDate) {
             alreadyInSavings = true;
          }
        } else if (eventDate.isBefore(now)) {
          alreadyInSavings = true;
        }

        if (!alreadyInSavings) {
          count++;
        }
      }
    }
    current = DateTime(year, month + 1, 1);
  }
  
  return count;
}

/// DateTime を Firestore 保存用文字列に変換
String _dateToStr(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Firestore 文字列を DateTime に変換
DateTime _strToDate(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// 提案の Map を Firestore 保存可能な形式にシリアライズ（DateTime→String）
Map<String, dynamic> _serializeSuggestions(Map<String, dynamic> s) {
  return {
    'reductionSuggestions': s['reductionSuggestions'] ?? [],
    'savingByPaymentReductionSuggestions': s['savingByPaymentReductionSuggestions'] ?? [],
    'increaseSuggestions': s['increaseSuggestions'] ?? [],
    'savingByPaymentIncreaseSuggestions': s['savingByPaymentIncreaseSuggestions'] ?? [],
    'delaySuggestions': ((s['delaySuggestions'] ?? []) as List).map((d) => {
          'items': d['items'],
          'requiredDate': _dateToStr(d['requiredDate'] as DateTime),
          'originalDate': _dateToStr(d['originalDate'] as DateTime),
        }).toList(),
    'advanceSuggestions': ((s['advanceSuggestions'] ?? []) as List).map((d) => {
          'name': d['name'],
          'originalDate': _dateToStr(d['originalDate'] as DateTime),
          'earliestDate': _dateToStr(d['earliestDate'] as DateTime),
        }).toList(),
  };
}

/// Firestore から読み込んだキャッシュを DateTime 付きの Map に変換
Map<String, dynamic> _deserializeSuggestions(Map raw) {
  List<Map<String, dynamic>> toList(dynamic src) =>
      src == null ? [] : (src as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  return {
    'reductionSuggestions': toList(raw['reductionSuggestions']),
    'savingByPaymentReductionSuggestions': toList(raw['savingByPaymentReductionSuggestions']),
    'increaseSuggestions': toList(raw['increaseSuggestions']),
    'savingByPaymentIncreaseSuggestions': toList(raw['savingByPaymentIncreaseSuggestions']),
    'delaySuggestions': toList(raw['delaySuggestions']).map((d) => {
          'items': List<String>.from(d['items'] as List),
          'requiredDate': _strToDate(d['requiredDate'] as String),
          'originalDate': _strToDate(d['originalDate'] as String),
        }).toList(),
    'advanceSuggestions': toList(raw['advanceSuggestions']).map((d) => {
          'name': d['name'] as String,
          'originalDate': _strToDate(d['originalDate'] as String),
          'earliestDate': _strToDate(d['earliestDate'] as String),
        }).toList(),
  };
}

/// 提案を計算する（二分探索を含む重い処理）。保存時に呼び出してFirestoreにキャッシュする。
Map<String, dynamic> computeSuggestions(AssetsData assets, BasicInfoData basicInfo) {
  final startDateParsed = _parseStartDate(basicInfo.forecastStartDate);
  if (startDateParsed == null) return {};
  final simulationStart = startDateParsed;

  // targets を組み立て
  List<Map<String, dynamic>> targets = [];
  DateTime? maxTargetDate;

  for (final item in basicInfo.expenses) {
    if (item.targetDate == null || item.targetDate!.isEmpty) return {};
    final d = _parseTargetMonth(item.targetDate);
    if (d == null) return {};
    final minBal = item.savingByPayment;
    targets.add({'cost': item.cost, 'date': d, 'minBalance': minBal});
    if (maxTargetDate == null || d.isAfter(maxTargetDate)) maxTargetDate = d;
  }
  targets.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

  int minAllowedExpense = -1;
  int cumulativeCost = 0;
  bool isImpossible = false;
  for (int i = 0; i < targets.length; i++) {
    cumulativeCost += targets[i]['cost'] as int;
    final minBalance = targets[i]['minBalance'] as int? ?? 0;
    final requiredTotal = cumulativeCost + minBalance;
    final tDate = targets[i]['date'] as DateTime;
    int iC = _calculateIncomeCount(simulationStart, tDate, assets.incomeDate, isBonus: false);
    int bC = _calculateIncomeCount(simulationStart, tDate, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
    final eBonus = bC * assets.bonusAmount;
    if (iC == 0) {
      if (assets.currentSavings + eBonus < requiredTotal) { isImpossible = true; break; }
      final a = assets.monthlyIncome;
      if (minAllowedExpense == -1 || a < minAllowedExpense) minAllowedExpense = a;
    } else {
      final reqAdd = requiredTotal - assets.currentSavings - eBonus;
      final reqMo = reqAdd > 0 ? (reqAdd / iC).ceil() : 0;
      final a = assets.monthlyIncome - reqMo;
      if (minAllowedExpense == -1 || a < minAllowedExpense) minAllowedExpense = a;
    }
  }
  if (cumulativeCost == 0) minAllowedExpense = assets.monthlyIncome;

  // isPlanDeficit ヘルパー
  bool isPlanDeficit(BasicInfoData testInfo) {
    List<Map<String, dynamic>> tt = [];
    DateTime? tmx;
    for (final item in testInfo.expenses) {
      final d = item.targetDate != null && item.targetDate!.isNotEmpty
          ? _parseTargetMonth(item.targetDate) ?? startDateParsed
          : startDateParsed;
      final minBal = item.savingByPayment;
      tt.add({'cost': item.cost, 'date': d, 'minBalance': minBal});
      if (tmx == null || d.isAfter(tmx)) tmx = d;
    }
    tt.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    int cum = 0;
    int mn = -1;
    bool imp = false;
    for (final t in tt) {
      cum += t['cost'] as int;
      final minBal = t['minBalance'] as int? ?? 0;
      final requiredTotal = cum + minBal;
      final tDate = t['date'] as DateTime;
      int iC = _calculateIncomeCount(simulationStart, tDate, assets.incomeDate, isBonus: false);
      int bC = _calculateIncomeCount(simulationStart, tDate, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
      final eB = bC * assets.bonusAmount;
      if (iC == 0) {
        if (assets.currentSavings + eB < requiredTotal) { imp = true; break; }
        final al = assets.monthlyIncome;
        if (mn == -1 || al < mn) mn = al;
      } else {
        final rA = requiredTotal - assets.currentSavings - eB;
        final rM = rA > 0 ? (rA / iC).ceil() : 0;
        final al = assets.monthlyIncome - rM;
        if (mn == -1 || al < mn) mn = al;
      }
    }
    return imp || mn <= 0;
  }

  List<Map<String, dynamic>> reductionSuggestions = [];
  List<Map<String, dynamic>> savingByPaymentReductionSuggestions = [];
  List<Map<String, dynamic>> delaySuggestions = [];
  List<Map<String, dynamic>> advanceSuggestions = [];
  List<Map<String, dynamic>> increaseSuggestions = [];
  List<Map<String, dynamic>> savingByPaymentIncreaseSuggestions = [];

  if (isImpossible || minAllowedExpense <= 0) {
    // 費用の減額提案
    for (int i = 0; i < basicInfo.expenses.length; i++) {
      final item = basicInfo.expenses[i];
      if (item.cost <= 0) continue;
      int left = 0, right = item.cost - 1, best = -1;
      while (left <= right) {
        final mid = left + (right - left) ~/ 2;
        final te = [...basicInfo.expenses]; te[i] = item.copyWith(cost: mid);
        if (!isPlanDeficit(basicInfo.copyWith(expenses: te))) { best = mid; left = mid + 1; } else { right = mid - 1; }
      }
      if (best != -1) reductionSuggestions.add({'name': item.name, 'suggestedCost': best});
    }
    // savingByPaymentの減額提案
    for (int i = 0; i < basicInfo.expenses.length; i++) {
      final item = basicInfo.expenses[i];
      if (item.savingByPayment <= 0) continue;
      int left = 0, right = item.savingByPayment - 1, best = -1;
      while (left <= right) {
        final mid = left + (right - left) ~/ 2;
        final te = [...basicInfo.expenses]; te[i] = item.copyWith(savingByPayment: mid);
        if (!isPlanDeficit(basicInfo.copyWith(expenses: te))) { best = mid; left = mid + 1; } else { right = mid - 1; }
      }
      if (best != -1) savingByPaymentReductionSuggestions.add({'name': item.name, 'currentAmount': item.savingByPayment, 'suggestedAmount': best});
    }
    // 時期延長提案
    Map<DateTime, int> cumByDate = {};
    int tot = 0;
    for (final t in targets) {
      tot += t['cost'] as int;
      final minBal = t['minBalance'] as int? ?? 0;
      cumByDate[t['date'] as DateTime] = tot + minBal;
    }
    if (assets.monthlyIncome > 0 || assets.bonusAmount > 0) {
      cumByDate.forEach((tDate, needed) {
        DateTime req = simulationStart; bool ok = false;
        for (int m = 0; m <= 600; m++) {
          final tm = DateTime(simulationStart.year, simulationStart.month + m + 1, 0);
          final iC = _calculateIncomeCount(simulationStart, tm, assets.incomeDate, isBonus: false);
          final bC = _calculateIncomeCount(simulationStart, tm, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
          final proj = assets.currentSavings + assets.monthlyIncome * iC + bC * assets.bonusAmount;
          if (proj >= needed) { req = DateTime(tm.year, tm.month, 1); ok = true; break; }
        }
        if (ok && req.isAfter(tDate)) {
          final items = basicInfo.expenses.where((it) {
            final d = it.targetDate != null && it.targetDate!.isNotEmpty
                ? _parseTargetMonth(it.targetDate) ?? startDateParsed : startDateParsed;
            return d == tDate;
          }).map((it) => it.name).toList();
          delaySuggestions.add({'items': items, 'requiredDate': req, 'originalDate': tDate});
        }
      });
    }
  } else {
    // 前倒し提案
    for (int i = 0; i < basicInfo.expenses.length; i++) {
      final item = basicInfo.expenses[i];
      if (item.targetDate == null || item.targetDate!.isEmpty) continue;
      final origDate = _parseTargetMonth(item.targetDate); if (origDate == null) continue;
      final maxAdv = (origDate.year * 12 + origDate.month) - (simulationStart.year * 12 + simulationStart.month);
      if (maxAdv <= 0) continue;
      int left = 1, right = maxAdv, bestAdv = 0;
      while (left <= right) {
        final mid = left + (right - left) ~/ 2;
        final oIdx = origDate.year * 12 + (origDate.month - 1);
        final nIdx = oIdx - mid;
        final ds = '${nIdx ~/ 12}/${(nIdx % 12 + 1).toString().padLeft(2, '0')}';
        final te = [...basicInfo.expenses]; te[i] = item.copyWith(targetDate: ds);
        if (!isPlanDeficit(basicInfo.copyWith(expenses: te))) { bestAdv = mid; left = mid + 1; } else { right = mid - 1; }
      }
      if (bestAdv > 0) {
        final oIdx = origDate.year * 12 + (origDate.month - 1);
        final nIdx = oIdx - bestAdv;
        advanceSuggestions.add({'name': item.name, 'originalDate': origDate, 'earliestDate': DateTime(nIdx ~/ 12, nIdx % 12 + 1)});
      }
    }
    // 費用の増額提案
    const int maxSearch = 1000000000;
    for (int i = 0; i < basicInfo.expenses.length; i++) {
      final item = basicInfo.expenses[i];
      int left = item.cost + 1, right = maxSearch, best = item.cost;
      while (left <= right) {
        final mid = left + (right - left) ~/ 2;
        final te = [...basicInfo.expenses]; te[i] = item.copyWith(cost: mid);
        if (!isPlanDeficit(basicInfo.copyWith(expenses: te))) { best = mid; left = mid + 1; } else { right = mid - 1; }
      }
      if (best > item.cost) increaseSuggestions.add({'name': item.name, 'currentCost': item.cost, 'maxCost': best});
    }
    // savingByPaymentの増額提案
    for (int i = 0; i < basicInfo.expenses.length; i++) {
      final item = basicInfo.expenses[i];
      int left = item.savingByPayment + 1, right = maxSearch, best = item.savingByPayment;
      while (left <= right) {
        final mid = left + (right - left) ~/ 2;
        final te = [...basicInfo.expenses]; te[i] = item.copyWith(savingByPayment: mid);
        if (!isPlanDeficit(basicInfo.copyWith(expenses: te))) { best = mid; left = mid + 1; } else { right = mid - 1; }
      }
      if (best > item.savingByPayment) savingByPaymentIncreaseSuggestions.add({'name': item.name, 'currentAmount': item.savingByPayment, 'maxAmount': best});
    }
  }

  return {
    'reductionSuggestions': reductionSuggestions,
    'savingByPaymentReductionSuggestions': savingByPaymentReductionSuggestions,
    'delaySuggestions': delaySuggestions,
    'advanceSuggestions': advanceSuggestions,
    'increaseSuggestions': increaseSuggestions,
    'savingByPaymentIncreaseSuggestions': savingByPaymentIncreaseSuggestions,
  };
}


/// 出費額計算：各 ExpenseItem の targetDate に基づき、最大の毎月の固定出費許容額を逆算
@riverpod
class FinancialCalculation extends _$FinancialCalculation {
  @override
  Map<String, dynamic> build() {
    final assetsDataOption = ref.watch(assetsDataProvider).value;
    final basicInfoDataOption = ref.watch(basicInfoDataProvider).value;

    if (assetsDataOption == null || basicInfoDataOption == null) {
      return {'isDataReady': false, 'message': 'データを読み込み中...'};
    }

    final assets = assetsDataOption;
    final basicInfo = basicInfoDataOption;

    if (basicInfo.forecastStartDate == null) {
      return {
        'isDataReady': false,
        'message': '基本情報から予測開始日を入力してください'
      };
    }

    if (assets.monthlyIncome == 0) {
      return {'isDataReady': false, 'message': '財産管理から月の収入を入力してください'};
    }

    final startDateParsed = _parseStartDate(basicInfo.forecastStartDate);
    if (startDateParsed == null) {
      return {
        'isDataReady': false,
        'message': '予測開始日の形式が正しくありません (yyyy/mm/dd)'
      };
    }

    final simulationStart = startDateParsed;
    
    DateTime? maxTargetDate;
    List<Map<String, dynamic>> targets = [];

    for (final item in basicInfo.expenses) {
      if (item.targetDate == null || item.targetDate!.isEmpty) {
        return {
          'isDataReady': false,
          'message': '出費額計算を行うには、すべての費用項目に目標時期を設定してください'
        };
      }
      
      final dateToUse = _parseTargetMonth(item.targetDate);
      if (dateToUse == null) {
        return {
          'isDataReady': false,
          'message': '${item.name} の目標時期の形式が正しくありません'
        };
      }
      
      if (dateToUse.isBefore(simulationStart)) {
        return {
          'isDataReady': false,
          'message': '${item.name} の目標時期は予測開始日以降に設定してください'
        };
      }

      targets.add({'cost': item.cost, 'date': dateToUse, 'minBalance': item.savingByPayment});
      
      if (maxTargetDate == null || dateToUse.isAfter(maxTargetDate)) {
        maxTargetDate = dateToUse;
      }
    }

    targets.sort((a, b) {
      final dtA = a['date'] as DateTime;
      final dtB = b['date'] as DateTime;
      return dtA.compareTo(dtB);
    });

    int minAllowedExpense = -1;
    int cumulativeCost = 0;
    bool isImpossible = false;
    String deficitMessage = '';
    int deficitAmount = 0;

    for (int i = 0; i < targets.length; i++) {
      cumulativeCost += targets[i]['cost'] as int;
      final minBalance = targets[i]['minBalance'] as int? ?? 0;
      final requiredTotal = cumulativeCost + minBalance;
      final targetDate = targets[i]['date'] as DateTime;

      // 指定日までの収入回数とボーナス回数を計算
      int incomeCount = _calculateIncomeCount(simulationStart, targetDate, assets.incomeDate, isBonus: false);
      int bonusCount = _calculateIncomeCount(simulationStart, targetDate, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
      final expectedTotalBonus = bonusCount * assets.bonusAmount;

      if (incomeCount == 0) {
        if (assets.currentSavings + expectedTotalBonus < requiredTotal) {
          isImpossible = true;
          deficitAmount = requiredTotal - (assets.currentSavings + expectedTotalBonus);
          final formatter = NumberFormat("#,###");
          final formattedDeficitAmount = formatter.format(deficitAmount);
          deficitMessage = '目標達成に必要な貯金が不足しています。\n(不足額: ¥$formattedDeficitAmount)';
          break;
        } else {
          final allowedExpense = assets.monthlyIncome;
          if (minAllowedExpense == -1 || allowedExpense < minAllowedExpense) {
            minAllowedExpense = allowedExpense;
          }
        }
      } else {
        final requiredAdditionalFunds = requiredTotal - assets.currentSavings - expectedTotalBonus;
        int requiredPerIncome = 0;
        if (requiredAdditionalFunds > 0) {
          requiredPerIncome = (requiredAdditionalFunds / incomeCount).ceil();
        }
        final allowedExpense = assets.monthlyIncome - requiredPerIncome;
        if (minAllowedExpense == -1 || allowedExpense < minAllowedExpense) {
          minAllowedExpense = allowedExpense;
        }
      }
    }

    if (cumulativeCost == 0) {
      minAllowedExpense = assets.monthlyIncome;
    }

    // キャッシュから提案を取得（二分探索は保存時のみ実行）
    final cache = ref.watch(calculationCacheProvider).value;
    final reductionSuggestions = (cache?['reductionSuggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final savingByPaymentReductionSuggestions = (cache?['savingByPaymentReductionSuggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final delaySuggestions = (cache?['delaySuggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final advanceSuggestions = (cache?['advanceSuggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final increaseSuggestions = (cache?['increaseSuggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final savingByPaymentIncreaseSuggestions = (cache?['savingByPaymentIncreaseSuggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (isImpossible || minAllowedExpense <= 0) {
      return {
        'isDataReady': true,
        'isDeficit': true,
        'message': isImpossible ? deficitMessage : '現在の収入では目標を達成できません。',
        'monthlyAllowedExpense': 0,
        'targetSavings': cumulativeCost,
        'deficitAmount': isImpossible ? deficitAmount : minAllowedExpense.abs(),
        'reductionSuggestions': reductionSuggestions,
        'savingByPaymentReductionSuggestions': savingByPaymentReductionSuggestions,
        'delaySuggestions': delaySuggestions,
      };
    }

    return {
      'isDataReady': true,
      'isDeficit': false,
      'monthlyAllowedExpense': minAllowedExpense,
      'targetSavings': cumulativeCost,
      'advanceSuggestions': advanceSuggestions,
      'increaseSuggestions': increaseSuggestions,
      'savingByPaymentIncreaseSuggestions': savingByPaymentIncreaseSuggestions,
    };
  }
}

/// 提案計算結果をFirestoreにキャッシュし、ストリームで提供する
@riverpod
class CalculationCacheNotifier extends _$CalculationCacheNotifier {
  @override
  Stream<Map<String, dynamic>?> build() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc('my_user_data')
        .snapshots()
        .map((snapshot) {
      final raw = snapshot.data()?['calculationCache'];
      if (raw == null) return null;
      return _deserializeSuggestions(Map<String, dynamic>.from(raw as Map));
    });
  }

  /// assetsData または basicInfoData が保存されたときに呼び出す
  Future<void> recompute(AssetsData assets, BasicInfoData basicInfo) async {
    final result = computeSuggestions(assets, basicInfo);
    final serialized = _serializeSuggestions(result);
    await FirebaseFirestore.instance
        .collection('users')
        .doc('my_user_data')
        .set({'calculationCache': serialized}, SetOptions(merge: true));
  }
}

/// 時期計算：各 ExpenseItem を賄える時期を計算（order 順、累積）
@riverpod
class ItemAffordabilityCalculation extends _$ItemAffordabilityCalculation {
  @override
  List<Map<String, dynamic>> build() {
    final assetsDataOption = ref.watch(assetsDataProvider).value;
    final basicInfoDataOption = ref.watch(basicInfoDataProvider).value;

    if (assetsDataOption == null || basicInfoDataOption == null) return [];

    final assets = assetsDataOption;
    final basicInfo = basicInfoDataOption;

    if (assets.monthlyIncome == 0) return [];

    final sortedItems = [...basicInfo.expenses]
      ..sort((a, b) => a.order.compareTo(b.order));

    int cumulativeCost = 0;
    final results = <Map<String, dynamic>>[];

    final startDateParsed = _parseStartDate(basicInfo.forecastStartDate) ?? DateTime.now();
    final simulationStart = startDateParsed;

    for (final item in sortedItems) {
      cumulativeCost += item.cost;

      // この費用支払い後に必要な最低残高
      final minBalance = item.savingByPayment;

      String? affordableDateStr;
      DateTime? affordableDate;
      int? remainingBalance;

      for (int m = 0; m <= 600; m++) {
        final targetMonth = DateTime(simulationStart.year, simulationStart.month + m + 1, 0); // 月末
        
        int incomeCount = _calculateIncomeCount(simulationStart, targetMonth, assets.incomeDate, isBonus: false);
        int bonusCount = _calculateIncomeCount(simulationStart, targetMonth, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);

        int projected = assets.currentSavings +
            ((assets.monthlyIncome - basicInfo.monthlyExpense) * incomeCount) +
            (assets.bonusAmount * bonusCount);

        int requiredProjected = cumulativeCost + minBalance;
        if (projected >= requiredProjected) {
          affordableDate = DateTime(targetMonth.year, targetMonth.month, 1);
          remainingBalance = projected - cumulativeCost;
          break;
        }
      }

      if (affordableDate != null) {
        if (affordableDate.isBefore(DateTime(simulationStart.year, simulationStart.month, 1))) {
          affordableDate = DateTime(simulationStart.year, simulationStart.month, 1);
        }
        affordableDateStr = '${affordableDate.year}/${affordableDate.month.toString().padLeft(2, '0')}';
      }

      results.add({
        'item': item,
        'affordableDate': affordableDateStr,
        'remainingBalance': remainingBalance,
      });
    }

    return results;
  }
}
