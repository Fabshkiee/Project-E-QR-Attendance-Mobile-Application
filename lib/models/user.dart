class User {
  final String _firstName;
  final String? _lastName;
  final String? _nickname;
  final String _membershipTypeID; // uuid
  final DateTime _startedDate; // start date of their membership
  final DateTime _validUntil; // end date of their membership

  User({
    required String firstName,
    String? lastName,
    String? nickname,
    required String membershipTypeID,
    required DateTime startedDate,
    required DateTime validUntil
  })  : _firstName = firstName,
        _lastName = lastName,
        _nickname = nickname,
        _membershipTypeID = membershipTypeID,
        _startedDate = startedDate,
        _validUntil = validUntil;

  String get displayName {
    final full = [_firstName, _lastName].where((s) => s != null && s.isNotEmpty).join(' ');
    return (_nickname?.isNotEmpty ?? false) ? _nickname! : full;
  }
}

// Maps user data from object to JSON and vice versa
// NOTE: Fields must match database field names
class UserMapper {	
  // Maps JSON data to User object
  User fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      nickname: json['nickname'],
      membershipTypeID: json['membership_type_id'],
      startedDate: json['started_date'],
      validUntil: json['valid_until'],
    );
  }

  // Maps User object to JSON data
  // Use this to pass the object as JSON object to Staff Authorization
  Map<String, dynamic> toJson(User user) {
    return {
      'first_name': user._firstName,
      'last_name': user._lastName,
      'nickname': user._nickname,
      'membership_type_id': user._membershipTypeID,
      'started_date' : user._startedDate,
      'valid_until': user._validUntil,
    };
  }
}