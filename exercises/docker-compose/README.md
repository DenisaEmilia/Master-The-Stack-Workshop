# Docker Compose lab — two containers, one conversation

Run a webpage and a Python API together, then see how they communicate. This exercise is separate from the original workshop at the repository root. It does not change or publish that application.

## Before you start

Install and start Docker Desktop (use Linux containers on Windows). Linux users can use Docker Engine with the Compose plugin. Check:

```text
docker version
docker compose version
```

Use **PowerShell or CMD on Windows**, or **Terminal with Bash/Zsh on macOS/Linux**. All commands below work in those terminals unless a specific terminal is named. Python is installed inside the API image; you do not need Python on your computer. No account, token, or package installation is needed for this public-source exercise.

From the repository root, enter the exercise folder:

```text
cd exercises/docker-compose
```

**Run every Compose command from this folder.** Compose reads `compose.yaml` here. If your original workshop is still using port 8080, use `docker ps` to identify it and stop only that demo (for example, `docker stop workshop-app`). Do not remove unrelated containers.

## 1. Build and start

```text
docker compose up -d --build
```

- `compose` manages the services in one YAML file.
- `up` creates the default network and the two containers.
- `--build` builds the images from this exercise's Dockerfiles.
- `-d` runs containers in the background; no new window opens.

Compose waits for the API's health check before starting the frontend. The first build downloads the official Nginx Alpine and Python Alpine images and may take longer.

Open `http://localhost:8080` and click **Contact Backend**.

**Expected:** `Hello from the backend!`

## 2. Understand the request

```text
Browser: http://localhost:8080/api/message
  → web (Nginx, port 80): forwards /api/message as /message
    → api (Python, port 5000): returns JSON
      → Nginx → browser: displays the message
```

Both services join Compose's **default network**. Docker's internal DNS turns the service name `api` into the API container's address. The frontend exposes only `127.0.0.1:8080:80`; the API has **no published host port**. `EXPOSE 5000` in its Dockerfile documents its internal port, but does not publish it.

The browser does not know the private hostname `api`. It always talks to Nginx on localhost, using the same origin as the page, so no CORS configuration is needed. Inside the web container, `localhost` would mean the web container itself, which is why Nginx uses `api:5000` instead.

The `resolver` in `web/nginx.conf` lets Nginx look up `api` again if Compose recreates it with a different address.

## 3. Inspect the services and logs

```text
docker compose ps
docker compose logs web
docker compose logs api
```

Expect `web` to show a mapping for `127.0.0.1:8080`. `api` can show `5000/tcp`, but must not show a host mapping such as `0.0.0.0:5000->5000/tcp`.

The web logs show requests to `/api/message`; API logs show requests to `/message`. Requests to `/health` also appear because of the health check. Docker Desktop groups these containers under the Compose project.

## 4. Check the JSON endpoints

You can open these URLs directly in your browser:

```text
http://localhost:8080/api/message
http://localhost:8080/api/health
```

Expected JSON (spacing may vary):

```json
{"message":"Hello from the backend!"}
```

```json
{"status":"UP"}
```

**Windows PowerShell:**

```powershell
Invoke-RestMethod http://localhost:8080/api/message
Invoke-RestMethod http://localhost:8080/api/health
```

**Windows CMD:**

```bat
curl.exe --fail http://localhost:8080/api/message
curl.exe --fail http://localhost:8080/api/health
```

**macOS/Linux Bash or Zsh:**

```bash
curl --fail http://localhost:8080/api/message
curl --fail http://localhost:8080/api/health
```

## 5. Break the connection and recover

Leave the webpage open and stop only the backend:

```text
docker compose stop api
```

Click **Contact Backend** again. **Expected:** a friendly message explaining that the backend cannot be reached. The webpage remains available because Nginx is still running. A request to `/api/message` now returns a gateway error; that is the intentional failure for this exercise.

Start the backend again:

```text
docker compose start api
```

Wait a few seconds, then click the button. **Expected:** `Hello from the backend!` returns. No page rebuild is needed. Check `docker compose ps` and the logs if the API is still starting.

## 6. Change the backend's message

In `compose.yaml`, change the default message in this line:

```yaml
WELCOME_MESSAGE: "${WELCOME_MESSAGE:-Hello from the backend!}"
```

For example, replace `Hello from the backend!` with `My two containers are talking!`. Leave the `${WELCOME_MESSAGE:-...}` structure intact. This reads an optional host environment variable and falls back to the message after `:-`.

Apply the configuration change:

```text
docker compose up -d
```

Click the button again. The API container is recreated to receive the new environment value. A plain `docker compose restart api` would reuse the old environment, so use `up -d` for configuration changes. If you already set a `WELCOME_MESSAGE` variable in your terminal, that value takes precedence over the default in this file.

## 7. Stop and clean up

```text
docker compose down
```

This removes this exercise's containers and default network, while keeping its images and your files. It leaves the root workshop and unrelated applications alone. To run the lab again, use `docker compose up -d --build` from this directory.

## Troubleshooting

| Problem | What to do |
| --- | --- |
| Cannot connect to Docker | Start Docker Desktop; select Linux containers on Windows. |
| Port 8080 is already allocated | Run `docker ps`, identify your previous demo, and stop only that container before starting this lab. |
| No configuration file found | Run `cd exercises/docker-compose` from the repository root. |
| Button shows an error | Run `docker compose ps` and `docker compose logs api`; start a stopped API with `docker compose start api`, wait briefly, and retry. |
| Message changes do not appear | Run `docker compose up -d` after editing the environment configuration; check for a host `WELCOME_MESSAGE` override. |
| Backend does not open at localhost:5000 | Expected: the API is private. Use `http://localhost:8080/api/message` through Nginx. |

## Files to explore

| File | Purpose |
| --- | --- |
| `compose.yaml` | Services, builds, frontend port, API environment, startup health check |
| `web/Dockerfile` | Official Nginx image with the page and proxy configuration |
| `web/index.html` | Blue workshop page and the small JavaScript button handler |
| `web/nginx.conf` | Routes `/api/` over the Compose network |
| `api/Dockerfile` | Official Python image; no dependency installation |
| `api/server.py` | Standard-library JSON server on port 5000 |

The root Dockerfile, application, validation scripts, and GitHub Actions workflow are unchanged. This lab is run locally and does not publish images to Docker Hub.
