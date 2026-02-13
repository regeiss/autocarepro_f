// Maintenance Form Screen - add/edit maintenance records with photo capture
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/service_provider_providers.dart';
import '../../service_providers/screens/service_provider_form_screen.dart';

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final MaintenanceRecord? record;

  const MaintenanceFormScreen({
    super.key,
    required this.vehicleId,
    this.record,
  });

  @override
  ConsumerState<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _notesController = TextEditingController();
  final _partsController = TextEditingController();

  ServiceType _selectedServiceType = ServiceType.oilChange;
  DateTime _selectedDate = DateTime.now();
  String? _receiptPhotoPath;
  String? _selectedProviderId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _loadExistingRecord();
    }
  }

  void _loadExistingRecord() {
    final record = widget.record!;
    _descriptionController.text = record.description ?? '';
    _costController.text = record.cost?.toStringAsFixed(2) ?? '';
    _mileageController.text = record.mileage?.toStringAsFixed(0) ?? '';
    _serviceProviderController.text = record.serviceProvider ?? '';
    _selectedProviderId = record.serviceProviderId;
    _notesController.text = record.notes ?? '';
    _partsController.text = record.partsReplacedJson ?? '';
    _selectedServiceType = ServiceType.fromDisplayName(record.serviceType);
    _selectedDate = DateTime.fromMillisecondsSinceEpoch(record.serviceDate);
    _receiptPhotoPath = record.receiptPhotoPath;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _serviceProviderController.dispose();
    _notesController.dispose();
    _partsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Maintenance' : 'Add Maintenance'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Service Type Dropdown
            DropdownButtonFormField<ServiceType>(
              value: _selectedServiceType,
              decoration: const InputDecoration(
                labelText: 'Service Type',
                prefixIcon: Icon(Icons.build),
                border: OutlineInputBorder(),
              ),
              items: ServiceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getServiceTypeIcon(type), size: 20),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedServiceType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Regular oil change',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Service Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Service Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat.yMMMd().format(_selectedDate),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cost
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the cost';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost < 0) {
                  return 'Please enter a valid cost';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Mileage
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Mileage',
                hintText: 'Current mileage',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final mileage = int.tryParse(value);
                  if (mileage == null || mileage < 0) {
                    return 'Please enter a valid mileage';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Service Provider Selector
            Consumer(
              builder: (context, ref, child) {
                final providersAsync = ref.watch(serviceProvidersListProvider);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: providersAsync.when(
                            data: (providers) {
                              return DropdownButtonFormField<String>(
                                value: _selectedProviderId,
                                decoration: InputDecoration(
                                  labelText: 'Service Provider (Optional)',
                                  prefixIcon: const Icon(Icons.store),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _selectedProviderId != null
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              _selectedProviderId = null;
                                              _serviceProviderController.clear();
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('None'),
                                  ),
                                  ...providers.map((provider) {
                                    return DropdownMenuItem(
                                      value: provider.id,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              provider.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (provider.rating != null) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.star,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                            Text(
                                              provider.rating!.toStringAsFixed(1),
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProviderId = value;
                                    if (value != null) {
                                      final provider = providers.firstWhere((p) => p.id == value);
                                      _serviceProviderController.text = provider.name;
                                    } else {
                                      _serviceProviderController.clear();
                                    }
                                  });
                                },
                              );
                            },
                            loading: () => TextFormField(
                              controller: _serviceProviderController,
                              decoration: const InputDecoration(
                                labelText: 'Service Provider (Optional)',
                                hintText: 'Loading providers...',
                                prefixIcon: Icon(Icons.store),
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            error: (_, __) => TextFormField(
                              controller: _serviceProviderController,
                              decoration: const InputDecoration(
                                labelText: 'Service Provider (Optional)',
                                hintText: 'e.g., Quick Lube',
                                prefixIcon: Icon(Icons.store),
                                border: OutlineInputBorder(),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quick add provider button
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          tooltip: 'Add New Provider',
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ServiceProviderFormScreen(),
                              ),
                            );
                            // Refresh providers list
                            ref.invalidate(serviceProvidersListProvider);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Parts Replaced
            TextFormField(
              controller: _partsController,
              decoration: const InputDecoration(
                labelText: 'Parts Replaced (Optional)',
                hintText: 'e.g., Oil filter, air filter',
                prefixIcon: Icon(Icons.construction),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Receipt Photo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt),
                        const SizedBox(width: 8),
                        Text(
                          'Receipt Photo',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_receiptPhotoPath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_receiptPhotoPath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.edit),
                            label: const Text('Change Photo'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _receiptPhotoPath = null;
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Remove'),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(useCamera: true),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(useCamera: false),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('From Gallery'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Additional details...',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMaintenance,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Maintenance' : 'Add Maintenance'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage({bool useCamera = false}) async {
    try {
      final picker = ImagePicker();
      final source = useCamera ? ImageSource.camera : ImageSource.gallery;
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _receiptPhotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveMaintenance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(maintenanceRepositoryProvider);
      final isEditing = widget.record != null;

      final record = MaintenanceRecord(
        id: isEditing ? widget.record!.id : '',
        vehicleId: widget.vehicleId,
        serviceType: _selectedServiceType.name,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        serviceDate: _selectedDate.millisecondsSinceEpoch,
        cost: _costController.text.isEmpty ? null : double.parse(_costController.text),
        mileage: _mileageController.text.isEmpty ? null : double.parse(_mileageController.text),
        serviceProvider: _serviceProviderController.text.trim().isEmpty
            ? null
            : _serviceProviderController.text.trim(),
        serviceProviderId: _selectedProviderId,
        receiptPhotoPath: _receiptPhotoPath,
        partsReplacedJson: _partsController.text.trim().isEmpty
            ? null
            : _partsController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: isEditing
            ? widget.record!.createdAt
            : DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      if (isEditing) {
        await repository.updateRecord(record);
      } else {
        await repository.addRecord(record);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Maintenance record updated'
                : 'Maintenance record added'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save maintenance record: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance Record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(maintenanceRepositoryProvider);
        await repository.deleteRecordById(widget.record!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maintenance record deleted')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  IconData _getServiceTypeIcon(ServiceType type) {
    switch (type) {
      case ServiceType.oilChange:
        return Icons.oil_barrel;
      case ServiceType.tireRotation:
        return Icons.tire_repair;
      case ServiceType.brakeService:
        return Icons.motion_photos_pause;
      case ServiceType.batteryReplacement:
        return Icons.battery_charging_full;
      case ServiceType.airFilter:
        return Icons.air;
      case ServiceType.transmission:
        return Icons.sync;
      case ServiceType.coolant:
        return Icons.water_drop;
      case ServiceType.sparkPlugs:
        return Icons.electric_bolt;
      case ServiceType.alignment:
        return Icons.straighten;
      case ServiceType.inspection:
        return Icons.fact_check;
      case ServiceType.registration:
        return Icons.description;
      case ServiceType.insurance:
        return Icons.shield;
      case ServiceType.cleaning:
        return Icons.local_car_wash;
      case ServiceType.other:
        return Icons.build;
    }
  }
}
