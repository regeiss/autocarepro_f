// Reminder Form Screen - add/edit reminders
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/repository_providers.dart';

class ReminderFormScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final Reminder? reminder;

  const ReminderFormScreen({
    super.key,
    required this.vehicleId,
    this.reminder,
  });

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _intervalValueController = TextEditingController();
  final _notifyBeforeController = TextEditingController();
  final _lastMileageController = TextEditingController();

  ReminderType _selectedReminderType = ReminderType.time;
  IntervalUnit _selectedIntervalUnit = IntervalUnit.months;
  DateTime? _lastServiceDate;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _loadExistingReminder();
    } else {
      // Set defaults
      _notifyBeforeController.text = '7';
    }
  }

  void _loadExistingReminder() {
    final reminder = widget.reminder!;
    _serviceTypeController.text = reminder.serviceType;
    _intervalValueController.text = reminder.intervalValue.toString();
    _notifyBeforeController.text = reminder.notifyBefore.toString();
    _selectedReminderType = ReminderType.fromValue(reminder.reminderType);
    _selectedIntervalUnit = IntervalUnit.fromValue(reminder.intervalUnit);
    _isActive = reminder.isActive;
    
    if (reminder.lastServiceDate != null) {
      _lastServiceDate = DateTime.fromMillisecondsSinceEpoch(reminder.lastServiceDate!);
    }
    if (reminder.lastServiceMileage != null) {
      _lastMileageController.text = reminder.lastServiceMileage!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _intervalValueController.dispose();
    _notifyBeforeController.dispose();
    _lastMileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'Add Reminder'),
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
            // Service Type
            TextFormField(
              controller: _serviceTypeController,
              decoration: const InputDecoration(
                labelText: 'Service Type',
                hintText: 'e.g., Oil Change',
                prefixIcon: Icon(Icons.build),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a service type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Reminder Type (Time or Mileage)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<ReminderType>(
                            title: const Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20),
                                SizedBox(width: 8),
                                Text('Time-Based'),
                              ],
                            ),
                            value: ReminderType.time,
                            groupValue: _selectedReminderType,
                            onChanged: (value) {
                              setState(() {
                                _selectedReminderType = value!;
                                // Switch to appropriate interval unit
                                if (_selectedIntervalUnit.isMileage) {
                                  _selectedIntervalUnit = IntervalUnit.months;
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<ReminderType>(
                            title: const Row(
                              children: [
                                Icon(Icons.speed, size: 20),
                                SizedBox(width: 8),
                                Text('Mileage-Based'),
                              ],
                            ),
                            value: ReminderType.mileage,
                            groupValue: _selectedReminderType,
                            onChanged: (value) {
                              setState(() {
                                _selectedReminderType = value!;
                                // Switch to appropriate interval unit
                                if (_selectedIntervalUnit.isTime) {
                                  _selectedIntervalUnit = IntervalUnit.miles;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interval
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _intervalValueController,
                    decoration: InputDecoration(
                      labelText: 'Interval',
                      hintText: 'e.g., 6',
                      prefixIcon: Icon(
                        _selectedReminderType == ReminderType.time
                            ? Icons.event_repeat
                            : Icons.straighten,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final interval = int.tryParse(value);
                      if (interval == null || interval <= 0) {
                        return 'Must be > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<IntervalUnit>(
                    value: _selectedIntervalUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: _getIntervalUnitOptions()
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.displayName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedIntervalUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Last Service Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Service (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedReminderType == ReminderType.time) ...[
                      InkWell(
                        onTap: _selectLastServiceDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Last Service Date',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _lastServiceDate != null
                                ? DateFormat.yMMMd().format(_lastServiceDate!)
                                : 'Not set',
                          ),
                        ),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _lastMileageController,
                        decoration: InputDecoration(
                          labelText: 'Last Service Mileage',
                          hintText: 'e.g., 25000',
                          prefixIcon: const Icon(Icons.speed),
                          suffix: Text(_selectedIntervalUnit == IntervalUnit.miles ? 'mi' : 'km'),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notify Before
            TextFormField(
              controller: _notifyBeforeController,
              decoration: InputDecoration(
                labelText: 'Notify Before',
                hintText: 'e.g., 7',
                prefixIcon: const Icon(Icons.notifications_active),
                suffix: Text(_selectedReminderType == ReminderType.time ? 'days' : _selectedIntervalUnit.displayName.toLowerCase()),
                border: const OutlineInputBorder(),
                helperText: 'When to send reminder notification',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final notify = int.tryParse(value);
                if (notify == null || notify < 0) {
                  return 'Must be >= 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Active Status
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Enable notifications for this reminder'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Reminder' : 'Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }

  List<IntervalUnit> _getIntervalUnitOptions() {
    if (_selectedReminderType == ReminderType.time) {
      return [IntervalUnit.days, IntervalUnit.months, IntervalUnit.years];
    } else {
      return [IntervalUnit.miles, IntervalUnit.kilometers];
    }
  }

  Future<void> _selectLastServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastServiceDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(reminderRepositoryProvider);
      final isEditing = widget.reminder != null;

      final reminder = Reminder.create(
        vehicleId: widget.vehicleId,
        serviceType: _serviceTypeController.text.trim(),
        reminderType: _selectedReminderType,
        intervalValue: int.parse(_intervalValueController.text),
        intervalUnit: _selectedIntervalUnit,
        lastServiceDate: _lastServiceDate,
        lastServiceMileage: _lastMileageController.text.isEmpty
            ? null
            : double.parse(_lastMileageController.text),
        isActive: _isActive,
        notifyBefore: int.parse(_notifyBeforeController.text),
      );

      // If editing, preserve the ID and timestamps
      final finalReminder = isEditing
          ? Reminder(
              id: widget.reminder!.id,
              vehicleId: reminder.vehicleId,
              serviceType: reminder.serviceType,
              reminderType: reminder.reminderType,
              intervalValue: reminder.intervalValue,
              intervalUnit: reminder.intervalUnit,
              lastServiceDate: reminder.lastServiceDate,
              lastServiceMileage: reminder.lastServiceMileage,
              nextReminderDate: reminder.nextReminderDate,
              nextReminderMileage: reminder.nextReminderMileage,
              isActive: reminder.isActive,
              notifyBefore: reminder.notifyBefore,
              createdAt: widget.reminder!.createdAt,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            )
          : reminder;

      if (isEditing) {
        await repository.updateReminder(finalReminder);
      } else {
        await repository.addReminder(finalReminder);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Reminder updated' : 'Reminder added'),
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
            content: Text('Failed to save reminder: $e'),
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
        title: const Text('Delete Reminder?'),
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
        final repository = ref.read(reminderRepositoryProvider);
        await repository.deleteReminderById(widget.reminder!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
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
}
