import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'register_viewmodel.dart';

/// Schermata di registrazione (RF8) — equivalente di `RegisterFragment`.
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

  RegisterViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      _viewModel = RegisterViewModel(AppScope.of(context).userRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;
    final errore = vm.errore;
    if (errore != null) {
      mostraMessaggio(context, errore);
      vm.erroreMostrato();
    }
    if (vm.registrazioneRiuscita) {
      vm.navigazioneCompletata();
      // Toglie login e registrazione dallo stack: con "indietro" non ci si torna.
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    for (final c in [_nome, _cognome, _email, _telefono, _password, _conferma]) {
      c.dispose();
    }
    super.dispose();
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
    final vm = _viewModel!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) => Column(
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
                  onPressed: vm.isLoading
                      ? null
                      : () => vm.registra(
                            nome: _nome.text,
                            cognome: _cognome.text,
                            email: _email.text,
                            telefono: _telefono.text,
                            password: _password.text,
                            confermaPassword: _conferma.text,
                          ),
                  child: const Text('Crea account'),
                ),
                Caricamento(visibile: vm.isLoading),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hai già un account? Accedi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
