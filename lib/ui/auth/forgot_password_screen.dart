import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/repositories/goride_exception.dart';
import '../../util/colori.dart';
import '../../util/validazione.dart';
import '../common/widget_comuni.dart';

/// Recupero password (RF7.1): la mail la manda Firebase.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _caricamento = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _invia() async {
    final email = _email.text.trim();
    if (email.isEmpty || !emailValida(email)) {
      mostraMessaggio(context, "Inserisci un'email valida");
      return;
    }

    setState(() => _caricamento = true);
    try {
      await AppScope.of(context).userRepository.inviaEmailRecupero(email);
      if (!mounted) return;
      mostraMessaggio(
          context, "Se l'email è registrata, riceverai il link di recupero");
      // Dopo 2,5 secondi torna al login (come postDelayed in Kotlin).
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      if (mounted) Navigator.pop(context);
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
              const SizedBox(height: 48),
              const Text(
                'Recupera la password',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colori.verdePrimario,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Inserisci l'email del tuo account: ti invieremo un link per "
                'impostare una nuova password.',
                style: TextStyle(color: Colori.grigioTesto),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _caricamento ? null : _invia,
                child: const Text('Invia link di recupero'),
              ),
              Caricamento(visibile: _caricamento),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Torna al login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
