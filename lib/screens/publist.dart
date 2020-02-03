import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PublicationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PublicationListState();
}

class PublicationListState extends State<PublicationList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPost(),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        print(snapshot.hasData);
        if (snapshot.hasData) {
          dynamic pubList = json.decode(snapshot.data.body);
          print(pubList['metadata']);

          return Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(pubList['metadata']['title']),
              ),
              body: ListView.builder(
                itemCount: pubList['publications'].length,
                itemBuilder: (BuildContext context, int index) {
                  dynamic item = pubList['publications'][index];

                  return FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        print(item['metadata']);
                      },
                      color: index % 2 == 0 ? Colors.blue[300] : Colors.blue,
                      child: Text(
                        "${item['metadata']['title']}",
                        textAlign: TextAlign.left,
                      ));
                },
              ));
        }

        return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Future<http.Response> fetchPost() {
    return http.get('https://readium2.herokuapp.com/opds2/publications.json');
  }
}
