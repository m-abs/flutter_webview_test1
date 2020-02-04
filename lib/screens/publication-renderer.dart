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
          return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text('Loaded'),
            ),
            body: Center(
              child: Text('Loaded'),
            ),
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

  Future<http.Response> fetchWebPublication() async {
    return http.get(widget.webPubHref);
  }
}
