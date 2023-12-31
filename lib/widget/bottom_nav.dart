import 'package:isushop/invite.dart';
import 'package:isushop/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar(
      {Key? key, required this.token, required this.callback, this.controller})
      : super(key: key);

  final String? token;
  final VoidBoolCallback callback;
  final InAppWebViewController? controller;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;
  double screenWidth = 0;
  bool shouldShowSearchBar = false;
  final textFieldController = TextEditingController();
  final GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return BottomNavigationBar(
      key: bottomNavigationKey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: ceruleanBlueColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 0) {
            shouldShowSearchBar = false;
            widget.callback(shouldShowSearchBar);
            // Navigator.of(context).pushNamed('/', arguments: {"path": "/"});
            if (ModalRoute.of(context)?.settings.name != "/" &&
                ModalRoute.of(context)?.settings.name != "/webview") {
              Navigator.of(context).pop();
            }
            widget.controller
                ?.loadUrl(urlRequest: URLRequest(url: Uri.parse(baseUriPath)));
          }
          if (index == 1) {
            shouldShowSearchBar = false;
            widget.callback(shouldShowSearchBar);
            if (ModalRoute.of(context)?.settings.name != "/invite") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InvitePage(
                            token: widget.token ?? "",
                            controller: widget.controller,
                          ),
                      settings: const RouteSettings(name: "/invite")));
            }
          }
          if (index == 2) {
            shouldShowSearchBar = !shouldShowSearchBar;
            widget.callback(shouldShowSearchBar);
          }
          if (index == 3) {
            showPopupMenu(context);
          }
        });
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/icons/isu_home.png'),
          label: AppLocalizations.of(context)!.homeNavBtn,
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/icons/isu_share.png'),
          label: AppLocalizations.of(context)!.inviteNavBtn,
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/icons/isu_search.png'),
          label: AppLocalizations.of(context)!.searchNavBtn,
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/icons/isu_member.png'),
          label: AppLocalizations.of(context)!.memberNavBtn,
        ),
      ],
    );
  }

  void showPopupMenu(BuildContext context) async {
    shouldShowSearchBar = false;
    widget.callback(shouldShowSearchBar);
    await showMenu(
      context: context,
      position: bottomNavigationPosition(context),
      items: <PopupMenuItem<String>>[
        PopupMenuItem(
            value: 'member_info',
            child: Text(AppLocalizations.of(context)!.memberInfo)),
        PopupMenuItem(
            value: 'reset_password',
            child: Text(AppLocalizations.of(context)!.resetPassword)),
        PopupMenuItem(
            value: 'my_coupon',
            child: Text(AppLocalizations.of(context)!.myCoupon)),
        PopupMenuItem(
            value: 'my_premium',
            child: Text(AppLocalizations.of(context)!.myPremium)),
        PopupMenuItem(
            value: 'logout', child: Text(AppLocalizations.of(context)!.logout)),
      ],
    ).then((value) {
      if (value == null) return;
      if (ModalRoute.of(context)?.settings.name != "/" &&
          ModalRoute.of(context)?.settings.name != "/webview") {
        Navigator.of(context).pop();
      }
      switch (value) {
        case "member_info":
          {
            // Navigator.of(context).pushNamed('/webview',
            //     arguments: {'token': widget.token, 'path': '/member/info'});
            widget.controller?.loadUrl(
                urlRequest:
                    URLRequest(url: Uri.parse("$baseUriPath/member/info")));
          }
          break;
        case "reset_password":
          {
            // Navigator.of(context).pushNamed('/webview', arguments: {
            //   'token': widget.token,
            //   'path': '/member/resetPassword'
            // });
            widget.controller?.loadUrl(
                urlRequest: URLRequest(
                    url: Uri.parse("$baseUriPath/member/resetPassword")));
          }
          break;
        case "my_coupon":
          {
            // Navigator.of(context).pushNamed('/webview',
            //     arguments: {'token': widget.token, 'path': '/member/coupon'});
            widget.controller?.loadUrl(
                urlRequest:
                    URLRequest(url: Uri.parse("$baseUriPath/member/coupon")));
          }
          break;
        case "my_premium":
          {
            // Navigator.of(context).pushNamed('/webview',
            //     arguments: {'token': widget.token, 'path': '/member/rules'});
            widget.controller?.loadUrl(
                urlRequest:
                    URLRequest(url: Uri.parse("$baseUriPath/member/rules")));
          }
          break;
        case "logout":
          {
            // Navigator.of(context).pushNamed('/webview',
            //     arguments: {'token': widget.token, 'path': '/logout'});
            widget.controller?.loadUrl(
                urlRequest: URLRequest(url: Uri.parse("$baseUriPath/logout")));
          }
          break;
        default:
          break;
      }
    });
  }

  void showSearchPopupMenu(BuildContext context) async {
    await showMenu(
      context: context,
      position: searchTextFieldPosition(context),
      items: <PopupMenuItem<String>>[
        PopupMenuItem(
          value: 'search',
          child: SizedBox(
              width: screenWidth - 15,
              child: TextField(
                controller: textFieldController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/webview', arguments: {
                      'token': widget.token,
                      'path': '/search?key=${textFieldController.text}'
                    });
                  },
                )),
              )),
        ),
      ],
    );
  }

  RelativeRect bottomNavigationPosition(BuildContext context) {
    final RenderBox bar =
        bottomNavigationKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(bottomNavigationKey.currentContext!)!
        .context
        .findRenderObject() as RenderBox;
    const Offset offset = Offset(0, -280);
    return RelativeRect.fromRect(
        Rect.fromPoints(
          bar.localToGlobal(bar.size.topRight(offset), ancestor: overlay),
          bar.localToGlobal(bar.size.topRight(offset), ancestor: overlay),
        ),
        Offset.zero & overlay.size);
  }

  RelativeRect searchTextFieldPosition(BuildContext context) {
    final RenderBox bar =
        bottomNavigationKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(bottomNavigationKey.currentContext!)!
        .context
        .findRenderObject() as RenderBox;
    const Offset offset = Offset(15, -70);
    return RelativeRect.fromRect(
        Rect.fromPoints(
          bar.localToGlobal(bar.size.topLeft(offset), ancestor: overlay),
          bar.localToGlobal(bar.size.topRight(offset.translate(-30.0, 0.0)),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size);
  }
}
