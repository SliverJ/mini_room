import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mini_room_game/vector/vector.dart';

import '../room.dart';
import 'data/furniture_size.dart';

class Furniture extends PositionComponent with DragCallbacks, TapCallbacks {
  Furniture({
    required Vector2 gridPosition, // ⚠ 그리드 좌표
    required this.furnitureSize,
    this.itemColor = const Color(0xFF4CAF50),
  }) {
    position = gridToWorld(gridPosition);
    size = Vector2(furnitureSize.gridWidth * Room.cellSize, furnitureSize.gridHeight * Room.cellSize);
  }

  late Room room;
  final FurnitureSize furnitureSize;
  final Color itemColor;
  bool _selected = false;

  void setSelected(bool value) {
    _selected = value;
  }

  @override
  void onMount() {
    super.onMount();
    room = parent as Room;
    updatePriority();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 기본 가구 본체
    final bodyPaint = Paint()
      ..color = _selected
          ? itemColor.withValues(alpha: 0.5) // 선택 시 밝게
          : itemColor;

    canvas.drawRect(size.toRect(), bodyPaint);

    // 선택 테두리
    if (_selected) {
      final borderPaint = Paint()
        ..color = const Color(0xFF2E7D32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRect(size.toRect(), borderPaint);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    print('## onTapDown ');
    room.select(this);
    super.onTapDown(event);
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
    room.clearSelection();
    super.onDragEnd(event);
  }

  void _clampToRoom() {
    position.x = position.x.clamp(0, room.size.x - size.x);
    position.y = position.y.clamp(0, room.size.y - size.y);
  }

  void updatePriority() {
    priority = room.nextZ();
    ;
  }
}
