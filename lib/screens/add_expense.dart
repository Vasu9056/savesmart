// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:savesmart/data/models/add_date.dart';

// class AddExpenseScreen extends StatefulWidget {
//   final String? groupId;
  
//   const AddExpenseScreen({Key? key, this.groupId}) : super(key: key);

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final box = Hive.box<Add_data>('data');
//   DateTime date = DateTime.now();
//   String? selectedCategory;
//   String? selectedType;
//   final TextEditingController explainController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
  
//   final List<String> categories = [
//     'Food',
//     'Transportation',
//     'Entertainment',
//     'Shopping',
//     'Utilities',
//     'Health',
//     'Education',
//     'Travel',
//     'Gifts',
//     'Other',
//   ];
  
//   final List<String> types = [
//     'Income',
//     'Expense',
//   ];
  
//   final Map<String, IconData> categoryIcons = {
//     'Food': Icons.fastfood,
//     'Transportation': Icons.directions_car,
//     'Entertainment': Icons.movie,
//     'Shopping': Icons.shopping_bag,
//     'Utilities': Icons.lightbulb,
//     'Health': Icons.medical_services,
//     'Education': Icons.school,
//     'Travel': Icons.flight,
//     'Gifts': Icons.card_giftcard,
//     'Other': Icons.more_horiz,
//   };

//   @override
//   void dispose() {
//     explainController.dispose();
//     amountController.dispose();
//     super.dispose();
//   }

//   void _saveExpense() {
//     if (selectedCategory == null || 
//         selectedType == null || 
//         amountController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all required fields'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
    
//     // Validate amount is a number
//     if (double.tryParse(amountController.text) == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid amount'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
    
//     final newExpense = Add_data(
//       selectedType!,
//       amountController.text,
//       date,
//       explainController.text.isEmpty ? 'No description' : explainController.text,
//       selectedCategory!,
//       groupId: widget.groupId,
//     );
    
//     box.add(newExpense);
    
//     if (widget.groupId != null) {
//       Navigator.of(context).pop(true);
//     } else {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.groupId != null ? 'Add Group Expense' : 'Add Transaction',
//           style: const TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildTypeSelector(),
//             const SizedBox(height: 24),
//             _buildAmountField(),
//             const SizedBox(height: 24),
//             _buildCategorySelector(),
//             const SizedBox(height: 24),
//             _buildDescriptionField(),
//             const SizedBox(height: 24),
//             _buildDatePicker(),
//             const SizedBox(height: 40),
//             _buildSaveButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTypeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Transaction Type',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: types.map((type) {
//             final isSelected = selectedType == type;
//             final color = type == 'Income' ? Colors.green : Colors.red;
            
