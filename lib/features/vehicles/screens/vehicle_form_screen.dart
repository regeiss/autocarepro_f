import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/vehicle_providers.dart';
import '../../../data/repositories/vehicle_repository.dart';

/// Vehicle form screen
/// 
/// Allows adding or editing a vehicle.
class VehicleFormScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({
    super.key,
    this.vehicle,
  });

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMileageUnit = 'miles';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _initializeWithVehicle(widget.vehicle!);
    }
  }

  void _initializeWithVehicle(Vehicle vehicle) {
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year.toString();
    _vinController.text = vehicle.vin ?? '';
    _licensePlateController.text = vehicle.licensePlate ?? '';
    _mileageController.text = vehicle.currentMileage?.toStringAsFixed(0) ?? '';
    _notesController.text = vehicle.notes ?? '';
    _selectedMileageUnit = vehicle.mileageUnit;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Make
            TextFormField(
              controller: _makeController,
              decoration: const InputDecoration(
                labelText: 'Make *',
                hintText: 'Toyota, Honda, Ford...',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the vehicle make';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                hintText: 'Camry, Accord, F-150...',
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the vehicle model';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Year
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year *',
                hintText: '2020',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the year';
                }
                final year = int.tryParse(value);
                if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // VIN (optional)
            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(
                labelText: 'VIN',
                hintText: '17-digit VIN (optional)',
                prefixIcon: Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(17),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length != 17) {
                  return 'VIN must be exactly 17 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // License Plate (optional)
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'License Plate',
                hintText: 'ABC-1234 (optional)',
                prefixIcon: Icon(Icons.pin),
              ),
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 16),

            // Current Mileage
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Current Mileage',
                      hintText: '45000',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final mileage = double.tryParse(value);
                        if (mileage == null || mileage < 0) {
                          return 'Please enter a valid mileage';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMileageUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'miles', child: Text('Miles')),
                      DropdownMenuItem(value: 'km', child: Text('KM')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMileageUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes (optional)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional information (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              maxLength: 500,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveVehicle,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Required fields note
            const Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(vehicleRepositoryProvider);

      final double? mileage = _mileageController.text.isNotEmpty
          ? double.tryParse(_mileageController.text)
          : null;

      if (widget.vehicle != null) {
        // Update existing vehicle
        final updated = widget.vehicle!.copyWith(
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          vin: _vinController.text.trim().isNotEmpty ? _vinController.text.trim() : null,
          licensePlate: _licensePlateController.text.trim().isNotEmpty
              ? _licensePlateController.text.trim()
              : null,
          currentMileage: mileage,
          mileageUnit: _selectedMileageUnit,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        await repository.updateVehicle(updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle updated successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new vehicle
        final vehicle = Vehicle.create(
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          vin: _vinController.text.trim().isNotEmpty ? _vinController.text.trim() : null,
          licensePlate: _licensePlateController.text.trim().isNotEmpty
              ? _licensePlateController.text.trim()
              : null,
          currentMileage: mileage,
          mileageUnit: _selectedMileageUnit,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        await repository.addVehicle(vehicle);

        // Refresh vehicles list
        ref.invalidate(vehiclesStreamProvider);
        ref.invalidate(vehicleCountProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle added successfully')),
          );
          Navigator.of(context).pop();
        }
      }
    } on RepositoryException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
