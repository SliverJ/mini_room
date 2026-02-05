import 'package:flame/game.dart';
import 'package:mini_room_game/room.dart';

Vector2 gridToWorld(Vector2 grid) {
  return Vector2(
    grid.x * Room.cellSize,
    grid.y * Room.cellSize,
  );
}

Vector2 snapToGrid(Vector2 pos) {
  return Vector2(
    (pos.x / Room.cellSize).round() * Room.cellSize,
    (pos.y / Room.cellSize).round() * Room.cellSize,
  );
}
