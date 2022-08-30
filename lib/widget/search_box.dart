import 'package:cbsdinfo_isu_shop/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SearchBox extends StatelessWidget {
  SearchBox({
    Key? key,
    required this.webviewController,
  }) : super(key: key);

  final textEditController = TextEditingController();
  final InAppWebViewController? webviewController;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 20,
        left: 20,
        child: Container(
            padding: const EdgeInsets.only(
                left: 14.0, top: 10.0, bottom: 10.0, right: 14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            width: MediaQuery.of(context).size.width - 40,
            child: TextField(
              controller: textEditController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name != "/") {
                    Navigator.of(context).pop();
                  }
                  webviewController?.loadUrl(
                      urlRequest: URLRequest(
                          url: Uri.parse(
                              "$baseUriPath/search?key=${textEditController.text}")));
                },
              )),
            )));
  }
}
