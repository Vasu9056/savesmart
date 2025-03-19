import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:savesmart/data/models/add_date.dart';
import 'package:savesmart/screens/add_expense.dart';
import 'package:savesmart/data/utility.dart'; // Import utility.dart

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final box = Hive.box<Add_data>('data');
  final List<String> day = [
    'Monday',
    "Tuesday",
    "Wednesday",
    "Thursday",
    'Friday',
    'Saturday',
    'Sunday'
  ];

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, value, child) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 340, child: _head())),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transactions History',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/groups'),
                          child: const Text(
                            'See Groups',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final history = box.values.toList()[index];
                      return getList(history, index);
                    },
                    childCount: box.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getList(Add_data history, int index) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        history.delete();
      },
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddExpenseScreen(
                    expenseToEdit: history, groupId: history.groupId)),
          );
          if (result == true) setState(() {});
        },
        child: get(index, history),
      ),
    );
  }

  ListTile get(int index, Add_data history) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset('images/${history.name}.png', height: 40),
      ),
      title: Text(
        history.name,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${day[history.datetime.weekday - 1]} ${history.datetime.year}-${history.datetime.day}-${history.datetime.month.toString().padLeft(2, '0')}',
        style: const TextStyle(fontWeight: FontWeight.w400),
      ),
      trailing: Text(
        '₹${history.amount}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 19,
          color: history.IN == 'Income' ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _head() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: const BoxDecoration(
                color: Color(0xff368983),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 35,
                    left: 340,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        height: 40,
                        width: 40,
                        color: const Color.fromRGBO(250, 250, 250, 0.1),
                        child: const Icon(Icons.notification_add_outlined,
                            size: 30, color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 35, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color.fromARGB(255, 224, 223, 223),
                          ),
                        ),
                        const Text(
                          'Vasu Langdecha',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 140,
          left: 37,
          child: Container(
            height: 170,
            width: 320,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Color.fromRGBO(47, 125, 121, 0.3),
                    offset: Offset(0, 6),
                    blurRadius: 12,
                    spreadRadius: 6)
              ],
              color: const Color.fromARGB(255, 47, 125, 121),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Balance',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white)),
                      Icon(Icons.more_horiz, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        '₹ ${total().toStringAsFixed(2)}', // Using utility.dart total()
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 85, 145, 141),
                            child: Icon(Icons.arrow_downward,
                                color: Colors.white, size: 19),
                          ),
                          SizedBox(width: 7),
                          Text('Income',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color:
                                      Color.fromARGB(255, 216, 216, 216))),
                        ],
                      ),
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: Color.fromARGB(255, 85, 145, 141),
                            child: Icon(Icons.arrow_upward,
                                color: Colors.white, size: 19),
                          ),
                          SizedBox(width: 7),
                          Text('Expenses',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color:
                                      Color.fromARGB(255, 216, 216, 216))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹ ${income().toStringAsFixed(2)}', // Using utility.dart income()
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white)),
                      Text('- ₹ ${(expenses().abs()).toStringAsFixed(2)}', // Using utility.dart expenses()
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}