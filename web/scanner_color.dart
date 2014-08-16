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
  
  int faceColor() {
    List<double> hsv = toHSV();
    if (hsv[1] < 0.3) {
      return COLOR_WHITE;
    } else if (hsv[0] >= 14 && hsv[0] < 39) {
      return COLOR_ORANGE;
    } else if (hsv[0] >= 39 && hsv[0] < 75) {
      return COLOR_YELLOW;
    } else if (hsv[0] >= 75 && hsv[0] < 166) {
      return COLOR_GREEN;
    } else if (hsv[0] >= 166 && hsv[0] < 307) {
      return COLOR_BLUE;
    }
    return COLOR_RED;
  }
  
  List<double> toHSV() {
    // I borrowed this guy's code http://www.javascripter.net/faq/rgb2hsv.htm
    
    double r = red / 255.0;
    double g = green / 255.0;
    double b = blue / 255.0;
    
    var minRGB = min(r, min(g, b));
    var maxRGB = max(r, max(g, b));
    
    // Black-gray-white
    if (minRGB == maxRGB) {
      return [0, 0, minRGB];
    }
    
    // Colors other than black-gray-white:
    var d = (r == minRGB) ? g - b : ((b == minRGB) ? r - g : b - r);
    var h = (r == minRGB) ? 3 : ((b == minRGB) ? 1 : 5);
    num computedH = 60 * (h - d / (maxRGB - minRGB));
    num computedS = (maxRGB - minRGB) / maxRGB;
    num computedV = maxRGB;
    return [computedH, computedS, computedV];
  }
}
