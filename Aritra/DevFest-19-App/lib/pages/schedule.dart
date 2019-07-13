// Flutter plugin imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';

// Data imports
import 'package:devfest19/data/sessionResponse.dart';
import 'package:devfest19/data/item.dart';

//pages import
import './error.dart';

// Utils imports
import './utils/sessionCard.dart';
import './utils/drawer.dart';
import './utils/drawerInfo.dart';

Future<List<SessionResponse>> fetchSessionResponse(
    http.Client client, BuildContext context) async {
  try {
    final response = await client
        .get('https://sessionize.com/api/v2/f0dxidzh/view/sessions');
    return compute(parseSessionResponse, response.body);
  } on SocketException catch (_) {
    selection(0);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ErrorPage(
                  message:
                      "Can't reach the servers, \n Please check your internet connection.",
                )));
  }
}

List<SessionResponse> parseSessionResponse(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<SessionResponse>((json) => SessionResponse.fromJson(json))
      .toList();
}

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  //slot,title,speaker,tags,level,venue
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  // Method which executes on pushing "Back Button"
  Future<bool> _willPopCallback() async {
    // Puts the flag up for "home", in drawer
    selection(0);
    // Pops until the last page remain
    Navigator.popUntil(context, ModalRoute.withName('/'));
    return false; // return true if the route to be popped
  }

  bool isBookmarked = false;
  bool isAdded = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          iconTheme: new IconThemeData(color: Colors.black87),
          title: Text(
            'Schedule',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          elevation: 5.0,
          backgroundColor: Colors.white,
        ),
        drawer: myDrawer(),
        body: FutureBuilder<List<SessionResponse>>(
          future: fetchSessionResponse(http.Client(), context),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);
            return snapshot.hasData
                ? SessionResponseItem(sessionResponse: snapshot.data)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class SessionResponseItem extends StatelessWidget {
  Item i = new Item();
  final List<SessionResponse> sessionResponse;
  SessionResponseItem({Key key, this.sessionResponse}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessionResponse[0].sessionsList.length,
      itemBuilder: (context, index) {
        return SessionCard(
          false,
          false,
          // Start Time
          sessionResponse[0].sessionsList[index].startsAt.toString(),
          // Title
          sessionResponse[0].sessionsList[index].title.toString(),
          // Speakers
          sessionResponse[0].sessionsList[index].speakers[0].name.toString(),
          // "tags",
          sessionResponse[0]
              .sessionsList[index]
              .categories[1]
              .categoryItems[0]
              .name
              .toString(),
          // hardness
          sessionResponse[0]
              .sessionsList[index]
              .categories[2]
              .categoryItems[0]
              .name
              .toString(),
          // Room
          sessionResponse[0].sessionsList[index].room.toString(),
          //description
          sessionResponse[0].sessionsList[index].description.toString(),
        );
      },
    );
  }
}
