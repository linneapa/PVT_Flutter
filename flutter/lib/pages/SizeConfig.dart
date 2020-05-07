import 'package:flutter/widgets.dart';

/*

This is code borrowed from the following webpage:
https://medium.com/flutter-community/flutter-effectively-scale-ui-according-to-different-screen-sizes-2cb7c115ea0a

A quick way to scale UI according different phone sizes. Simply replace the size parameter with SizeConfig.blockSizeVertical * [some number] or SizeConfig.blockSizeHorizontal * [some number],
The article got some critique saying the functionality of scaling is built into flutter as is and that this method is redundant.
It seems to work okay though and was a quick solution, so I've left it in, and its currently in use to scale map_page.dart, settings.dart and favorites.dart.

// Carl 2020-05-07

 */


class SizeConfig {
  static MediaQueryData _mediaQueryData;

  static double screenWidth;
  static double screenHeight;

  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth -
        _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight -
        _safeAreaVertical) / 100;
  }
}