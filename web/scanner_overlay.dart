part of cube_entry;

class ScannerOverlay {
  final CanvasElement _canvas;
  
  int gridSize;
  int gridX;
  int gridY;
  
  ScannerOverlay(CanvasElement canvas) : _canvas = canvas;
  
  setup(num videoWidth, num videoHeight) {
    double scale = window.devicePixelRatio;
    _canvas.width = (scale * videoWidth).round();
    _canvas.height = (scale * videoHeight).round();
    
    gridSize = (min(videoWidth, videoHeight) - 30).round();
    gridX = ((videoWidth - gridSize) / 2).round();
    gridY = ((videoHeight - gridSize) / 2).round();

    int rectSize = (gridSize * scale).round();
    int rectX = (gridX * scale).round();
    int rectY = (gridY * scale).round();
    
    CanvasRenderingContext2D context = _canvas.getContext('2d');
    
    context.clearRect(0, 0, videoWidth, videoHeight);
    
    context.lineWidth = 5 * scale;
    context.strokeStyle = '#FFFFFF';
    context.beginPath();
    
    // border of square
    context.moveTo(rectX, rectY);
    context.lineTo(rectX + rectSize, rectY);
    context.lineTo(rectX + rectSize, rectY + rectSize);
    context.lineTo(rectX, rectY + rectSize);
    context.closePath();
    
    // horizontal lines
    context.moveTo(rectX, rectY + rectSize / 3);
    context.lineTo(rectX + rectSize, rectY + rectSize / 3);
    context.moveTo(rectX, rectY + 2 * rectSize / 3);
    context.lineTo(rectX + rectSize, rectY + 2 * rectSize / 3);
    
    // vertical lines
    context.moveTo(rectX + rectSize / 3, rectY);
    context.lineTo(rectX + rectSize / 3, rectY + rectSize);
    context.moveTo(rectX + 2 * rectSize / 3, rectY);
    context.lineTo(rectX + 2 * rectSize / 3, rectY + rectSize);
    
    context.stroke();
  }
}
