import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_test1/screens/publication-renderer.dart';
import 'package:http/http.dart' as http;

class PublicationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PublicationListState();
}

class PublicationListState extends State<PublicationList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchOPDSFeed(),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          dynamic opdsFeed = json.decode(snapshot.data.body);

          dynamic feedMetadata = opdsFeed['metadata'];
          dynamic title = feedMetadata['title'];
          dynamic numberOfItems = feedMetadata['numberOfItems'];
          dynamic publications = opdsFeed['publications'];

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: ListView.builder(
              itemCount: numberOfItems,
              itemBuilder: (BuildContext context, int index) {
                dynamic publication = publications[index];
                dynamic pubMetadata = publication['metadata'];
                String title = pubMetadata['title'];
                String src = publication['images'][0]["href"];

                String href = publication['links'][0]["href"];

                return Container(
                  color: index % 2 != 0 ? Colors.grey[300] : Colors.grey[100],
                  child: ListTile(
                    title: Text(title),
                    leading: src != null ? Image.network(src) : null,
                    onTap: () {
                      print(href);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PublicationRenderer(
                                    webPubHref: href,
                                  )));
                    },
                  ),
                );
              },
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

  Future<http.Response> fetchOPDSFeed() async {
    return http.get('https://readium2.herokuapp.com/opds2/publications.json');
  }
}
