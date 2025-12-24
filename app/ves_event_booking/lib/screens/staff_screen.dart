import 'package:flutter/material.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => StaffScreenSate();
}

class StaffScreenSate extends State<StaffScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Staff Screen'));
  }
}
