import 'dart:async';
import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mini_room_game/room.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'furniture/data/furniture_model.dart';
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
  final defaultLayout = [
    FurnitureModel(x: 1, y: 2, w: 3, h: 1, color: 0xFF4CAF50),
    FurnitureModel(x: 4, y: 3, w: 2, h: 2, color: 0xFFFFC107),
  ];


  @override
  Widget build(BuildContext context) {
    return GameWidget(
      backgroundBuilder: (context) => Container(color: Colors.white),
      game: DragGame(displaySize: MediaQuery.of(context).size, layout: defaultLayout),
    );
  }
}

class DragGame extends FlameGame {
  DragGame({required this.displaySize,  required this.layout,
  });

  final List<FurnitureModel> layout;
  Size displaySize;

  late Room room;

  @override
  Future<void> onLoad() async {
    double cellSize = Room.cellSize;
    double width = (displaySize.width ~/ cellSize) * cellSize;

    room = Room(position: Vector2((displaySize.width - width) / 2, 100), size: Vector2(width, ((displaySize.height ~/ cellSize) * cellSize) / 2), allowOverlap: false);

    add(room);

    // room.add(
    //   DraggableBox(
    //     position: Vector2(50, 50), // ⚠ room 기준 좌표
    //     size: Vector2(80, 80),
    //   ),
    // );

    await room.loadFromData(layout);
  }

  // Future<void> saveRoom(Room room) async {
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   final data = room.furnitures.map((f) => f.toJson()).toList();
  //
  //   final jsonString = jsonEncode(data);
  //
  //   await prefs.setString('room_data', jsonString);
  // }
  //
  // Future<void> loadRoom(Room room) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonString = prefs.getString('room_data');
  //
  //   if (jsonString == null) return;
  //
  //   final List list = jsonDecode(jsonString);
  //
  //   clearFurnitures(room);
  //
  //   for (final item in list) {
  //     room.add(Furniture.fromJson(item));
  //   }
  // }

  void clearFurnitures(Room room) {
    for (final f in room.furnitures) {
      f.removeFromParent();
    }
  }
}
