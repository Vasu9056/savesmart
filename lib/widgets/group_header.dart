import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class GroupHeader extends StatelessWidget {
  final String groupName;
  final Function(String) onGroupNameChanged;
  final List<Contact> selectedContacts;
  final Function(int) onContactRemoved;

  const GroupHeader({
    Key? key,
    required this.groupName,
    required this.onGroupNameChanged,
    required this.selectedContacts,
    required this.onContactRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xff368983).withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Group Name",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff368983),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: onGroupNameChanged,
            decoration: InputDecoration(
              hintText: "Enter group name",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xffC5C5C5), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xff368983), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Selected Contacts: ${selectedContacts.length}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff368983),
            ),
          ),
          const SizedBox(height: 8),
          if (selectedContacts.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedContacts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      backgroundColor: const Color(0xff368983).withOpacity(0.2),
                      label: Text(
                        selectedContacts[index].displayName,
                        style: const TextStyle(
                          color: Color(0xff368983),
                        ),
                      ),
                      deleteIconColor: const Color(0xff368983),
                      onDeleted: () => onContactRemoved(index),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}