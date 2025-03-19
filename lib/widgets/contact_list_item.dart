import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final VoidCallback onTap;

  const ContactListItem({
    Key? key,
    required this.contact,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isSelected ? const Color(0xff368983) : Colors.grey.shade300,
        child: Text(
          contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        contact.displayName,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: contact.phones.isNotEmpty
          ? Text(contact.phones.first.number)
          : const Text('No phone number', style: TextStyle(fontStyle: FontStyle.italic)),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Color(0xff368983),
            )
          : const Icon(
              Icons.circle_outlined,
              color: Colors.grey,
            ),
    );
  }
}