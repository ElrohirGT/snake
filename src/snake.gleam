import gleam/io
import gleam/string
import gleam/int
import gleam/otp/actor
import gleam/erlang/process
import gleam/erlang.{get_line}
import board.{handle_message}

pub fn main() {
  let assert Ok(actor) =
    actor.start(
      board.GameState(
        board_size: board.Vector2(x: 3, y: 3),
        snake: [board.Vector2(x: 1, y: 1), board.Vector2(x: 1, y: 2)],
        tail_direction: board.Down,
      ),
      handle_message,
    )

  game_loop(actor, 0)
  io.println("The game ended")
}

fn game_loop(actor, count: Int) {
  // Render to screen
  io.println(string.append("Render #", int.to_string(count)))
  process.call(actor, board.Render, 1000 / 60)

  // Obtain user input
  let assert Ok(value) = get_line("Input (Press q to exit): ")

  // Call next game loop if it shouldn't exit
  case value {
    "q\n" -> {
      io.println("Endindg game...")
      process.send(actor, board.Stop)
    }
    _ -> game_loop(actor, count + 1)
  }
}
