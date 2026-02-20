// Screen for adding/editing service providers
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/service_provider_providers.dart';
import '../../../data/providers/profile_providers.dart';
import '../../../data/providers/repository_providers.dart';

class ServiceProviderFormScreen extends ConsumerStatefulWidget {
  final ServiceProvider? provider; // For editing

  const ServiceProviderFormScreen({
    super.key,
    this.provider,
  });

  @override
  ConsumerState<ServiceProviderFormScreen> createState() => _ServiceProviderFormScreenState();
}

class _ServiceProviderFormScreenState extends ConsumerState<ServiceProviderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  
  double? _rating;
  final List<String> _specialties = [];
  final _specialtyController = TextEditingController();
  bool _isLoading = false;

  // Common specialty options
  final List<String> _commonSpecialties = [
    'Oil Change',
    'Tire Service',
    'Brake Repair',
    'Engine Repair',
    'Transmission',
    'Electrical',
    'AC & Heating',
    'Body Work',
    'Paint',
    'Detailing',
    'Inspection',
    'Alignment',
    'Suspension',
    'Exhaust',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _initializeFromProvider(widget.provider!);
    }
  }

  void _initializeFromProvider(ServiceProvider provider) {
    _nameController.text = provider.name;
    _phoneController.text = provider.phone ?? '';
    _emailController.text = provider.email ?? '';
    _addressController.text = provider.address ?? '';
    _websiteController.text = provider.website ?? '';
    _notesController.text = provider.notes ?? '';
    _rating = provider.rating;
    _specialties.addAll(provider.specialties);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Provider' : 'Add Provider'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'e.g., Joe\'s Auto Shop',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        hintText: 'e.g., (555) 123-4567',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'e.g., contact@shop.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Invalid email format';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location & Website
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location & Website',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: '123 Main St, City, State 12345',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Website
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rating
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final starValue = index + 1.0;
                          return IconButton(
                            icon: Icon(
                              _rating != null && _rating! >= starValue
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = _rating == starValue ? null : starValue;
                              });
                            },
                          );
                        }),
                        const SizedBox(width: 8),
                        if (_rating != null)
                          Chip(
                            label: Text(_rating!.toStringAsFixed(1)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => _rating = null);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Specialties
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specialties',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What services does this provider specialize in?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selected specialties
                    if (_specialties.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _specialties.map((specialty) {
                          return Chip(
                            label: Text(specialty),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _specialties.remove(specialty);
                              });
                            },
                          );
                        }).toList(),
                      ),

                    if (_specialties.isNotEmpty) const SizedBox(height: 16),

                    // Quick add specialties
                    Text(
                      'Quick Add:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonSpecialties
                          .where((s) => !_specialties.contains(s))
                          .map((specialty) {
                        return ActionChip(
                          label: Text(specialty),
                          onPressed: () {
                            setState(() {
                              _specialties.add(specialty);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Custom specialty
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _specialtyController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Specialty',
                              hintText: 'Enter a specialty',
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (_specialtyController.text.trim().isNotEmpty) {
                              setState(() {
                                final specialty = _specialtyController.text.trim();
                                if (!_specialties.contains(specialty)) {
                                  _specialties.add(specialty);
                                }
                                _specialtyController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add any additional notes about this provider',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProvider,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update Provider' : 'Save Provider'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(serviceProviderRepositoryProvider);
      final isEditing = widget.provider != null;

      final profileId = ref.read(currentProfileIdProvider).value;
      if (!isEditing && profileId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a profile first')),
          );
        }
        return;
      }

      final provider = isEditing
          ? widget.provider!.copyWith(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
              email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
              website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              rating: _rating,
              specialties: _specialties,
            )
          : ServiceProvider.create(
              profileId: profileId!,
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
              email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
              address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
              website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              rating: _rating,
              specialties: _specialties,
            );

      if (isEditing) {
        await repository.updateProvider(provider);
      } else {
        await repository.addProvider(provider);
      }

      // Invalidate providers to refresh data
      ref.invalidate(serviceProvidersStreamProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Provider updated successfully'
                  : 'Provider added successfully',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving provider: $e')),
        );
      }
    }
  }
}
