import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/int
import gleam/io
import gleam/result
import model.{type SnakeMovement, type Vector2, add}
import renderer.{type Board}
import lib.{between, default_snake_body_pos, default_snake_head_pos}

/// Represents a set of successful response the engine can respond
/// when a movement is processed
pub type MovementResponse {
  GameOver(reason: String)
  Render(Board)
}

/// Represents a set of errors the engine can respond with
/// when a movement is invalid or raises an error
pub type MovementError {
  /// Movement error that is raised when the snake is trying to move out of bounds
  OutOfBounds
  /// Movement error that is raised when the snake tries to move "backwards"
  BackwardsMovement
}

/// Messages to pass to the Game engine
/// The engine that contains all the business logic
pub type GameMessages {
  /// Message to pass when a Snake moves in a certain direction
  Movement(
    Subject(Result(MovementResponse, MovementError)),
    direction: SnakeMovement,
  )
  Stop
}

/// Represents the Game state
pub type GameState {
  GameState(
    board_size: Vector2,
    snake: List(Vector2),
    food: List(Vector2),
    growth_direction: SnakeMovement,
  )
}

/// Generates the default state of the engine given the board size
pub fn generate_default_state(columns: Int) -> GameState {
  let snake_head = default_snake_head_pos(columns)
  let snake_body = default_snake_body_pos(columns)
  GameState(
    board_size: model.Vector2(columns, columns),
    snake: [snake_head, snake_body],
    food: [add(snake_head, model.Vector2(0, -2))],
    growth_direction: model.Down,
  )
}

/// Generates a `Board` to render based on the given `GameState`
pub fn game_state_to_board(state: GameState) -> Board {
  let snake_idx =
    state.snake
    |> list.map(model.to_index(_, state.board_size.x))
  let food_idx =
    state.food
    |> list.map(model.to_index(_, state.board_size.x))

  let cells =
    list.range(0, state.board_size.y * state.board_size.x - 1)
    |> list.map(fn(idx) {
      let is_snake_head = list.first(snake_idx) == Ok(idx)
      let is_snake_idx = list.contains(snake_idx, idx)
      let is_food_idx = list.contains(food_idx, idx)

      case [is_snake_head, is_snake_idx, is_food_idx] {
        [True, _, _] -> renderer.SnakeHead
        [_, True, _] -> renderer.SnakeBody
        [_, _, True] -> renderer.Food
        _ -> renderer.Empty
      }
    })

  renderer.Board(cells, state.board_size.x)
}

pub fn handle_message(
  message: GameMessages,
  state: GameState,
) -> actor.Next(GameMessages, GameState) {
  case message {
    Stop -> actor.Stop(process.Normal)
    Movement(client, direction) -> {
      let assert Ok(head) = list.first(state.snake)
      let assert Ok(neck) = list.at(state.snake, 1)
      let direction_vector = model.to_vector(direction)
      let head_future = model.add(head, direction_vector)
      let future_has_food =
        state.food
        |> list.find(fn(a) { a == head_future })
      let future_has_snake =
        state.snake
        |> list.find(fn(a) { a == head_future })
        |> result.is_ok

      let #(new_snake, updated_foods) = case future_has_food {
        Ok(food_pos) -> {
          let append_to_end = fn(a, list) { list.append(list, [a]) }
          let assert Ok(tail) = list.last(state.snake)
          let new_snake =
            state.growth_direction
            |> model.to_vector
            |> model.add(tail)
            |> append_to_end(state.snake)
          let new_food =
            model.Vector2(
              int.random(state.board_size.x),
              int.random(state.board_size.y),
            )

          #(
            new_snake,
            state.food
              |> list.filter(fn(a) { a != food_pos })
              |> list.append([new_food]),
          )
        }
        Error(Nil) -> #(state.snake, state.food)
      }

      case
        [
          between(head_future.x, -1, state.board_size.x),
          between(head_future.y, -1, state.board_size.y),
          head_future == neck,
          future_has_snake,
        ]
      {
        [True, True, False, False] -> {
          let #(moved_snake, tail_growth_direction) =
            move_snake(new_snake, direction, #([], model.Up))
          let new_state =
            GameState(
              state.board_size,
              moved_snake,
              updated_foods,
              tail_growth_direction,
            )
          let response =
            new_state
            |> game_state_to_board
            |> Render
            |> Ok
          process.send(client, response)
          actor.continue(new_state)
        }
        [_, _, False, True] -> {
          process.send(client, Ok(GameOver("You ate yourself!")))
          actor.continue(state)
        }
        [_, _, True, _] -> {
          process.send(client, Error(BackwardsMovement))
          actor.continue(state)
        }
        _ -> {
          process.send(client, Error(OutOfBounds))
          actor.continue(state)
        }
      }
    }
  }
}

fn move_snake(
  snake: List(Vector2),
  previous_movement: SnakeMovement,
  result: #(List(Vector2), SnakeMovement),
) -> #(List(Vector2), SnakeMovement) {
  case snake {
    [] -> result
    [first, ..rest] -> {
      let moved_part =
        previous_movement
        |> model.to_vector
        |> model.add(first)
      let moved_snake = list.append(result.0, [moved_part])
      case list.first(rest) {
        Ok(next_part) -> {
          let assert Ok(current_direction) =
            model.subtract(first, next_part)
            |> model.to_direction()
          let result = #(moved_snake, model.contrary(current_direction))
          move_snake(rest, current_direction, result)
        }
        Error(_) -> #(moved_snake, result.1)
      }
    }
  }
}
