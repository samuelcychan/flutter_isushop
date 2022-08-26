import 'dart:io';

import 'package:cbsdinfo_isu_shop/widget/webview_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'firebase_options.dart';

const ceruleanBlueColor = Color(0xFF2A52B8);
const grayColor = Color(0xFF646464);
const baseUriPath = "https://portal.isu-shop.com";
const smsUriPath = "$baseUriPath/sys/api/Member/MemberRecommendSend";

typedef VoidBoolCallback = void Function(bool val);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  SystemUiOverlayStyle style = const SystemUiOverlayStyle(
    statusBarColor: ceruleanBlueColor,
  );
  SystemChrome.setSystemUIOverlayStyle(style);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool shouldShowSearchBar = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '愛嬉遊',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      routes: <String, WidgetBuilder>{
        '/webview': (_) => const WebviewPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const WebviewPage();
  }
}
