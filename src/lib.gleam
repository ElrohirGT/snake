//// The lib module has utility functions that can be reused across a variety of modules

import model.{type Vector2}

/// Gets the default position of the head of the snake given the size of the board.
/// The (0,0) of the coordinates is the top left corner
pub fn default_snake_head_pos(columns: Int) -> Vector2 {
  let half_idx = columns / 2
  model.Vector2(half_idx, half_idx)
}

/// Gets the default position of the body of the snake given the size of the board.
/// The (0,0) of the coordinates is the top left corner
pub fn default_snake_body_pos(columns: Int) -> Vector2 {
  let assert model.Vector2(x, y) = default_snake_head_pos(columns)
  model.Vector2(x, y + 1)
}

/// Checks if a number is between a range
pub fn between(number: Int, min: Int, max: Int) {
  number < max && number > min
}

/// Checks if a number is between a range (inclusive)
pub fn between_inc(number: Int, min: Int, max: Int) {
  number <= max && number >= min
}
