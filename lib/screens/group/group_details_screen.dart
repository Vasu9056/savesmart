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

      for (var i = 0; i < groupBox.length; i++) {
        final Group? currentGroup = groupBox.getAt(i);
        if (currentGroup != null && currentGroup.id == groupId) {
          group = currentGroup;
          _loadGroupExpenses(groupId);
          setState(() => isLoading = false);
          return;
        }
      }

      setState(() => isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group not found'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() => isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading group: $e'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      });
    }
  }

  void _loadGroupExpenses(String groupId) {
    groupExpenses = expenseBox.values
        .where((expense) => expense.groupId == groupId)
        .toList()
      ..sort((a, b) => b.datetime.compareTo(a.datetime));
  }

  void _addExpenseToGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpenseScreen(groupId: group.id)),
    );
    if (result == true) {
      _loadGroupExpenses(group.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          group.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupInfoCard(),
            const SizedBox(height: 16),
            _buildExpensesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpenseToGroup,
        backgroundColor: const Color(0xff368983),
        heroTag: 'groupDetailsFab_${group.id}',
        child: const Icon(Icons.add, color: Colors.white), // Enhanced unique hero tag
      ),
    );
  }

  Widget _buildGroupInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2)),
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Chip(
                label: Text("${group.memberCount} members"),
                backgroundColor: const Color(0xff368983).withOpacity(0.1),
                labelStyle: const TextStyle(color: Color(0xff368983), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Members", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: group.memberNames.map((member) => Chip(
              label: Text(member),
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(color: Colors.grey[800], fontSize: 12),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            "Created on: ${group.createdDate.day}/${group.createdDate.month}/${group.createdDate.year}",
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Group Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "${groupExpenses.length} ${groupExpenses.length == 1 ? 'expense' : 'expenses'}",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          groupExpenses.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "No expenses yet. Add one!",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupExpenses.length,
                  itemBuilder: (context, index) => _buildExpenseItem(groupExpenses[index]),
                ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Add_data expense) {
    return Dismissible(
      key: Key(expense.key.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        expense.delete();
        setState(() => groupExpenses.remove(expense));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: expense.IN == "Income" ? Colors.green[50] : Colors.red[50],
            child: Icon(
              expense.IN == "Income" ? Icons.arrow_upward : Icons.arrow_downward,
              color: expense.IN == "Income" ? Colors.green : Colors.red,
            ),
          ),
          title: Text(expense.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(expense.explain, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${expense.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: expense.IN == 'Income' ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${expense.datetime.day}/${expense.datetime.month}/${expense.datetime.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}