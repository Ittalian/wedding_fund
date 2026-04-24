import 'package:cloud_firestore/cloud_firestore.dart';
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

/// proposeDate (yyyy/mm) を DateTime に変換（その月の1日）
DateTime? _parseProposeDate(String? proposeDate) {
  if (proposeDate == null || proposeDate.isEmpty) return null;
  final parts = proposeDate.split('/');
  if (parts.length != 2) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null || month < 1 || month > 12) return null;
  return DateTime(year, month, 1);
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

    if (basicInfo.proposeDate == null) {
      return {
        'isDataReady': false,
        'message': '基本情報からプロポーズ予定年月を入力してください'
      };
    }

    if (assets.monthlyIncome == 0) {
      return {'isDataReady': false, 'message': '財産管理から月の収入を入力してください'};
    }

    final proposeDateParsed = _parseProposeDate(basicInfo.proposeDate);
    if (proposeDateParsed == null) {
      return {
        'isDataReady': false,
        'message': 'プロポーズ予定年月の形式が正しくありません (yyyy/mm)'
      };
    }

    final now = DateTime.now();
    
    // 目標地点と必要累積額のリストを作成
    // targetDate が未設定の ExpenseItem と savingsGoal は proposeDate を目標時期とする
    List<Map<String, dynamic>> targets = [];

    // expenses
    for (final item in basicInfo.expenses) {
      final dateToUse = item.targetDate != null && item.targetDate!.isNotEmpty
          ? _parseProposeDate(item.targetDate) ?? proposeDateParsed
          : proposeDateParsed;
      targets.add({'cost': item.cost, 'date': dateToUse});
    }
    // savingsGoal
    if (basicInfo.savingsGoal > 0) {
      targets.add({'cost': basicInfo.savingsGoal, 'date': proposeDateParsed});
    }

    // targetDate 順に並び替え
    targets.sort((a, b) {
      final dtA = a['date'] as DateTime;
      final dtB = b['date'] as DateTime;
      return dtA.compareTo(dtB);
    });

    int minAllowedExpense = -1; // -1 indicates not calculated yet
    int cumulativeCost = 0;
    bool isImpossible = false;
    String deficitMessage = '';
    int deficitAmount = 0;

    for (int i = 0; i < targets.length; i++) {
      cumulativeCost += targets[i]['cost'] as int;
      final targetDate = targets[i]['date'] as DateTime;

      // targetDate までに何ヶ月あるか
      int monthsLeft = (targetDate.year - now.year) * 12 + targetDate.month - now.month;
      if (monthsLeft < 0) monthsLeft = 0;

      // 月数ごとのボーナス回数
      int futureBonusOccurrences = 0;
      for (int m = 1; m <= monthsLeft; m++) {
        final checkMonth = DateTime(now.year, now.month + m, 1);
        if (assets.bonusMonths.contains(checkMonth.month)) {
          futureBonusOccurrences++;
        }
      }

      final expectedTotalBonus = futureBonusOccurrences * assets.bonusAmount;

      if (monthsLeft == 0) {
        // 今月または過去の目標 -> 現在の貯金だけで賄える必要がある
        if (assets.currentSavings < cumulativeCost) {
          isImpossible = true;
          deficitAmount = cumulativeCost - assets.currentSavings;
          deficitMessage = '目標達成に必要な貯金が不足しています。\n(不足額: ¥$deficitAmount)';
          break;
        }
      } else {
        // 月割りでの必要貯金
        // 必要な追加資金 = 累積コスト - 現在の貯金 - ボーナス
        final requiredAdditionalFunds = cumulativeCost - assets.currentSavings - expectedTotalBonus;
        
        int requiredMonthlySaving = 0;
        if (requiredAdditionalFunds > 0) {
          requiredMonthlySaving = (requiredAdditionalFunds / monthsLeft).ceil();
        }
        
        final allowedExpense = assets.monthlyIncome - requiredMonthlySaving;
        
        if (minAllowedExpense == -1 || allowedExpense < minAllowedExpense) {
          minAllowedExpense = allowedExpense;
        }
      }
    }

    // 累積コストが0（目標なし）の場合は月収をそのまま許容出費とする
    if (cumulativeCost == 0) {
      minAllowedExpense = assets.monthlyIncome;
    }

    List<Map<String, dynamic>> reductionSuggestions = [];
    List<Map<String, dynamic>> delaySuggestions = [];

    if (isImpossible || minAllowedExpense < 0) {
      // 内部ヘルパー：特定の BasicInfoData で不足になるかを判定
      bool isPlanDeficit(BasicInfoData testInfo) {
        List<Map<String, dynamic>> testTargets = [];
        for (final item in testInfo.expenses) {
          final dateToUse = item.targetDate != null && item.targetDate!.isNotEmpty
              ? _parseProposeDate(item.targetDate) ?? proposeDateParsed
              : proposeDateParsed;
          testTargets.add({'cost': item.cost, 'date': dateToUse});
        }
        if (testInfo.savingsGoal > 0) {
          testTargets.add({'cost': testInfo.savingsGoal, 'date': proposeDateParsed});
        }
        testTargets.sort((a, b) {
          final dtA = a['date'] as DateTime;
          final dtB = b['date'] as DateTime;
          return dtA.compareTo(dtB);
        });

        int tempCum = 0;
        int tempMin = -1;
        bool tempImp = false;
        for (int i = 0; i < testTargets.length; i++) {
          tempCum += testTargets[i]['cost'] as int;
          final tDate = testTargets[i]['date'] as DateTime;
          int mLeft = (tDate.year - now.year) * 12 + tDate.month - now.month;
          if (mLeft < 0) mLeft = 0;
          int fBonus = 0;
          for (int m = 1; m <= mLeft; m++) {
            final cm = DateTime(now.year, now.month + m, 1);
            if (assets.bonusMonths.contains(cm.month)) fBonus++;
          }
          final eBonus = fBonus * assets.bonusAmount;
          if (mLeft == 0) {
            if (assets.currentSavings < tempCum) {
              tempImp = true;
              break;
            }
          } else {
            final reqAdd = tempCum - assets.currentSavings - eBonus;
            int reqMo = reqAdd > 0 ? (reqAdd / mLeft).ceil() : 0;
            final allowed = assets.monthlyIncome - reqMo;
            if (tempMin == -1 || allowed < tempMin) tempMin = allowed;
          }
        }
        return tempImp || tempMin < 0;
      }

      // 1. 各項目の減額提案を計算
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
            left = mid + 1; // 減額幅をなるべく小さく（costを大きく）したい
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

      // 2. 時期の見直し提案を計算
      Map<DateTime, int> cumulativeByDate = {};
      int totalSoFar = 0;
      for (final t in targets) {
        totalSoFar += t['cost'] as int;
        cumulativeByDate[t['date'] as DateTime] = totalSoFar;
      }

      int netMonthly = assets.monthlyIncome - basicInfo.monthlyExpense;
      if (netMonthly > 0 || assets.bonusAmount > 0) {
        cumulativeByDate.forEach((targetDate, cumulativeNeeded) {
          DateTime requiredDate = now;
          bool canAfford = false;
          for (int m = 0; m <= 600; m++) {
            int bonusCount = 0;
            for (int i = 1; i <= m; i++) {
              final checkMonth = DateTime(now.year, now.month + i, 1);
              if (assets.bonusMonths.contains(checkMonth.month)) bonusCount++;
            }
            int projected = assets.currentSavings + netMonthly * m + bonusCount * assets.bonusAmount;
            if (projected >= cumulativeNeeded) {
              requiredDate = DateTime(now.year, now.month + m, 1);
              canAfford = true;
              break;
            }
          }

          if (canAfford && requiredDate.isAfter(targetDate)) {
            List<String> itemsHere = [];
            for (final item in basicInfo.expenses) {
              final d = item.targetDate != null && item.targetDate!.isNotEmpty
                  ? _parseProposeDate(item.targetDate) ?? proposeDateParsed
                  : proposeDateParsed;
              if (d == targetDate) itemsHere.add(item.name);
            }
            // if (targetDate == proposeDateParsed && basicInfo.savingsGoal > 0) {
            //   itemsHere.add('目標貯金');
            // }
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

    final now = DateTime.now();
    final netMonthly = assets.monthlyIncome - basicInfo.monthlyExpense;

    int cumulativeCost = 0;
    const maxMonths = 600;
    final results = <Map<String, dynamic>>[];

    final proposeDateParsed = _parseProposeDate(basicInfo.proposeDate);

    for (final item in sortedItems) {
      cumulativeCost += item.cost;

      String? affordableDateStr;
      DateTime? affordableMonth;

      for (int m = 0; m <= maxMonths; m++) {
        // m ヶ月後までのボーナス回数を計算
        int bonusCount = 0;
        for (int i = 1; i <= m; i++) {
          final checkMonth = DateTime(now.year, now.month + i, 1);
          if (assets.bonusMonths.contains(checkMonth.month)) {
            bonusCount++;
          }
        }

        final projected = assets.currentSavings +
            netMonthly * m +
            bonusCount * assets.bonusAmount;

        if (projected >= cumulativeCost) {
          // 収入が入った当月（mヶ月後）に賄える判定とする
          affordableMonth = DateTime(now.year, now.month + m, 1);
          break;
        }
      }

      if (affordableMonth != null) {
        // プロポーズ予定月より前ならプロポーズ予定月に合わせる
        if (proposeDateParsed != null && affordableMonth.isBefore(proposeDateParsed)) {
          affordableMonth = proposeDateParsed;
        }
        affordableDateStr = '${affordableMonth.year}/${affordableMonth.month.toString().padLeft(2, '0')}';
      }

      results.add({
        'item': item,
        'affordableDate': affordableDateStr,
      });
    }

    return results;
  }
}
