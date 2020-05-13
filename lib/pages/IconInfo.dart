import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

/*
This is a helper class to the filter popup dialog in map_page.dart. It is a way to set and update the states of the icon buttons.
 */

class IconInfo with ChangeNotifier {

  IconInfo(this._carToggled, this._truckToggled, this._motorcycleToggled);

  var _carToggled = true;
  var _truckToggled = false;
  var _motorcycleToggled = false;

  bool get carToggled => _carToggled;
  bool get truckToggled => _truckToggled;
  bool get motorcycleToggled => _motorcycleToggled;

  set car(bool newVal) {
    _carToggled = newVal;
    notifyListeners();
  }

  set truck(bool newVal) {
    _truckToggled = newVal;
    notifyListeners();
  }

  set motorcycle(bool newVal) {
    _motorcycleToggled = newVal;
    notifyListeners();
  }
}