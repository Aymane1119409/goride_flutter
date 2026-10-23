import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/repositories/goride_exception.dart';
import '../../util/colori.dart';
import '../../util/validazione.dart';
import '../common/widget_comuni.dart';

/// Schermata di login (RF7).
///
/// È uno `StatefulWidget` (lezione 3.3): lo stato (`_caricamento`) vive nello
/// State e ogni modifica passa da `setState()`, che fa ridisegnare la schermata.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// true mentre aspettiamo la risposta di Firebase: disattiva il bottone.
  bool _caricamento = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _accedi() async {
    final email = _email.text.trim();
    final password = _password.text;

    // Validazione lato client: niente chiamata di rete inutile.
    if (email.isEmpty) {
      mostraMessaggio(context, "Inserisci l'email");
      return;
    }
    if (!emailValida(email)) {
      mostraMessaggio(context, 'Email non valida');
      return;
    }
    if (password.isEmpty) {
      mostraMessaggio(context, 'Inserisci la password');
      return;
    }

    setState(() => _caricamento = true);
    try {
      await AppScope.of(context).userRepository.login(email, password);
      // Dopo un `await` la schermata potrebbe non esistere più: lo verifica `mounted`.
      if (mounted) Navigator.pushReplacementNamed(context, Routes.home);
    } on GoRideException catch (e) {
      if (mounted) mostraMessaggio(context, e.messaggio);
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              const Text(
                'GoRide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colori.verdePrimario,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Accedi per iniziare a pedalare',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colori.grigioTesto),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onSubmitted: (_) => _accedi(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.forgotPassword),
                  child: const Text('Password dimenticata?'),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                // onPressed null = bottone disattivato durante il caricamento
                onPressed: _caricamento ? null : _accedi,
                child: const Text('Accedi'),
              ),
              Caricamento(visibile: _caricamento),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.register),
                child: const Text('Non hai un account? Registrati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
