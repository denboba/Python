import 'package:flutter/cupertino.dart';

import '../../../model/article_model.dart';
import '../provider/article_provider.dart';
import '../../../provider/auth_provider.dart';
import 'article_card.dart';
import '../screens/article_detail_screen.dart';
import 'package:provider/provider.dart';

class RelatedArticles extends StatelessWidget {
  final List<ArticleModel> articles;

  const RelatedArticles({
    required this.articles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Related Articles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                return Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == articles.length - 1 ? 16 : 8,
                  ),
                  child: ArticleCard(
                    article: articles[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ArticleDetailScreen(
                            article: articles[index],
                          ),
                        ),
                      );
                    },
                    onLike: () {
                      final userId = context.read<HymedCareAuthProvider>().currentUser!.uid;
                      context.read<ArticleProvider>().toggleLike(articles[index].id, userId);
                    },
                    isLiked: articles[index].likes.contains(
                      context.read<HymedCareAuthProvider>().currentUser!.uid,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
