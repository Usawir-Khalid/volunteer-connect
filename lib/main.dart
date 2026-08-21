import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);

    debugPrint('════════ FLUTTER ERROR ════════');
    debugPrint(details.exceptionAsString());
    debugPrintStack(stackTrace: details.stack);
    debugPrint('════════ END FLUTTER ERROR ════════');
  };

  // Catch errors that happen outside the Flutter framework.
  ui.PlatformDispatcher.instance.onError = (
    Object error,
    StackTrace stack,
  ) {
    debugPrint('════════ ASYNC ERROR ════════');
    debugPrint(error.toString());
    debugPrintStack(stackTrace: stack);
    debugPrint('════════ END ASYNC ERROR ════════');

    return true;
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: VolunteerConnectApp(),
    ),
  );
}