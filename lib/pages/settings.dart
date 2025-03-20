import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../widgets/earth_widget.dart';
import 'learn_pathway.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: PathwayUI(grade: 8, subject: "math")
    );
  }
}
