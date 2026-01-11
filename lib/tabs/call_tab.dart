import 'package:flutter/material.dart';

class CallTab extends StatefulWidget {
  const CallTab({super.key});

  @override
  State<CallTab> createState() => _CallTabState();
}

class _CallTabState extends State<CallTab> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Call Tab'),
      ),
    );
  }
}