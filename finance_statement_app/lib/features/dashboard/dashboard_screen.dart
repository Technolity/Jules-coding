import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/glass_container.dart';
import '../accounts/cubit/accounts_cubit.dart';
import '../accounts/cubit/accounts_state.dart';
import '../../data/models/account_model.dart';
import '../transactions/transactions_screen.dart'; // Will create next

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accounts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, state) {
            if (state is AccountsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountsLoaded) {
              if (state.accounts.isEmpty) {
                return const Center(
                  child: Text(
                    "No accounts found.\nTap + to add one.",
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (_) => TransactionsScreen(accountId: account.id!),
                           ),
                         ).then((_) {
                           if (context.mounted) {
                             context.read<AccountsCubit>().loadAccounts();
                           }
                         });
                      },
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(account.color),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    account.accountNumber,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is AccountsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final balanceController = TextEditingController(text: "0.0");

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Account"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Account Name"),
                ),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: "Account Number"),
                ),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: "Initial Balance"),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final number = numberController.text.trim();
                final balance = double.tryParse(balanceController.text) ?? 0.0;

                if (name.isNotEmpty) {
                  // Use the context from the parent widget, not dialogContext, to find the provider
                  // Or pass the cubit.
                  // Since BlocProvider is above DashboardScreen, we can use context.read if we passed context.
                  // But usually dialogs have their own context tree.
                  // Solution: Capture cubit before showDialog.
                  context.read<AccountsCubit>().addAccount(Account(
                        name: name,
                        accountNumber: number,
                        initialBalance: balance,
                        color: 0xFF1C1C1E, // Default accent
                      ));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
