import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PublicationRenderer extends StatefulWidget {
  PublicationRenderer({this.webPubHref});

  final String webPubHref;
  @override
  State<StatefulWidget> createState() => PublicationRendererState();
}

class PublicationRendererState extends State<PublicationRenderer> {
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
          dynamic resources = webPub['resources'];
          dynamic toc = webPub['toc'];
          dynamic pageList = webPub['page-list'];
          dynamic landmarks = webPub['landmarks'];
          print(json.encode(toc));
          return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(title),
            ),
            body: Center(
              child: Text('Loaded'),
            ),
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

  Widget _makeDrawer(context, dynamic webPub) {
    List<Widget> children = [
      DrawerHeader(
        child: Text('Drawer Header'),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
      Semantics(
        header: true,
        child: ListTile(
          title: Text(
            'Table of Content',
            style: TextStyle(fontWeight: FontWeight.bold),
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
      tocWidgets.add(ListTile(
        title: Text(tocItem['title']),
        contentPadding: EdgeInsets.fromLTRB(
          16 * (depth + 1),
          16,
          16,
          16,
        ),
        onTap: () {
          print(tocItem['href']);

          Navigator.pop(context);
        },
      ));

      if (tocItem['children'] != null) {
        tocWidgets.addAll(_makeToc(context, tocItem['children'], depth + 1));
      }
    }

    return tocWidgets;
  }

  Future<http.Response> fetchWebPublication() async {
    return http.get(widget.webPubHref);
  }
}
