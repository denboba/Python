import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/article_model.dart';
import 'dart:convert'; // Add this line

class ArticleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ArticleModel> _articles = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 10;
  String? _error;

  List<ArticleModel> get articles => _articles;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final doc = await _firestore.collection('metadata').doc('categories').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final categoryList = List<String>.from(data['list'] ?? []);
        _categories = ['All', ...categoryList];
        _setError(null);
      } else {
        _categories = ['All'];
        _setError('Categories not found');
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = ['All'];
      _setError('Failed to load categories');
    }
    notifyListeners();
  }

  Future<void> loadArticles() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _setError(null);
      notifyListeners();

      debugPrint('Loading articles for category: $_selectedCategory');
      Query query = _firestore.collection('articles')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (_selectedCategory != 'All') {
        query = query.where('categories', arrayContains: _selectedCategory);
      }

      final snapshot = await query.get();
      //debugPrint('Found ${snapshot.docs.length} articles in Firestore');
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      _articles = [];
      for (var doc in snapshot.docs) {
        try {
          // debugPrint('Processing article ${doc.id}');
          // debugPrint('Article data: ${doc.data()}');
          final article = ArticleModel.fromFirestore(doc);
          _articles.add(article);
        } catch (e) {
          //debugPrint('Error parsing article ${doc.id}: $e');
          // Continue to next article if one fails to parse
        }
      }

    //  debugPrint('Successfully loaded ${_articles.length} articles');
      if (_articles.isEmpty && snapshot.docs.isNotEmpty) {
        _setError('Failed to load articles properly');
      }

    } catch (e) {
     // debugPrint('Error loading articles: $e');
      _setError('Failed to load articles');
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreArticles() async {
    if (_isLoading || _lastDocument == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore.collection('articles')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize);

      if (_selectedCategory != 'All') {
        query = query.where('categories', arrayContains: _selectedCategory);
      }

      final snapshot = await query.get();
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      for (var doc in snapshot.docs) {
        try {
          final article = ArticleModel.fromFirestore(doc);
          _articles.add(article);
        } catch (e) {
          //debugPrint('Error parsing article ${doc.id}: $e');
          // Continue to next article if one fails to parse
        }
      }

    } catch (e) {
     // debugPrint('Error loading more articles: $e');
      _setError('Failed to load more articles');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _articles = [];
      _lastDocument = null;
      loadArticles();
    }
  }

  Future<void> refreshArticles() async {
    _lastDocument = null;
    await loadArticles();
  }

  Future<void> toggleLike(String articleId, String userId) async {
    try {
      final docRef = _firestore.collection('articles').doc(articleId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Article not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await docRef.update({'likes': likes});

      // Update local state
      final index = _articles.indexWhere((article) => article.id == articleId);
      if (index != -1) {
        _articles[index] = _articles[index].copyWith(likes: likes);
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling like: $e');
      _setError('Failed to update like');
    }
  }

  Future<void> incrementViews(String articleId) async {
    try {
      await _firestore.collection('articles').doc(articleId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
   //   debugPrint('Error incrementing views: $e');
    }
  }

  Future<void> createArticle({
    required String title,
    required dynamic content, // Can be either String or Map<String, dynamic>
    String? summary,
    String? imageUrl,
    required String authorId,
    required String authorName,
    required String authorImageUrl,
    required List<String> categories,
    required int readTime,
  }) async {
    try {
      if (title.isEmpty) {
        throw Exception('Title cannot be empty');
      }

      if (categories.isEmpty) {
        throw Exception('Please select at least one category');
      }

      final docRef = _firestore.collection('articles').doc();
      
      // Convert content to proper format
      final Map<String, dynamic> contentMap;
      if (content is String) {
        // If content is plain text, convert it to Quill Delta format
        contentMap = {
          'ops': [
            {
              'insert': content,
            }
          ]
        };
      } else if (content is Map<String, dynamic>) {
        contentMap = content;
      } else {
        throw Exception('Invalid content format');
      }
      
      final articleData = {
        'title': title.trim(),
        'content': contentMap,
        'imageUrl': imageUrl ?? '',
        'authorId': authorId,
        'authorName': authorName,
        'authorImageUrl': authorImageUrl,
        'categories': categories,
        'likes': [],
        'views': 0,
        'readTime': readTime,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (summary != null && summary.trim().isNotEmpty) {
        articleData['summary'] = summary.trim();
      }

      await docRef.set(articleData);

      // Create a new ArticleModel instance
      final newArticle = ArticleModel(
        id: docRef.id,
        title: title.trim(),
        content: json.encode(contentMap), // Convert map to JSON string for the model
        summary: summary?.trim(),
        imageUrl: imageUrl ?? '',
        authorId: authorId,
        authorName: authorName,
        authorImageUrl: authorImageUrl,
        categories: categories,
        likes: [],
        views: 0,
        readTime: readTime,
        createdAt: DateTime.now(),
      );

      if (_selectedCategory == 'All' || categories.contains(_selectedCategory)) {
        _articles.insert(0, newArticle);
        notifyListeners();
      }

    } catch (e) {
      print('Error creating article: $e');
      rethrow;
    }
  }

  Future<List<ArticleModel>> getRelatedArticles(String currentArticleId, List<String> categories) async {
    try {
      if (categories.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('articles')
          .where('categories', arrayContainsAny: categories)
          .where(FieldPath.documentId, isNotEqualTo: currentArticleId)
          .orderBy(FieldPath.documentId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      return querySnapshot.docs
          .map((doc) {
            try {
              return ArticleModel.fromFirestore(doc);
            } catch (e) {
             // debugPrint('Error parsing article ${doc.id}: $e');
              return null;
            }
          })
          .where((article) => article != null)
          .cast<ArticleModel>()
          .toList();
    } catch (e) {
     // debugPrint('Error getting related articles: $e');
      return [];
    }
  }

  Future<void> deleteArticle(String articleId) async {
    try {
      await _firestore.collection('articles').doc(articleId).delete();
      _articles.removeWhere((article) => article.id == articleId);
      notifyListeners();
    } catch (e) {
     // debugPrint('Error deleting article: $e');
      rethrow;
    }
  }
}
