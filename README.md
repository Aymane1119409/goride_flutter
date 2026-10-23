# GoRide — versione Flutter

App di bike sharing per Ancona, versione **Flutter** del progetto GoRide
(la versione Kotlin nativa è nel repository del collega).

Le due app usano **lo stesso progetto Firebase** (`go-ride-a24f7`):
utenti, corse e recensioni sono condivisi.

## Requisiti

- Flutter SDK (stable) — verificare con `flutter doctor`
- Android Studio con Android SDK, **Android SDK Platform 37** e un emulatore con Google Play
- Plugin **Flutter** e **Dart** in Android Studio

## Come avviarla

1. Clonare il repository e aprire la cartella in Android Studio (vista **Project**).
2. Creare (o completare) il file `android/local.properties` aggiungendo la chiave di Google Maps:
   ```
   MAPS_API_KEY=la_chiave_maps
   ```
   È la stessa chiave usata dall'app Kotlin. Questo file **non** va su Git
   (è in `.gitignore`), per questo va aggiunta a mano.
3. Da terminale, nella cartella del progetto:
   ```
   flutter pub get
   flutter run
   ```
   con l'emulatore acceso.

> Nota: l'app usa l'identificativo `com.example.goride`, lo stesso dell'app Kotlin
> (necessario per la configurazione Firebase). Sullo stesso dispositivo le due app
> si sostituiscono a vicenda.

## Struttura del codice (`lib/`)

```
lib/
├── main.dart               avvio: Firebase, repository, rotte con nome
├── firebase_options.dart   configurazione del progetto Firebase
├── app/                    AppScope (InheritedWidget), rotte, tema
├── data/
│   ├── models/             Vehicle, Ride, Review, AppUser, ActiveRide
│   ├── local/              database SQLite (sqflite): corse, corsa_attiva
│   ├── remote/             mock dei mezzi attorno ad Ancona
│   └── repositories/       Vehicle, User, Ride, Review (unica porta verso i dati)
├── ui/                     schermate per sezione (StatefulWidget) + RideViewModel
│   ├── auth/               login, registrazione, recupero password, profilo
│   ├── map/                mappa Google, dettaglio mezzo
│   ├── ride/               corsa con timer, scadenza, estensione
│   ├── history/            storico e dettaglio corsa
│   ├── community/          recensioni in tempo reale
│   └── home/               BottomNavigationBar con le 4 sezioni
└── util/                   colori e formattazione
```

## Scelte principali

- Architettura: schermata (`StatefulWidget` con `setState`, `FutureBuilder`, `StreamBuilder`) → Repository → dati. Solo la corsa usa un `RideViewModel` (`ChangeNotifier`), perché il timer deve sopravvivere anche uscendo dalla schermata.
- Stato condiviso con un **`InheritedWidget`** (`AppScope`), senza librerie esterne.
- Navigazione con **rotte con nome** e argomenti.
- Database locale con **sqflite**, dati remoti con **Cloud Firestore**.
- Eccezioni dichiarate rispetto agli appunti: Firebase, Google Maps, permission_handler.
