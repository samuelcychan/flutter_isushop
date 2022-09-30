import 'package:isushop/main.dart';
import 'package:isushop/widget/bottom_nav.dart';
import 'package:isushop/widget/search_box.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({Key? key}) : super(key: key);

  @override
  State<WebviewPage> createState() => _WebviewState();
}

class _WebviewState extends State<WebviewPage> {
  final GlobalKey webviewKey = GlobalKey();
  String? token = "";
  String fcmToken = "";
  bool shouldShowBottomNav = false;
  bool shouldShowSearchBar = false;
  bool shouldShowFAB = false;

  TextEditingController textFieldController = TextEditingController();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  @override
  void initState() {
    super.initState();
    checkGeolocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    dynamic obj = ModalRoute.of(context)?.settings.arguments;
    token ??= obj?["token"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ceruleanBlueColor,
        toolbarHeight: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
          onWillPop: () async {
            if ((await webViewController?.canGoBack()) ?? false) {
              webViewController!.goBack();
              return false;
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return false;
            }
            return true;
          },
          child: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webviewKey,
                        initialUrlRequest: URLRequest(
                            url:
                                Uri.parse("$baseUriPath${obj?['path'] ?? ''}")),
                        initialOptions: options,
                        onWebViewCreated: (controller) async {
                          fcmToken =
                              await FirebaseMessaging.instance.getToken() ?? "";
                          final expiresDate = DateTime.now()
                              .add(const Duration(days: 1))
                              .millisecondsSinceEpoch;
                          CookieManager manager = CookieManager.instance();
                          if (fcmToken.isNotEmpty) {
                            debugPrint(fcmToken);
                            await manager.setCookie(
                              url: Uri.parse(baseUriPath),
                              name: "deviceToken",
                              value: fcmToken,
                              domain: "portal.isu-shop.com",
                              expiresDate: expiresDate,
                              isSecure: false,
                            );
                          }
                          await manager.setCookie(
                            url: Uri.parse(baseUriPath),
                            name: "isHidden",
                            value: "1",
                            domain: "portal.isu-shop.com",
                            expiresDate: expiresDate,
                            isSecure: false,
                          );
                          webViewController = controller;
                          controller.addJavaScriptHandler(
                              handlerName: "launchMazuApp",
                              callback: (args) {
                                LaunchApp.openApp(
                                  androidPackageName:
                                      'com.keynovation.mazuaround',
                                  iosUrlScheme: 'mazuaround://',
                                  appStoreLink:
                                      'https://apps.apple.com/us/app/媽祖環禱/id1642334332',
                                );
                              });
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) async {
                          if (url.toString().contains("login") ||
                              url.toString().contains("logout")) {
                            shouldShowBottomNav = false;
                          } else {
                            shouldShowBottomNav = true;
                          }
                          shouldShowFAB = !checkIsuDomain(url.toString());
                          CookieManager manager = CookieManager.instance();
                          Cookie? cookie = await manager.getCookie(
                              url: Uri.parse("https://portal.isu-shop.com/"),
                              name: "Authorization");
                          setState(() {
                            token = cookie?.value?.toString() ?? "";
                          });
                        },
                        androidOnGeolocationPermissionsShowPrompt:
                            (InAppWebViewController controller,
                                String origin) async {
                          return GeolocationPermissionShowPromptResponse(
                              origin: origin, allow: true, retain: true);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url;
                          if (uri?.scheme.startsWith("mailto") ?? false) {
                            if (uri != null) {
                              Share.share(
                                  uri.queryParameters["body"].toString(),
                                  subject: uri.queryParameters["subject"]
                                      .toString());
                              return NavigationActionPolicy.CANCEL;
                            }
                          }
                          if (uri?.scheme.startsWith("tel") ?? false) {
                            if (uri != null) {
                              await launchUrl(
                                uri,
                              );
                            }
                            return NavigationActionPolicy.CANCEL;
                          }
                          return NavigationActionPolicy.ALLOW;
                        },
                      ),
                      Visibility(
                          visible: shouldShowSearchBar,
                          child: SearchBox(
                            callback: (val) => setState(() {
                              shouldShowSearchBar = val;
                            }),
                            webviewController: webViewController,
                          )),
                    ],
                  ),
                ),
              ]))),
      bottomNavigationBar: (token?.isNotEmpty ?? false) && shouldShowBottomNav
          ? BottomNavBar(
              token: token,
              callback: (val) => setState(() {
                shouldShowSearchBar = val;
              }),
              controller: webViewController,
            )
          : null,
      floatingActionButton: (shouldShowFAB)
          ? Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: FloatingActionButton(
                onPressed: () {
                  webViewController?.goBack();
                },
                backgroundColor: ceruleanBlueColor,
                child: const Icon(Icons.arrow_back),
              ))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  void checkGeolocationPermission() async {
    await [
      Permission.locationWhenInUse,
    ].request();
    final status = await Permission.locationWhenInUse.status;
    if (status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  bool checkIsuDomain(String url) {
    return url.contains(baseUriPath);
  }
}
