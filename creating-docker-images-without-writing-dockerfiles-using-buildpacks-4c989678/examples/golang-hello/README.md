# golang-hello

A minimal "hello world" web app used to demonstrate building a container image
with [Cloud Native Buildpacks](https://buildpacks.io/) via the `pack` CLI —
no Dockerfile required.

## Details

| | |
|---|---|
| Language   | Go |
| Version    | 1.23 (see `go.mod`, any modern 1.2x toolchain works) |
| Framework  | None — standard library `net/http` only |
| Entrypoint | `main.go`, compiled to a binary named `golang-hello` |
| Port       | Reads `PORT` env var, defaults to `8080` |

## Files

- `go.mod` — module definition. The Paketo Go buildpack detects this and
  runs `go build` on the module.
- `main.go` — the app itself.
- `Procfile` — declares the `web` process (`golang-hello`, the compiled
  binary name). Go buildpacks don't have an `npm start` equivalent, so this
  is required to tell the platform what to run.

## Build the image

```bash
pack build golang-hello --path . --builder paketobuildpacks/builder-jammy-base
```

## Run it

```bash
docker run --rm -p 8080:8080 -e PORT=8080 golang-hello
```

Then visit:

- http://localhost:8080/ — hello world message
- http://localhost:8080/healthz — JSON health check
