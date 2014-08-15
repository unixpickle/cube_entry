import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';

class CameraView {
  final DivElement container;
  final VideoElement viewport;
  final CanvasElement overlay;
  final CanvasElement invisCanvas;
  CanvasRenderingContext2D context;
  CanvasRenderingContext2D invisContext;
  
  int get videoWidth => viewport.videoWidth;
  int get videoHeight => viewport.videoHeight;
  
  num width;
  num height;
  
  int get canvasWidth => (width * window.devicePixelRatio).round();
  int get canvasHeight => (height * window.devicePixelRatio).round();
  
  Rectangle<int> get focusRect {
    int overlaySize = (min(width, height) - 30).round();
    int rectX = ((width - overlaySize) / 2).round();
    int rectY = ((height - overlaySize) / 2).round();
    return new Rectangle<int>(rectX, rectY, overlaySize, overlaySize);
  }
  
  static bool get supported => MediaStream.supported;
  
  CameraView(DivElement container) : container = container,
      viewport = container.querySelector('video'),
      overlay = container.querySelector('canvas'),
      invisCanvas = new CanvasElement() {
  }
  
  void start() {
    if (!MediaStream.supported) {
      throw new UnsupportedError('Cannot use camera.');
    }
    Future f = window.navigator.getUserMedia(audio: false, video: true);
    f.then((MediaStream stream) {
      String url = Url.createObjectUrlFromStream(stream);
      viewport.src = url;
      viewport.onPlaying.listen(resizeCanvas);
    }).catchError((_) {
      window.alert('failed to capture video!');
    });
  }
  
  List<Int32x4> readCubeColors() {
    invisContext.clearRect(0, 0, canvasWidth, canvasHeight);
    invisContext.drawImageToRect(viewport, new Rectangle(0, 0,
        canvasWidth, canvasHeight));
    ImageData data = invisContext.getImageData(0, 0, canvasWidth, canvasHeight);
    List<int> buffer = data.data;
    
    Rectangle<int> r = focusRect;
    List<Int32x4> sums = new List<Int32x4>();
    int secSize = (r.width / 3).round();
    for (int secY = 0; secY < 3; ++secY) {
      for (int secX = 0; secX < 3; ++secX) {
        int startX = r.left + (secX * r.width / 3).round();
        int startY = r.top + (secY * r.height / 3).round();
        Int32x4 cur = new Int32x4(0, 0, 0, 0);
        for (int x = startX; x < startX + secSize; ++x) {
          for (int y = startY; y < startY + secSize; ++y) {
            int dataIdx = (x + (y * data.width)) * 4;
            cur += new Int32x4(buffer[dataIdx], buffer[dataIdx + 1],
                buffer[dataIdx + 2], 0);
          }
        }
        int count = secSize * secSize;
        sums.add(new Int32x4(cur.x ~/ count, cur.y ~/ count, cur.z ~/ count,
            cur.w ~/ count));
      }
    }
    return sums;
  }
  
  void resizeCanvas(_) {
    width = videoWidth;
    height = videoHeight;
    num scale = 1;
    if (width > height) {
      scale = 600 / width;
    } else {
      scale = 600 / height;
    }
    width *= scale;
    height *= scale;
    container.style.width = '${width}px';
    container.style.height = '${height}px';
    overlay.width = invisCanvas.width = canvasWidth;
    overlay.height = invisCanvas.height = canvasHeight;
    
    context = overlay.getContext('2d');
    invisContext = invisCanvas.getContext('2d');
    
    drawOverlay();
  }
  
  void drawOverlay() {
    Rectangle<num> rect = focusRect;
    num overlaySize = rect.width * window.devicePixelRatio;
    num rectX = rect.left * window.devicePixelRatio;
    num rectY = rect.top * window.devicePixelRatio;
    context.clearRect(0, 0, canvasWidth, canvasHeight);
    
    context.lineWidth = 5 * window.devicePixelRatio;
    context.strokeStyle = '#FFFFFF';
    context.beginPath();
    
    // border of square
    context.moveTo(rectX, rectY);
    context.lineTo(rectX + overlaySize, rectY);
    context.lineTo(rectX + overlaySize, rectY + overlaySize);
    context.lineTo(rectX, rectY + overlaySize);
    context.closePath();
    
    // horizontal lines
    context.moveTo(rectX, rectY + overlaySize / 3);
    context.lineTo(rectX + overlaySize, rectY + overlaySize / 3);
    context.moveTo(rectX, rectY + 2 * overlaySize / 3);
    context.lineTo(rectX + overlaySize, rectY + 2 * overlaySize / 3);
    
    // vertical lines
    context.moveTo(rectX + overlaySize / 3, rectY);
    context.lineTo(rectX + overlaySize / 3, rectY + overlaySize);
    context.moveTo(rectX + 2 * overlaySize / 3, rectY);
    context.lineTo(rectX + 2 * overlaySize / 3, rectY + overlaySize);
    
    context.stroke();
  }
}

void main() {
  CameraView view = new CameraView(querySelector('.video-container'));
  view.start();
  querySelector('#scan-photo').onClick.listen((_) {
    DateTime start = new DateTime.now();
    print('${view.readCubeColors()}');
    print('${start.difference(new DateTime.now()).inMilliseconds}');
  });
}
