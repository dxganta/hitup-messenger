part of 'contacts_bloc.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();
}

class InitialContactsState extends ContactsState {
  @override
  String toString() => "InitialContactsState";

  @override
  List<Object> get props => [];
}

class FetchingContactsState extends ContactsState {
  @override
  String toString() => "FetchingContactsState";

  @override
  List<Object> get props => [];
}

class FetchedContactsState extends ContactsState {
  final List<MyContact> contacts;

  FetchedContactsState(this.contacts);

  @override
  String toString() => "FetchedContactsState";

  @override
  List<Object> get props => [contacts];
}

class ErrorState extends ContactsState {
  // TODO: Implement errors

  @override
  List<Object> get props => [];
}
