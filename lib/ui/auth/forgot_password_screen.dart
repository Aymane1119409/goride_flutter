import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'forgot_password_viewmodel.dart';

/// Recupero password (RF7.1) — equivalente di `ForgotPasswordFragment`.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  ForgotPasswordViewModel? _viewModel;
  Timer? _chiusuraRitardata;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      _viewModel = ForgotPasswordViewModel(AppScope.of(context).userRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;
    final messaggio = vm.messaggio;
    if (messaggio != null) {
      mostraMessaggio(context, messaggio);
      vm.messaggioMostrato();
    }
    if (vm.emailInviata && _chiusuraRitardata == null) {
      // Dopo 2,5 secondi torna al login (come postDelayed in Kotlin).
      _chiusuraRitardata = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _chiusuraRitardata?.cancel();
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    _email.dispose();
    super.dispose();
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
                  onPressed: vm.isLoading ? null : () => vm.inviaEmail(_email.text),
                  child: const Text('Invia link di recupero'),
                ),
                Caricamento(visibile: vm.isLoading),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Torna al login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
