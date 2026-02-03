import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/database_helper.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'features/accounts/cubit/accounts_cubit.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DatabaseHelper init (includes Windows FFI check) is done lazily on access,
  // but we should ensure the FFI part is handled if needed.
  // The helper code: `if (Platform.isWindows...) sqfliteFfiInit();` is inside `get database`.
  // So it's fine.

  final dbHelper = DatabaseHelper.instance;
  final financeRepository = FinanceRepositoryImpl(databaseHelper: dbHelper);

  runApp(MyApp(financeRepository: financeRepository));
}

class MyApp extends StatelessWidget {
  final FinanceRepositoryImpl financeRepository;

  const MyApp({super.key, required this.financeRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountsCubit>(
          create: (context) => AccountsCubit(financeRepository),
        ),
        // TransactionsCubit needs to be scoped or global?
        // Typically scoped to the screen, but global is easier for now if we want.
        // I will scope it in the TransactionsScreen to pass the repo.
      ],
      child: MaterialApp(
        title: 'Finance Statement',
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
