import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? titleWidget; // Added titleWidget
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? bottom;
  final bool showAppBar;
  final bool centerTitle;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.title = '', // Made optional with default empty string
    this.titleWidget, // Initialize
    this.actions,
    this.drawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottom,
    this.showAppBar = true,
    this.centerTitle = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Cross-platform check for iOS style
    final bool isIOS =
        !kIsWeb && Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColorScheme.background,
      drawer: drawer,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: AppColorScheme.background,
              elevation: 0,
              centerTitle: centerTitle,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(
                        isIOS
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_back_rounded,
                        color: AppColorScheme.textMain,
                        size: isIOS ? 22 : 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : (drawer != null
                        ? Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: AppColorScheme.textMain,
                              ),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            ),
                          )
                        : null),
              title:
                  titleWidget ?? // Use titleWidget if provided
                  (title.isEmpty
                      ? null
                      : Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColorScheme.textMain,
                              ),
                        )),
              actions: actions,
              bottom: bottom,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
