// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Servicio de Vecinos';

  @override
  String get activityHistory => 'Historial de Actividad';

  @override
  String get noActivityFound => 'No se encontró historial de actividad.';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get profileUpdated => 'Perfil actualizado con éxito';

  @override
  String get failedToUpdateProfile => 'Error al actualizar el perfil';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get requiredField => 'Este campo es obligatorio';
}


