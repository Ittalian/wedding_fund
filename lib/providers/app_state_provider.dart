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

      targets.add({'cost': item.cost, 'date': dateToUse});
      
      if (maxTargetDate == null || dateToUse.isAfter(maxTargetDate)) {
        maxTargetDate = dateToUse;
      }
    }
    
    if (basicInfo.savingsGoal > 0) {
      if (!basicInfo.alwaysKeepSavingsGoal) {
        if (maxTargetDate == null) {
          return {
            'isDataReady': false,
            'message': '貯金目標を計算するため、少なくとも1つの費用項目とその目標時期を設定してください'
          };
        }
        targets.add({'cost': basicInfo.savingsGoal, 'date': maxTargetDate});
      }
    }

    targets.sort((a, b) {
      final dtA = a['date'] as DateTime;
      final dtB = b['date'] as DateTime;
      return dtA.compareTo(dtB);
    });

    int minAllowedExpense = -1;
    int cumulativeCost = basicInfo.alwaysKeepSavingsGoal ? basicInfo.savingsGoal : 0;
    bool isImpossible = false;
    String deficitMessage = '';
    int deficitAmount = 0;

    for (int i = 0; i < targets.length; i++) {
      cumulativeCost += targets[i]['cost'] as int;
      final targetDate = targets[i]['date'] as DateTime;

      // 指定日までの収入回数とボーナス回数を計算
      int incomeCount = _calculateIncomeCount(simulationStart, targetDate, assets.incomeDate, isBonus: false);
      int bonusCount = _calculateIncomeCount(simulationStart, targetDate, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
      final expectedTotalBonus = bonusCount * assets.bonusAmount;

      if (incomeCount == 0) {
        if (assets.currentSavings + expectedTotalBonus < cumulativeCost) {
          isImpossible = true;
          deficitAmount = cumulativeCost - (assets.currentSavings + expectedTotalBonus);
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
        final requiredAdditionalFunds = cumulativeCost - assets.currentSavings - expectedTotalBonus;
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

    List<Map<String, dynamic>> reductionSuggestions = [];
    List<Map<String, dynamic>> delaySuggestions = [];

    if (isImpossible || minAllowedExpense < 0) {
      bool isPlanDeficit(BasicInfoData testInfo) {
        List<Map<String, dynamic>> testTargets = [];
        DateTime? testMaxTargetDate;
        
        for (final item in testInfo.expenses) {
          final dateToUse = item.targetDate != null && item.targetDate!.isNotEmpty
              ? _parseTargetMonth(item.targetDate) ?? startDateParsed
              : startDateParsed;
          testTargets.add({'cost': item.cost, 'date': dateToUse});
          if (testMaxTargetDate == null || dateToUse.isAfter(testMaxTargetDate)) {
            testMaxTargetDate = dateToUse;
          }
        }
        if (testInfo.savingsGoal > 0) {
          if (!testInfo.alwaysKeepSavingsGoal) {
            testTargets.add({'cost': testInfo.savingsGoal, 'date': testMaxTargetDate ?? startDateParsed});
          }
        }
        testTargets.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

        int tempCum = testInfo.alwaysKeepSavingsGoal ? testInfo.savingsGoal : 0;
        int tempMin = -1;
        bool tempImp = false;
        for (int i = 0; i < testTargets.length; i++) {
          tempCum += testTargets[i]['cost'] as int;
          final tDate = testTargets[i]['date'] as DateTime;
          int iCount = _calculateIncomeCount(simulationStart, tDate, assets.incomeDate, isBonus: false);
          int bCount = _calculateIncomeCount(simulationStart, tDate, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
          final eBonus = bCount * assets.bonusAmount;

          if (iCount == 0) {
            if (assets.currentSavings + eBonus < tempCum) {
              tempImp = true;
              break;
            } else {
              final allowed = assets.monthlyIncome;
              if (tempMin == -1 || allowed < tempMin) tempMin = allowed;
            }
          } else {
            final reqAdd = tempCum - assets.currentSavings - eBonus;
            int reqMo = reqAdd > 0 ? (reqAdd / iCount).ceil() : 0;
            final allowed = assets.monthlyIncome - reqMo;
            if (tempMin == -1 || allowed < tempMin) tempMin = allowed;
          }
        }
        return tempImp || tempMin < 0;
      }

      for (int i = 0; i < basicInfo.expenses.length; i++) {
        final item = basicInfo.expenses[i];
        if (item.cost <= 0) continue;
        int left = 0;
        int right = item.cost - 1;
        int bestValid = -1;
        while (left <= right) {
          int mid = left + (right - left) ~/ 2;
          final testExpenses = [...basicInfo.expenses];
          testExpenses[i] = item.copyWith(cost: mid);
          if (!isPlanDeficit(basicInfo.copyWith(expenses: testExpenses))) {
            bestValid = mid;
            left = mid + 1;
          } else {
            right = mid - 1;
          }
        }
        if (bestValid != -1) {
          reductionSuggestions.add({'name': item.name, 'suggestedCost': bestValid});
        }
      }
      if (basicInfo.savingsGoal > 0) {
        int left = 0;
        int right = basicInfo.savingsGoal - 1;
        int bestValid = -1;
        while (left <= right) {
          int mid = left + (right - left) ~/ 2;
          if (!isPlanDeficit(basicInfo.copyWith(savingsGoal: mid))) {
            bestValid = mid;
            left = mid + 1;
          } else {
            right = mid - 1;
          }
        }
        if (bestValid != -1) {
          reductionSuggestions.add({'name': '目標貯金', 'suggestedCost': bestValid});
        }
      }

      Map<DateTime, int> cumulativeByDate = {};
      int totalSoFar = basicInfo.alwaysKeepSavingsGoal ? basicInfo.savingsGoal : 0;
      for (final t in targets) {
        totalSoFar += t['cost'] as int;
        cumulativeByDate[t['date'] as DateTime] = totalSoFar;
      }

      int netMonthly = assets.monthlyIncome - basicInfo.monthlyExpense;
      if (netMonthly > 0 || assets.bonusAmount > 0) {
        cumulativeByDate.forEach((targetDate, cumulativeNeeded) {
          DateTime requiredDate = simulationStart;
          bool canAfford = false;
          
          for (int m = 0; m <= 600; m++) {
            final tm = DateTime(simulationStart.year, simulationStart.month + m + 1, 0); // 月末
            int iC = _calculateIncomeCount(simulationStart, tm, assets.incomeDate, isBonus: false);
            int bC = _calculateIncomeCount(simulationStart, tm, assets.bonusDate, isBonus: true, bonusMonths: assets.bonusMonths);
            int projected = assets.currentSavings + (assets.monthlyIncome - basicInfo.monthlyExpense) * iC + bC * assets.bonusAmount;
            if (projected >= cumulativeNeeded) {
              requiredDate = DateTime(tm.year, tm.month, 1);
              canAfford = true;
              break;
            }
          }

          if (canAfford && requiredDate.isAfter(targetDate)) {
            List<String> itemsHere = [];
            for (final item in basicInfo.expenses) {
              final d = item.targetDate != null && item.targetDate!.isNotEmpty
                  ? _parseTargetMonth(item.targetDate) ?? startDateParsed
                  : startDateParsed;
              if (d == targetDate) itemsHere.add(item.name);
            }
            delaySuggestions.add({
              'items': itemsHere,
              'requiredDate': requiredDate,
              'originalDate': targetDate,
            });
          }
        });
      }
    }

    if (isImpossible || minAllowedExpense < 0) {
      return {
        'isDataReady': true,
        'isDeficit': true,
        'message': isImpossible ? deficitMessage : '現在の収入では目標を達成できません。',
        'monthlyAllowedExpense': 0,
        'targetSavings': cumulativeCost,
        'deficitAmount': isImpossible ? deficitAmount : minAllowedExpense.abs(),
        'reductionSuggestions': reductionSuggestions,
        'delaySuggestions': delaySuggestions,
      };
    }

    return {
      'isDataReady': true,
      'isDeficit': false,
      'monthlyAllowedExpense': minAllowedExpense,
      'targetSavings': cumulativeCost,
    };
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

        int requiredProjected = cumulativeCost + (basicInfo.alwaysKeepSavingsGoal ? basicInfo.savingsGoal : 0);
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
