import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PublicationRenderer extends StatefulWidget {
  PublicationRenderer({this.webPubHref});

  final String webPubHref;
  @override
  State<StatefulWidget> createState() => PublicationRendererState();
}

class PublicationRendererState extends State<PublicationRenderer> {
  final Completer<WebViewController> _webViewController =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchWebPublication(),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          dynamic webPub = json.decode(snapshot.data.body);
          dynamic metadata = webPub['metadata'];
          dynamic title = metadata['title'];

          dynamic readingOrder = webPub['readingOrder'];

          String initialUrl = _resolveUrl(readingOrder[1]['href']);

          return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(title),
            ),
            body: _makeWebView(initialUrl),
            drawer: _makeDrawer(context, webPub),
          );
        }

        return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text('Loading...'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Builder _makeWebView(String initialUrl) {
    return Builder(
      builder: (context) {
        return WebView(
          debuggingEnabled: true,
          initialUrl: initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController.complete(webViewController);

            webViewController.loadUrl(initialUrl);
          },
          navigationDelegate: (NavigationRequest request) {
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
        );
      },
    );
  }

  Widget _makeDrawer(context, dynamic webPub) {
    dynamic metadata = webPub['metadata'];
    dynamic title = metadata['title'];

    List<Widget> children = [
      Semantics(
        child: DrawerHeader(
          child: Text(title),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
      ),
      Semantics(
        header: true,
        child: ListTile(
          title: Text(
            'Indholdsfortegnelse',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      )
    ];

    children.addAll(_makeToc(context, webPub['toc'], 0));

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }

  List<Widget> _makeToc(context, dynamic tocItems, double depth) {
    List<Widget> tocWidgets = List<Widget>();
    for (var i = 0; i < tocItems.length; i += 1) {
      dynamic tocItem = tocItems[i];
      String itemHref = tocItem['href'];
      String itemTitle = tocItem['title'];

      tocWidgets.add(
        Semantics(
          hint: itemHref != null ? 'Go to' : null,
          button: itemHref != null,
          header: itemHref == null,
          child: ListTile(
            title: Text(
              itemTitle,
              style: TextStyle(fontWeight: itemHref != null ? FontWeight.normal : FontWeight.bold),
            ),
            contentPadding: EdgeInsets.fromLTRB(
              16 * (depth + 1),
              0,
              16,
              0,
            ),
            onTap: () {
              if (itemHref != null) {
                _loadUrl(itemHref);
              }

              Navigator.pop(context);
            },
          ),
        ),
      );

      if (tocItem['children'] == null) {
        continue;
      }

      tocWidgets.addAll(_makeToc(context, tocItem['children'], depth + 1));
    }

    return tocWidgets;
  }

  String _resolveUrl(String localUri) {
    Uri uri = Uri.parse(widget.webPubHref);

    return uri.resolve(localUri).toString();
  }

  void _loadUrl(String localUri) async {
    WebViewController webViewController = await _webViewController.future;
    webViewController.loadUrl(_resolveUrl(localUri));
  }

  Future<http.Response> fetchWebPublication() {
    return http.get(widget.webPubHref);
  }
}
