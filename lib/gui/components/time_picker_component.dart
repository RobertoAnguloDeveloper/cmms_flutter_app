// 📂 lib/gui/components/time_picker_component.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

enum TimePickerMode {
  digital,
  analog,
  spinner
}

enum TimeFormat {
  h12,  // 12-hour format with AM/PM
  h24   // 24-hour format
}

class TimePickerComponent extends StatefulWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final TimePickerMode mode;
  final TimeFormat format;
  final bool showSeconds;
  final bool enabled;
  final String? label;
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;

  const TimePickerComponent({
    super.key,
    this.initialTime,
    this.onTimeChanged,
    this.mode = TimePickerMode.digital,
    this.format = TimeFormat.h24,
    this.showSeconds = false,
    this.enabled = true,
    this.label,
    this.minTime,
    this.maxTime,
  });

  @override
  State<TimePickerComponent> createState() => _TimePickerComponentState();
}

class _TimePickerComponentState extends State<TimePickerComponent> {
  late TimeOfDay _selectedTime;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  bool _isTimeInRange(TimeOfDay time) {
    if (widget.minTime == null && widget.maxTime == null) return true;

    final currentMinutes = time.hour * 60 + time.minute;
    final minMinutes = widget.minTime?.hour ?? 0 * 60 + (widget.minTime?.minute ?? 0);
    final maxMinutes = widget.maxTime?.hour ?? 23 * 60 + (widget.maxTime?.minute ?? 59);

    return currentMinutes >= minMinutes && currentMinutes <= maxMinutes;
  }

  void _updateTime(TimeOfDay newTime) {
    if (!_isTimeInRange(newTime)) return;

    setState(() {
      _selectedTime = newTime;
    });
    widget.onTimeChanged?.call(newTime);
  }

  Widget _buildDigitalPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hours
        _TimeSpinner(
          value: widget.format == TimeFormat.h12
              ? _convert24To12Hour(_selectedTime.hour)
              : _selectedTime.hour,
          minValue: widget.format == TimeFormat.h12 ? 1 : 0,
          maxValue: widget.format == TimeFormat.h12 ? 12 : 23,
          onChanged: widget.enabled ? (value) {
            final newHour = widget.format == TimeFormat.h12
                ? value + (_selectedTime.period == DayPeriod.pm ? 12 : 0)
                : value;
            _updateTime(TimeOfDay(hour: newHour, minute: _selectedTime.minute));
          } : null,
        ),

        Text(':', style: Theme.of(context).textTheme.headlineMedium),

        // Minutes
        _TimeSpinner(
          value: _selectedTime.minute,
          minValue: 0,
          maxValue: 59,
          onChanged: widget.enabled ? (value) {
            _updateTime(TimeOfDay(hour: _selectedTime.hour, minute: value));
          } : null,
          showLeadingZero: true,
        ),

        // Optional seconds
        if (widget.showSeconds) ...[
          Text(':', style: Theme.of(context).textTheme.headlineMedium),
          _TimeSpinner(
            value: _seconds,
            minValue: 0,
            maxValue: 59,
            onChanged: widget.enabled ? (value) {
              setState(() => _seconds = value);
            } : null,
            showLeadingZero: true,
          ),
        ],

        // AM/PM for 12-hour format
        if (widget.format == TimeFormat.h12) ...[
          const SizedBox(width: AppSpacing.md),
          _AmPmSelector(
            period: _selectedTime.period,
            onChanged: widget.enabled ? (period) {
              final currentHour = _convert24To12Hour(_selectedTime.hour);
              final hour = period == DayPeriod.pm && currentHour != 12
                  ? currentHour + 12
                  : (period == DayPeriod.am && currentHour == 12 ? 0 : currentHour);
              _updateTime(TimeOfDay(hour: hour, minute: _selectedTime.minute));
            } : null,
          ),
        ],
      ],
    );
  }

  Widget _buildAnalogPicker() {
    return InkWell(
      onTap: widget.enabled ? () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: widget.format == TimeFormat.h24,
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          _updateTime(time);
        }
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              color: widget.enabled
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _formatTime(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: widget.enabled
                    ? null
                    : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _convert24To12Hour(int hour24) {
    if (hour24 == 0) return 12; // Midnight
    if (hour24 > 12) return hour24 - 12;
    return hour24;
  }

  String _formatTime() {
    final hour = widget.format == TimeFormat.h12
        ? _convert24To12Hour(_selectedTime.hour)
        : _selectedTime.hour;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final seconds = widget.showSeconds
        ? ':${_seconds.toString().padLeft(2, '0')}'
        : '';
    final period = widget.format == TimeFormat.h12
        ? ' ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}'
        : '';

    return '$hour:$minute$seconds$period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        widget.mode == TimePickerMode.analog
            ? _buildAnalogPicker()
            : _buildDigitalPicker(),
      ],
    );
  }
}

class _TimeSpinner extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int>? onChanged;
  final bool showLeadingZero;

  const _TimeSpinner({
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.onChanged,
    this.showLeadingZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_drop_up),
            onPressed: onChanged == null ? null : () {
              final newValue = value >= maxValue ? minValue : value + 1;
              onChanged?.call(newValue);
            },
          ),
          Text(
            showLeadingZero ? value.toString().padLeft(2, '0') : value.toString(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: onChanged == null ? null : () {
              final newValue = value <= minValue ? maxValue : value - 1;
              onChanged?.call(newValue);
            },
          ),
        ],
      ),
    );
  }
}

class _AmPmSelector extends StatelessWidget {
  final DayPeriod period;
  final ValueChanged<DayPeriod>? onChanged;

  const _AmPmSelector({
    required this.period,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AmPmButton(
          text: 'AM',
          isSelected: period == DayPeriod.am,
          onPressed: onChanged == null ? null : () {
            onChanged?.call(DayPeriod.am);
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        _AmPmButton(
          text: 'PM',
          isSelected: period == DayPeriod.pm,
          onPressed: onChanged == null ? null : () {
            onChanged?.call(DayPeriod.pm);
          },
        ),
      ],
    );
  }
}

class _AmPmButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _AmPmButton({
    required this.text,
    required this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        backgroundColor: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : null,
        foregroundColor: isSelected
            ? theme.colorScheme.primary
            : theme.textTheme.bodyMedium?.color,
      ),
      child: Text(text),
    );
  }
}