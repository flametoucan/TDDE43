// lib/repo_detail.dart
import 'package:flutter/material.dart';
import 'models/repository.dart';

class RepoDetailPage extends StatelessWidget {
  final Repository repo;

  const RepoDetailPage({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('repoDetail'),
      appBar: AppBar(title: Text(repo.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Row(
              children: [
                if (repo.ownerAvatarUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(repo.ownerAvatarUrl),
                    radius: 28,
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(repo.ownerLogin,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(repo.fullName,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(repo.description.isEmpty
                ? 'Ingen beskrivning.'
                : repo.description),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                Chip(label: Text('⭐ ${repo.stargazersCount}')),
                Chip(label: Text('🍴 ${repo.forksCount}')),
                Chip(label: Text('🧩 ${repo.language}')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Öppna i webbläsare
                // För enkelhet: använd Navigator för att returnera hämta url; i produktionsapp använd url_launcher
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Repo URL'),
                    content: SelectableText(repo.htmlUrl),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Stäng')),
                    ],
                  ),
                );
              },
              child: const Text('Visa GitHub-länk'),
            ),
          ],
        ),
      ),
    );
  }
}
