import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/add_date.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? groupId;
  final Add_data? expenseToEdit;  
  final int? expenseKey;       

  const AddExpenseScreen({
    Key? key,
    this.groupId,
    this.expenseToEdit,
    this.expenseKey,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final Box<Add_data> box;
  late DateTime date;
  late String? selectedCategory;
  late String? selectedType;
  late TextEditingController explainController;
  late TextEditingController amountController;
  bool isEditing = false;

  final List<String> categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Education',
  ];

  final List<String> types = ['Income', 'Expense'];

  final Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transportation': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Education': Icons.shopping_bag,
  };

  @override
  void initState() {
    super.initState();
    box = Hive.box<Add_data>('data');
    isEditing = widget.expenseToEdit != null;

    // Initialize with existing expense data if editing
    date = isEditing ? widget.expenseToEdit!.datetime : DateTime.now();
    selectedCategory = isEditing ? widget.expenseToEdit!.name : null;
    selectedType = isEditing ? widget.expenseToEdit!.IN : null;
    explainController = TextEditingController(
      text: isEditing ? widget.expenseToEdit!.explain : '',
    );
    amountController = TextEditingController(
      text: isEditing ? widget.expenseToEdit!.amount : '',
    );
  }

  @override
  void dispose() {
    explainController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _saveOrUpdateExpense() {
    if (selectedCategory == null || 
        selectedType == null || 
        amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final expense = Add_data(
      selectedType!,
      amountController.text,
      date,
      explainController.text.isEmpty ? 'No description' : explainController.text,
      selectedCategory!,
      groupId: widget.groupId,
    );

    if (isEditing && widget.expenseKey != null) {
      // Update existing expense
      box.put(widget.expenseKey, expense);
    } else {
      // Add new expense
      box.add(expense);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isEditing 
              ? 'Edit ${widget.groupId != null ? 'Group ' : ''}Expense'
              : 'Add ${widget.groupId != null ? 'Group ' : ''}Expense',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                child: _buildTypeSelector(),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: _buildAmountField(),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: _buildCategorySelector(),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: _buildDescriptionField(),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: _buildDatePicker(),
              ),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: types.map((type) {
            final isSelected = selectedType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedType = type),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (type == 'Income' ? Colors.green[50] : Colors.red[50])
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? (type == 'Income' ? Colors.green : Colors.red)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type == 'Income' ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 20,
                        color: isSelected 
                            ? (type == 'Income' ? Colors.green : Colors.red)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type,
                        style: TextStyle(
                          color: isSelected 
                              ? (type == 'Income' ? Colors.green : Colors.red)
                              : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.currency_rupee, color: Colors.grey),
            hintText: '0.00',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Select Category'),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  Icon(categoryIcons[category], size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(category),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedCategory = value),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: explainController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a description...',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xff368983),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              setState(() => date = selectedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xff368983)),
                const SizedBox(width: 12),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveOrUpdateExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff368983),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isEditing ? 'Update' : 'Save',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

}