import 'dart:convert';
import 'dart:math';
import 'dart:ui_web' as ui_web;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_identity_services_web/id.dart' as google_id;
import 'package:google_identity_services_web/loader.dart' as google_loader;
import 'package:web/web.dart' as web;

import 'google_web_credential.dart';

int _viewCounter = 0;

Widget buildGoogleSignInAction(
  BuildContext context, {
  required VoidCallback? onPressed,
  required ValueChanged<GoogleWebCredential> onWebCredential,
}) {
  return _GoogleIdentityButton(
    enabled: onPressed != null,
    onPressed: onPressed,
    onCredential: onWebCredential,
  );
}

class _GoogleIdentityButton extends StatefulWidget {
  const _GoogleIdentityButton({
    required this.enabled,
    required this.onPressed,
    required this.onCredential,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final ValueChanged<GoogleWebCredential> onCredential;

  @override
  State<_GoogleIdentityButton> createState() => _GoogleIdentityButtonState();
}

class _GoogleIdentityButtonState extends State<_GoogleIdentityButton> {
  late final String _viewType = 'wicara_google_sign_in_${_viewCounter++}';
  late final String _rawNonce = _generateNonce();
  late final String _hashedNonce = sha256
      .convert(utf8.encode(_rawNonce))
      .toString();

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = web.HTMLDivElement();
      _renderButton(element);
      return element;
    });
  }

  void _renderButton(web.HTMLDivElement element) {
    google_loader.loadWebSdk().then((_) {
      final clientId = _resolveGoogleClientId();
      if (clientId == null) {
        element.textContent =
            'Google Sign-In is not configured. Set WICARA_GOOGLE_WEB_CLIENT_ID.';
        element.style
          ..color = '#8A1C1C'
          ..fontSize = '13px'
          ..padding = '12px'
          ..textAlign = 'center';
        return;
      }
      google_id.id.initialize(
        google_id.IdConfiguration(
          client_id: clientId,
          callback: _handleCredential,
          nonce: _hashedNonce,
          use_fedcm_for_prompt: true,
          cancel_on_tap_outside: false,
        ),
      );
      google_id.id.renderButton(
        element,
        google_id.GsiButtonConfiguration(
          type: google_id.ButtonType.standard,
          theme: google_id.ButtonTheme.outline,
          size: google_id.ButtonSize.large,
          text: google_id.ButtonText.continue_with,
          shape: google_id.ButtonShape.rectangular,
          logo_alignment: google_id.ButtonLogoAlignment.left,
          width: 372,
          click_listener: (_) => widget.onPressed?.call(),
        ),
      );
    });
  }

  void _handleCredential(google_id.CredentialResponse response) {
    final credential = response.credential;
    if (credential == null || credential.isEmpty) {
      return;
    }
    widget.onCredential(
      GoogleWebCredential(idToken: credential, nonce: _rawNonce),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1 : 0.58,
      child: AbsorbPointer(
        absorbing: !widget.enabled,
        child: SizedBox(
          width: double.infinity,
          height: 47,
          child: HtmlElementView(viewType: _viewType),
        ),
      ),
    );
  }
}

String? _resolveGoogleClientId() {
  const compiledValue = String.fromEnvironment('WICARA_GOOGLE_WEB_CLIENT_ID');
  final configured = compiledValue.trim();
  if (_isUsableGoogleClientId(configured)) return configured;

  final metaValue = web.document
      .querySelector('meta[name="google-signin-client_id"]')
      ?.getAttribute('content')
      ?.trim();
  return _isUsableGoogleClientId(metaValue) ? metaValue : null;
}

bool _isUsableGoogleClientId(String? value) {
  return value != null &&
      value.isNotEmpty &&
      !value.startsWith('YOUR_') &&
      value.endsWith('.apps.googleusercontent.com');
}

String _generateNonce() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}
