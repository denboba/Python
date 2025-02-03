import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../model/article_model.dart';
import '../provider/article_provider.dart';
import '../../../provider/auth_provider.dart';
import '../widgets/article_content_view.dart';
import '../widgets/related_articles.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Increment views when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleProvider>(context, listen: false)
          .incrementViews(widget.article.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.article.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            widget.article.likes.contains(Provider.of<HymedCareAuthProvider>(context, listen: false).currentUser!.uid)
                ? CupertinoIcons.heart_fill
                : CupertinoIcons.heart,
            color: widget.article.likes.contains(Provider.of<HymedCareAuthProvider>(context, listen: false).currentUser!.uid)
                ? CupertinoColors.systemRed
                : CupertinoColors.systemGrey,
          ),
          onPressed: () {
            Provider.of<ArticleProvider>(context, listen: false).toggleLike(widget.article.id, Provider.of<HymedCareAuthProvider>(context, listen: false).currentUser!.uid);
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.article.imageUrl.isNotEmpty)
                Hero(
                  tag: 'article_image_${widget.article.id}',
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Image.network(
                      widget.article.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Hero(
                tag: 'article_title_${widget.article.id}',
                child: Text(
                  widget.article.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.article.authorImageUrl.isNotEmpty
                        ? NetworkImage(widget.article.authorImageUrl)
                        : null,
                    child: widget.article.authorImageUrl.isEmpty
                        ? const Icon(
                            CupertinoIcons.person_fill,

                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.article.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(widget.article.createdAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.eye, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.article.views}'),
                      const SizedBox(width: 16),
                      Icon(
                        CupertinoIcons.heart_fill,
                        size: 16,
                        color: CupertinoColors.systemRed,
                      ),
                      const SizedBox(width: 4),
                      Text('${widget.article.likes.length}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: widget.article.categories.map((category) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ArticleContentView(
                content: widget.article.content,
                readOnly: true,
              ),
              const SizedBox(height: 32),
              FutureBuilder(
                future: Provider.of<ArticleProvider>(context, listen: false).getRelatedArticles(widget.article.id, widget.article.categories),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<ArticleModel> relatedArticles = snapshot.data ?? [];
                    if (relatedArticles.isNotEmpty) {
                      return Column(
                        children: [
                          const Text(
                            'Related Articles',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RelatedArticles(articles: relatedArticles),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
