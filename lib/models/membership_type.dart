class MembershipType {
  final String id;
  final String name;
  final double monthlyFee;
  final double studentFee;

  MembershipType({
    required this.id,
    required this.name,
    required this.monthlyFee,
    required this.studentFee,
  });

  factory MembershipType.fromJson(Map<String, dynamic> json) {
    return MembershipType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      monthlyFee: double.tryParse((json['monthly_fee'] ?? '').toString()) ?? 0,
      studentFee: double.tryParse((json['student_fee'] ?? '').toString()) ?? 0,
    );
  }
}
