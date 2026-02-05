import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mini_room_game/vector/vector.dart';

import '../room.dart';
import 'data/furniture_size.dart';

class Furniture extends PositionComponent with DragCallbacks {
  Furniture({
    required Vector2 gridPosition, // ⚠ 그리드 좌표
    required this.furnitureSize,
    this.itemColor,
  }) {
    position = gridToWorld(gridPosition);
    size = Vector2(furnitureSize.gridWidth * Room.cellSize, furnitureSize.gridHeight * Room.cellSize);
  }

  late Room room;
  final FurnitureSize furnitureSize;
  final Color? itemColor;

  @override
  void onMount() {
    super.onMount();
    room = parent as Room;
    updatePriority();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = itemColor ?? const Color(0xFF4CAF50);

    canvas.drawRect(size.toRect(), paint);
  }


  @override
  void onDragStart(DragStartEvent event) {
    // 🔥 여기서 앞으로 가져옴
    updatePriority();
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    _clampToRoom();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    position = snapToGrid(position);
    _clampToRoom();
    super.onDragEnd(event);
  }

  void _clampToRoom() {
    position.x = position.x.clamp(0, room.size.x - size.x);
    position.y = position.y.clamp(0, room.size.y - size.y);
  }

  void updatePriority() {
    priority = room.nextZ();;
  }
}
