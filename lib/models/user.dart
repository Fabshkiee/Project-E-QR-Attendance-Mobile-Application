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

