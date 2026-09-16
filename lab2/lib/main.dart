import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const NetTest());
}

class NetTest extends StatefulWidget {
  final http.Client? httpClient;
  const NetTest({super.key, this.httpClient});

  @override
  State<NetTest> createState() => _NetTestState();
}

class _NetTestState extends State<NetTest> {
  // Managed state scoped to widget instance
  String _selectedLanguage = "JavaScript";
  final String _createdAfterDate = "2024-01-01";

  final List<String> _languages = const [
    "JavaScript",
    "TypeScript",
    "Go",
    "Rust",
    "Swift",
    "PHP",
    "CSS",
    "C",
    "Python",
    "Ruby",
    "Java",
  ];

  late Future<List<Post>> _futurePosts;

  // Custom client getter for injectable HTTP client (used during UI testing)
  http.Client get _httpClient => widget.httpClient ?? http.Client();

  @override
  void initState() {
    super.initState();
    _futurePosts = fetchPosts();
  }

  /// Fetches trending repositories from GitHub REST API
  Future<List<Post>> fetchPosts() async {
    final url = Uri.parse(
      'https://api.github.com/search/repositories?q=language:$_selectedLanguage+created:>$_createdAfterDate&sort=stars&order=desc',
    );

    try {
      final response = await _httpClient.get(
        url,
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'MyFlutterApp',
        },
      );

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List items = jsonResponse['items'] ?? [];

      if (items.isEmpty) {
        return [];
      }

      return items.map((item) => Post.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load GitHub repositories: $e');
    }
  }

  void _onLanguageChanged(String? newLanguage) {
    if (newLanguage == null || newLanguage == _selectedLanguage) return;
    setState(() {
      _selectedLanguage = newLanguage;
      _futurePosts = fetchPosts();
    });
  }

  // ---------------------------------------------------------------------------
  // MAIN UI BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
          centerTitle: true,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.grey.shade600,
        appBar: AppBar(title: const Text('Git list')),
        body: Column(
          children: [
            const SizedBox(height: 10),
            _buildLanguageSelector(),
            const SizedBox(height: 10),
            Expanded(child: _buildPostsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        alignment: Alignment.center,
        isExpanded: true,
        initialValue: _selectedLanguage,
        onChanged: _onLanguageChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: _languages.map((lang) {
          return DropdownMenuItem(
            value: lang,
            child: Center(child: Text(lang)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostsList() {
    return FutureBuilder<List<Post>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'No repositories found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ItemCard(
              index: index,
              post: post,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedScreen(post: post),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// ITEM CARD WIDGET
// -----------------------------------------------------------------------------

class ItemCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final int index;

  const ItemCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEven = index.isEven;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isEven ? Colors.blue.shade100 : Colors.white,
        child: InkWell(
          hoverColor: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  post.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.description ?? "No description available",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${post.stargazersCount}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DETAILED VIEW SCREEN
// -----------------------------------------------------------------------------

class DetailedScreen extends StatelessWidget {
  final Post post;
  const DetailedScreen({super.key, required this.post});

  Widget _buildInfoRow({
    required int index,
    required String text,
  }) {
    final bool isEven = index.isEven;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: isEven ? Colors.white : Colors.grey.shade300,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final infoItems = [
      'Full Name: ${post.fullName}',
      'Description: ${post.description ?? "No description"}',
      'Stars: ${post.stargazersCount}',
      'Forks: ${post.forksCount}',
      'Homepage: ${post.homepage ?? "No homepage found"}',
      'Language: ${post.language}',
      'Created at: ${post.created}',
      'Updated at: ${post.updated}',
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade600,
      appBar: AppBar(title: Text(post.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              infoItems.length,
              (index) => _buildInfoRow(
                index: index,
                text: infoItems[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA MODEL
// -----------------------------------------------------------------------------

class Post {
  final String name;
  final String fullName;
  final String? description;
  final int stargazersCount;
  final int forksCount;
  final String created;
  final String updated;
  final String? homepage;
  final String language;

  const Post({
    required this.name,
    required this.fullName,
    required this.stargazersCount,
    required this.description,
    required this.forksCount,
    required this.created,
    required this.updated,
    required this.homepage,
    required this.language,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      stargazersCount: json['stargazers_count'] ?? 0,
      description: json['description'],
      forksCount: json['forks_count'] ?? 0,
      created: json['created_at'] ?? '',
      updated: json['updated_at'] ?? '',
      homepage: json['homepage'],
      language: json['language'] ?? 'N/A',
    );
  }
}