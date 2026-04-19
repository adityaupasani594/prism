// import 'package:flutter/material.dart';
// import '../widgets/top_app_bar.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../widgets/power_button.dart';
// import '../../theme/colors.dart';
//
// class BusinessDashboardScreen extends StatefulWidget {
//   const BusinessDashboardScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
// }
//
// class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBody: true,
//       appBar: const TopAppBar(title: 'Business Hub'),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Dashboard',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             const SizedBox(height: 32),
//             Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 gradient: PrismColors.powerGradient,
//                 borderRadius: BorderRadius.circular(32),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'TOTAL BALANCE',
//                     style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$124,500.00',
//                     style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             PowerButton(
//               text: 'View Analytics',
//               isPrimary: false,
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
