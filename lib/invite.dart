import 'dart:convert';
import 'dart:io';

import 'package:isushop/main.dart';
import 'package:isushop/widget/bottom_nav.dart';
import 'package:isushop/widget/search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

const smsBody = "test";

class InvitePage extends StatefulWidget {
  const InvitePage({Key? key, required this.token, this.controller})
      : super(key: key);

  final String token;
  final InAppWebViewController? controller;

  @override
  State<InvitePage> createState() => _ShareState();
}

class _ShareState extends State<InvitePage> {
  List<Contact>? contacts;
  Map<Contact, bool> selectedItem = {};
  bool shouldShowSearchBar = false;
  AppLocalizations? appLocalizations;
  ScaffoldMessengerState? scaffoldMessengerState;
  final textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  void getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      var fullContacts =
          await FlutterContacts.getContacts(withProperties: true);
      contacts = fullContacts.where((x) => x.phones.isNotEmpty).toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);
    scaffoldMessengerState = ScaffoldMessenger.of(context);
    return Stack(children: <Widget>[
      Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            image: AssetImage("assets/images/header_bg.png"),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
      Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(child: inviteContent()),
        bottomNavigationBar: BottomNavBar(
          token: widget.token,
          callback: (val) => setState(() {
            shouldShowSearchBar = val;
          }),
          controller: widget.controller,
        ),
      ),
    ]);
  }

  Widget inviteContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          Column(children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 60.0, left: 14.0, right: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Html(
                data: appLocalizations?.inviteDescription,
              ),
            ),
            Expanded(
              child: Container(
                  margin: const EdgeInsets.only(
                      left: 15.0, top: 12.0, right: 15.0, bottom: 12.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: ListView.separated(
                    itemCount: contacts?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 9.0),
                                child:
                                    Text(appLocalizations?.inviteList ?? "")),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(appLocalizations?.invitee ?? ""),
                                    Text(
                                        "${selectedItem.entries.length}/${contacts?.length ?? 0} ${appLocalizations?.selectedInvitee}")
                                  ],
                                )),
                            const Divider(),
                            listItem(index),
                          ],
                        );
                      } else {
                        return listItem(index);
                      }
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                  )),
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 14.0, right: 14.0, bottom: 13.0),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Image.asset("assets/images/icons/isu_invite.png"),
                      label: Text(appLocalizations?.directInvite ?? ""),
                      onPressed: () async {
                        String notifyMsg = appLocalizations?.smsSent ?? "";
                        await Future.forEach(selectedItem.keys, (key) async {
                          final response = await http.post(
                            Uri.parse(smsUriPath),
                            headers: {
                              HttpHeaders.authorizationHeader:
                                  "Bearer ${widget.token}",
                              HttpHeaders.contentTypeHeader: "application/json",
                            },
                            body: json.encode({
                              'telephone': (key as Contact).phones.first.number,
                              'smsMessage': appLocalizations?.inviteDescription,
                            }),
                          );
                          if (response.statusCode != 200) {
                            notifyMsg = appLocalizations?.smsNotSent ?? "";
                          }
                        });
                        var snack = SnackBar(content: Text(notifyMsg));
                        scaffoldMessengerState?.showSnackBar(snack);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                    )))
          ]),
          Visibility(
              visible: shouldShowSearchBar,
              child: SearchBox(
                webviewController: widget.controller,
              )),
        ],
      ),
    );
  }

  CheckboxListTile listItem(index) {
    return CheckboxListTile(
        title: Text(contacts?[index].displayName ?? ""),
        value: selectedItem[contacts?[index]] ?? false,
        onChanged: (value) {
          if (!(value ?? false)) {
            selectedItem.remove(contacts?[index]);
          } else {
            if (contacts?.isNotEmpty ?? false) {
              selectedItem[contacts![index]] = true;
            }
          }
          setState(() {});
        });
  }
}
