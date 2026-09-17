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
        apiKey: 'AIzaSyD7k36zjHRBEEoZwQj9JXRpihI4n4SvNbo',
        authDomain: 'uzinduziafrica-2223c.firebaseapp.com',
        projectId:'app.uzinduziafrica.com', //'uzinduziafrica-2223c',
        storageBucket: 'uzinduziafrica-2223c.firebasestorage.app',
        messagingSenderId: '636866540205',
        appId: '1:636866540205:web:a401812347e495e25f8c24',
      ),
    );
  }

  runApp(const ProviderScope(child: UzinduziApp()));
}