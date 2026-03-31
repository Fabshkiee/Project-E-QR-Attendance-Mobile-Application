class User {
  final String fullName;
  final String? nickname;
  final String membershipTier;
  final String duration;

  User({
    required this.fullName,
    this.nickname,
    this.membershipTier = 'default',
    this.duration = 'default',
  });

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
  Map<String, dynamic> toJson(User user) {
    return {
      'full_name': user.fullName,
      'nickname': user.nickname,
      'membership_type_id': user.membershipTier,
      'valid_until': user.duration,
    };
  }
}

