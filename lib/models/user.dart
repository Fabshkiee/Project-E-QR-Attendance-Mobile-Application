class User {
  final String _fullName;
  final String? _nickname;
  final String _membershipTypeID; // uuid
  final DateTime _startedDate; // start date of their membership
  final DateTime _validUntil; // end date of their membership

  User({
    required String fullName,
    String? nickname,
    required String membershipTypeID,
    required DateTime startedDate,
    required DateTime validUntil
  })  : _fullName = fullName,
        _nickname = nickname,
        _membershipTypeID = membershipTypeID,
        _startedDate = startedDate,
        _validUntil = validUntil;

}

// Maps user data from object to JSON and vice versa
// NOTE: Fields must match database field names
class UserMapper {	
  // Maps JSON data to User object
  User fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['full_name'],
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
      'full_name': user._fullName,
      'nickname': user._nickname,
      'membership_type_id': user._membershipTypeID,
      'started_date' : user._startedDate,
      'valid_until': user._validUntil,
    };
  }
}