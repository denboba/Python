import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/userModel.dart';

class HymedCareAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String currentUserId = '';

  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String ?_phoneNumber;
  UserModel? _currentUser;
  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;
  UserModel? get currentUser => _currentUser;

  User? get user => _auth.currentUser;

  String get userRole => _currentUser?.role ?? '';

  Future<void> initializeUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      await _loadCurrentUser();
    }
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _currentUser = UserModel.fromMap({
          'uid': currentUserId,
          ...userData,
        });
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<void> registerWithRole({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception("User creation failed.");
      }
      currentUserId = userCredential.user!.uid;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await _firestore.collection('users').doc(currentUserId).set({
        'uid': currentUserId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'createdAt': timestamp,
        'lastSeen': timestamp,
        'isOnline': true,
      });

      await _loadCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error in registerWithRole: $e');
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        currentUserId = userCredential.user!.uid;
        await _firestore.collection('users').doc(currentUserId).update({
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
          'isOnline': true,
        });
        await _loadCurrentUser();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in signIn: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
        'isOnline': false,
      });
      await _auth.signOut();
      _currentUser = null;
      currentUserId = '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error in signOut: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (!_auth.currentUser!.emailVerified) {
        throw 'Please verify your email before logging in.';
      }
      currentUserId = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(currentUserId).update({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
        'isOnline': true,
      });
      await _loadCurrentUser(); // Load user data after successful login
      
    } catch (e) {
      throw e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _firestore.collection('users').doc(currentUserId).update({
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
      'isOnline': false,
    });
    await _auth.signOut();
    await _clearUserInfo();
    _currentUser = null;
    notifyListeners();
  }

  Future<String> storeFileToStorage(File file, String fileName) async {
    UploadTask uploadTask = _storage.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> _saveUserInfo(String firstName, String lastName, String email,
      String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', '$firstName $lastName');
    await prefs.setString('userEmail', email);
    await prefs.setString('userId', currentUserId);
  //  await prefs.setString('userRole', role);
  }

  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName'),
      'userEmail': prefs.getString('userEmail'),
      'userId': prefs.getString('userId'),
    };
  }

  Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userId');
   // await prefs.remove('userRole');
  }

  // fetch all doctors from firestore
  Future<List<UserModel>> fetchAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    List<UserModel> doctors = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return UserModel.fromMap({
        'uid': doc.id,
        ...data,
      });
    }).toList();
    return doctors;
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;
      
      final userData = userDoc.data() as Map<String, dynamic>;
      return UserModel.fromMap({
        'uid': userId,
        ...userData,
      });
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    File? imageFile,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (currentUser == null) throw Exception('No user logged in');
      
      String? profilePicture = currentUser!.profilePicture;
      
      // Upload new profile picture if provided
      if (imageFile != null) {
        final ref = _storage.ref().child('profile_pictures/${currentUser!.uid}');
        await ref.putFile(imageFile);
        profilePicture = await ref.getDownloadURL();
        data['profilePicture'] = profilePicture;
      }

      // Create updated user data
      Map<String, dynamic> updatedData = {
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'phoneNumber': data['phoneNumber'],
        'profilePicture': data['profilePicture'] ?? profilePicture,
        'address': data['address'],
        'bio': data['bio'],
      };

      // Add role-specific fields
      if (currentUser!.role == 'Doctor') {
        updatedData.addAll({
          'specialization': data['specialization'],
          'licenseNumber': data['licenseNumber'],
          'experienceYears': data['experienceYears'], // Will be int
          'education': data['education'],
          'languages': data['languages'], // Will be List<String>
          'certifications': data['certifications'], // Will be List<String>
        });
      } else {
        updatedData.addAll({
          'emergencyContact': data['emergencyContact'],
          'bloodType': data['bloodType'],
          'allergies': data['allergies'],
          'currentMedications': data['currentMedications'],
          'medicalHistory': data['medicalHistory'],
          'insuranceProvider': data['insuranceProvider'],
          'insuranceNumber': data['insuranceNumber'],
        });
      }

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update(updatedData);

      // Update local state with new UserModel
      _currentUser = UserModel.fromMap({
        ..._currentUser!.toMap(),
        ...updatedData,
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> rateDoctorAndUpdateAverage({
    required String doctorId,
    required double rating,
    String? comment,
  }) async {
    try {
      if (_currentUser == null) throw Exception('No user logged in');
      if (_currentUser!.role != 'Patient') throw Exception('Only patients can rate doctors');

      final doctorRef = _firestore.collection('users').doc(doctorId);
      final ratingRef = _firestore.collection('doctor_ratings').doc();

      // Create the rating document
      final ratingData = {
        'id': ratingRef.id,
        'doctorId': doctorId,
        'patientId': _currentUser!.uid,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Get all ratings for this doctor
      final ratingsSnapshot = await _firestore
          .collection('doctor_ratings')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      // Calculate new average rating
      final ratings = ratingsSnapshot.docs.map((doc) => doc.data()['rating'] as num).toList();
      ratings.add(rating);
      final newAverageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      // Update doctor's average rating and review count in a transaction
      await _firestore.runTransaction((transaction) async {
        final doctorDoc = await transaction.get(doctorRef);
        if (!doctorDoc.exists) {
          throw Exception('Doctor not found');
        }

        transaction.update(doctorRef, {
          'rating': newAverageRating,
          'reviewCount': ratings.length,
        });

        transaction.set(ratingRef, ratingData);
      });

    } catch (e) {
      debugPrint('Error rating doctor: $e');
      rethrow;
    }
  }

  Stream<List<UserModel>> getTopRatedDoctors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Doctor')
        .orderBy('rating', descending: true)
        .limit(4)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Stream<List<UserModel>> getTopDoctors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'Doctor')
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();
        });
  }
}
