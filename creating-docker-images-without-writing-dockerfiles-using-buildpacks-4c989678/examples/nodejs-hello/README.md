# nodejs-hello

A minimal "hello world" web app used to demonstrate building a container image
with [Cloud Native Buildpacks](https://buildpacks.io/) via the `pack` CLI —
no Dockerfile required.

## Details

| | |
|---|---|
| Language   | Node.js |
| Version    | >=22 <25 (see `engines` in `package.json`) |
| Framework  | Express 4 |
| Entrypoint | `server.js` (`npm start`) |
| Port       | Reads `PORT` env var, defaults to `8080` |

## Files

- `package.json` — declares the `start` script and the `express` dependency.
  The Paketo Node.js buildpack detects this file, runs `npm install`, and
  uses `npm start` as the web process automatically (no `Procfile` needed).
- `server.js` — the app itself.

## Build the image

```bash
pack build nodejs-hello --path . --builder paketobuildpacks/builder-jammy-base
```

## Run it

```bash
docker run --rm -p 8080:8080 -e PORT=8080 nodejs-hello
```

Then visit:

- http://localhost:8080/ — hello world message
- http://localhost:8080/healthz — JSON health check
