abstract class CooCooException implements Exception {
  String errorMessage();
}

class UserNotFoundException extends CooCooException {
  @override
  String errorMessage() => 'No user found for provided uid/username';
}

class UsernameMappingUndefinedException extends CooCooException {
  @override
  String errorMessage() => 'User not found';
}

class ContactAlreadyExistsException extends CooCooException {
  @override
  String errorMessage() => 'MyContact already exists!';
}
