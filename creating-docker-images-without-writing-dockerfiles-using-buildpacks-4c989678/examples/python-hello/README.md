# python-hello

A minimal "hello world" web app used to demonstrate building a container image
with [Cloud Native Buildpacks](https://buildpacks.io/) via the `pack` CLI —
no Dockerfile required.

## Details

| | |
|---|---|
| Language   | Python |
| Version    | 3.13 (see `.python-version`) |
| Framework  | FastAPI, served by Uvicorn |
| Entrypoint | `main.py` (`python main.py`) |
| Port       | Hardcoded to `8000` — the app does **not** read a `PORT` env var (unlike the Node.js/Go examples) |

## Files

- `requirements.txt` — declares `fastapi[standard]`, which pulls in Uvicorn
  as well. The Paketo Pip buildpack detects this file and installs
  dependencies.
- `.python-version` — pins the runtime to 3.13, read by the Paketo CPython
  buildpack to select the interpreter version.
- `main.py` — the app itself.
- `Procfile` — declares the `web` process as `python main.py`. Like Go,
  Python buildpacks have no `npm start` equivalent, so this is required.

> **Note:** unlike the other two examples, `main.py` starts Uvicorn with a
> hardcoded `port=8000` instead of reading `$PORT`. That's a good discussion
> point in the tutorial — most buildpack platforms inject `PORT` and expect
> the app to bind to it, so this app only works correctly if you happen to
> publish container port 8000.

## Build the image

Python isn't included in the `base` builder used for the other two examples
— it needs the `full` builder:

```bash
pack build python-hello --path . --builder paketobuildpacks/builder-jammy-full
```

## Run it

```bash
docker run --rm -p 8000:8000 python-hello
```

Then visit:

- http://localhost:8000/ — returns `{"Hello": "World"}`
