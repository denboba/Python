import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../model/article_model.dart';
import '../provider/article_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../widgets/avatar.dart';
import 'create_article_screen.dart';
import 'article_detail_screen.dart';

class ArticlesTab extends StatefulWidget {
  const ArticlesTab({super.key});

  @override
  State<ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<ArticlesTab> {
  final ScrollController _mainScrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _mainScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    await articleProvider.loadCategories();
    await articleProvider.loadArticles();
  }

  void _onScroll() {
    if (_mainScrollController.position.pixels >= _mainScrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    setState(() => _isLoadingMore = true);
    await Provider.of<ArticleProvider>(context, listen: false).loadMoreArticles();
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HymedCareAuthProvider>(context);
    final articleProvider = Provider.of<ArticleProvider>(context);
    final currentUser = authProvider.currentUser;
    
    if (authProvider.isLoading) {
      return const CupertinoActivityIndicator();
    }
    
    if (currentUser == null) {
      return const Center(
        child: Text('Please log in to view articles'),
      );
    }

    final isDoctor = currentUser.role == 'Doctor';

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Articles'),
      ),
      child: Stack(
        children: [
          CustomScrollView(
            controller: _mainScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.only(top: 10),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: articleProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = articleProvider.categories[index];
                      final isSelected = category == articleProvider.selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          borderRadius: BorderRadius.circular(16),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onPressed: () {
                            articleProvider.setSelectedCategory(category);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverPadding(

                padding: const EdgeInsets.only(bottom: 10),
                sliver: articleProvider.isLoading && articleProvider.articles.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : articleProvider.articles.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text('No articles found'),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == articleProvider.articles.length) {
                              return _isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(child: CupertinoActivityIndicator()),
                                  )
                                : null;
                            }
                            return ArticleCard(
                              article: articleProvider.articles[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ArticleDetailScreen(
                                      article: articleProvider.articles[index],
                                    ),
                                  ),
                                );
                              },
                              onLike: () {
                                final userId = context.read<HymedCareAuthProvider>().currentUser!.uid;
                                articleProvider.toggleLike(articleProvider.articles[index].id, userId);
                              },
                              isLiked: articleProvider.articles[index].likes.contains(
                                context.read<HymedCareAuthProvider>().currentUser!.uid,
                              ),
                            );
                          },
                          childCount: articleProvider.articles.length + (_isLoadingMore ? 1 : 0),
                        ),
                      ),
              ),
            ],
          ),

          if (isDoctor)
            Positioned(
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const CreateArticleScreen(),
                    ),
                  ).then((_) {
                    articleProvider.loadArticles();
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoColors.systemBlue,
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool? isLiked;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onLike,
    this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<HymedCareAuthProvider>(context).currentUser!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: CupertinoColors.systemBlue.withOpacity(0),

            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.summary != null && article.summary!.isNotEmpty
                        ? article.summary!
                        : article.plainTextContent.length > 150 
                            ? '${article.plainTextContent.substring(0, 150)}...'
                            : article.plainTextContent,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CupertinoAvatar(
                        name: "assets/images/d1.png",
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.authorName,
                              style: const TextStyle(
                              ),
                            ),
                            Text(
                              DateFormat.yMMMd().format(article.createdAt),
                              style: const TextStyle(
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: onLike,
                        child: Icon(
                          isLiked ?? false ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          color: isLiked ?? false ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                        ),
                      ),
                      Text('${article.likes.length}'),
                      const SizedBox(width: 16),
                      const Icon(CupertinoIcons.eye),
                      const SizedBox(width: 4),
                      Text('${article.views}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: article.categories.map((category) {
                      return Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
