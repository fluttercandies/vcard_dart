import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/editor/editor_page.dart';
import '../pages/export/export_page.dart';
import '../pages/home/home_page.dart';

/// Application route paths.
abstract final class AppRoutes {
  static const String home = '/';
  static const String editor = '/editor';
  static const String editorNew = '/editor/new';
  static const String export = '/export';
}

/// Application router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.editorNew,
      builder: (context, state) => const EditorPage(),
    ),
    GoRoute(
      path: '${AppRoutes.editor}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return EditorPage(contactId: id);
      },
    ),
    GoRoute(
      path: '${AppRoutes.export}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExportPage(contactId: id);
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);

/// Extension for easy navigation.
extension AppRouterExtension on BuildContext {
  /// Navigate to home page.
  void goHome() => go(AppRoutes.home);

  /// Navigate to create new contact.
  void goNewContact() => go(AppRoutes.editorNew);

  /// Navigate to edit contact.
  void goEditContact(String id) => go('${AppRoutes.editor}/$id');

  /// Navigate to export contact.
  void goExport(String id) => go('${AppRoutes.export}/$id');

  /// Go back to previous page.
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      goHome();
    }
  }
}
