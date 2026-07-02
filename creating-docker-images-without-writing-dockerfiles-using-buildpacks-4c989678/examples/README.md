# Buildpacks Tutorial: Sample Apps

Sample apps for a tutorial on building container images with
[Cloud Native Buildpacks](https://buildpacks.io/) using the `pack` CLI —
no Dockerfile needed. Each app is intentionally tiny (hello world + a
health check route) so the focus stays on the buildpacks workflow, not the
app code.

## Examples

| Directory | Language | Framework | Details |
|---|---|---|---|
| [`nodejs-hello/`](nodejs-hello/) | Node.js 22 | Express 4 | [README](nodejs-hello/README.md) |
| [`golang-hello/`](golang-hello/) | Go 1.23 | stdlib `net/http` | [README](golang-hello/README.md) |
| [`python-hello/`](python-hello/) | Python 3.13 | FastAPI + Uvicorn | [README](python-hello/README.md) |

## Prerequisites

1. **Docker** (or another OCI-compatible daemon) running locally.
2. **`pack` CLI** — install via:
   ```bash
   # macOS
   brew install buildpacks/tap/pack

   # Linux (see https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/ for other options)
   curl -sSL "https://github.com/buildpacks/pack/releases/latest/download/pack-v$(curl -s https://api.github.com/repos/buildpacks/pack/releases/latest | grep tag_name | cut -d '"' -f4 | tr -d v)-linux.tgz" | tar -C /usr/local/bin/ --no-same-owner -xzv pack
   ```
   Verify with `pack version`.

## The general workflow

For any example directory:

```bash
cd nodejs-hello   # or golang-hello, or python-hello

# Build an OCI image from source using buildpacks — no Dockerfile involved
pack build <image-name> --path . --builder <builder>

# Run the resulting image like any other container
docker run --rm -p 8080:8080 -e PORT=8080 <image-name>
```

`pack build` automatically:
1. **Detects** the language/framework from files in the directory
   (`package.json` for Node, `go.mod` for Go, `requirements.txt` for Python).
2. **Builds** the app using the matching buildpack (installs dependencies,
   compiles, etc.) — reproducibly, without a hand-written Dockerfile.
3. **Packages** everything into a runnable OCI image, layered and cached
   for fast rebuilds.

Two different builders are used across these examples on purpose — it's a
good opportunity to show that not every builder ships every language:

- `paketobuildpacks/builder-jammy-base` — used for `nodejs-hello` and
  `golang-hello`.
- `paketobuildpacks/builder-jammy-full` — required for `python-hello`,
  since Python isn't included in the `base` builder.

Run `pack builder suggest` to see other builder options and what each one
includes.

Exact run command per example (ports/env vary — see each app's README):

```bash
docker run --rm -p 8080:8080 -e PORT=8080 nodejs-hello
docker run --rm -p 8080:8080 -e PORT=8080 golang-hello
docker run --rm -p 8000:8000 python-hello
```

## Suggested tutorial flow

1. `pack build` the Node.js example, run it, hit `/` and `/healthz`.
2. `pack build` the Go example, run it, compare image size/build output.
3. `pack build` the Python example with the `full` builder, and discuss why
   `base` wasn't enough — plus note that this app ignores `$PORT` entirely,
   a common real-world gotcha when adopting buildpacks.
4. Inspect the generated image with `docker inspect` / `pack inspect-image`
   to show there's no Dockerfile anywhere in the process.
5. Rebuild after a trivial code change to demonstrate buildpack layer
   caching (fast rebuilds).
