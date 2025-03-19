import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/widgets/contact_list_item.dart';
import 'package:savesmart/widgets/group_header.dart';
import 'package:uuid/uuid.dart';
import 'package:savesmart/data/models/group.dart' as expense_model;
import 'package:share_plus/share_plus.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<Contact> contacts = [];
  List<Contact> selectedContacts = [];
  List<Contact> filteredContacts = []; // Add filtered contacts list
  String groupName = "";
  String searchQuery = ""; // Add search query state
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
          filteredContacts = fetchedContacts; // Initialize filtered contacts
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name and select at least one contact'),
          backgroundColor: Colors.red,
        ),
      );
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
    
    // Generate group link
    final groupLink = 'savesmart://join-group/$groupId';
    
    // Create and save the group
    final newGroup = expense_model.Group(
      name: groupName,
      memberNames: memberNames,
      memberPhones: memberPhones,
      createdDate: DateTime.now(),
      id: groupId,
      groupLink: groupLink,
    );
    
    await groupBox.add(newGroup);
    print('Group saved with ID: ${newGroup.id}');
    
    // Show dialog with group link and share option
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Group Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your group has been created! Share the link below to invite others:'),
              const SizedBox(height: 10),
              Text(
                groupLink,
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await Share.share(
                  'Join my group on SaveSmart: $groupLink',
                  subject: 'Invite to Join Group',
                );
                if (result.status == ShareResultStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group link shared successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (result.status == ShareResultStatus.dismissed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share action was canceled.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Share Link'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to group details screen
                Navigator.pushReplacementNamed(
                  context,
                  '/group-details',
                  arguments: {'groupId': groupId},
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  // Add search filter logic
  void _filterContacts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredContacts = contacts;
      } else {
        filteredContacts = contacts
            .where((contact) =>
                contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
                searchQuery = ""; // Reset search query on refresh
                filteredContacts = contacts; // Reset filtered contacts
              });
              _getContactPermission();
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
          // Add search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xff368983),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xff368983),
                        ),
                        onPressed: () {
                          setState(() {
                            searchQuery = "";
                            filteredContacts = contacts;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff368983)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff368983)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff368983), width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildContactListSection(),
          ),
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
                  searchQuery = ""; // Reset search query on retry
                  filteredContacts = contacts; // Reset filtered contacts
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
    
    if (filteredContacts.isEmpty) {
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
      itemCount: filteredContacts.length, // Use filteredContacts instead of contacts
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];
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
        onPressed: _createGroup,
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