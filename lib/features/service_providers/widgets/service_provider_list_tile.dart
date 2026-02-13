// Widget to display a service provider in a list
library;

import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import '../../../app/theme.dart';

class ServiceProviderListTile extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback? onTap;

  const ServiceProviderListTile({
    super.key,
    required this.provider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Provider icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  _getProviderIcon(),
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Provider info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      provider.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Contact info
                    Text(
                      provider.displayContact,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Specialties
                    if (provider.specialties.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.specialties.take(3).join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Rating
                    if (provider.rating != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < provider.rating!.floor()) {
                              return const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              );
                            } else if (index < provider.rating!.ceil() &&
                                provider.rating! % 1 > 0) {
                              return const Icon(
                                Icons.star_half,
                                size: 14,
                                color: Colors.amber,
                              );
                            } else {
                              return Icon(
                                Icons.star_border,
                                size: 14,
                                color: Colors.grey[400],
                              );
                            }
                          }),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProviderIcon() {
    // You could make this more sophisticated based on specialties
    if (provider.specialties.isNotEmpty) {
      final specialty = provider.specialties.first.toLowerCase();
      if (specialty.contains('oil')) return Icons.opacity;
      if (specialty.contains('tire')) return Icons.circle_outlined;
      if (specialty.contains('brake')) return Icons.error_outline;
      if (specialty.contains('engine')) return Icons.settings;
      if (specialty.contains('body')) return Icons.build_circle;
      if (specialty.contains('electric')) return Icons.bolt;
    }
    return Icons.store;
  }
}
