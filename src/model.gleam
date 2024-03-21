/// Possible moves the snake can make
pub type SnakeMovement {
  Up
  Down
  Left
  Right
}

/// Converts a `SnakeMovement` into a direction `Vector2`
pub fn to_vector(movement: SnakeMovement) -> Vector2 {
  case movement {
    Up -> Vector2(0, -1)
    Down -> Vector2(0, 1)
    Left -> Vector2(-1, 0)
    Right -> Vector2(1, 0)
  }
}

/// Converts a direction `Vector2` into a `SnakeMovement`
pub fn to_direction(vector: Vector2) -> Result(SnakeMovement, Nil) {
  let assert Vector2(x, y) = vector
  case [x, y] {
    [0, -1] -> Ok(Up)
    [0, 1] -> Ok(Down)
    [-1, 0] -> Ok(Left)
    [1, 0] -> Ok(Right)
    _ -> Error(Nil)
  }
}

/// Gets the direction opposite of the one provided
pub fn contrary(direction: SnakeMovement) -> SnakeMovement {
  case direction {
    Up -> Down
    Down -> Up
    Left -> Right
    Right -> Left
  }
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

/// Executes `a` - `b`
pub fn subtract(a: Vector2, b: Vector2) -> Vector2 {
  let assert Vector2(x1, y1) = a
  let assert Vector2(x2, y2) = b

  Vector2(x1 - x2, y1 - y2)
}

/// If a grid with `columns` was converted into a 1D array
/// Then `pos` would have a certain index in that array.
/// This function computes said index.
pub fn to_index(pos: Vector2, columns: Int) -> Int {
  let assert Vector2(x, y) = pos
  columns * y + x
}
