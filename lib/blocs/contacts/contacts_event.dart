part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();
}

class FetchContactsEvent extends ContactsEvent {
  @override
  String toString() => 'FetchContactsEvent';

  @override
  List<Object> get props => [];
}

class ReceivedContactsEvent extends ContactsEvent {
  final List<MyContact> contacts;

  ReceivedContactsEvent(this.contacts);

  @override
  String toString() => "ReceivedContactsEvent";

  @override
  List<Object> get props => [contacts];
}
