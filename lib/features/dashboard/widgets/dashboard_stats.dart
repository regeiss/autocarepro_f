import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../../../data/providers/maintenance_providers.dart';
import '../../../data/providers/reminder_providers.dart';
import '../../../app/theme.dart';

/// Dashboard statistics widget
///
/// Displays summary statistics cards showing:
/// - Total vehicles
/// - Monthly expenses
/// - Active reminders
class DashboardStats extends ConsumerWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleCountAsync = ref.watch(vehicleCountProvider);
    final monthlyExpensesAsync = ref.watch(monthlyExpensesProvider);
    final activeRemindersAsync = ref.watch(totalActiveRemindersCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: _StatCard(
                icon: Icons.directions_car,
                label: 'Vehicles',
                value: vehicleCountAsync.when(
                  data: (count) => count.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: _StatCard(
                icon: Icons.attach_money,
                label: 'This Month',
                value: monthlyExpensesAsync.when(
                  data: (amount) => '\$${amount.toStringAsFixed(0)}',
                  loading: () => '...',
                  error: (_, __) => '\$0',
                ),
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: _StatCard(
                icon: Icons.notifications_active,
                label: 'Reminders',
                value: activeRemindersAsync.when(
                  data: (count) => count.toString(),
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
