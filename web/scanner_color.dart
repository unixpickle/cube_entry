part of cube_entry;

List<int> _identComps(int ident) {
  List<List<int>> colors = [[0, 255, 0], [0, 0, 255], [255, 255, 255],
                            [255, 255, 40], [255, 0, 0], [255, 165, 0]];
  return colors[ident];
}

class ScannerColor {
  final int red;
  final int green;
  final int blue;
  
  static const int COLOR_GREEN = 0;
  static const int COLOR_BLUE = 1;
  static const int COLOR_WHITE = 2;
  static const int COLOR_YELLOW = 3;
  static const int COLOR_RED = 4;
  static const int COLOR_ORANGE = 5;
  
  static final List<String> COLOR_NAMES = ['green', 'blue', 'white', 'yellow',
                                           'red', 'orange'];
  
  ScannerColor(this.red, this.green, this.blue);
  
  ScannerColor.fromIdentifier(int ident) : red = _identComps(ident)[0],
      green = _identComps(ident)[1], blue = _identComps(ident)[2];
  
  int difference(ScannerColor c) {
    return (red - c.red).abs() + (green - c.green).abs() +
        (blue - c.blue).abs();  
  }
}
