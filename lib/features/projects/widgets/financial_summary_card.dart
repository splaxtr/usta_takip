import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/gelir_gider_model.dart';
import '../../../data/services/hive_service.dart';

/// Finansal özet kartı widget'ı
///
/// Projeye ait gelir, gider ve kar/zarar özetini gösterir
class FinancialSummaryCard extends StatefulWidget {
  final ProjectModel project;

  const FinancialSummaryCard({
    super.key,
    required this.project,
  });

  @override
  State<FinancialSummaryCard> createState() => _FinancialSummaryCardState();
}

class _FinancialSummaryCardState extends State<FinancialSummaryCard> {
  List<GelirGiderModel> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _netProfit = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final transactions = HiveService.getGelirGiderByProject(widget.project.id);

    double income = 0.0;
    double expense = 0.0;

    for (var transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    setState(() {
      _transactions = transactions;
      _totalIncome = income;
      _totalExpense = expense;
      _netProfit = income - expense;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingXl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        // Özet Kartları
        _buildSummaryCards(),

        const SizedBox(height: AppSizes.spaceMd),

        // Bütçe Karşılaştırma
        _buildBudgetComparison(),

        const SizedBox(height: AppSizes.spaceMd),

        // Son İşlemler
        _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Gelir',
            amount: _totalIncome,
            icon: Icons.trending_up,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSizes.spaceMd),
        Expanded(
          child: _buildSummaryCard(
            title: 'Gider',
            amount: _totalExpense,
            icon: Icons.trending_down,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconLg),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              NumberHelper.formatCurrency(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetComparison() {
    final budgetUsagePercent = widget.project.budget > 0
        ? (_totalExpense / widget.project.budget) * 100
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bütçe Kullanımı',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${budgetUsagePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getBudgetColor(budgetUsagePercent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: LinearProgressIndicator(
                value: budgetUsagePercent / 100,
                minHeight: 8,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getBudgetColor(budgetUsagePercent),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harcanan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      NumberHelper.formatCurrency(_totalExpense),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Bütçe',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    Text(
                      NumberHelper.formatCurrency(widget.project.budget),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceMd),
            const Divider(),
            const SizedBox(height: AppSizes.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Kar/Zarar',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  NumberHelper.formatCurrency(_netProfit.abs()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _netProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son İşlemler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${_transactions.length} işlem',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 60,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSizes.spaceSm),
                    Text(
                      'Henüz işlem kaydı yok',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length > 5 ? 5 : _transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return _buildTransactionTile(transaction);
              },
            ),
          if (_transactions.length > 5) ...[
            const Divider(height: 1),
            InkWell(
              onTap: () {
                // TODO: Tüm işlemleri göster
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingSm),
                child: Center(
                  child: Text(
                    'Tüm İşlemleri Gör (${_transactions.length})',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTile(GelirGiderModel transaction) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      leading: CircleAvatar(
        backgroundColor: transaction.isIncome
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        child: Icon(
          transaction.isIncome ? Icons.add : Icons.remove,
          color: transaction.isIncome ? AppColors.success : AppColors.error,
        ),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        transaction.category,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: Text(
        '${transaction.isIncome ? '+' : '-'}${NumberHelper.formatCurrency(transaction.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.isIncome ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Color _getBudgetColor(double percent) {
    if (percent < 50) {
      return AppColors.success;
    } else if (percent < 80) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
