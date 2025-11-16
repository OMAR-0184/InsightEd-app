import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_question.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart'; 

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final bookmarks = appProvider.bookmarkedQuestions;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_remove_outlined,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarks yet.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on a quiz question to save it here.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookmarks.keys.length,
              itemBuilder: (context, index) {
                final pdfName = bookmarks.keys.elementAt(index);
                final questions = bookmarks[pdfName]!;
                if (questions.isEmpty) return const SizedBox.shrink(); // Skip if empty

                return Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: Theme.of(context).dividerColor, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    key: PageStorageKey(pdfName), // Helps maintain expanded state
                    backgroundColor: Theme.of(context).cardColor,
                    title: Text(
                      pdfName.replaceAll('.pdf', ''),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${questions.length} question(s)',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                    ),
                    children: questions.map((q) {
                      return _buildQuestionTile(context, appProvider, pdfName, q);
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildQuestionTile(
    BuildContext context,
    AppProvider provider,
    String pdfName,
    QuizQuestion question,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        title: Text(question.question,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Answer: ${question.answer}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodySmall?.color)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_remove, color: AppColors.primaryColor),
          tooltip: 'Remove bookmark',
          onPressed: () {

            provider.toggleBookmark(pdfName, question);
          },
        ),
        onTap: () {
          // Show explanation in a dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Explanation', style: Theme.of(context).textTheme.headlineSmall),
              content: SingleChildScrollView(
                  child: Text(question.description,
                      style: Theme.of(context).textTheme.bodyLarge)),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}