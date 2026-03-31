class User {
  final String _fullName;
  final String? _nickname;
  final String _membershipTier;
  final DateTime _duration;

  User({
    required String fullName,
    String? nickname,
    required String membershipTier,
    required DateTime duration
  })  : _duration = duration, 
        _membershipTier = membershipTier, 
        _nickname = nickname, 
        _fullName = fullName;

}

// Maps user data from object to JSON and vice versa
// NOTE: Fields must match database field names
class UserMapper {	
  // Maps JSON data to User object
  User fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['full_name'],
      nickname: json['nickname'],
      membershipTier: json['membership_type_id'],
      duration: json['valid_until'],
    );
  }

  // Maps User object to JSON data
  // Use this to pass the object as JSON object to Staff Authorization
  Map<String, dynamic> toJson(User user) {
    return {
      'full_name': user._fullName,
      'nickname': user._nickname,
      'membership_type_id': user._membershipTier,
      'valid_until': user._duration,
    };
  }
}