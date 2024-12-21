// 📂 lib/gui/components/calendar_component.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

class CalendarComponent extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showTimePicker;
  final ValueChanged<DateTime>? onDateSelected;
  final bool highlightToday;
  final Color? highlightColor;
  final Map<DateTime, String>? markedDates;

  const CalendarComponent({
    super.key,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    this.showTimePicker = false,
    this.onDateSelected,
    this.highlightToday = true,
    this.highlightColor,
    this.markedDates,
  });

  @override
  State<CalendarComponent> createState() => _CalendarComponentState();
}

class _CalendarComponentState extends State<CalendarComponent> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
  }

  void _updateSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    });
    widget.onDateSelected?.call(_selectedDate);
  }

  void _updateSelectedTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        time.hour,
        time.minute,
      );
    });
    widget.onDateSelected?.call(_selectedDate);
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
          },
        ),
        Text(
          '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _WeekdayLabel('Sun'),
          _WeekdayLabel('Mon'),
          _WeekdayLabel('Tue'),
          _WeekdayLabel('Wed'),
          _WeekdayLabel('Thu'),
          _WeekdayLabel('Fri'),
          _WeekdayLabel('Sat'),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final leadingDays = (firstWeekday + 6) % 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: leadingDays + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingDays) {
          return const SizedBox();
        }

        final day = index - leadingDays + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);

        return _CalendarDay(
          date: date,
          isSelected: date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day,
          isToday: widget.highlightToday && _isToday(date),
          highlightColor: widget.highlightColor,
          isMarked: widget.markedDates?.containsKey(date) ?? false,
          markerText: widget.markedDates?[date],
          onTap: () => _updateSelectedDate(date),
        );
      },
    );
  }

  Widget _buildTimePicker() {
    if (!widget.showTimePicker) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: InkWell(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _selectedTime,
          );
          if (time != null) {
            _updateSelectedTime(time);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _selectedTime.format(context),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildWeekdayHeader(),
        _buildCalendarGrid(),
        _buildTimePicker(),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final Color? highlightColor;
  final bool isMarked;
  final String? markerText;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.date,
    required this.isSelected,
    required this.isToday,
    this.highlightColor,
    this.isMarked = false,
    this.markerText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? (highlightColor ?? theme.primaryColor).withOpacity(0.1)
              : null,
          border: isToday
              ? Border.all(
            color: highlightColor ?? theme.primaryColor,
            width: 1,
          )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              date.day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? highlightColor ?? theme.primaryColor
                    : null,
                fontWeight: isSelected || isToday
                    ? FontWeight.bold
                    : null,
              ),
            ),
            if (isMarked)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: highlightColor ?? theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}