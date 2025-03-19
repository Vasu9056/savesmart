import 'package:hive/hive.dart';
part 'group.g.dart';

@HiveType(typeId: 1)
class Group extends HiveObject {
  @HiveField(0)
  String name;
  
  @HiveField(1)
  List<String> memberNames;
  
  @HiveField(2)
  List<String> memberPhones;
  
  @HiveField(3)
  DateTime createdDate;
  
  @HiveField(4)
  String id;
  
  @HiveField(5) // Add new field for group link
  String? groupLink;

  Group({
    required this.name,
    required this.memberNames,
    required this.memberPhones,
    required this.createdDate,
    required this.id,
    this.groupLink,
  });
  
  // Helper method to get total number of members
  int get memberCount => memberNames.length;
}