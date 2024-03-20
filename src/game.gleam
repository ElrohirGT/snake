import gleam/otp/actor
import model.{type SnakeMovement, type Vector2}

/// Messages to pass to the Game engine
/// The engine that cContains all the business logic
pub type GameMessages {
  /// Message to pass when a Snake moves in a certain direction
  Movement(direction: SnakeMovement)
}

/// Represents the Game state
pub type GameState {
  GameState(
    board_size: Vector2,
    snake: List(Vector2),
    tail_direction: SnakeMovement,
  )
}

pub fn handle_message(
  message: GameMessages,
  state: GameState,
) -> actor.Next(GameMessages, GameState) {
  todo
}
