import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String email;
  
  @HiveField(3)
  String? profileImage;
  
  @HiveField(4)
  DateTime createdDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.createdDate,
  });
}

// Run this command to generate the adapter:
// flutter packages pub run build_runner build