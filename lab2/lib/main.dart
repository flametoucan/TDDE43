// lib/main.dart
import 'package:flutter/material.dart';
import 'github_service.dart';
import 'models/repository.dart';
import 'repo_detail.dart';

void main() {
  runApp(const GitHubTrendingApp());
}

class GitHubTrendingApp extends StatelessWidget {
  const GitHubTrendingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Trending',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TrendingHomePage(),
    );
  }
}

class TrendingHomePage extends StatefulWidget {
  const TrendingHomePage({Key? key}) : super(key: key);

  @override
  State<TrendingHomePage> createState() => _TrendingHomePageState();
}

class _TrendingHomePageState extends State<TrendingHomePage> {
  final GithubService _service =
      GithubService(); // Add token: GithubService(githubToken: 'xxx')
  final List<String> languages = [
    'Dart',
    'JavaScript',
    'Python',
    'Java',
    'C++',
    'Go',
    'TypeScript'
  ];
  final List<String> periods = ['daily', 'weekly', 'monthly'];

  String selectedLanguage = 'Dart';
  String selectedPeriod = 'weekly';
  bool _loading = false;
  String? _error;
  List<Repository> _repos = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repos = await _service.fetchTrending(
          language: selectedLanguage, period: selectedPeriod);
      setState(() {
        _repos = repos;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Trending (approx)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: const Key('languageDropdown'),
                    value: selectedLanguage,
                    decoration: const InputDecoration(labelText: 'Language'),
                    items: languages
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selectedLanguage = v);
                      _fetch();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    key: const Key('periodDropdown'),
                    value: selectedPeriod,
                    decoration: const InputDecoration(labelText: 'Period'),
                    items: periods
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selectedPeriod = v);
                      _fetch();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetch,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Fel: $_error',
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      : ListView.builder(
                          key: const Key('repoList'),
                          itemCount: _repos.length,
                          itemBuilder: (context, index) {
                            final r = _repos[index];
                            return ListTile(
                              key: Key('repo_$index'),
                              leading: r.ownerAvatarUrl.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(r.ownerAvatarUrl))
                                  : null,
                              title: Text(r.fullName),
                              subtitle: Text(
                                  r.description.isEmpty
                                      ? 'Ingen beskrivning'
                                      : r.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('⭐ ${r.stargazersCount}'),
                                  Text(r.language),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RepoDetailPage(repo: r)),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
