import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/gelir_gider_model.dart';

/// İşlem (Gelir/Gider) kartı widget'ı
///
/// Finansal işlemleri liste halinde gösterir
class TransactionCard extends StatelessWidget {
  final GelirGiderModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              // İkon
              _buildIcon(),

              const SizedBox(width: AppSizes.spaceMd),

              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Açıklama ve Kategori
                    Text(
                      transaction.description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSizes.spaceXs),

                    // Kategori
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingXs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTransactionColor().withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusXs),
                          ),
                          child: Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w600,
                              color: _getTransactionColor(),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceSm),
                        Icon(
                          _getPaymentIcon(),
                          size: AppSizes.iconXs,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSizes.spaceXs),
                        Text(
                          _getPaymentMethodText(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceXs),

                    // Tarih
                    Text(
                      DateHelper.formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.spaceSm),

              // Tutar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.isIncome ? '+' : '-'}${NumberHelper.formatCurrency(transaction.amount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTransactionColor(),
                        ),
                  ),
                  if (transaction.invoiceNumber != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.invoiceNumber!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: AppSizes.fontXs,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: _getTransactionColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(
        transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: _getTransactionColor(),
        size: AppSizes.iconLg,
      ),
    );
  }

  Color _getTransactionColor() {
    return transaction.isIncome ? AppColors.success : AppColors.error;
  }

  IconData _getPaymentIcon() {
    switch (transaction.paymentMethod) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.check:
        return Icons.receipt;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  String _getPaymentMethodText() {
    switch (transaction.paymentMethod) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.bankTransfer:
        return 'Havale';
      case PaymentMethod.creditCard:
        return 'Kart';
      case PaymentMethod.check:
        return 'Çek';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }
}

/// Kompakt işlem kartı (daha küçük liste için)
class CompactTransactionCard extends StatelessWidget {
  final GelirGiderModel transaction;
  final VoidCallback? onTap;

  const CompactTransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
        '${transaction.category} • ${DateHelper.formatDate(transaction.date)}',
        style: const TextStyle(fontSize: AppSizes.fontSm),
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
}

/// İşlem detay kartı (detay sayfada kullanım için)
class TransactionDetailCard extends StatelessWidget {
  final GelirGiderModel transaction;

  const TransactionDetailCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              color: transaction.isIncome
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                topRight: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  transaction.isIncome
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: transaction.isIncome
                      ? AppColors.success
                      : AppColors.error,
                  size: AppSizes.iconLg,
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Text(
                  transaction.isIncome ? 'GELİR' : 'GİDER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tutar
                Text(
                  NumberHelper.formatCurrency(transaction.amount),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: transaction.isIncome
                            ? AppColors.success
                            : AppColors.error,
                      ),
                ),

                const SizedBox(height: AppSizes.spaceMd),
                const Divider(),
                const SizedBox(height: AppSizes.spaceMd),

                // Detaylar
                _buildDetailRow(
                  context,
                  icon: Icons.description,
                  label: 'Açıklama',
                  value: transaction.description,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.category,
                  label: 'Kategori',
                  value: transaction.category,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Tarih',
                  value: DateHelper.formatDate(transaction.date),
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.payment,
                  label: 'Ödeme Yöntemi',
                  value: _getPaymentMethodText(transaction.paymentMethod),
                ),
                if (transaction.invoiceNumber != null)
                  _buildDetailRow(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Fatura/Fiş No',
                    value: transaction.invoiceNumber!,
                  ),
                if (transaction.notes != null &&
                    transaction.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  const Divider(),
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    'Notlar:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spaceXs),
                  Text(
                    transaction.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.spaceSm),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.bankTransfer:
        return 'Banka Havalesi';
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.check:
        return 'Çek';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }
}

/// Günlük işlem özeti widget'ı
class DailyTransactionSummary extends StatelessWidget {
  final DateTime date;
  final List<GelirGiderModel> transactions;

  const DailyTransactionSummary({
    super.key,
    required this.date,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final netAmount = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMd),
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateHelper.formatDate(date),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context,
                label: 'Gelir',
                amount: totalIncome,
                color: AppColors.success,
              ),
              _buildSummaryItem(
                context,
                label: 'Gider',
                amount: totalExpense,
                color: AppColors.error,
              ),
              _buildSummaryItem(
                context,
                label: 'Net',
                amount: netAmount,
                color: netAmount >= 0 ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          NumberHelper.formatCurrency(amount.abs()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
