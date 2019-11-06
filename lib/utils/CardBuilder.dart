import 'package:flutter/material.dart';

class CardBuilder extends StatefulWidget {
  final String title;
  final String value;

  const CardBuilder({Key key, this.title, this.value}) : super(key: key);

  @override
  _CardBuilderState createState() => _CardBuilderState();
}

class _CardBuilderState extends State<CardBuilder> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      child: Row(

        mainAxisAlignment:MainAxisAlignment.spaceBetween ,
        children: <Widget>[
          Text(widget.title),
          Text(widget.value)
        ],
      ),
    );
  }
}
