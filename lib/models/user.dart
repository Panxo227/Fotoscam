class AppUser {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? avatarPath;
  final String themeMode; // light / dark / custom
  final int? customColorValue;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.avatarPath,
    this.themeMode = 'light',
    this.customColorValue,
  });

  AppUser copyWith({
    String? username,
    String? email,
    String? avatarPath,
    String? themeMode,
    int? customColorValue,
  }) =>
      AppUser(
        id: id,
        username: username ?? this.username,
        email: email ?? this.email,
        createdAt: createdAt,
        avatarPath: avatarPath ?? this.avatarPath,
        themeMode: themeMode ?? this.themeMode,
        customColorValue: customColorValue ?? this.customColorValue,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
        'avatarPath': avatarPath,
        'themeMode': themeMode,
        'customColorValue': customColorValue,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        createdAt: DateTime.parse(json['createdAt']),
        avatarPath: json['avatarPath'],
        themeMode: json['themeMode'] ?? 'light',
        customColorValue: json['customColorValue'],
      );
}
