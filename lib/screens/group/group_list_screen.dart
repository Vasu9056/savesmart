// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:savesmart/data/models/group.dart';
// import 'package:savesmart/screens/group/create_group_screen.dart';

// class GroupListScreen extends StatefulWidget {
//   const GroupListScreen({Key? key}) : super(key: key);

//   @override
//   State<GroupListScreen> createState() => _GroupListScreenState();
// }

// class _GroupListScreenState extends State<GroupListScreen> {
//   final groupBox = Hive.box<Group>('groups');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "My Groups",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: groupBox.listenable(),
//         builder: (context, box, _) {
//           if (box.isEmpty) {
//             return _buildEmptyState();
//           }
//           return _buildGroupList(box);
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const CreateGroupScreen(),
//             ),
//           );
//         },
//         backgroundColor: const Color(0xff368983),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.group_outlined,
//             size: 80,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             "No groups yet",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Create a group to track shared expenses",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 30),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CreateGroupScreen(),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.add),
//             label: const Text("Create Group"),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGroupList(Box<Group> box) {
//     final groups = box.values.toList();
    
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: groups.length,
//       itemBuilder: (context, index) {
//         final group = groups[index];
//         return _buildGroupCard(group);
//       },
//     );
//   }

//   Widget _buildGroupCard(Group group) {
//     return Dismissible(
//       key: Key(group.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         color: Colors.red,
//         child: const Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       confirmDismiss: (direction) async {
//         return await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Delete Group'),
//             content: Text('Are you sure you want to delete "${group.name}"?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text(
//                   'Delete',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//       onDismissed: (direction) {
//         group.delete();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${group.name} deleted'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       },
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: InkWell(
//           onTap: () {
//             Navigator.pushNamed(
//               context,
//               '/group-details',
//               arguments: {
//                 'groupId': group.id,
//               },
//             );
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         group.name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: const Color(0xff368983).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Text(
//                         "${group.memberCount} members",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Color(0xff368983),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   height: 32,
//                   child: group.memberNames.isEmpty
//                       ? const Text(
//                           "No members",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         )
//                       : ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: group.memberNames.length > 3 ? 3 : group.memberNames.length,
//                           itemBuilder: (context, index) {
//                             if (index < 2 || group.memberNames.length <= 3) {
//                               return Container(
//                                 margin: const EdgeInsets.only(right: 8),
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Text(
//                                   group.memberNames[index],
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade800,
//                                   ),
//                                 ),
//                               );
//                             } else {
//                               return Container(
//                                 margin: const EdgeInsets.only(right: 8),
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade200,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Text(
//                                   "+${group.memberNames.length - 2} more",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade800,
//                                   ),
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Created on: ${group.createdDate.day}/${group.createdDate.month}/${group.createdDate.year}",
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const Icon(
//                       Icons.arrow_forward_ios,
//                       color: Color(0xff368983),
//                       size: 16,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
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
      appBar: AppBar(
        title: const Text(
          "My Groups",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: groupBox.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return _buildEmptyState();
          }
          return _buildGroupList(box);
        },
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            // Use MaterialPageRoute without transitions to avoid hero animations
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const CreateGroupScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return child; // No transition animation
                },
              ),
            );
          },
          backgroundColor: const Color(0xff368983),
          child: const Icon(Icons.add, color: Colors.white),
          // Remove heroTag completely
          heroTag: null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "No groups yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create a group to track shared expenses",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Use MaterialPageRoute without transitions
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const CreateGroupScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return child; // No transition animation
                  },
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Create Group"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(Box<Group> box) {
    final groups = box.values.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(group);
      },
    );
  }

  Widget _buildGroupCard(Group group) {
    return Dismissible(
      key: Key(group.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Group'),
            content: Text('Are you sure you want to delete "${group.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
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
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/group-details',
              arguments: {
                'groupId': group.id,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
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
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff368983).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "${group.memberCount} members",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff368983),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: group.memberNames.isEmpty
                      ? const Text(
                          "No members",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: group.memberNames.length > 3 ? 3 : group.memberNames.length,
                          itemBuilder: (context, index) {
                            if (index < 2 || group.memberNames.length <= 3) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  group.memberNames[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "+${group.memberNames.length - 2} more",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Created on: ${group.createdDate.day}/${group.createdDate.month}/${group.createdDate.year}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xff368983),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


