

class FurnitureModel {
  FurnitureModel({required this.x, required this.y, required this.w, required this.h, this.color = 0xff0000000});

  int x;
  int y;
  int w;
  int h;
  int color;

  @override
  String toString() {
    return 'FurnitureModel{x: $x, y: $y, w: $w, h: $h, color: $color}';
  }
}
