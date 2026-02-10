import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:mini_room_game/furniture/funiture.dart';
import 'package:mini_room_game/vector/vector.dart';

import 'furniture/data/furniture_model.dart';
import 'furniture/data/furniture_size.dart';

class Room extends PositionComponent with TapCallbacks {
  static const double cellSize = 40;

  Room({required super.position, required super.size, this.allowOverlap = false});

  int _zCounter = 0;
  Furniture? selected;
  final bool allowOverlap; // 가구 겹침 여부

  int nextZ() => ++_zCounter;

  List<Furniture> get furnitures => children.whereType<Furniture>().toList();
  List<FurnitureModel> data = [];



  Future<void> loadFromData(List<FurnitureModel> data) async {
    this.data = data;
    for (final f in data) {
      add(Furniture(model: f));
    }
  }

  Future<void> checkData() async {
    for (final f in data) {
      print('## data = ${data.toString()}');
    }
  }

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

  bool canPlace(Furniture me, Vector2 newPos) {
    if (allowOverlap) return true;

    final myRect = Rect.fromLTWH(newPos.x, newPos.y, me.size.x, me.size.y);

    // 전체 자식 중 Furniture 클래스(또는 그 자식 클래스)인 것만 필터링한다.
    for (final c in children.whereType<Furniture>()) {
      if (c == me) continue;

      final other = Rect.fromLTWH(c.position.x, c.position.y, c.size.x, c.size.y);

      // 현재 선택된 가구가 다른 가구와 겹치는지 확인한다.
      if (myRect.overlaps(other)) return false;
    }
    return true;
  }

  Vector2? findNearestAvailable(Furniture me, Vector2 start) {
    if (allowOverlap) return start;

    final startGrid = worldToGrid(start);

    const maxRadius = 20; // 충분히 크게

    for (int r = 1; r <= maxRadius; r++) {
      for (int dx = -r; dx <= r; dx++) {
        for (int dy = -r; dy <= r; dy++) {
          // 가장자리만 검사 (속도 개선)
          if (dx.abs() != r && dy.abs() != r) continue;

          final grid = startGrid + Vector2(dx.toDouble(), dy.toDouble());
          final world = gridToWorld(grid);

          // 방 범위 체크
          if (world.x < 0 || world.y < 0 || world.x + me.size.x > size.x || world.y + me.size.y > size.y) {
            continue;
          }

          if (canPlace(me, world)) {
            return world;
          }
        }
      }
    }

    return null; // 끝까지 못 찾음
  }
}
