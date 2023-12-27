import 'package:flutter/material.dart';

class MainViewItemList extends StatefulWidget {
  final String imagePath;
  final Color backgroundColor;
  final String title;

  MainViewItemList(
      {required this.imagePath,
      required this.backgroundColor,
      required this.title});

  @override
  _MainViewItemList createState() => _MainViewItemList();
}

class _MainViewItemList extends State<MainViewItemList> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        child: Container(
          // height: constraints.maxHeight * 0.9,
          // width: constraints.maxWidth,
          child: Card(
            margin: EdgeInsets.all(2.0),
            elevation: isHovered ? 10 : 0,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            color: widget.backgroundColor,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.ease,
              padding: EdgeInsets.all(isHovered ? 20 : 10),
              decoration: BoxDecoration(
                color: isHovered
                    ? Color.fromRGBO(73, 73, 73, 1)
                    : widget.backgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: GestureDetector(
                child: Center(
                  child: Text(
                    widget.title,
                    textScaleFactor: 0.8,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sora',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
