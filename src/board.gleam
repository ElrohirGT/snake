import gleam/string
import gleam/int
import gleam/io
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

/// Possible moves the snake can make
pub type SnakeMovement {
  Up
  Down
  Left
  Right
}

/// Possible messages to the Board
pub type Message {
  Render(Subject(Nil))
  Stop
  Movement(direction: SnakeMovement)
  Eat
}

pub type Vector2 {
  Vector2(x: Int, y: Int)
}

/// Represents the Game state
pub type GameState {
  /// Represents the game state
  GameState(
    board_size: Vector2,
    snake: List(Vector2),
    tail_direction: SnakeMovement,
  )
}

/// Function that handles every message passed to the Board actor
pub fn handle_message(
  message: Message,
  state: GameState,
) -> actor.Next(Message, GameState) {
  case message {
    Stop -> actor.Stop(process.Normal)
    Render(client) -> {
      let board_state =
        "["
        |> string.append(int.to_string(state.board_size.x))
        |> string.append(", ")
        |> string.append(int.to_string(state.board_size.y))
        |> string.append("]")
      io.println(board_state)
      process.send(client, Nil)
      actor.continue(state)
    }
    _ -> todo
  }
}
