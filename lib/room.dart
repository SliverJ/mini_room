import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mini_room_game/furniture/funiture.dart';

class Room extends PositionComponent with TapCallbacks {
  Room({required Vector2 position, required Vector2 size}) {
    this.position = position;
    this.size = size;
  }

  static const double cellSize = 40;
  int _zCounter = 0;
  Furniture? selected;

  int nextZ() => ++_zCounter;

  @override
  void onTapDown(TapDownEvent event) {
    clearSelection();
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // final paint = Paint()
    //   ..color = const Color(0xFFE0E0E0);
    //
    // canvas.drawRect(size.toRect(), paint);

    final paint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    // 세로 그리드 선
    for (double x = 0; x <= size.x + 0.1; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), paint);
    }
    // 오른쪽 경계선 (너비가 cellSize의 배수가 아닐 경우 대비)
    // if ((size.x % cellSize).abs() > 0.1) {
    //   canvas.drawLine(Offset(size.x, 0), Offset(size.x, size.y), paint);
    // }

    // 가로 그리드 선
    for (double y = 0; y <= size.y + 0.1; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), paint);
    }
    // 아래쪽 경계선 (높이가 cellSize의 배수가 아닐 경우 대비)
    // if ((size.y % cellSize).abs() > 0.1) {
    //   canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), paint);
    // }
  }

  void select(Furniture f) {
    if (selected == f) return;
    selected?.setSelected(false);
    selected = f;
    selected!.setSelected(true);
  }

  void clearSelection() {
    selected?.setSelected(false);
    selected = null;
  }
}
