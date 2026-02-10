import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mini_room_game/room.dart';

import 'furniture/data/furniture_size.dart';
import 'furniture/funiture.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GameWidget(
      backgroundBuilder: (context) => Container(color: Colors.white),
      game: DragGame(displaySize: MediaQuery.of(context).size),
    );
  }
}

class DragGame extends FlameGame {
  DragGame({required this.displaySize});

  Size displaySize;

  late Room room;

  @override
  Future<void> onLoad() async {
    double cellSize = Room.cellSize;
    double width = (displaySize.width ~/ cellSize) * cellSize;

    room = Room(position: Vector2((displaySize.width - width) / 2, 100), size: Vector2(width, ((displaySize.height ~/ cellSize) * cellSize) / 2), allowOverlap: true);

    add(room);

    // room.add(
    //   DraggableBox(
    //     position: Vector2(50, 50), // ⚠ room 기준 좌표
    //     size: Vector2(80, 80),
    //   ),
    // );

    // 3칸짜리 소파
    room.add(Furniture(gridPosition: Vector2(1, 2), furnitureSize: const FurnitureSize(3, 1)));

    // 2x2 테이블
    room.add(Furniture(gridPosition: Vector2(4, 3), furnitureSize: const FurnitureSize(2, 2), itemColor: Colors.amber));
  }
}
