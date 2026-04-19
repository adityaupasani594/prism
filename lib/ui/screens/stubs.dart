import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class DataMarketplaceScreen extends StatelessWidget {
  const DataMarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Marketplace')),
      body: const Center(
        child: Text('Data Marketplace: Coming Soon'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings: Coming Soon'),
      ),
    );
  }
}
