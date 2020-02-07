import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webview_test1/screens/publication-renderer.dart';
import 'package:http/http.dart' as http;
import 'package:local_assets_server/local_assets_server.dart';

class PublicationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PublicationListState();
}

class PublicationListState extends State<PublicationList> {
  bool _isListening = false;
  String _address;
  int _port;
  LocalAssetsServer _server;

  get _baseUrl => 'http://$_address:$_port/';

  @override
  void initState() {
    _initServer();

    super.initState();
  }

  void _initServer() async {
    _server = new LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/streamer',
    );

    final address = await _server.serve();

    print(address);

    setState(() {
      _address = address.address;
      _port = _server.boundPort;
      _isListening = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isListening) {
      return _makeLoading();
    }

    return FutureBuilder(
      future: fetchOPDSFeed(),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data.headers);
          print(snapshot.data.statusCode);
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
                    leading: src != null ? Image.network(_resolveToLocalUrl(src)) : null,
                    onTap: () {
                      print(href);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PublicationRenderer(
                                    webPubHref: _resolveToLocalUrl(href),
                                    baseUrl: _baseUrl,
                                  )));
                    },
                  ),
                );
              },
            ),
          );
        }

        return _makeLoading();
      },
    );
  }

  Widget _makeLoading() {
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
  }

  String _resolveToLocalUrl(String url) {
    return url.replaceAll('https://readium2.herokuapp.com/', _baseUrl);
  }

  Future<http.Response> fetchOPDSFeed() async {
    String url = _resolveToLocalUrl('https://readium2.herokuapp.com/opds2/publications.json');
    print(url);
    try {
      return await http.get(url);
    } catch (err) {
      print(
          err); // retry, herokuapp generates the feed on the first request and delivers it on the following requests
      return await http.get(url);
    }
  }
}
