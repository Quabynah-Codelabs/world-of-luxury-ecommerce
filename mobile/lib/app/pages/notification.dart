import 'package:flutter/material.dart';
import 'package:handyman/domain/services/messaging.dart';

class NotificationPage extends StatefulWidget {
  final NotificationPayload payload;

  const NotificationPage({Key key, this.payload}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double _kWidth, _kHeight;
  ThemeData _themeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _themeData = Theme.of(context);
    final size = MediaQuery.of(context).size;
    _kWidth = size.width;
    _kHeight = size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Text(
          widget.payload.payloadType.toString(),
          style: _themeData.textTheme.headline4,
        ),
      ),
    );
  }
}
