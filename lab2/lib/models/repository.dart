// lib/models/repository.dart
class Repository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final String htmlUrl;
  final String language;
  final int stargazersCount;
  final int forksCount;
  final String ownerLogin;
  final String ownerAvatarUrl;

  Repository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String? ?? '',
      htmlUrl: json['html_url'] as String,
      language: json['language'] as String? ?? 'Unknown',
      stargazersCount: json['stargazers_count'] as int,
      forksCount: json['forks_count'] as int,
      ownerLogin: (json['owner']?['login'] as String?) ?? '',
      ownerAvatarUrl: (json['owner']?['avatar_url'] as String?) ?? '',
    );
  }
}
