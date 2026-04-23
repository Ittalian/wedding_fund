import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_state_provider.dart';
import 'assets_screen.dart';
import 'basic_info_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum _CalcMode { expense, timing }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _CalcMode _mode = _CalcMode.expense;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'ja_JP', symbol: '¥');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // モード切り替えボタン
              SegmentedButton<_CalcMode>(
                segments: const [
                  ButtonSegment(
                    value: _CalcMode.expense,
                    label: Text('出費額計算'),
                    icon: Icon(Icons.calculate),
                  ),
                  ButtonSegment(
                    value: _CalcMode.timing,
                    label: Text('時期計算'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) =>
                    setState(() => _mode = s.first),
              ),
              const SizedBox(height: 16),

              if (_mode == _CalcMode.expense)
                _buildExpenseMode(currencyFormatter)
              else
                _buildTimingMode(currencyFormatter),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AssetsScreen())),
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('財産管理'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const BasicInfoScreen())),
                icon: const Icon(Icons.favorite),
                label: const Text('基本情報管理'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink.shade50,
                  foregroundColor: Colors.pink.shade900,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 出費額計算モード（既存ロジック）
  // ──────────────────────────────────────────
  Widget _buildExpenseMode(NumberFormat fmt) {
    final calcData = ref.watch(financialCalculationProvider);

    if (calcData['isDataReady'] == true &&
        calcData['message'] != null &&
        (calcData['message'] as String).contains('達成')) {
      return Card(
        color: Colors.green.shade50,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            calcData['message'],
            style: const TextStyle(fontSize: 18, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (calcData['isDataReady'] == false || calcData['isDeficit'] == true) {
      return Card(
        color: Colors.red.shade50,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                calcData['message'] ?? '情報を入力してください',
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              if (calcData['isDeficit'] == true && calcData['deficitAmount'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '現在不足額: ${fmt.format(calcData['deficitAmount'])}\n\n'
                    '計画や目標を見直してください。',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '計算結果（出費額計算）',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('目標達成に必要な毎月の出費上限額',
                style: TextStyle(fontSize: 14)),
            Text(
              fmt.format(calcData['monthlyAllowedExpense']),
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            const SizedBox(height: 16),
            Text(
              '全体の目標貯金額: ${fmt.format(calcData['targetSavings'])}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 時期計算モード（各項目を賄える時期を表示）
  // ──────────────────────────────────────────
  Widget _buildTimingMode(NumberFormat fmt) {
    final results = ref.watch(itemAffordabilityCalculationProvider);

    if (results.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 40),
              SizedBox(height: 8),
              Text(
                '財産管理から月の収入を入力し、\n基本情報に費用項目を追加してください',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '各費用項目を賄える時期',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          '優先度順に累積計算 • 当月で賄える判定',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ...results.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final item = result['item'];
          final affordableDate = result['affordableDate'] as String?;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
              ),
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(fmt.format(item.cost)),
              trailing: affordableDate != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('賄える時期',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey)),
                        Text(
                          affordableDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '計算不可',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
            ),
          );
        }),
      ],
    );
  }
}
