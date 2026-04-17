import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Custom dialog showing both date and time pickers in one interface
class CombinedDateTimePickerDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime startDate;
  final DateTime endDate;

  const CombinedDateTimePickerDialog({
    Key? key,
    required this.initialDateTime,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<CombinedDateTimePickerDialog> createState() =>
      _CombinedDateTimePickerDialogState();
}

class _CombinedDateTimePickerDialogState
    extends State<CombinedDateTimePickerDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'Set Date & Time',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Date Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SizedBox(
                        height: 350,
                        child: CalendarDatePicker(
                          initialDate: _selectedDate,
                          firstDate: widget.startDate,
                          lastDate: widget.endDate,
                          onDateChanged: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Time Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours
                        Column(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 150,
                              child: ListWheelScrollView(
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedTime = _selectedTime.replacing(
                                      hour: index,
                                    );
                                  });
                                },
                                children: List.generate(
                                  24,
                                  (index) => Center(
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: index == _selectedTime.hour
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Hour'),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Minutes
                        Column(
                          children: [
                            SizedBox(
                              width: 70,
                              height: 150,
                              child: ListWheelScrollView(
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedTime = _selectedTime.replacing(
                                      minute: index * 5, // 5-minute increments
                                    );
                                  });
                                },
                                children: List.generate(
                                  12,
                                  (index) {
                                    final minute = index * 5;
                                    return Center(
                                      child: Text(
                                        minute.toString().padLeft(2, '0'),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: minute == _selectedTime.minute
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Minute'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Display selected date and time
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${DateFormat('dd.MM.yyyy').format(_selectedDate)} at ${_selectedTime.format(context)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final finalDateTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );
                      Navigator.pop(context, finalDateTime);
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
