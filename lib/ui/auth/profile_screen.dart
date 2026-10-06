import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/app_user.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';
import '../common/widget_comuni.dart';
import 'profile_viewmodel.dart';

/// Sezione "Profilo" (RF8.1) — equivalente di `ProfileFragment`.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _telefono = TextEditingController();

  ProfileViewModel? _viewModel;

  /// Ultimo profilo copiato nei campi di testo.
  AppUser? _utenteMostrato;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      _viewModel = ProfileViewModel(AppScope.of(context).userRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;

    // Quando arriva un profilo nuovo, riempiamo i campi modificabili.
    final utente = vm.utente;
    if (utente != null && !identical(utente, _utenteMostrato)) {
      _utenteMostrato = utente;
      _nome.text = utente.nome;
      _cognome.text = utente.cognome;
      _telefono.text = utente.telefono;
    }

    final messaggio = vm.messaggio;
    if (messaggio != null) {
      mostraMessaggio(context, messaggio);
      vm.messaggioMostrato();
    }

    if (vm.logoutEseguito) {
      vm.navigazioneCompletata();
      // Svuota tutto lo stack e torna al login.
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    _nome.dispose();
    _cognome.dispose();
    _telefono.dispose();
    super.dispose();
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
    if (conferma == true) await _viewModel!.logout();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;

    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final utente = vm.utente;
            return ListView(
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
                          onPressed: vm.isLoading
                              ? null
                              : () => vm.salvaModifiche(
                                    nome: _nome.text,
                                    cognome: _cognome.text,
                                    telefono: _telefono.text,
                                  ),
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
                Caricamento(visibile: vm.isLoading),
              ],
            );
          },
        ),
      ),
    );
  }
}
