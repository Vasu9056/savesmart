import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/group.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late Box<Group> groupBox;
  Group? group;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (!Hive.isBoxOpen('groups')) {
      Hive.openBox<Group>('groups').then((box) {
        groupBox = box;
        _loadGroup();
      });
    } else {
      groupBox = Hive.box<Group>('groups');
      _loadGroup();
    }
  }

  void _loadGroup() {
    try {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final groupId = args['groupId'] as String;
      print('Loading group with groupId: $groupId');
      print('Total groups in Hive: ${groupBox.length}');

      for (var i = 0; i < groupBox.length; i++) {
        final Group? currentGroup = groupBox.getAt(i);
        print('Checking group at index $i: ${currentGroup?.id}');
        if (currentGroup != null && currentGroup.id == groupId) {
          setState(() {
            group = currentGroup;
            isLoading = false;
          });
          print('Group found: ${group!.name}');
          return;
        }
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Group not found';
      });
      print('Group not found for groupId: $groupId');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading group: $e';
      });
      print('Error loading group: $e');
    }
  }

  void _joinGroup() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name and phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (group == null) {
      print('Group is null, cannot join');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Joining group: ${group!.name} with ID: ${group!.id}');
    group!.memberNames.add(_nameController.text);
    group!.memberPhones.add(_phoneController.text);
    await group!.save();
    print('Group updated: ${group!.memberNames}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully joined ${group!.name}'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      '/group-details',
      arguments: {'groupId': group!.id},
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff368983),
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff368983),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join ${group!.name}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your details to join ${group!.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff368983), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Your Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff368983), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _joinGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff368983),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Join Group',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}