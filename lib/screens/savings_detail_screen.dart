import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_item.dart';

/// 各費用項目の「支払い後の目標貯金額」を個別設定する画面
///
/// pop 時に返す値: SavingsDetailResult
///   - expenses: 更新後の費用リスト
///   - shouldUncheckAlwaysKeep: 詳細設定が1つ以上あれば true
class SavingsDetailScreen extends StatefulWidget {
  final List<ExpenseItem> expenses;
  final int savingsGoal;

  const SavingsDetailScreen({
    super.key,
    required this.expenses,
    required this.savingsGoal,
  });

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _controllers;
  late List<ExpenseItem> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
    _controllers = _expenses.map((e) {
      final text = e.savingByPayment > 0 ? e.savingByPayment.toString() : '';
      return TextEditingController(text: text);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('全ての詳細設定を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (final c in _controllers) {
                  c.text = '';
                }
              });
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updatedExpenses = <ExpenseItem>[];
    for (int i = 0; i < _expenses.length; i++) {
      final val = int.tryParse(_controllers[i].text.trim()) ?? 0;
      updatedExpenses.add(_expenses[i].copyWith(savingByPayment: val));
    }

    final hasAnyDetail = updatedExpenses.any((e) => e.savingByPayment > 0);

    Navigator.pop(
      context,
      SavingsDetailResult(
        expenses: updatedExpenses,
        shouldUncheckAlwaysKeep: hasAnyDetail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('貯金詳細設定'),
        actions: [
          TextButton.icon(
            onPressed: _clearAll,
            icon: Icon(Icons.delete_sweep, color: colorScheme.error),
            label: Text(
              '全て削除',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '各費用項目の支払い後に維持したい貯金額を設定します。\n'
                '未入力の項目は「必要な貯金目標額（¥${NumberFormat("#,###").format(widget.savingsGoal)}）」を使用します。',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _expenses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _expenses[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '費用: ¥${NumberFormat("#,###").format(item.cost)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '支払い後の目標貯金額（円）',
                              hintText:
                                  '未入力: ¥${NumberFormat("#,###").format(widget.savingsGoal)} を使用',
                              border: const OutlineInputBorder(),
                              prefixText: '¥ ',
                              suffixIcon: _controllers[index].text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _controllers[index].clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final v = int.tryParse(value);
                                if (v == null || v < 0) {
                                  return '0以上の整数で入力してください';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('保存する'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavingsDetailResult {
  final List<ExpenseItem> expenses;
  final bool shouldUncheckAlwaysKeep;

  const SavingsDetailResult({
    required this.expenses,
    required this.shouldUncheckAlwaysKeep,
  });
}
