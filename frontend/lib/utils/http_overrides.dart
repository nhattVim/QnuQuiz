import 'dart:io';

/// HTTP overrides to handle SSL certificate issues in development
/// WARNING: This disables certificate verification - ONLY use in development!
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Only allow for Appwrite cloud endpoints in development
        if (host.contains('appwrite.io') || host.contains('cloud.appwrite.io')) {
          return true; // Allow Appwrite cloud certificates
        }
        return false; // Reject other certificates
      };
  }
}

