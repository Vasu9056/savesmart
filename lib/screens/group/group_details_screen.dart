import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/add_date.dart';
import 'package:savesmart/data/models/group.dart';
import 'package:savesmart/screens/add_expense.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final groupBox = Hive.box<Group>('groups');
  final expenseBox = Hive.box<Add_data>('data');
  late Group group;
  bool isLoading = true;
  List<Add_data> groupExpenses = [];
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGroupData();
  }

  void _loadGroupData() {
    try {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final groupId = args['groupId'] as String;
      
      // Find the group with the matching ID
      for (var i = 0; i < groupBox.length; i++) {
        final Group? currentGroup = groupBox.getAt(i);
        if (currentGroup != null && currentGroup.id == groupId) {
          group = currentGroup;
          _loadGroupExpenses(groupId);
          setState(() {
            isLoading = false;
          });
          return;
        }
      }
      
      // Group not found
      setState(() {
        isLoading = false;
      });
      
      // Show error and navigate back if group not found
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group not found'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    } catch (e) {
      // Handle any errors
      setState(() {
        isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading group: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }
  
  void _loadGroupExpenses(String groupId) {
    groupExpenses = [];
    
    // Get all expenses with this groupId
    for (var i = 0; i < expenseBox.length; i++) {
      final Add_data? expense = expenseBox.getAt(i);
      if (expense != null && expense.groupId == groupId) {
        groupExpenses.add(expense);
      }
    }
    
    // Sort expenses by date (newest first)
    groupExpenses.sort((a, b) => b.datetime.compareTo(a.datetime));
  }
  
  void _addExpenseToGroup() async {
    // Navigate to Add screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Add_Screen(groupId: group.id),
      ),
    );
    
    if (result == true) {
      // If expense was added, refresh the expense list
      _loadGroupExpenses(group.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          group.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildGroupInfoCard(),
          const SizedBox(height: 16),
          _buildExpensesHeader(),
          Expanded(
            child: _buildExpensesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpenseToGroup,
        backgroundColor: const Color(0xff368983),
        child: const Icon(Icons.add, color: Colors.white),
        heroTag: 'groupDetailsFab', // Add a unique hero tag
      ),
    );
  }
  
  Widget _buildGroupInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff368983),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${group.memberCount} members",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Members:",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.memberNames.map((member) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Created on: ${group.createdDate.day}/${group.createdDate.month}/${group.createdDate.year}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpensesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Group Expenses",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${groupExpenses.length} ${groupExpenses.length == 1 ? 'expense' : 'expenses'}",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpensesList() {
    if (groupExpenses.isEmpty) {
      return const Center(
        child: Text(
          "No expenses yet. Add one!",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupExpenses.length,
      itemBuilder: (context, index) {
        final expense = groupExpenses[index];
        return _buildExpenseItem(expense);
      },
    );
  }
  
  Widget _buildExpenseItem(Add_data expense) {
    return Dismissible(
      key: Key(expense.key.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        expense.delete();
        setState(() {
          groupExpenses.remove(expense);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted'),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: expense.IN == "Income" ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              expense.IN == "Income" ? Icons.arrow_upward : Icons.arrow_downward,
              color: expense.IN == "Income" ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            expense.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            expense.explain,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹ ${expense.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: expense.IN == 'Income' ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${expense.datetime.day}/${expense.datetime.month}/${expense.datetime.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

