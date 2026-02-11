import 'dart:async';
import 'dart:convert';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:mini_room_game/room.dart';
import 'package:mini_room_game/shop/shop_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'furniture/data/funiture_type.dart';
import 'furniture/data/furniture_model.dart';
import 'furniture/funiture.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final defaultLayout = [FurnitureModel(x: 1, y: 2, w: 3, h: 1, color: 0xFF4CAF50), FurnitureModel(x: 4, y: 3, w: 2, h: 2, color: 0xFFFFC107)];
  final shopItems = [
    FurnitureType(id: 'sofa', w: 3, h: 1, color: 0xFF4CAF50),
    FurnitureType(id: 'table', w: 2, h: 2, color: 0xFFFFC107),
    FurnitureType(id: 'bed', w: 3, h: 2, color: 0xFF2196F3),
    FurnitureType(id: 'plant', w: 1, h: 1, color: 0xFF2E7D32),
  ];

  DragGame? game;

  @override
  void initState() {
    super.initState();
  }

  Future<List<FurnitureModel>> loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString('room_layout');

    if (text == null) {
      return []; // 처음 실행
    }

    final List list = jsonDecode(text);
    return list.map((e) => FurnitureModel.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FutureBuilder<List<FurnitureModel>>(
        future: loadLayout(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(); // 또는 로딩 화면
          }

          // 저장 데이터가 있으면 사용, 없으면 기본값
          final layout = snapshot.data!.isEmpty ? defaultLayout : snapshot.data!;
          game ??= DragGame(displaySize: MediaQuery.of(context).size, layout: layout);

          // print('## game = ${game == null}');

          return Stack(
            children: [
              GameWidget(
                backgroundBuilder: (context) => Container(color: Colors.white),
                game: game!,
              ),
              // ⭐ 하단 상점
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ShopBar(game: game!, shopItems: shopItems),
                // child: Draggable<FurnitureType>(
                //   data: shopSofa,
                //   feedback: Container(width: 60, height: 60, color: Colors.green),
                //   child: Container(width: 60, height: 60, color: Colors.green),
                //   onDragStarted: () {
                //     game?.startShopDrag(shopSofa);
                //   },
                //   onDragUpdate: (detail) {
                //     game?.updateShopDragPosition(detail.globalPosition);
                //   },
                //   onDragEnd: (_) {
                //     game?.endShopDrag();
                //   },
                // ),
              ),
            ],
          );
        },
      ),
    );
    // return GameWidget(
    //   backgroundBuilder: (context) => Container(color: Colors.white),
    //   game: DragGame(displaySize: MediaQuery.of(context).size, layout: defaultLayout),
    // );
  }
}

class DragGame extends FlameGame {
  DragGame({required this.displaySize, required this.layout});

  final List<FurnitureModel> layout;
  Size displaySize;

  late Room room;

  Furniture? shopPreview;

  @override
  Future<void> onLoad() async {
    double cellSize = Room.cellSize;
    double width = (displaySize.width ~/ cellSize) * cellSize;

    room = Room(position: Vector2((displaySize.width - width) / 2, 100), size: Vector2(width, ((displaySize.height ~/ cellSize) * cellSize) / 2), allowOverlap: false);

    add(room);

    await room.loadFromData(layout);
  }

  void clearFurnitures(Room room) {
    for (final f in room.furnitures) {
      f.removeFromParent();
    }
  }

  // 상점 드래그 시작
  void startShopDrag(FurnitureType type, Offset global) {
    final model = FurnitureModel(x: 0, y: 0, w: type.w, h: type.h, color: type.color);

    shopPreview = Furniture(model: model)..isPreviewFromShop = true..forceDragging(true);

    room.add(shopPreview!);

    updateShopDragPosition(global);
  }

  // 드래그 중 위치 갱신
  void updateShopDragPosition(Offset global) {
    if (shopPreview == null) return;

    final gamePoint = convertGlobalToLocalCoordinate(
      Vector2(global.dx, global.dy),
    );

    final roomPoint = gamePoint - room.position;

    shopPreview!.updatePreviewAt(
      roomPoint - shopPreview!.size / 2,
    );
  }

  // 드래그 종료
  void endShopDrag() {
    shopPreview?.finishShopDrop();
    shopPreview = null;
  }
}
