import 'package:flutter/material.dart';

class ReflectionInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ReflectionInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 3,
      maxLines: 5,
      textInputAction:
          TextInputAction.newline,
      decoration: InputDecoration(
        hintText:
            'What did you learn today?',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
      ),
    );
  }
}