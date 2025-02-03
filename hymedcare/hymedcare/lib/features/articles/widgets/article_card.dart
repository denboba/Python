import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

import '../../../model/article_model.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final bool isLiked;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onLike,
    required this.isLiked,
  });

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _formatReadTime(int minutes) {
    return '$minutes min read';
  }

  String _getPreviewText() {
    final plainText = article.plainTextContent;
    return plainText.length > 150 
        ? '${plainText.substring(0, 150)}...'
        : plainText;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO Correct the card here
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 2),
              color:  Colors.purpleAccent
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (article.summary != null && article.summary!.isNotEmpty)
              Text(
                article.summary!,
                style: const TextStyle(
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                _getPreviewText(),
                style: const TextStyle(
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: article.authorImageUrl.isNotEmpty
                      ? NetworkImage(article.authorImageUrl)
                      : null,
                  child: article.authorImageUrl.isEmpty
                      ? const Icon(
                          CupertinoIcons.person_fill,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(article.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.eye,
                      size: 16

                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${article.views}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onLike,
                      child: Row(
                        children: [
                          Icon(
                            isLiked
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            size: 16,
                            color: isLiked
                                ? CupertinoColors.systemRed
                                : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${article.likes.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isLiked
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatReadTime(article.readTime),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
