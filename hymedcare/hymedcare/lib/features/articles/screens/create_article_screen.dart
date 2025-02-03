import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../provider/article_provider.dart';
import '../../../provider/auth_provider.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final _titleController = TextEditingController();
  final _readTimeController = TextEditingController();
  late QuillController _quillController;
  final List<String> _selectedCategories = [];
  File? _selectedImage;
  bool _isLoading = false;
  final FocusNode _editorFocusNode = FocusNode();

  final List<String> _availableCategories = [
    'Mental Health',
    'Dental Health',
    'Personal Treatment',
    'Fitness',
    'Regular Exercise',
    'Oncology',
    'Hematology',
    'Nephrology and Renal Transplantation',
    'Pediatrics',
  ];
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('article_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Widget _buildEditor() {
    return Column(
      children: [
        QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: _quillController,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _quillController,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                  scrollable: true,
                  padding: const EdgeInsets.all(8),
                  autoFocus: false,
                  expands: false,
                  placeholder: 'Write your story...',
                  enableInteractiveSelection: true,
                  enableSelectionToolbar: true,
                  scrollBottomInset: 50,
                  maxHeight: MediaQuery.of(context).size.height,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardAppearance: Brightness.light,
                  customStyleBuilder: (attribute) {
                    if (attribute.key == 'header') {
                      switch (attribute.value) {
                        case 1:
                          return const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          );
                        case 2:
                          return const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          );
                        default:
                          return const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          );
                      }
                    }
                    return const TextStyle(
                      fontSize: 16,
                      height: 1.15,
                    );
                  },
                  embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                  isOnTapOutsideEnabled: true,
                  onImagePaste: (bytes) async {
                    try {
                      final tempDir = await Directory.systemTemp.createTemp();
                      final file = File('${tempDir.path}/image.png');
                      await file.writeAsBytes(bytes);
                      final picker = ImagePicker();
                      final XFile pickedFile = XFile(file.path);
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('article_images')
                          .child('${DateTime.now().millisecondsSinceEpoch}.png');
                      await ref.putFile(File(pickedFile.path));
                      final url = await ref.getDownloadURL();
                      return url;
                    } catch (e) {
                      print('Error uploading pasted image: $e');
                      return null;
                    }
                  },
                  customLinkPrefixes: const ['https://', 'http://', 'tel:', 'mailto:'],
                ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (_titleController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a title for your article'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (_selectedCategories.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Please select at least one category'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      // Get the content as a Delta object
      final delta = _quillController.document.toDelta();

      // Convert the content to a map that can be stored in Firestore
      final contentMap = {
        'ops': delta.toJson(),
        'plainText': _quillController.document.toPlainText(),
      };

      final articleProvider = context.read<ArticleProvider>();
      final authProvider = context.read<HymedCareAuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get user profile image URL from Firebase Auth
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final userPhotoUrl = firebaseUser?.photoURL ?? '';

      await articleProvider.createArticle(
        title: _titleController.text,
        content: contentMap,
        imageUrl: imageUrl,
        authorId: currentUser.uid,
        authorName: '${currentUser.firstName} ${currentUser.lastName}'.trim(),
        authorImageUrl: userPhotoUrl,
        categories: _selectedCategories,
        readTime: int.tryParse(_readTimeController.text) ?? 5,
      );

      if (mounted) {
        Navigator.pop(context);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Article published successfully!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Error publishing article: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  bool _isToolbarVisible = true; // State variable
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(

      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Write Article',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _handleSubmit,
                child: const Text(
                  'Publish',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [

            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableCategories.length,
                itemBuilder: (context, index) {
                  final category = _availableCategories[index];
                  final isSelected = _selectedCategories.contains(category);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCategories.remove(category);
                          } else {
                            _selectedCategories.add(category);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                         // color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                           // color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                           // color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Title Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoTextField(
                controller: _titleController,
                placeholder: 'Title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                  ),
                ),
                maxLines: 2,
              ),
            ),

            // Categories


            const SizedBox(height: 16),

            // Content Editor
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: QuillEditor.basic(
                          configurations: QuillEditorConfigurations(
                            controller: _quillController,
                            placeholder: 'Write your story...',
                            padding: const EdgeInsets.all(0),
                            autoFocus: false,
                            customStyles: DefaultStyles(
                              // paragraph: DefaultTextBlockStyle(
                              //   const TextStyle(
                              //     fontSize: 18,
                              //     height: 1.5,
                              //   ),
                              //   const VerticalSpacing(12, 8) as HorizontalSpacing,
                              //   const VerticalSpacing(0, 0)
                              //       as VerticalSpacing,
                              //
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero, // Removes extra padding
                          child: Icon(
                            _isToolbarVisible ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _isToolbarVisible = !_isToolbarVisible;
                            });
                          },
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: _isToolbarVisible ? 50 : 0, // Adjust height based on visibility
                          child: _isToolbarVisible
                              ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: QuillToolbar.simple(
                              configurations: QuillSimpleToolbarConfigurations(
                                controller: _quillController,
                                sharedConfigurations: const QuillSharedConfigurations(
                                  locale: Locale('en'),
                                ),
                              ),
                            ),
                          )
                              : SizedBox.shrink(),
                        ),
                      ],
                    )

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
