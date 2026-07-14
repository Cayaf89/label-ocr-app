import 'package:go_router/go_router.dart';
import '../screens/template_list_screen.dart';
import '../screens/template_screen.dart';
import '../screens/scan_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'template-list',
      builder: (context, state) => const TemplateListScreen(),
    ),
    GoRoute(
      path: '/templates/new',
      name: 'template-create',
      builder: (context, state) => const TemplateScreen(templateId: null),
    ),
    GoRoute(
      path: '/templates/:id/configure',
      name: 'template-configure',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TemplateScreen(templateId: id);
      },
    ),
    GoRoute(
      path: '/scan',
      name: 'scan',
      builder: (context, state) => const ScanScreen(),
    ),
  ],
);
