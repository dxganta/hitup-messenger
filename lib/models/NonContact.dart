import 'package:equatable/equatable.dart';

class NonContact extends Equatable {
  final String name;
  final String phoneNumber;

  NonContact(this.phoneNumber, {this.name});

  @override
  List<Object> get props => [phoneNumber];
}
