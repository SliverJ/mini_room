import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';

class DraggableBox extends PositionComponent
    with DragCallbacks {

  DraggableBox({
    required Vector2 position,
    required Vector2 size,
  }) {
    this.position = position;
    this.size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFF4CAF50);

    canvas.drawRect(
      size.toRect(),
      paint,
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // ✅ 정답: event.delta 사용
    position += event.localDelta;

    final room = parent as PositionComponent;

    position.x = position.x.clamp(0, room.size.x - size.x);
    position.y = position.y.clamp(0, room.size.y - size.y);
  }
}
