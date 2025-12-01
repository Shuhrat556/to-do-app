import 'package:flutter/material.dart';

import 'injection/injection_container.dart';
import 'src/app.dart';
export 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const ToDoProApp());
}
