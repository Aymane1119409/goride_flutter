/// Controllo del formato email usato da login, registrazione e recupero password
/// (al posto di `android.util.Patterns.EMAIL_ADDRESS` della versione Kotlin).
final RegExp formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool emailValida(String email) => formatoEmail.hasMatch(email);
