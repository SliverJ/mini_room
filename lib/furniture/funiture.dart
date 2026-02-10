import 'dart:convert';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'package:mini_room_game/vector/vector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../room.dart';
import 'data/furniture_model.dart';
import 'data/furniture_size.dart';

class Furniture extends PositionComponent with DragCallbacks, TapCallbacks {
  // Furniture({
  //   required Vector2 gridPosition, // ⚠ 그리드 좌표
  //   required this.furnitureSize,
  //   this.itemColor = const Color(0xFF4CAF50),
  // }) {
  //   this.gridPosition = gridPosition.clone();
  //   position = gridToWorld(gridPosition);
  //   size = Vector2(furnitureSize.gridWidth * Room.cellSize, furnitureSize.gridHeight * Room.cellSize);
  // }

  Furniture({required this.model})
      : furnitureSize = FurnitureSize(model.w, model.h),
        itemColor = Color(model.color) {
    position = gridToWorld(Vector2(model.x.toDouble(), model.y.toDouble()));
    size = Vector2(
      furnitureSize.gridWidth * Room.cellSize,
      furnitureSize.gridHeight * Room.cellSize,
    );
  }

  final FurnitureModel model;
  final FurnitureSize furnitureSize;
  final Color itemColor;

  late Room room;
  late Vector2 gridPosition;

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
    Vector2? target;

    if (_ghostPosition != null) {
      if (_canPlace) {
        position = _ghostPosition!;
        target = _ghostPosition;
        gridPosition = worldToGrid(target!);
      } else {
        // 🔥 가장 가까운 빈칸 찾기
        // final near = room.findNearestAvailable(this, _ghostPosition!);
        // if (near != null) {
        //   position = near;
        // }
        // 실패 → 원위치 복귀
        if (_originPosition != null) {
          position = _originPosition!;
          target = _originPosition;
        }
      }
    }

    if (target != null) {
      add(
        MoveToEffect(
          target,
          EffectController(
            duration: _canPlace ? 0.15 : 0.1,
            curve: Curves.easeOut,
          ),
        ),
      );
      playDropFeedback(); // ⭐ 이게 핵심
    }

    _ghostPosition = null;


    // position = snapToGrid(position);
    // _clampToRoom();

    // ⭐⭐⭐ 데이터 업데이트
    final grid = worldToGrid(position);
    model.x = grid.x.toInt();
    model.y = grid.y.toInt();

    print("changed: ${model.x}, ${model.y}");
    saveLayout(room.layout);

    room.clearSelection();
    super.onDragEnd(event);
  }

  void playDropFeedback() {
    // add(
    //   ScaleEffect.to(
    //     Vector2.all(1.08),
    //     EffectController(duration: 0.07),
    //     onComplete: () {
    //       add(
    //         ScaleEffect.to(
    //           Vector2.all(1.0),
    //           EffectController(duration: 0.07),
    //         ),
    //       );
    //     },
    //   ),
    // );
    add(
      SequenceEffect([
        ScaleEffect.to(Vector2.all(1.08), EffectController(duration: 0.07)),
        ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.07)),
      ]),
    );
  }


  void _clampToRoom() {
    position.x = position.x.clamp(0, room.size.x - size.x);
    position.y = position.y.clamp(0, room.size.y - size.y);
  }

  void updatePriority() {
    priority = room.nextZ();
  }

  Future<void> saveLayout(List<FurnitureModel> layout) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = layout.map((e) => e.toJson()).toList();
    final text = jsonEncode(jsonList);

    await prefs.setString('room_layout', text);
  }
}
