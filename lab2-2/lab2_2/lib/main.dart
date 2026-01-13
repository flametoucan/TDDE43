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

String language = "JavaScript";
String date = "2024-01-01";
List<String> languages = [
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

class _NetTestState extends State<NetTest> {
  http.Client get _httpClient => widget.httpClient ?? http.Client();
  late Future<List<Post>> futurePosts;
  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey, // text + icons
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.grey.shade600,
        appBar: AppBar(title: Center(child: const Text('Git list'))),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: DropdownButtonFormField<String>(
                  alignment: Alignment.center,
                  isExpanded: true,
                  value: language,
                  onChanged: (String? newLanguage) {
                    setState(() {
                      language = newLanguage!;
                      futurePosts = fetchPosts();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    for (var lang in languages)
                      DropdownMenuItem(
                        value: lang,
                        child: Center(child: Text(lang)),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Post>>(
                future: futurePosts,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final posts = snapshot.data!;
                    return Expanded(
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final p = posts[index];
                          return itemCard(
                            index: index,
                            title: p.name,
                            description: p.description ?? " ",
                            stars: p.stargazers_count,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return detailedScreen(post: p);
                                  },
                                ),
                              );
                              if (!context.mounted) return;
                            },
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return Text("Hol up site is loading . . . ");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Post>> fetchPosts() async {
    final url = Uri.parse(
      'https://api.github.com/search/repositories?q=language:$language+created:>$date&sort=stars&order=desc',
    );

    final response = await _httpClient.get(
      url,
      headers: {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'MyFlutterApp',
      },
    );

    if (response.body.isEmpty) {
      List<Post> test = [];
      return test;
    }
    final jsonResponse = jsonDecode(response.body);

    List items = jsonResponse['items'];
    if (items.isEmpty) {
      List<Post> test = [];
      return test;
    }
    // Convert every item to a Post object
    return items.map((item) => Post.fromJson(item)).toList();
  }
}

class detailedScreen extends StatelessWidget {
  final Post post;
  const detailedScreen({super.key, required this.post});

  Widget infoRow({
    required BuildContext context,
    required int index,
    required String text,
  }) {
    final bool isEven = index.isEven;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      color: isEven ? Colors.white : Colors.grey.shade300,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Vad som visas när man klicka sig in på ett kort
    return Scaffold(
      backgroundColor: Colors.grey.shade600,
      appBar: AppBar(title: Text(post.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoRow(
              context: context,
              index: 0,
              text: 'Full Name: ${post.full_name}',
            ),
            infoRow(
              context: context,
              index: 1,
              text: 'Description: ${post.description ?? "No description"}',
            ),
            infoRow(
              context: context,
              index: 2,
              text: 'Stars: ${post.stargazers_count}',
            ),
            infoRow(
              context: context,
              index: 3,
              text: 'Forks: ${post.forks_count}',
            ),
            infoRow(
              context: context,
              index: 4,
              text: 'Homepage: ${post.homepage ?? "No homepage found"}',
            ),
            infoRow(
              context: context,
              index: 5,
              text: 'Language: ${post.language}',
            ),
            infoRow(
              context: context,
              index: 6,
              text: 'Created at: ${post.created}',
            ),
            infoRow(
              context: context,
              index: 7,
              text: 'Updated at: ${post.updated}',
            ),
          ],
        ),
      ),
    );
  }
}

class itemCard extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback onTap;
  final int index;
  final int stars;

  const itemCard({
    super.key,
    required this.title,
    required this.onTap,
    this.description,
    required this.index,
    required this.stars,
  });
  @override
  Widget build(BuildContext context) {
    //Det som visas på varje kort
    final bool isEven = index.isEven;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isEven ? Colors.blue.shade100 : Colors.white,
        child: InkWell(
          hoverColor: Colors.blue,
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text(
                  description.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      stars.toString(),
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

class Post {
  final String name;
  final String full_name;
  final String? description;
  final int stargazers_count;
  final int forks_count;
  final String created;
  final String updated;
  final String? homepage;
  final String language;

  Post({
    required this.name,
    required this.full_name,
    required this.stargazers_count,
    required this.description,
    required this.forks_count,
    required this.created,
    required this.updated,
    required this.homepage,
    required this.language,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      name: json['name'],
      stargazers_count: json['stargazers_count'],

      description: json['description'],
      forks_count: json['forks_count'],
      full_name: json['full_name'],
      created: json['created_at'],
      updated: json['updated_at'],
      homepage: json['homepage'],
      language: json['language'],
    );
  }
}
