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
    actor.start(
      renderer.Board(
        {
          list.range(0, columns * columns - 1)
          |> list.map(fn(_) { renderer.Empty })
        },
        columns,
      ),
      handle_message,
    )

  game_loop(actor, 0)
  io.println("The game ended")
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
