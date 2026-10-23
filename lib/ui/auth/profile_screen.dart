import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/goride_exception.dart';
import '../../data/repositories/user_repository.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';
import '../common/widget_comuni.dart';

/// Sezione "Profilo" (RF8.1): mostra e modifica i dati, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _telefono = TextEditingController();

  late UserRepository _repository;
  AppUser? _utente;
  bool _caricamento = false;
  bool _inizializzato = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Qui (e non in initState) si può leggere l'InheritedWidget AppScope.
    // Il flag fa sì che il profilo venga caricato una volta sola.
    if (!_inizializzato) {
      _inizializzato = true;
      _repository = AppScope.of(context).userRepository;
      _caricamento = true; // niente setState: il primo build non è ancora avvenuto
      _caricaProfilo();
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _caricaProfilo() async {
    if (!_caricamento) setState(() => _caricamento = true);
    try {
      final utente = await _repository.getProfilo();
      if (!mounted) return;
      // Riempiamo i campi modificabili con i dati letti da Firestore.
      _nome.text = utente.nome;
      _cognome.text = utente.cognome;
      _telefono.text = utente.telefono;
      setState(() => _utente = utente);
    } on GoRideException catch (e) {
      if (mounted) mostraMessaggio(context, e.messaggio);
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  Future<void> _salvaModifiche() async {
    final nome = _nome.text.trim();
    final cognome = _cognome.text.trim();
    final telefono = _telefono.text.trim();

    String? errore;
    if (nome.isEmpty) {
      errore = 'Il nome non può essere vuoto';
    } else if (cognome.isEmpty) {
      errore = 'Il cognome non può essere vuoto';
    } else if (telefono.length < 8) {
      errore = 'Numero di telefono non valido';
    }
    if (errore != null) {
      mostraMessaggio(context, errore);
      return;
    }

    setState(() => _caricamento = true);
    try {
      await _repository.aggiornaProfilo(
          nome: nome, cognome: cognome, telefono: telefono);
      if (!mounted) return;
      mostraMessaggio(context, 'Profilo aggiornato');
      await _caricaProfilo();
    } on GoRideException catch (e) {
      if (mounted) mostraMessaggio(context, e.messaggio);
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  Future<void> _confermaLogout() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Uscire dall'account?"),
        content: const Text(
          'Dovrai inserire di nuovo email e password al prossimo accesso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Esci'),
          ),
        ],
      ),
    );
    if (conferma != true) return;
    await _repository.logout();
    if (!mounted) return;
    // Svuota tutto lo stack e torna al login.
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final utente = _utente;

    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Il tuo profilo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              utente?.email ?? '',
              style: const TextStyle(color: Colori.grigioTesto),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Dati personali',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nome,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cognome,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(labelText: 'Cognome'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telefono,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Telefono'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _caricamento ? null : _salvaModifiche,
                      child: const Text('Salva modifiche'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (utente != null)
              Text(
                'Iscritto dal ${Formatters.dataBreve(utente.dataRegistrazione)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colori.grigioTesto),
              ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colori.errore,
                side: const BorderSide(color: Colori.errore),
              ),
              onPressed: _confermaLogout,
              child: const Text('Esci'),
            ),
            Caricamento(visibile: _caricamento),
          ],
        ),
      ),
    );
  }
}
