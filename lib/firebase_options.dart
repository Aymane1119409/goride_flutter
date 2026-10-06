// Configurazione Firebase per Android, ricavata dal google-services.json
// dell'app Kotlin: stesso progetto (go-ride-a24f7), quindi utenti, corse
// e recensioni sono condivisi tra le due app.
// (È lo stesso file che genererebbe `flutterfire configure`.)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Firebase è configurato solo per Android in questo progetto.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDniIERDwBe0zLeOe9WyL4zRilYlmRFNW8',
    appId: '1:513015084944:android:b33ed6e563a9e328186515',
    messagingSenderId: '513015084944',
    projectId: 'go-ride-a24f7',
    storageBucket: 'go-ride-a24f7.firebasestorage.app',
  );
}
