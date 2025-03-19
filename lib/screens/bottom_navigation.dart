// import 'package:flutter/material.dart';
// import 'package:savesmart/screens/add_expense.dart';
// import 'package:savesmart/screens/group/group_list_screen.dart';
// import 'package:savesmart/screens/home_screen.dart';
// import 'package:savesmart/screens/profile_screen.dart';
// import 'package:savesmart/screens/statistics_screen.dart';

// class Bottom extends StatefulWidget {
//   const Bottom({Key? key}) : super(key: key);

//   @override
//   State<Bottom> createState() => _BottomState();
// }

// class _BottomState extends State<Bottom> {
//   int _selectedIndex = 0;
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const StatisticsScreen(),
//     const GroupListScreen(),
//     const ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
//           );
//         },
//         backgroundColor: const Color(0xff368983),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(0, Icons.home, 'Home'),
//               _buildNavItem(1, Icons.bar_chart, 'Stats'),
//               const SizedBox(width: 20), // Space for FAB
//               _buildNavItem(2, Icons.group, 'Groups'),
//               _buildNavItem(3, Icons.person, 'Profile'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, IconData icon, String label) {
//     final isSelected = _selectedIndex == index;
//     return InkWell(
//       onTap: () => setState(() => _selectedIndex = index),
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? const Color(0xff368983) : Colors.grey,
//               size: 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: isSelected ? const Color(0xff368983) : Colors.grey,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:savesmart/screens/add_expense.dart';
import 'package:savesmart/screens/group/group_list_screen.dart';
import 'package:savesmart/screens/home_screen.dart';
import 'package:savesmart/screens/profile_screen.dart';
import 'package:savesmart/screens/statistics_screen.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  // ignore: non_constant_identifier_names
  int index_color = 0;
  // ignore: non_constant_identifier_names
  List Screen = [Home(), Statistics(), GroupListScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Screen[index_color],
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) =>AddExpenseScreen()));
        },
        backgroundColor: Color(0xff368983),
        child: Icon(Icons.add,color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 1.5,
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 0;
                  });
                },
                child: Icon(
                  Icons.home,
                  size: 30,
                  color: index_color == 0 ? Color(0xff368983) : Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 1;
                  });
                },
                child: Icon(
                  Icons.bar_chart_outlined,
                  size: 30,
                  color: index_color == 1 ? Color(0xff368983) : Colors.grey,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 2;
                  });
                },
                child: Icon(
                  Icons.group_outlined,
                  size: 30,
                  color: index_color == 2 ? Color(0xff368983) : Colors.grey,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index_color = 3;
                  });
                },
                child: Icon(
                  Icons.person_outlined,
                  size: 30,
                  color: index_color == 3 ? Color(0xff368983) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

