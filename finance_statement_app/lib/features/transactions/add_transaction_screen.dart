import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/finance_repository_impl.dart'; // For DI if needed, but we pass via cubit usually
import '../../data/datasources/database_helper.dart';

// Since this screen is pushed and might not have the parent cubit in context if not passed,
// we often just do the operation here or return the result to the previous screen.
// Simpler is to return result. The previous screen reloads.
// But wait, the previous screen's cubit is not available here?
// I'll create a new Cubit instance or use Repository directly to add.
// Actually, it's cleaner to use Repository directly here or have a specific AddTransactionCubit.
// I'll use Repository directly for simplicity of "Add" operations which are one-shot.

class AddTransactionScreen extends StatefulWidget {
  final int accountId;

  const AddTransactionScreen({super.key, required this.accountId});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _partyController = TextEditingController();
  final _descController = TextEditingController();

  TransactionType _type = TransactionType.debit; // Default to Expense
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Type Selector
              GlassContainer(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = TransactionType.debit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == TransactionType.debit ? Colors.red[100] : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text("Money Out", style: TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = TransactionType.credit),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == TransactionType.credit ? Colors.green[100] : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text("Money In", style: TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: InputBorder.none,
                    icon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter amount";
                    if (double.tryParse(value) == null) return "Invalid number";
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Party Name
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _partyController,
                  decoration: const InputDecoration(
                    labelText: "To / From (Name or Account)",
                    border: InputBorder.none,
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter name/account";
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Description
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                    border: InputBorder.none,
                    icon: Icon(Icons.notes),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Transaction"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final party = _partyController.text;
      final desc = _descController.text;

      final tx = TransactionModel(
        accountId: widget.accountId,
        amount: amount,
        type: _type,
        date: _selectedDate,
        partyName: party,
        description: desc,
      );

      final repo = FinanceRepositoryImpl(databaseHelper: DatabaseHelper.instance);
      await repo.createTransaction(tx);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    }
  }
}
