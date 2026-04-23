import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assets_data.dart';
import '../providers/app_state_provider.dart' as atp;

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  late TextEditingController _savingsController;
  late TextEditingController _incomeController;
  late TextEditingController _bonusController;
  List<int> _bonusMonths = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _savingsController = TextEditingController();
    _incomeController = TextEditingController();
    _bonusController = TextEditingController();
  }

  @override
  void dispose() {
    _savingsController.dispose();
    _incomeController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  void _loadData(AssetsData data) {
    if (_savingsController.text.isEmpty) {
      _savingsController.text = data.currentSavings.toString();
      _incomeController.text = data.monthlyIncome.toString();
      _bonusController.text = data.bonusAmount.toString();
      _bonusMonths = List.from(data.bonusMonths);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final data = AssetsData(
      currentSavings: int.tryParse(_savingsController.text) ?? 0,
      monthlyIncome: int.tryParse(_incomeController.text) ?? 0,
      bonusAmount: int.tryParse(_bonusController.text) ?? 0,
      bonusMonths: _bonusMonths,
    );

    await ref.read(atp.assetsDataProvider.notifier).updateAssets(data);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
      Navigator.pop(context);
    }
  }

  void _toggleMonth(int month) {
    setState(() {
      if (_bonusMonths.contains(month)) {
        _bonusMonths.remove(month);
      } else {
        _bonusMonths.add(month);
      }
      _bonusMonths.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsDataAsync = ref.watch(atp.assetsDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('財産管理')),
      body: assetsDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (data) {
          _loadData(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _savingsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '現在の貯金額 (円)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _incomeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '月毎の平均収入 (手取り/円)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bonusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ボーナスの金額 (1回あたり/円)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                const Text('ボーナスの入る時期（月）を選択', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final isSelected = _bonusMonths.contains(month);
                    return FilterChip(
                      label: Text('$month月'),
                      selected: isSelected,
                      onSelected: (_) => _toggleMonth(month),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving ? const CircularProgressIndicator() : const Text('保存する'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
