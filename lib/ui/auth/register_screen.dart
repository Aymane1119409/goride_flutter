import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/repositories/goride_exception.dart';
import '../../util/colori.dart';
import '../../util/validazione.dart';
import '../common/widget_comuni.dart';

/// Schermata di registrazione (RF8).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _password = TextEditingController();
  final _conferma = TextEditingController();

  bool _caricamento = false;

  @override
  void dispose() {
    for (final c in [_nome, _cognome, _email, _telefono, _password, _conferma]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Stessi controlli e stessi messaggi di `RegisterViewModel.kt`.
  /// Restituisce il messaggio d'errore, oppure null se è tutto a posto.
  String? _valida() {
    final telefono = _telefono.text.trim();
    if (_nome.text.trim().isEmpty) return 'Inserisci il nome';
    if (_cognome.text.trim().isEmpty) return 'Inserisci il cognome';
    if (_email.text.trim().isEmpty) return "Inserisci l'email";
    if (!emailValida(_email.text.trim())) return 'Email non valida';
    if (telefono.isEmpty) return 'Inserisci il telefono';
    if (telefono.length < 8) return 'Numero di telefono troppo corto';
    if (_password.text.length < 6) {
      return 'La password deve avere almeno 6 caratteri';
    }
    if (_password.text != _conferma.text) return 'Le password non coincidono';
    return null;
  }

  Future<void> _registrati() async {
    final errore = _valida();
    if (errore != null) {
      mostraMessaggio(context, errore);
      return;
    }

    setState(() => _caricamento = true);
    try {
      await AppScope.of(context).userRepository.registra(
            nome: _nome.text.trim(),
            cognome: _cognome.text.trim(),
            email: _email.text.trim(),
            telefono: _telefono.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      // Toglie login e registrazione dallo stack: con "indietro" non ci si torna.
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    } on GoRideException catch (e) {
      if (mounted) mostraMessaggio(context, e.messaggio);
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  Widget _campo(
    TextEditingController controller,
    String etichetta, {
    bool nascosto = false,
    TextInputType tastiera = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        obscureText: nascosto,
        keyboardType: tastiera,
        decoration: InputDecoration(labelText: etichetta),
      ),
    );
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
              const SizedBox(height: 32),
              const Text(
                'Crea il tuo account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colori.verdePrimario,
                ),
              ),
              const SizedBox(height: 20),
              _campo(_nome, 'Nome', tastiera: TextInputType.name),
              _campo(_cognome, 'Cognome', tastiera: TextInputType.name),
              _campo(_email, 'Email', tastiera: TextInputType.emailAddress),
              _campo(_telefono, 'Telefono', tastiera: TextInputType.phone),
              _campo(_password, 'Password', nascosto: true),
              _campo(_conferma, 'Conferma password', nascosto: true),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _caricamento ? null : _registrati,
                child: const Text('Crea account'),
              ),
              Caricamento(visibile: _caricamento),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hai già un account? Accedi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
