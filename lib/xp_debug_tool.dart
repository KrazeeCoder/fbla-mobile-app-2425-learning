import 'utils/app_logger.dart';

/// A simple test function to verify that the logger is working correctly
void testLogger() {
  AppLogger.i('Testing info logging');
  AppLogger.d('Testing debug logging');
  AppLogger.w('Testing warning logging');
  AppLogger.e('Testing error logging', error: Exception('Test exception'));

  // The logger output should appear in the console
  // This confirms that the logger is working correctly
}
