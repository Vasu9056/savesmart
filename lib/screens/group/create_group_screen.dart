import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/widgets/contact_list_item.dart';
import 'package:savesmart/widgets/group_header.dart';
import 'package:uuid/uuid.dart';
import 'package:savesmart/data/models/group.dart' as expense_model;


class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  String groupName = "";
  bool isLoading = true;
  String errorMessage = "";
  late Box<expense_model.Group> groupBox;
  
  @override
  void initState() {
    super.initState();
    _initializeGroupBox();
    _getContactPermission();
  }

  void _initializeGroupBox() async {
    if (!Hive.isBoxOpen('groups')) {
      groupBox = await Hive.openBox<expense_model.Group>('groups');
    } else {
      groupBox = Hive.box<expense_model.Group>('groups');
    }
  }

  void _getContactPermission() async {
    try {
      if (await Permission.contacts.isGranted) {
        _fetchContacts();
      } else {
        var status = await Permission.contacts.request();
        if (status.isGranted) {
          _fetchContacts();
        } else {
          setState(() {
            isLoading = false;
            errorMessage = "Permission denied. Please allow contact access in settings.";
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error requesting permission: $e";
      });
    }
  }

  void _fetchContacts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      var fetchedContacts = await FlutterContacts.getContacts(withProperties: true);
      
      if (mounted) {
        setState(() {
          contacts = fetchedContacts;
          isLoading = false;
          if (contacts.isEmpty) {
            errorMessage = "No contacts found on device.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Error fetching contacts: $e";
        });
      }
    }
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  void _removeSelectedContact(int index) {
    setState(() {
      selectedContacts.removeAt(index);
    });
  }

  void _createGroup() async {
    if (groupName.isEmpty || selectedContacts.isEmpty) {
      return;
    }
    
    final uuid = Uuid();
    final groupId = uuid.v4();
    
    List<String> memberNames = [];
    List<String> memberPhones = [];
    
    for (var contact in selectedContacts) {
      memberNames.add(contact.displayName);
      
      if (contact.phones.isNotEmpty) {
        memberPhones.add(contact.phones.first.number);
      } else {
        memberPhones.add('');
      }
    }
    
    // Create and save the group
    final newGroup = expense_model.Group(
      name: groupName,
      memberNames: memberNames,
      memberPhones: memberPhones,
      createdDate: DateTime.now(),
      id: groupId,
    );
    
    await groupBox.add(newGroup);
    
    // Navigate to group details screen
    if (mounted) {
      Navigator.pushReplacementNamed(
        context, 
        '/group-details',
        arguments: {
          'groupId': groupId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Group",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = "";
              });
              _getContactPermission();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Group header section with name input and selected contacts
          GroupHeader(
            groupName: groupName,
            onGroupNameChanged: (value) {
              setState(() {
                groupName = value;
              });
            },
            selectedContacts: selectedContacts,
            onContactRemoved: _removeSelectedContact,
          ),
          
          // Contact list or loading/error states
          Expanded(
            child: _buildContactListSection(),
          ),
          
          // Create group button
          if (!isLoading && errorMessage.isEmpty)
            _buildCreateGroupButton(),
        ],
      ),
    );
  }

  Widget _buildContactListSection() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xff368983),
            ),
            SizedBox(height: 16),
            Text(
              "Loading contacts...",
              style: TextStyle(
                color: Color(0xff368983),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = "";
                });
                _getContactPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff368983),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
    
    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          "No contacts found",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final isSelected = selectedContacts.contains(contact);
        
        return ContactListItem(
          contact: contact,
          isSelected: isSelected,
          onTap: () => _toggleContactSelection(contact),
        );
      },
    );
  }

  Widget _buildCreateGroupButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: selectedContacts.isEmpty || groupName.isEmpty
            ? null
            : _createGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff368983),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 50),
          disabledBackgroundColor: const Color(0xff368983).withOpacity(0.5),
        ),
        child: const Text(
          "Create Group",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}