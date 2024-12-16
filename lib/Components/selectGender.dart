import 'package:flutter/material.dart';

class Selectgender extends StatelessWidget {
  String title;
  List<String> options;
  String groupValue;
   void Function(String?) onChanged;
   Selectgender({super.key,required this.title,required this.options,required this.groupValue,required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return
       Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'boahmed',
                  color: Color(0xff8042E1),
                  fontSize: 16,
                ),
              ),
              Row(
                children: options.map((String option) {
                  return Expanded(
                    child: RadioListTile<String>(
                      title: Text(
                        option,
                        style: const TextStyle(
                          fontFamily: 'boahmed',
                          color: Color(0xff8042E1),
                          fontSize: 16,
                        ),
                      ),
                      value: option,
                      groupValue: groupValue,
                      onChanged: onChanged,
                      activeColor: const Color(0xff8042E1),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );

  }
}
