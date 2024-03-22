# Snake
Las dependencias del proyecto son:
- Gleam
- Erlang

Si se tiene Nix instalado con flakes se puede utilizar, este comando crea una shell con las dependencias instaladas:
```bash
nix develop
```

Una vez se tenga instaladas las dependencias para compilar y correr el proyecto:
```bash
gleam run
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
