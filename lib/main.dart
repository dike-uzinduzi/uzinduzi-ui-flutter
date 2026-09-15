import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAj5GyEzyVNS2yLxj1Stac-BTOJNDtijJI',
        authDomain: 'zinduziafrica.firebaseapp.com',
        projectId: 'zinduziafrica',
        storageBucket: 'zinduziafrica.firebasestorage.app',
        messagingSenderId: '43388235704',
        appId: '1:43388235704:web:f67ef640b93fba88eea94d',
      ),
    );
  }

  runApp(const ProviderScope(child: UzinduziApp()));
}