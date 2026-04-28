import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'consent_request_screen.dart';
import 'data_marketplace_screen.dart';
import 'identity_wallet_screen.dart';
import 'prism_shield_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const IdentityWalletScreen(),
    const ConsentRequestScreen(),
    const DataMarketplaceScreen(),
    const PrismShieldScreen(),
  ];

  int _clampIndex(int index) {
    if (_screens.isEmpty) return 0;
    if (index < 0) return 0;
    if (index >= _screens.length) return _screens.length - 1;
    return index;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _clampIndex(widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _clampIndex(_currentIndex),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = _clampIndex(index);
          });
        },
      ),
    );
  }
}
