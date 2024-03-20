/// Possible moves the snake can make
pub type SnakeMovement {
  Up
  Down
  Left
  Right
}

/// Represents a coordinate inside the game
pub type Vector2 {
  Vector2(x: Int, y: Int)
}

/// Add two vectors together
pub fn add(a: Vector2, b: Vector2) -> Vector2 {
  let assert Vector2(x1, y1) = a
  let assert Vector2(x2, y2) = b

  Vector2(x1 + x2, y1 + y2)
}

/// If a grid with `columns` was converted into a 1D array
/// Then `pos` would have a certain index in that array.
/// This function computes said index.
pub fn to_index(pos: Vector2, columns: Int) -> Int {
  let assert Vector2(x, y) = pos
  columns * y + x
}
