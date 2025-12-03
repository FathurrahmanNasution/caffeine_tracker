import 'package:flutter/material.dart';

class DeepLinkHandler {
  static void handleLink(BuildContext context, Uri uri) {
    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'];

    if (mode == 'resetPassword' && oobCode != null) {
      Navigator.pushNamed(
        context,
        '/change-password',
        arguments: oobCode,
      );
    }
  }
}