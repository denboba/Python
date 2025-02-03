import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/article_provider.dart';
import '../../../provider/auth_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import 'article_detail_screen.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late ArticleProvider _articleProvider;
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    _initializeArticles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeArticles() async {
    await _articleProvider.loadCategories();
    await _articleProvider.loadArticles();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _articleProvider.loadMoreArticles();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await _articleProvider.refreshArticles();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Articles'),
      ),
      child: SafeArea(
        child: Consumer<ArticleProvider>(
          builder: (context, articleProvider, _) {
            if (articleProvider.isLoading && articleProvider.articles.isEmpty) {
              return const Center(child: CupertinoActivityIndicator());
            }

            return Column(
              children: [
                CategoryChips(
                  categories: articleProvider.categories,
                  selectedCategory: articleProvider.selectedCategory,
                  onCategorySelected: articleProvider.setSelectedCategory,
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: _onRefresh,
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= articleProvider.articles.length) {
                                return _isLoadingMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CupertinoActivityIndicator(),
                                      )
                                    : null;
                              }

                              final article = articleProvider.articles[index];
                              final currentUserId = Provider.of<HymedCareAuthProvider>(
                                context,
                                listen: false,
                              ).currentUserId;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ArticleCard(
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
                                ),
                              );
                            },
                            childCount: articleProvider.articles.length + (_isLoadingMore ? 1 : 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
