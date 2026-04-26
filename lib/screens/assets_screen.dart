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
  late TextEditingController _incomeDateController;
  late TextEditingController _bonusController;
  late TextEditingController _bonusDateController;
  List<int> _bonusMonths = [];
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _savingsController = TextEditingController();
    _incomeController = TextEditingController();
    _incomeDateController = TextEditingController();
    _bonusController = TextEditingController();
    _bonusDateController = TextEditingController();
  }

  @override
  void dispose() {
    _savingsController.dispose();
    _incomeController.dispose();
    _incomeDateController.dispose();
    _bonusController.dispose();
    _bonusDateController.dispose();
    super.dispose();
  }

  void _loadData(AssetsData data) {
    if (_savingsController.text.isEmpty) {
      _savingsController.text = data.currentSavings.toString();
      _incomeController.text = data.monthlyIncome.toString();
      _incomeDateController.text = data.incomeDate.toString();
      _bonusController.text = data.bonusAmount.toString();
      _bonusDateController.text = data.bonusDate.toString();
      _bonusMonths = List.from(data.bonusMonths);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final incomeDate = int.tryParse(_incomeDateController.text) ?? 25;
    final bonusDate = int.tryParse(_bonusDateController.text) ?? 5;

    setState(() => _isSaving = true);
    final data = AssetsData(
      currentSavings: int.tryParse(_savingsController.text) ?? 0,
      monthlyIncome: int.tryParse(_incomeController.text) ?? 0,
      incomeDate: incomeDate,
      bonusAmount: int.tryParse(_bonusController.text) ?? 0,
      bonusMonths: _bonusMonths,
      bonusDate: bonusDate,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('貯金情報を入力', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _savingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '現在の貯金額 (円)', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '入力してください';
                      if (int.tryParse(value) == null) return '数値で入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  const Text('基本給の情報を入力', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '月毎の平均収入 (手取り/円)', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '入力してください';
                      if (int.tryParse(value) == null) return '数値で入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _incomeDateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '平均収入が入る日 (1~31)', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '入力してください';
                      final val = int.tryParse(value);
                      if (val == null) return '数値で入力してください';
                      if (val < 1 || val > 31) return '1~31の間で入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text('ボーナスの情報を入力', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: List.generate(12, (index) {
                      final month = index + 1;
                      final isSelected = _bonusMonths.contains(month);
                      return FilterChip(
                        label: Text('$month月'),
                        selected: isSelected,
                        onSelected: (_) {
                          _toggleMonth(month);
                          // ボーナス月が変わったときに日付のバリデーションを再評価するため
                          _formKey.currentState?.validate();
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bonusDateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ボーナスが入る日 (1~31)', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '入力してください';
                      final val = int.tryParse(value);
                      if (val == null) return '数値で入力してください';
                      if (val < 1 || val > 31) return '1~31の間で入力してください';
                      final months = [];
                      for (final month in _bonusMonths) {
                        final testDate = DateTime(2024, month, val);
                        if (testDate.month != month) {
                          months.add('$month月');
                        }
                      }
                      if (months.isNotEmpty) {
                        return '${months.join(',')}には$val日は存在しません';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bonusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ボーナスの金額 (1回あたり/円)', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '入力してください';
                      if (int.tryParse(value) == null) return '数値で入力してください';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving ? const CircularProgressIndicator() : const Text('保存する'),
                )
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}
