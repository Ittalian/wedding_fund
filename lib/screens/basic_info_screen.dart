import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/basic_info_data.dart';
import '../models/expense_item.dart';
import '../providers/app_state_provider.dart' as atp;

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

enum _InfoMode { expense, timing }

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _forecastStartDateController;
  late TextEditingController _monthlyExpenseController;
  late TextEditingController _savingsGoalController;
  List<ExpenseItem> _expenses = [];
  _InfoMode _mode = _InfoMode.expense;

  bool _isSaving = false;
  bool _isInitialized = false;
  bool _alwaysKeepSavingsGoal = false;

  static const List<Map<String, String>> _defaultItems = [
    {'id': 'engagement_ring', 'name': '婚約指輪'},
    {'id': 'wedding_ring', 'name': '結婚指輪'},
    {'id': 'wedding_ceremony', 'name': '結婚式'},
    {'id': 'honeymoon', 'name': '新婚旅行'},
    {'id': 'moving_cost', 'name': '新居の契約金'},
  ];

  @override
  void initState() {
    super.initState();
    _forecastStartDateController = TextEditingController();
    _monthlyExpenseController = TextEditingController();
    _savingsGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _forecastStartDateController.dispose();
    _monthlyExpenseController.dispose();
    _savingsGoalController.dispose();
    super.dispose();
  }

  void _loadData(BasicInfoData data) {
    if (!_isInitialized) {
      _forecastStartDateController.text = data.forecastStartDate ?? '';
      _monthlyExpenseController.text = data.monthlyExpense.toString();
      _savingsGoalController.text = data.savingsGoal.toString();
      _alwaysKeepSavingsGoal = data.alwaysKeepSavingsGoal;

      // expenses が空の場合はデフォルト5項目を追加
      if (data.expenses.isEmpty) {
        _expenses = _defaultItems.asMap().entries.map((e) {
          return ExpenseItem(
            id: e.value['id']!,
            name: e.value['name']!,
            cost: 0,
            order: e.key,
          );
        }).toList();
      } else {
        _expenses = List.from(data.expenses)
          ..sort((a, b) => a.order.compareTo(b.order));
      }

      _isInitialized = true;
    }
  }

  bool _isValidStartDate(String value) {
    if (value.isEmpty) return true;
    final regex = RegExp(r'^\d{4}/\d{2}/\d{2}$');
    if (!regex.hasMatch(value)) return false;
    final parts = value.split('/');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return false;
    if (month < 1 || month > 12) return false;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }

  bool _isValidTargetMonth(String value) {
    if (value.isEmpty) return true;
    final regex = RegExp(r'^\d{4}/\d{2}$');
    if (!regex.hasMatch(value)) return false;
    final parts = value.split('/');
    final month = int.tryParse(parts[1]);
    return month != null && month >= 1 && month <= 12;
  }

  DateTime? _parseStartDate(String? date) {
    if (date == null || date.isEmpty) return null;
    final parts = date.split('/');
    if (parts.length != 2) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null || month < 1 || month > 12) return null;
    return DateTime(year, month, 1);
  }

  List<ExpenseItem> _getSortedForExpense() {
    final list = List<ExpenseItem>.from(_expenses);
    final defaultDate = _parseStartDate(_forecastStartDateController.text);
    list.sort((a, b) {
      final dtA = (a.targetDate != null && a.targetDate!.isNotEmpty)
          ? (_parseStartDate(a.targetDate) ?? defaultDate)
          : defaultDate;
      final dtB = (b.targetDate != null && b.targetDate!.isNotEmpty)
          ? (_parseStartDate(b.targetDate) ?? defaultDate)
          : defaultDate;

      if (dtA == null && dtB == null) return a.order.compareTo(b.order);
      if (dtA == null) return 1;
      if (dtB == null) return -1;

      final cmp = dtA.compareTo(dtB);
      if (cmp != 0) return cmp;
      return a.order.compareTo(b.order);
    });
    return list;
  }

  void _addExpenseItem() {
    final nameCtl = TextEditingController();
    final costCtl = TextEditingController();
    final targetDateCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('費用項目を追加'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: '項目名 (例: 冷蔵庫)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '必須項目です';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: costCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '金額 (円)'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return '数値で入力してください';
                    }
                    return null;
                  },
                ),
                if (_mode == _InfoMode.expense) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: targetDateCtl,
                    decoration: const InputDecoration(labelText: '目標時期 (yyyy/mm)'),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !_isValidTargetMonth(value)) {
                        return 'yyyy/mm形式で入力してください';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                
                final dateTxt = targetDateCtl.text.trim();
                final newTargetDate = _mode == _InfoMode.expense ? (dateTxt.isEmpty ? null : dateTxt) : null;

                final cost = int.tryParse(costCtl.text) ?? 0;
                setState(() {
                  _expenses.add(ExpenseItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtl.text.trim(),
                    cost: cost,
                    order: _expenses.length,
                    targetDate: newTargetDate,
                  ));
                });
                Navigator.pop(context);
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  void _editExpenseItem(ExpenseItem item) {
    final nameCtl = TextEditingController(text: item.name);
    final costCtl = TextEditingController(text: item.cost.toString());
    final targetDateCtl = TextEditingController(text: item.targetDate ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('費用項目を編集'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: '項目名'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '必須項目です';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: costCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '金額 (円)'),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return '数値で入力してください';
                    }
                    return null;
                  },
                ),
                if (_mode == _InfoMode.expense) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: targetDateCtl,
                    decoration: const InputDecoration(labelText: '目標時期 (yyyy/mm)'),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !_isValidTargetMonth(value)) {
                        return 'yyyy/mm形式で入力してください';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final dateTxt = targetDateCtl.text.trim();
                final newTargetDate = _mode == _InfoMode.expense ? (dateTxt.isEmpty ? null : dateTxt) : item.targetDate;

                final cost = int.tryParse(costCtl.text) ?? 0;
                final index = _expenses.indexWhere((e) => e.id == item.id);
                if (index != -1) {
                  setState(() {
                    _expenses[index] = item.copyWith(
                      name: nameCtl.text.trim(),
                      cost: cost,
                      targetDate: newTargetDate,
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _expenses.removeAt(oldIndex);
      _expenses.insert(newIndex, item);
      // order を振り直す
      for (int i = 0; i < _expenses.length; i++) {
        _expenses[i] = _expenses[i].copyWith(order: i);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    _showSavingDialog();

    final startDate = _forecastStartDateController.text.trim();
    final data = BasicInfoData(
      forecastStartDate: startDate.isEmpty ? null : startDate,
      monthlyExpense: int.tryParse(_monthlyExpenseController.text) ?? 0,
      savingsGoal: int.tryParse(_savingsGoalController.text) ?? 0,
      alwaysKeepSavingsGoal: _alwaysKeepSavingsGoal,
      expenses: _expenses,
    );

    await ref.read(atp.basicInfoDataProvider.notifier).updateBasicInfo(data);

    // 提案キャッシュを再計算してFirestoreに保存
    final assets = ref.read(atp.assetsDataProvider).value;
    if (assets != null) {
      await ref.read(atp.calculationCacheProvider.notifier).recompute(assets, data);
    }

    if (mounted) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('保存しました')));
      Navigator.pop(context);
    }
  }

  void _showSavingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('保存中...'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basicInfoAsync = ref.watch(atp.basicInfoDataProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'ja_JP', symbol: '¥');

    return Scaffold(
      appBar: AppBar(title: const Text('基本情報管理')),
      body: basicInfoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (data) {
          _loadData(data);
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 予測開始日
                  _buildField(
                    '予測開始日 (yyyy/mm/dd)',
                    _forecastStartDateController,
                    keyboardType: TextInputType.text,
                    hint: '例: 2027/06/01',
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !_isValidStartDate(value)) {
                        return 'yyyy/mm/dd形式で入力してください';
                      }
                      return null;
                    },
                  ),
                  // 月の固定出費
                  _buildField(
                    '月の固定出費額 (円)', 
                    _monthlyExpenseController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return '数値で入力してください';
                      }
                      return null;
                    },
                  ),
                  // 必要な貯金目標額
                  _buildField(
                    '必要な貯金目標額 (円)', 
                    _savingsGoalController,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return '数値で入力してください';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _alwaysKeepSavingsGoal,
                        onChanged: (bool? value) {
                          setState(() {
                            _alwaysKeepSavingsGoal = value ?? false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _alwaysKeepSavingsGoal = !_alwaysKeepSavingsGoal;
                          });
                        },
                        child: const Text('常に目標額を貯金'),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                SegmentedButton<_InfoMode>(
                  segments: const [
                    ButtonSegment(
                      value: _InfoMode.expense,
                      label: Text('出費額計算'),
                      icon: Icon(Icons.calculate),
                    ),
                    ButtonSegment(
                      value: _InfoMode.timing,
                      label: Text('時期計算'),
                      icon: Icon(Icons.calendar_month),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _mode == _InfoMode.expense ? '費用項目（自動並び替え）' : '費用項目（ドラッグで並び替え）',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextButton.icon(
                      onPressed: _addExpenseItem,
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
                  ],
                ),
                Text(
                  _mode == _InfoMode.expense
                      ? '目標時期(昇順)'
                      : '時系列(昇順)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                if (_mode == _InfoMode.expense)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getSortedForExpense().length,
                    itemBuilder: (context, index) {
                      final item = _getSortedForExpense()[index];
                      return _buildExpenseCard(item, currencyFormatter, isDraggable: false);
                    },
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _expenses.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final item = _expenses[index];
                      return _buildExpenseCard(item, currencyFormatter, isDraggable: true, index: index);
                    },
                  ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存する'),
                ),
              ],
            ),
          ),
        );
      },
    ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem item, NumberFormat fmt, {required bool isDraggable, int? index}) {
    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: isDraggable && index != null
            ? ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle, color: Colors.grey),
              )
            : const SizedBox(width: 24, height: 24),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fmt.format(item.cost)),
            if (item.targetDate != null && _mode == _InfoMode.expense)
              Text('目標: ${item.targetDate}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              onPressed: () => _editExpenseItem(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('確認'),
                      content: const Text('費用項目を削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _expenses.removeWhere((e) => e.id == item.id));
                            Navigator.pop(context);
                          },
                          child: const Text('削除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.number,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
