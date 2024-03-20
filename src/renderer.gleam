import gleam/string
import gleam/list
import gleam/string_builder
import gleam/int
import gleam/io
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import model.{type Vector2}

/// Represents all possible states of a board cell
pub type BoardCell {
  Empty
  Snake
  Food
}

pub fn board_cell_to_string(cell: BoardCell) -> String {
  case cell {
    Empty -> "| "
    Snake -> "|#"
    Food -> "|*"
  }
}

/// Possible messages to the Renderer
pub type RendererMessages {
  Render(client: Subject(Nil))
  Stop
}

/// Represents the Board to render to the screen
/// It's the state of the actor `Renderer`
pub type Board {
  Board(cells: List(BoardCell), columns: Int)
}

/// Function that handles every message passed to the Board actor
pub fn handle_message(
  message: RendererMessages,
  state: Board,
) -> actor.Next(RendererMessages, Board) {
  case message {
    Stop -> actor.Stop(process.Normal)
    Render(client) -> {
      print_board(state)
      process.send(client, Nil)
      actor.continue(state)
    }
  }
}

fn print_board(board: Board) {
  let columns = board.columns
  let render_cell_to_screen = fn(cell: BoardCell, idx: Int) {
    let suffix = case { idx + 1 } % columns {
      0 -> "|\n"
      _ -> ""
    }
    [board_cell_to_string(cell), suffix]
    |> string_builder.from_strings()
    |> string_builder.to_string()
  }

  board.cells
  |> list.index_map(render_cell_to_screen)
  |> string_builder.from_strings()
  |> string_builder.to_string()
  |> io.println()
}
