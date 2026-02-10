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
  Vector2? _originPosition;
  Vector2? _ghostPosition;
  bool _selected = false;
  bool _dragging = false;
  bool _canPlace = true;

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

    if (_dragging && _ghostPosition != null) {
      canvas.save();
      canvas.translate(
        _ghostPosition!.x - position.x,
        _ghostPosition!.y - position.y,
      );

      final ghostPaint = Paint()
        ..color = _canPlace
            ? const Color(0xFF4CAF50).withValues(alpha: 0.25) // 가능
            : const Color(0xFFD32F2F).withValues(alpha: 0.25); // 불가

      canvas.drawRect(size.toRect(), ghostPaint);
      canvas.restore();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // TODO: implement onTapDown
    super.onTapDown(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    _dragging = true;

    _originPosition = position.clone();

    room.select(this);
    // 🔥 여기서 앞으로 가져옴
    updatePriority();
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
    _clampToRoom();

    _ghostPosition = snapToGrid(position);

    if (_ghostPosition != null) {
      _canPlace = room.canPlace(this, _ghostPosition!);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dragging = false;
    if (_ghostPosition != null) {
      if (_canPlace) {
        position = _ghostPosition!;
      } else {
        // 🔥 가장 가까운 빈칸 찾기
        // final near = room.findNearestAvailable(this, _ghostPosition!);
        // if (near != null) {
        //   position = near;
        // }
        // 실패 → 원위치 복귀
        if (_originPosition != null) {
          position = _originPosition!;
        }
      }
    }
    _ghostPosition = null;


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
  }
}
