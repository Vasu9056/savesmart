import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savesmart/data/models/group.dart';
import 'package:savesmart/screens/group/create_group_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final groupBox = Hive.box<Group>('groups');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F9), // Softer background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff368983),
        title: const Text(
          "My Groups",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xff368983), const Color(0xff368983).withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: groupBox.listenable(),
                builder: (context, box, _) {
                  if (box.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildGroupList(box);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
        ),
        backgroundColor: const Color(0xff368983),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        heroTag: 'groupListFab', // Unique heroTag
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 60,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Groups Yet",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create a group to start tracking expenses",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff368983),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Create Group",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList(Box<Group> box) {
    final groups = box.values.toList();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(group);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16), // Space between group cards
    );
  }

  Widget _buildGroupCard(Group group) {
    return Dismissible(
      key: Key(group.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Group'),
            content: Text('Are you sure you want to delete "${group.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        group.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${group.name} deleted'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Card(
        elevation: 3,
        color: Colors.white.withOpacity(0.88),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text("${group.memberCount}"),
                    avatar: const Icon(Icons.people, size: 16, color: Color(0xff368983)),
                    backgroundColor: const Color(0xff368983).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xff368983)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _buildMemberChips(group),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Created: ${group.createdDate.day}/${group.createdDate.month}/${group.createdDate.year}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Color(0xff368983), size: 16),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/group-details',
                      arguments: {'groupId': group.id},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMemberChips(Group group) {
    if (group.memberNames.isEmpty) {
      return [
        const Text(
          "No members",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        )
      ];
    }

    List<Widget> chips = group.memberNames.take(3).map((name) => Chip(
      label: Text(name),
      backgroundColor: const Color(0xff368983).withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    )).toList();

    if (group.memberNames.length > 3) {
      chips.add(Chip(
        label: Text("+${group.memberNames.length - 3}"),
        backgroundColor: const Color(0xff368983).withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }

    return chips;
  }
}