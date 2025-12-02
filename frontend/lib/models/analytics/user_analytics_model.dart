class UserAnalyticsModel {
  final int totalUsers;
  final int newUsersThisMonth;
  final int activeUsers;
  final int studentsCount;
  final int teachersCount;
  final int adminCount;

  UserAnalyticsModel({
    required this.totalUsers,
    required this.newUsersThisMonth,
    required this.activeUsers,
    required this.studentsCount,
    required this.teachersCount,
    required this.adminCount,
  });

  factory UserAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsModel(
      totalUsers: json['totalUsers'],
      newUsersThisMonth: json['newUsersThisMonth'],
      activeUsers: json['activeUsers'],
      studentsCount: json['studentsCount'],
      teachersCount: json['teachersCount'],
      adminCount: json['adminCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'totalUsers': totalUsers,
        'newUsersThisMonth': newUsersThisMonth,
        'activeUsers': activeUsers,
        'studentsCount': studentsCount,
        'teachersCount': teachersCount,
        'adminCount': adminCount,
      };
}
