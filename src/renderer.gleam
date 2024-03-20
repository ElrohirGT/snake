import gleam/list
import gleam/string_builder
import gleam/io
import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam_community/ansi
import model
import lib.{default_snake_body_pos, default_snake_head_pos}

/// Represents all possible states of a board cell
pub type BoardCell {
  Empty
  SnakeHead
  SnakeBody
  Food
}

pub fn board_cell_to_string(cell: BoardCell) -> String {
  case cell {
    Empty -> "| "
    SnakeHead -> "|" <> ansi.green("$")
    SnakeBody -> "|#"
    Food -> "|" <> ansi.red("*")
  }
}

/// Represents the Board to render to the screen
/// It's the state of the actor `Renderer`
pub type Board {
  Board(cells: List(BoardCell), columns: Int)
}

/// Possible messages to the Renderer
pub type RendererMessages {
  Render(client: Subject(Nil), board: Board)
  Stop
}

/// Represents the state of the renderer
pub type RendererState {
  RendererState(frame_count: Int)
}

/// Generates a starting default state for the actor
pub fn generate_default_state() {
  RendererState(0)
}

/// Function that handles every message passed to the Board actor
pub fn handle_message(
  message: RendererMessages,
  state: RendererState,
) -> actor.Next(RendererMessages, RendererState) {
  case message {
    Stop -> actor.Stop(process.Normal)
    Render(client, board) -> {
      print_board(board)
      process.send(client, Nil)
      actor.continue(RendererState(state.frame_count + 1))
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
