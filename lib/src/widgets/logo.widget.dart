import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final textColor1;
  final textColor2;

  LogoWidget({this.textColor1: Colors.white, this.textColor2: Colors.white70});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(right: 10.0),
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: Icon(
              Icons.vpn_key,
              color: Colors.white,
              size: 18.0,
            ),
          ),
          Text(
            'Password ',
            style: TextStyle(
              color: textColor1,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Manager',
            style: TextStyle(
              color: textColor2,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
