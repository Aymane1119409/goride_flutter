import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'login_viewmodel.dart';

/// Schermata di login (RF7) — equivalente di `LoginFragment` + fragment_login.xml.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  LoginViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Qui (e non in initState) si può leggere l'InheritedWidget.
    // Il controllo su null garantisce che il ViewModel nasca una volta sola.
    if (_viewModel == null) {
      _viewModel = LoginViewModel(AppScope.of(context).userRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  /// Equivalente di `osservaViewModel()` nel Fragment: reagisce agli EVENTI
  /// (errore da mostrare una volta, navigazione) e poi li consuma.
  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;
    final errore = vm.errore;
    if (errore != null) {
      mostraMessaggio(context, errore);
      vm.erroreMostrato();
    }
    if (vm.loginRiuscito) {
      vm.navigazioneCompletata();
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _accedi() => _viewModel!.login(_email.text, _password.text);

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // ListenableBuilder si ridisegna a ogni notifyListeners(): è il nostro "observe".
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) => Column(
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
                  onPressed: vm.isLoading ? null : _accedi,
                  child: const Text('Accedi'),
                ),
                Caricamento(visibile: vm.isLoading),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, Routes.register),
                  child: const Text('Non hai un account? Registrati'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
