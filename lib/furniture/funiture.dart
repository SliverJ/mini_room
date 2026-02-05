import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:mini_room_game/vector/vector.dart';

import '../room.dart';
import 'data/furniture_size.dart';

class Furniture extends PositionComponent
    with DragCallbacks {

  late Room room;
  final FurnitureSize furnitureSize;
  final Color? itemColor;

  Furniture({
    required Vector2 gridPosition, // ⚠ 그리드 좌표
    required this.furnitureSize,
    this.itemColor,
  }) {
    position = gridToWorld(gridPosition);
    size = Vector2(
      furnitureSize.gridWidth * Room.cellSize,
      furnitureSize.gridHeight * Room.cellSize,
    );
  }

  @override
  void onMount() {
    super.onMount();
    room = parent as Room;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = itemColor ?? const Color(0xFF4CAF50);

    canvas.drawRect(size.toRect(), paint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    _clampToRoom();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print('## position = $position, size = $size');
    print('## position round = ${(position.x / 40).round()}');
    position = snapToGrid(position);
    print('## snapToGrid = $position');
    _clampToRoom();

    super.onDragEnd(event);
  }

  void _clampToRoom() {
    position.x = position.x.clamp(
      0,
      room.size.x - size.x,
    );
    position.y = position.y.clamp(
      0,
      room.size.y - size.y,
    );
  }
}
