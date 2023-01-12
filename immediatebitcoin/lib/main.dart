import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'localization/AppLanguage.dart';
import 'localization/app_localization.dart';
import 'portfoliopage.dart';
import 'trendsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(MyApp(
    appLanguage: appLanguage,
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage? appLanguage;
  MyApp({this.appLanguage});

  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage!,
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorObservers: const [
              // FirebaseAnalyticsObserver(analytics: analytics)
            ],
            title: 'Bitcoin',
            theme: ThemeData(
              textTheme: GoogleFonts.openSansTextTheme(),
            ),
            locale: model.appLocal,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', ''),
              Locale('de', ''),
              Locale('es', ''),
              Locale('fi', ''),
              Locale('fr', ''),
              Locale('it', ''),
              Locale('nl', ''),
              Locale('nb', ''),
              Locale('pt', ''),
              Locale('ru', ''),
              Locale('sv', '')
            ],
            routes: <String, WidgetBuilder>{
              '/myHomePage': (BuildContext context) => MyHomePage(),
              '/homePage': (BuildContext context) => PortfolioPage(),
              '/driftPage': (BuildContext context) => TrendsPage(),
            },
            home: Provider<FirebaseAnalytics>(
                create: (context) => analytics, child: MyHomePage()),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/image/Splash.png',
              fit: BoxFit.fitHeight,
              height: MediaQuery.of(context).size.height,
            ),
          ],
        ));
  }

  @override
  void initState() {
    homePage();
    super.initState();
  }

  Future<void> homePage() async {
    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      Navigator.of(context).pushReplacementNamed('/homePage');
    });
  }
}
