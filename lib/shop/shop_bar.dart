import 'package:flutter/material.dart';
import 'package:mini_room_game/main.dart';

import '../furniture/data/funiture_type.dart';

class ShopBar extends StatelessWidget {
  const ShopBar({
    super.key,
    required this.game,
    required this.shopItems,
  });

  final DragGame game;
  final List<FurnitureType> shopItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.black12,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        itemCount: shopItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = shopItems[index];

          return Listener(
            onPointerDown: (event) => game.startShopDrag(item, event.position),
            child: Draggable<FurnitureType>(
              data: item,

              // feedback: _itemView(item, dragging: true),
              feedback: const SizedBox(),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _itemView(item),
              ),
              child: _itemView(item),
              onDragUpdate: (detail) =>
                  game.updateShopDragPosition(detail.globalPosition),
              onDragEnd: (_) => game.endShopDrag(),
            ),
          );
        },
      ),
    );
  }

  Widget _itemView(FurnitureType item, {bool dragging = false}) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(item.color),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dragging ? Colors.white : Colors.black26,
          width: 2,
        ),
      ),
      child: Text(
        '${item.w}x${item.h}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
