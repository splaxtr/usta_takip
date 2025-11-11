import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget testlerinde ortak kullanılan sarmalayıcı.
///
/// Varsayılan olarak koyu tema ve MaterialApp ile birlikte çalışır.
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
  Locale? locale,
  Iterable<NavigatorObserver> navigatorObservers = const [],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: theme ?? ThemeData.dark(useMaterial3: true),
      home: Scaffold(body: widget),
      navigatorObservers: [...navigatorObservers],
    ),
  );
  await tester.pumpAndSettle();
}

/// Sadece widget'ı pump etmek için hafif alternatif (Scaffold eklenmez).
Future<void> pumpBareWidget(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? ThemeData.dark(useMaterial3: true),
      home: widget,
    ),
  );
  await tester.pump();
}