//             return Expanded(
//               child: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     selectedType = type;
//                   });
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: isSelected ? color : Colors.grey.shade300,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(
//                         type == 'Income' ? Icons.arrow_upward : Icons.arrow_downward,
//                         color: isSelected ? color : Colors.grey,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         type,
//                         style: TextStyle(
//                           color: isSelected ? color : Colors.grey.shade700,
//                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildAmountField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Amount',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: amountController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             hintText: '0.00',
//             prefixText: '₹ ',
//             prefixStyle: const TextStyle(
//               color: Colors.black,
//               fontSize: 18,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Color(0xff368983), width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategorySelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Category',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: DropdownButton<String>(
//             value: selectedCategory,
//             isExpanded: true,
//             hint: const Text('Select Category'),
//             underline: const SizedBox(),
//             items: categories.map((category) {
//               return DropdownMenuItem<String>(
//                 value: category,
//                 child: Row(
//                   children: [
//                     Icon(
//                       categoryIcons[category] ?? Icons.category,
//                       color: const Color(0xff368983),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(category),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 selectedCategory = value;
//               });
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Description',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: explainController,
//           maxLines: 3,
//           decoration: InputDecoration(
//             hintText: 'Add a description...',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Color(0xff368983), width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDatePicker() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Date',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         InkWell(
//           onTap: () async {
//             final selectedDate = await showDatePicker(
//               context: context,
//               initialDate: date,
//               firstDate: DateTime(2020),
//               lastDate: DateTime.now().add(const Duration(days: 365)),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: const ColorScheme.light(
//                       primary: Color(0xff368983),
//                     ),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
            
//             if (selectedDate != null) {
//               setState(() {
//                 date = selectedDate;
//               });
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.calendar_today,
//                   color: Color(0xff368983),
//                   size: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   '${date.day}/${date.month}/${date.year}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _saveExpense,
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: const Text(
//           'Save',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/add_date.dart';

// ignore: camel_case_types
class Add_Screen extends StatefulWidget {
  final String? groupId;
  
  const Add_Screen({super.key, this.groupId});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

// ignore: camel_case_types
class _Add_ScreenState extends State<Add_Screen> {
  final box = Hive.box<Add_data>('data');
  DateTime date = DateTime.now();
  String? selctedItem;
  String? selctedItemi;
  final TextEditingController expalin_C = TextEditingController();
  FocusNode ex = FocusNode();
  final TextEditingController amount_c = TextEditingController();
  FocusNode amount_ = FocusNode();
  final List<String> _item = [
    'Food',
    "Transfer",
    "Transportation",
    "Education"
  ];
  final List<String> _itemei = [
    'Income',
    "Expand",
  ];
  
  @override
  void initState() {
    super.initState();
    ex.addListener(() {
      setState(() {});
    });
    amount_.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            // background_container(context),
            Positioned(
              top: 120,
              child: main_container(),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container main_container() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 550,
      width: 340,
      child: Column(
        children: [
          SizedBox(height: 50),
          name(),
          SizedBox(height: 30),
          explain(),
          SizedBox(height: 30),
          amount(),
          SizedBox(height: 30),
          How(),
          SizedBox(height: 30),
          date_time(),
          Spacer(),
          save(),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  GestureDetector save() {
    return GestureDetector(
      onTap: () {
        if (selctedItem == null || selctedItemi == null || amount_c.text.isEmpty) {
          // Show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all fields'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        var add = Add_data(
          selctedItemi!, 
          amount_c.text, 
          date, 
          expalin_C.text, 
          selctedItem!,
          groupId: widget.groupId,
        );
        
        box.add(add);
        
        if (widget.groupId != null) {
          // Return true to indicate a new expense was added to the group
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Hero(
        tag: 'save_button_${widget.groupId ?? 'default'}',
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xff368983),
          ),
          width: 120,
          height: 50,
          child: Text(
            'Save',
            style: TextStyle(
              fontFamily: 'f',
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget date_time() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5))),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100));
          if (newDate == null) return;
          setState(() {
            date = newDate;
          });
        },
        child: Text(
          'Date : ${date.year} / ${date.day} / ${date.month}',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Padding How() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selctedItemi,
          onChanged: ((value) {
            setState(() {
              selctedItemi = value!;
            });
          }),
          items: _itemei
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text(
                            e,
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => _itemei
              .map((e) => Row(
                    children: [Text(e)],
                  ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'How',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding amount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amount_,
        controller: amount_c,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  Padding explain() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        focusNode: ex,
        controller: expalin_C,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: widget.groupId != null ? 'description for group expense' : 'explain',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  // Padding name() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 15),
  //       width: 300,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(
  //           width: 2,
  //           color: Color(0xffC5C5C5),
  //         ),
  //       ),
  //       child: DropdownButton<String>(
  //         value: selctedItem,
  //         onChanged: ((value) {
  //           setState(() {
  //             selctedItem = value!;
  //           });
  //         }),
  //         items: _item
  //             .map((e) => DropdownMenuItem(
  //                   value: e,
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     child: Row(
  //                       children: [
  //                         SizedBox(width: 10),
  //                         Text(
  //                           e,
  //                           style: TextStyle(fontSize: 18),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ))
  //             .toList(),
  //         selectedItemBuilder: (BuildContext context) => _item
  //             .map((e) => Row(
  //                   children: [Text(e)],
  //                 ))
  //             .toList(),
  //         hint: Padding(
  //           padding: const EdgeInsets.only(top: 12),
  //           child: Text(
  //             'Category',
  //             style: TextStyle(color: Colors.grey),
  //           ),
  //         ),
  //         dropdownColor: Colors.white,
  //         isExpanded: true,
  //         underline: Container(),
  //       ),
  //     ),
  //   );
  // }
  Padding name() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: selctedItem,
          onChanged: ((value) {
            setState(() {
              selctedItem = value!;
            });
          }),
          items: _item
              .map((e) => DropdownMenuItem(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            child: Image.asset('images/${e}.png'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            e,
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    value: e,
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => _item
              .map((e) => Row(
                    children: [
                      Container(
                        width: 42,
                        child: Image.asset('images/${e}.png'),
                      ),
                      SizedBox(width: 5),
                      Text(e)
                    ],
                  ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Name',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

}