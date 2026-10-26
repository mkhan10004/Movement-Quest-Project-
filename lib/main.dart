import 'package:flutter/material.dart';

import 'data/quest_repository.dart';
import 'data/settings_store.dart';
import 'state/quest_controller.dart';
import 'screens/catalog_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuestBootstrap());
}

class QuestBootstrap extends StatefulWidget {
  const QuestBootstrap({super.key});
  @override
  State<QuestBootstrap> createState() => _QuestBootstrapState();
}

class _QuestBootstrapState extends State<QuestBootstrap> {
  QuestController? controller;
  String? error;
  bool opening = false;
  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    if (opening) return;
    setState(() {
      opening = true;
      error = null;
    });
    QuestRepository? repository;
    try {
      repository = await QuestRepository.open();
      if (!mounted) {
        await repository.close();
        return;
      }
      final next = QuestController(repository, SettingsStore());
      await next.initialize();
      if (!mounted) {
        next.dispose();
        await repository.close();
        return;
      }
      setState(() {
        controller = next;
        opening = false;
      });
    } catch (_) {
      await repository?.close();
      if (mounted)
        setState(() {
          opening = false;
          error = 'Could not open local storage. Retry to continue.';
        });
    }
  }

  @override
  void dispose() {
    final c = controller;
    c?.dispose();
    c?.repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null)
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: error == null
                ? const CircularProgressIndicator()
                : Notice(error!, retry: open),
          ),
        ),
      );
    return QuestApp(controller: c);
  }
}

class QuestApp extends StatelessWidget {
  final QuestController controller;
  const QuestApp({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => MaterialApp(
      title: 'Movement Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff216b59)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff64c8a5),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      themeMode: controller.settings.theme == 'dark'
          ? ThemeMode.dark
          : controller.settings.theme == 'light'
          ? ThemeMode.light
          : ThemeMode.system,
      home: QuestShell(controller: controller),
    ),
  );
}

class QuestShell extends StatefulWidget {
  final QuestController controller;
  const QuestShell({super.key, required this.controller});
  @override
  State<QuestShell> createState() => _QuestShellState();
}

class _QuestShellState extends State<QuestShell> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movement Quest'),
        actions: [
          if (const bool.fromEnvironment('ENABLE_FAILURE_DEMO'))
            IconButton(
              tooltip: 'Reject next database write once',
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                c.repository.rejectNextWrite = true;
                feedback(context, 'Next database write will be rejected once.');
              },
            ),
          IconButton(
            tooltip: 'Refresh saved records',
            onPressed: c.busy ? null : c.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : c.readError != null
          ? Center(child: Notice(c.readError!, retry: c.refresh))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: IndexedStack(
                  index: selected,
                  children: [
                    CatalogScreen(controller: c),
                    HistoryScreen(controller: c),
                    SettingsScreen(controller: c),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: c.busy
            ? null
            : (i) => setState(() => selected = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Catalog',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
    );
  }
}
