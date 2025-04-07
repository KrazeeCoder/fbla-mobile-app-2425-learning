import 'package:logger/logger.dart';

/// A utility class for logging across the app.
/// Uses the logger package to provide better logging than print statements.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Log debug information
  static void d(String message, {dynamic data}) {
    _logger.d('$message${data != null ? ' $data' : ''}');
  }

  /// Log informational messages
  static void i(String message, [dynamic data]) {
    _logger.i('$message${data != null ? ' $data' : ''}');
  }

  /// Log warning messages
  static void w(String message, [dynamic data]) {
    _logger.w('$message${data != null ? ' $data' : ''}');
  }

  /// Log error messages
  static void e(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
