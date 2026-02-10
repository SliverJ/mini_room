

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

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'color': color,
  };

  factory FurnitureModel.fromJson(Map<String, dynamic> json) {
    return FurnitureModel(
      x: json['x'],
      y: json['y'],
      w: json['w'],
      h: json['h'],
      color: json['color'],
    );
  }
}
