import gleam/io
import gleam/string
import gleam/int
import gleam/otp/actor
import gleam/erlang/process
import gleam/erlang.{get_line}
import renderer
import game
import model.{type SnakeMovement}

pub fn main() {
  let columns = 9
  let default_engine_state = game.generate_default_state(columns)
  let assert Ok(engine_actor) =
    actor.start(default_engine_state, game.handle_message)
  let assert Ok(render_actor) =
    actor.start(renderer.generate_default_state(), renderer.handle_message)

  game_loop(
    engine_actor,
    render_actor,
    0,
    game.game_state_to_board(default_engine_state),
  )
  io.println("The game ended")
}

/// Represents all the commands the user can type
type Commands {
  /// The user wants to quit the game
  Quit
  /// the user wants to move the snake
  MoveSnake(SnakeMovement)
}

/// Function that executes the main game loop
fn game_loop(engine, display, count: Int, board: renderer.Board) {
  let end_game_routine = fn() {
    io.println("Ending game...")

    process.send(display, renderer.Stop)
    process.send(engine, game.Stop)
  }

  // Render to screen
  process.call(display, renderer.Render(_, board), 1000 / 60)

  // Obtain user input
  let command = ask_input()

  // Call next game loop if it shouldn't exit
  case command {
    Quit -> {
      end_game_routine()
    }
    MoveSnake(movement) -> {
      case process.call(engine, game.Movement(_, movement), 1000 / 30) {
        Ok(game.Render(new_board)) ->
          game_loop(engine, display, count + 1, new_board)
        Ok(game.GameOver(end_message)) -> {
          io.println("The game has ended: " <> end_message)
          end_game_routine()
        }
        Error(game.OutOfBounds) ->
          io.println("INVALID MOVEMENT - OUT OF BOUNDS")
        Error(game.BackwardsMovement) ->
          io.println("INVALID MOVEMENT - CAN'T MOVE BACKWARDS")
      }
      game_loop(engine, display, count + 1, board)
    }
  }
}

/// Function that asks for the user command
/// If the user types an invalid command, it asks again
fn ask_input() -> Commands {
  let assert Ok(value) = get_line("Input (Press q to exit): ")
  case parse_command(value) {
    Ok(command) -> command
    Error(_) -> ask_input()
  }
}

/// Parses a user command into an enum that we can use
fn parse_command(command: String) -> Result(Commands, Nil) {
  case command {
    "q\n" -> Ok(Quit)
    "k\n" | "w\n" -> Ok(MoveSnake(model.Up))
    "j\n" | "s\n" -> Ok(MoveSnake(model.Down))
    "h\n" | "a\n" -> Ok(MoveSnake(model.Left))
    "l\n" | "d\n" -> Ok(MoveSnake(model.Right))
    _ -> Error(Nil)
  }
}
