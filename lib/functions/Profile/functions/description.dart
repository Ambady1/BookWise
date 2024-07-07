import 'package:flutter/material.dart';

List<Widget> _buildDescription(String description) {
  return description.split('\n').map((line) {
    return Text(
      line,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    );
  }).toList();
}
