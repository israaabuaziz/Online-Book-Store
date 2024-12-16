import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Birthday extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const Birthday({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<Birthday> createState() => _BirthdayState();
}

class _BirthdayState extends State<Birthday> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DateTimeField(
          format: DateFormat('yyyy-MM-dd'),
          initialValue: _selectedDate,
          decoration: InputDecoration(
            labelText: 'Birth Date',
            labelStyle: const TextStyle(
              fontFamily: 'boahmed',
              color: Color(0xff8042E1),
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xff8042E1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xff8042E1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Color(0xff8042E1),
                width: 2.0,
              ),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
          ),
          onShowPicker: (context, currentValue) async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            }
            return date;
          },
        ),
      ),
    );
  }
}