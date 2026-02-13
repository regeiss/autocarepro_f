import 'package:floor/floor.dart';
import 'package:uuid/uuid.dart';
import 'vehicle_model.dart';

/// Schedules maintenance reminders based on time or mileage
@Entity(
  tableName: 'reminders',
  foreignKeys: [
    ForeignKey(
      childColumns: ['vehicleId'],
      parentColumns: ['id'],
      entity: Vehicle,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [
    Index(value: ['vehicleId']),
    Index(value: ['isActive']),
  ],
)
class Reminder {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'vehicleId')
  final String vehicleId;

  final String serviceType;
  final String reminderType; // 'time' or 'mileage'
  final int intervalValue;
  final String intervalUnit; // 'days', 'months', 'miles', 'km'
  final int? lastServiceDate; // Stored as milliseconds since epoch
  final double? lastServiceMileage;
  final int? nextReminderDate; // Stored as milliseconds since epoch
  final double? nextReminderMileage;
  final bool isActive;
  final int notifyBefore; // Days or miles before to notify
  final int createdAt; // Stored as milliseconds since epoch
  final int updatedAt; // Stored as milliseconds since epoch

  Reminder({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.reminderType,
    required this.intervalValue,
    required this.intervalUnit,
    this.lastServiceDate,
    this.lastServiceMileage,
    this.nextReminderDate,
    this.nextReminderMileage,
    this.isActive = true,
    this.notifyBefore = 7, // Default 7 days or miles
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating new reminders
  factory Reminder.create({
    required String vehicleId,
    required String serviceType,
    required ReminderType reminderType,
    required int intervalValue,
    required IntervalUnit intervalUnit,
    DateTime? lastServiceDate,
    double? lastServiceMileage,
    bool isActive = true,
    int notifyBefore = 7,
  }) {
    final now = DateTime.now();

    // Calculate next reminder
    DateTime? nextDate;
    double? nextMileage;

    if (reminderType == ReminderType.time) {
      final startDate = lastServiceDate ?? now;
      nextDate = _calculateNextDate(startDate, intervalValue, intervalUnit);
    } else if (reminderType == ReminderType.mileage) {
      if (lastServiceMileage != null) {
        nextMileage = lastServiceMileage + intervalValue.toDouble();
      }
    }

    return Reminder(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      serviceType: serviceType,
      reminderType: reminderType.value,
      intervalValue: intervalValue,
      intervalUnit: intervalUnit.value,
      lastServiceDate: lastServiceDate?.millisecondsSinceEpoch,
      lastServiceMileage: lastServiceMileage,
      nextReminderDate: nextDate?.millisecondsSinceEpoch,
      nextReminderMileage: nextMileage,
      isActive: isActive,
      notifyBefore: notifyBefore,
      createdAt: now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );
  }

  /// Calculate next date based on interval
  static DateTime _calculateNextDate(
    DateTime startDate,
    int intervalValue,
    IntervalUnit intervalUnit,
  ) {
    switch (intervalUnit) {
      case IntervalUnit.days:
        return startDate.add(Duration(days: intervalValue));
      case IntervalUnit.months:
        return DateTime(
          startDate.year,
          startDate.month + intervalValue,
          startDate.day,
        );
      case IntervalUnit.years:
        return DateTime(
          startDate.year + intervalValue,
          startDate.month,
          startDate.day,
        );
      default:
        return startDate.add(Duration(days: intervalValue));
    }
  }

  /// Copy with method for updates
  Reminder copyWith({
    String? serviceType,
    String? reminderType,
    int? intervalValue,
    String? intervalUnit,
    DateTime? lastServiceDate,
    double? lastServiceMileage,
    DateTime? nextReminderDate,
    double? nextReminderMileage,
    bool? isActive,
    int? notifyBefore,
  }) {
    return Reminder(
      id: id,
      vehicleId: vehicleId,
      serviceType: serviceType ?? this.serviceType,
      reminderType: reminderType ?? this.reminderType,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      lastServiceDate:
          lastServiceDate?.millisecondsSinceEpoch ?? this.lastServiceDate,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
      nextReminderDate:
          nextReminderDate?.millisecondsSinceEpoch ?? this.nextReminderDate,
      nextReminderMileage: nextReminderMileage ?? this.nextReminderMileage,
      isActive: isActive ?? this.isActive,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get last service date as DateTime
  DateTime? get lastServiceDateAsDateTime {
    return lastServiceDate != null
        ? DateTime.fromMillisecondsSinceEpoch(lastServiceDate!)
        : null;
  }

  /// Get next reminder date as DateTime
  DateTime? get nextReminderDateAsDateTime {
    return nextReminderDate != null
        ? DateTime.fromMillisecondsSinceEpoch(nextReminderDate!)
        : null;
  }

  /// Get created date as DateTime
  DateTime get createdAtAsDateTime {
    return DateTime.fromMillisecondsSinceEpoch(createdAt);
  }

  /// Get updated date as DateTime
  DateTime get updatedAtAsDateTime {
    return DateTime.fromMillisecondsSinceEpoch(updatedAt);
  }

  /// Check if reminder is due (for time-based)
  bool get isDue {
    if (!isActive) return false;

    if (reminderType == 'time' && nextReminderDate != null) {
      return DateTime.now().isAfter(nextReminderDateAsDateTime!);
    }

    // Mileage-based requires current vehicle mileage to check
    return false;
  }

  /// Check if reminder is overdue (for time-based)
  bool isOverdue() {
    if (!isActive) return false;

    if (reminderType == 'time' && nextReminderDate != null) {
      return DateTime.now().isAfter(nextReminderDateAsDateTime!);
    }

    // Mileage-based requires current vehicle mileage to check
    return false;
  }

  /// Check if reminder is due soon (within notifyBefore threshold)
  bool isDueSoon() {
    if (!isActive) return false;

    if (reminderType == 'time' && nextReminderDate != null) {
      final notifyDate = nextReminderDateAsDateTime!.subtract(Duration(days: notifyBefore));
      return DateTime.now().isAfter(notifyDate) && DateTime.now().isBefore(nextReminderDateAsDateTime!);
    }

    // Mileage-based requires current vehicle mileage to check
    return false;
  }

  /// Check if reminder is due (for mileage-based)
  bool isDueMileage(double currentMileage) {
    if (!isActive) return false;

    if (reminderType == 'mileage' && nextReminderMileage != null) {
      return currentMileage >= nextReminderMileage!;
    }

    return false;
  }

  /// Check if should notify soon (within notifyBefore threshold)
  bool get shouldNotifySoon {
    if (!isActive) return false;

    if (reminderType == 'time' && nextReminderDate != null) {
      final notifyDate = nextReminderDateAsDateTime!
          .subtract(Duration(days: notifyBefore));
      return DateTime.now().isAfter(notifyDate) &&
          DateTime.now().isBefore(nextReminderDateAsDateTime!);
    }

    return false;
  }

  /// Check if should notify soon (for mileage)
  bool shouldNotifySoonMileage(double currentMileage) {
    if (!isActive) return false;

    if (reminderType == 'mileage' && nextReminderMileage != null) {
      final notifyMileage = nextReminderMileage! - notifyBefore;
      return currentMileage >= notifyMileage &&
          currentMileage < nextReminderMileage!;
    }

    return false;
  }

  /// Calculate days until due (negative if overdue)
  int? get daysUntilDue {
    if (nextReminderDate == null) return null;
    return nextReminderDateAsDateTime!.difference(DateTime.now()).inDays;
  }

  /// Calculate mileage until due
  double? milesUntilDue(double currentMileage) {
    if (nextReminderMileage == null) return null;
    return nextReminderMileage! - currentMileage;
  }

  /// Update reminder after service completion
  Reminder updateAfterService({
    required DateTime serviceDate,
    double? serviceMileage,
  }) {
    DateTime? newNextDate;
    double? newNextMileage;

    if (reminderType == 'time') {
      newNextDate = _calculateNextDate(
        serviceDate,
        intervalValue,
        IntervalUnit.fromValue(intervalUnit),
      );
    }

    if (reminderType == 'mileage' && serviceMileage != null) {
      newNextMileage = serviceMileage + intervalValue;
    }

    return copyWith(
      lastServiceDate: serviceDate,
      lastServiceMileage: serviceMileage,
      nextReminderDate: newNextDate,
      nextReminderMileage: newNextMileage,
    );
  }

  /// Validation
  String? validate() {
    if (vehicleId.trim().isEmpty) return 'Vehicle ID is required';
    if (serviceType.trim().isEmpty) return 'Service type is required';
    if (reminderType != 'time' && reminderType != 'mileage') {
      return 'Reminder type must be either "time" or "mileage"';
    }
    if (intervalValue <= 0) return 'Interval value must be positive';
    if (notifyBefore < 0) return 'Notify before cannot be negative';

    if (reminderType == 'time') {
      if (intervalUnit != 'days' &&
          intervalUnit != 'months' &&
          intervalUnit != 'years') {
        return 'Invalid interval unit for time-based reminder';
      }
    } else if (reminderType == 'mileage') {
      if (intervalUnit != 'miles' && intervalUnit != 'km') {
        return 'Invalid interval unit for mileage-based reminder';
      }
    }

    return null;
  }

  @override
  String toString() {
    if (reminderType == 'time') {
      return 'Reminder(type: $serviceType, every: $intervalValue $intervalUnit, next: ${nextReminderDateAsDateTime?.toString().split(' ')[0]})';
    } else {
      return 'Reminder(type: $serviceType, every: $intervalValue $intervalUnit, next: $nextReminderMileage)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Reminder type enum
enum ReminderType {
  time('time', 'Time-Based'),
  mileage('mileage', 'Mileage-Based');

  const ReminderType(this.value, this.displayName);
  final String value;
  final String displayName;

  static ReminderType fromValue(String value) {
    return ReminderType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReminderType.time,
    );
  }
}

/// Interval unit enum
enum IntervalUnit {
  days('days', 'Days'),
  months('months', 'Months'),
  years('years', 'Years'),
  miles('miles', 'Miles'),
  kilometers('km', 'Kilometers');

  const IntervalUnit(this.value, this.displayName);
  final String value;
  final String displayName;

  static IntervalUnit fromValue(String value) {
    return IntervalUnit.values.firstWhere(
      (unit) => unit.value == value,
      orElse: () => IntervalUnit.days,
    );
  }

  bool get isTime => this == days || this == months || this == years;
  bool get isMileage => this == miles || this == kilometers;
}
