// Screen to display list of service providers
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/service_provider_providers.dart';
import '../../dashboard/widgets/empty_state.dart';
import '../widgets/service_provider_list_tile.dart';
import 'service_provider_detail_screen.dart';
import 'service_provider_form_screen.dart';

class ServiceProvidersListScreen extends ConsumerStatefulWidget {
  const ServiceProvidersListScreen({super.key});

  @override
  ConsumerState<ServiceProvidersListScreen> createState() => _ServiceProvidersListScreenState();
}

class _ServiceProvidersListScreenState extends ConsumerState<ServiceProvidersListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(serviceProvidersStreamProvider);
    final sortOption = ref.watch(providerSortOptionProvider);
    final ratingFilter = ref.watch(providerRatingFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
        actions: [
          // Sort menu
          PopupMenuButton<ProviderSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              ref.read(providerSortOptionProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(
                ProviderSortOption.nameAsc,
                'Name (A-Z)',
                Icons.sort_by_alpha,
                sortOption,
                context,
              ),
              _buildSortMenuItem(
                ProviderSortOption.nameDesc,
                'Name (Z-A)',
                Icons.sort_by_alpha,
                sortOption,
                context,
              ),
              _buildSortMenuItem(
                ProviderSortOption.ratingHigh,
                'Rating (High-Low)',
                Icons.star,
                sortOption,
                context,
              ),
              _buildSortMenuItem(
                ProviderSortOption.ratingLow,
                'Rating (Low-High)',
                Icons.star_border,
                sortOption,
                context,
              ),
              _buildSortMenuItem(
                ProviderSortOption.newest,
                'Newest First',
                Icons.new_releases,
                sortOption,
                context,
              ),
              _buildSortMenuItem(
                ProviderSortOption.oldest,
                'Oldest First',
                Icons.access_time,
                sortOption,
                context,
              ),
            ],
          ),

          // Filter menu
          PopupMenuButton<double?>(
            icon: Icon(
              ratingFilter != null ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filter by rating',
            onSelected: (value) {
              ref.read(providerRatingFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: ratingFilter == null ? Theme.of(context).primaryColor : null,
                    ),
                    const SizedBox(width: 12),
                    const Text('All Ratings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...[5.0, 4.0, 3.0, 2.0, 1.0].map((rating) => PopupMenuItem(
                value: rating,
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: ratingFilter == rating ? Theme.of(context).primaryColor : Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text('$rating+ Stars'),
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search providers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Active filters
          if (ratingFilter != null || sortOption != ProviderSortOption.nameAsc)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (ratingFilter != null)
                    Chip(
                      avatar: const Icon(Icons.star, size: 16),
                      label: Text('$ratingFilter+ Stars'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        ref.read(providerRatingFilterProvider.notifier).state = null;
                      },
                    ),
                  if (sortOption != ProviderSortOption.nameAsc)
                    Chip(
                      avatar: const Icon(Icons.sort, size: 16),
                      label: Text(_getSortLabel(sortOption)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        ref.read(providerSortOptionProvider.notifier).state = ProviderSortOption.nameAsc;
                      },
                    ),
                ],
              ),
            ),

          // Provider list
          Expanded(
            child: providersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
              data: (providers) {
                // Apply search filter
                var filteredProviders = providers;
                if (_searchQuery.isNotEmpty) {
                  filteredProviders = providers.where((provider) {
                    final query = _searchQuery.toLowerCase();
                    return provider.name.toLowerCase().contains(query) ||
                        (provider.phone?.toLowerCase().contains(query) ?? false) ||
                        (provider.email?.toLowerCase().contains(query) ?? false) ||
                        (provider.address?.toLowerCase().contains(query) ?? false) ||
                        provider.specialties.any((s) => s.toLowerCase().contains(query));
                  }).toList();
                }

                // Apply rating filter
                if (ratingFilter != null) {
                  filteredProviders = filteredProviders
                      .where((p) => p.rating != null && p.rating! >= ratingFilter)
                      .toList();
                }

                // Apply sort
                filteredProviders = _sortProviders(filteredProviders, sortOption);

                if (filteredProviders.isEmpty) {
                  return EmptyState(
                    icon: _searchQuery.isNotEmpty || ratingFilter != null
                        ? Icons.search_off
                        : Icons.store,
                    title: _searchQuery.isNotEmpty || ratingFilter != null
                        ? 'No Providers Found'
                        : 'No Service Providers Yet',
                    message: _searchQuery.isNotEmpty || ratingFilter != null
                        ? 'Try adjusting your search or filters.'
                        : 'Add your favorite mechanics, shops,\nand service centers.',
                    actionLabel: _searchQuery.isNotEmpty || ratingFilter != null
                        ? 'Clear Filters'
                        : 'Add Provider',
                    onAction: _searchQuery.isNotEmpty || ratingFilter != null
                        ? () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            ref.read(providerRatingFilterProvider.notifier).state = null;
                          }
                        : () => _navigateToAddProvider(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(serviceProvidersStreamProvider);
                  },
                  child: Column(
                    children: [
                      // Provider count
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              '${filteredProviders.length} provider${filteredProviders.length != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Provider list
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredProviders.length,
                          itemBuilder: (context, index) {
                            final provider = filteredProviders[index];
                            return ServiceProviderListTile(
                              provider: provider,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ServiceProviderDetailScreen(
                                      providerId: provider.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddProvider(context),
        tooltip: 'Add Provider',
        child: const Icon(Icons.add),
      ),
    );
  }

  PopupMenuItem<ProviderSortOption> _buildSortMenuItem(
    ProviderSortOption value,
    String label,
    IconData icon,
    ProviderSortOption currentSort,
    BuildContext context,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: currentSort == value ? Theme.of(context).primaryColor : null,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  String _getSortLabel(ProviderSortOption option) {
    switch (option) {
      case ProviderSortOption.nameAsc:
        return 'Name (A-Z)';
      case ProviderSortOption.nameDesc:
        return 'Name (Z-A)';
      case ProviderSortOption.ratingHigh:
        return 'Rating (High-Low)';
      case ProviderSortOption.ratingLow:
        return 'Rating (Low-High)';
      case ProviderSortOption.newest:
        return 'Newest';
      case ProviderSortOption.oldest:
        return 'Oldest';
    }
  }

  List<ServiceProvider> _sortProviders(List<ServiceProvider> providers, ProviderSortOption option) {
    final sorted = List<ServiceProvider>.from(providers);

    switch (option) {
      case ProviderSortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProviderSortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProviderSortOption.ratingHigh:
        sorted.sort((a, b) {
          if (a.rating == null && b.rating == null) return 0;
          if (a.rating == null) return 1;
          if (b.rating == null) return -1;
          return b.rating!.compareTo(a.rating!);
        });
        break;
      case ProviderSortOption.ratingLow:
        sorted.sort((a, b) {
          if (a.rating == null && b.rating == null) return 0;
          if (a.rating == null) return 1;
          if (b.rating == null) return -1;
          return a.rating!.compareTo(b.rating!);
        });
        break;
      case ProviderSortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProviderSortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return sorted;
  }

  void _navigateToAddProvider(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ServiceProviderFormScreen(),
      ),
    );
  }
}
