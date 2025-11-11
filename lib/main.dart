import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/bootstrap/bootstrap.dart';

Future<void> main() async {
  final dependencies = await bootstrapApplication();
  runApp(UstaTakipApp(dependencies: dependencies));
}
