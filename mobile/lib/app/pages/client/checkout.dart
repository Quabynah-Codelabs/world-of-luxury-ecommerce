import 'package:flutter/material.dart';
import 'package:handyman/data/local_database.dart';
import 'package:meta/meta.dart';

/// Checkout page for customer payment
class CheckoutPage extends StatefulWidget {
  final Booking booking;
  final Artisan artisan;

  const CheckoutPage({
    Key key,
    @required this.booking,
    @required this.artisan,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
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
    );
  }
}
