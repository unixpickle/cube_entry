import 'dart:html';
import 'dart:math';
import 'dart:async';

class CameraView {
  final DivElement container;
  final VideoElement viewport;
  final CanvasElement overlay;
  CanvasRenderingContext2D context;
  
  int get videoWidth => viewport.videoWidth;
  int get videoHeight => viewport.videoHeight;
  
  num width;
  num height;
  
  num get canvasWidth => width * window.devicePixelRatio;
  num get canvasHeight => height * window.devicePixelRatio;
  
  Rectangle<num> get focusRect {
    num overlaySize = min(width, height) - 30;
    num rectX = (width - overlaySize) / 2;
    num rectY = (height - overlaySize) / 2;
    return new Rectangle<num>(rectX, rectY, overlaySize, overlaySize);
  }
  
  static bool get supported => MediaStream.supported;
  
  CameraView(DivElement container) : container = container,
      viewport = container.querySelector('video'),
      overlay = container.querySelector('canvas') {
    context = overlay.getContext('2d');
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
    overlay.width = (width * window.devicePixelRatio).round();
    overlay.height = (height * window.devicePixelRatio).round();
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
}
