import gleam/io
import gleam/list
import gleam/string
import gleam/int
import gleam/otp/actor
import gleam/erlang/process
import gleam/erlang.{get_line}
import renderer.{handle_message}

pub fn main() {
  let columns = 9
  let assert Ok(actor) =
    actor.start(generate_default_state(columns), handle_message)

  game_loop(actor, 0)
  io.println("The game ended")
}

/// Generates the default state of the game
/// The columns attribute is used to determine the number of columns in the board.
fn generate_default_state(columns: Int) {
  let half_idx = columns / 2
  let map_index = fn(idx) {
    let snake_head = { columns * half_idx } + half_idx
    let snake_body = { columns * { half_idx + 1 } } + half_idx
    case idx {
      _ if idx == snake_head -> renderer.SnakeHead
      _ if idx == snake_body -> renderer.SnakeBody
      _ -> renderer.Empty
    }
  }

  renderer.Board(
    {
      list.range(0, columns * columns - 1)
      |> list.map(map_index)
    },
    columns,
  )
}

fn game_loop(actor, count: Int) {
  // Render to screen
  process.call(actor, renderer.Render, 1000 / 60)
  io.println(string.append("Render #", int.to_string(count)))

  // Obtain user input
  let assert Ok(value) = get_line("Input (Press q to exit): ")

  // Call next game loop if it shouldn't exit
  case value {
    "q\n" -> {
      io.println("Ending game...")
      process.send(actor, renderer.Stop)
    }
    _ -> game_loop(actor, count + 1)
  }
}
