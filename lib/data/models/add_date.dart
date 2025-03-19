import 'package:hive/hive.dart';
part 'add_date.g.dart';

@HiveType(typeId: 0)
// ignore: camel_case_types
class Add_data extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String explain;
  @HiveField(2)
  String amount;
  @HiveField(3)
  // ignore: non_constant_identifier_names
  String IN;
  @HiveField(4)
  DateTime datetime;
  String? groupId;
  // Add_data(this.IN, this.amount, this.datetime, this.explain, this.name);
  Add_data(this.IN, this.amount, this.datetime, this.explain, this.name,
      {this.groupId});
}
