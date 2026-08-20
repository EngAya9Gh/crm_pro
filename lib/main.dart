import 'package:flutter/material.dart';
import 'package:crm_wakeel/core/utils/responsive_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/config/theme/color_scheme.dart';
import 'core/services/di/di_container.dart';
import 'core/utils/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_bloc.dart';
import 'package:crm_wakeel/features/settings/presentation/bloc/lookups_event.dart';
import 'features/splash/presentation/views/splash_screen.dart';

import 'package:crm_wakeel/core/utils/simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Bloc Observer
  Bloc.observer = SimpleBlocObserver();

  // Initialize Dependency Injection
  await initDi();

  runApp(const WakeelCRM());
}

class WakeelCRM extends StatelessWidget {
  const WakeelCRM({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Responsive Helper
    ResponsiveHelper.init(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(
          create: (_) => getIt<LookupsBloc>()..add(LoadAllLookups()),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        // Localization
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Theme
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.tajawal().fontFamily,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColorScheme.primary,
            primary: AppColorScheme.primary,
            secondary: AppColorScheme.secondary,
            surface: AppColorScheme.background,
            error: AppColorScheme.error,
          ),
          scaffoldBackgroundColor: AppColorScheme.background,
          textTheme: GoogleFonts.tajawalTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColorScheme.background,
            elevation: 0,
            centerTitle: true,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
