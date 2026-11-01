# Docker Compose lab — two containers, one conversation

Run a webpage and a Python API together, then see how they communicate. This exercise is separate from the original workshop at the repository root. It does not change or publish that application.

## Before you start

Install [Git](https://git-scm.com/downloads) and [Docker Desktop](https://docs.docker.com/desktop/). Start Docker Desktop and wait for its engine (use Linux containers on Windows). Linux users can use Docker Engine with the Compose plugin. **Check your tools:**

```text
git --version
docker version
docker compose version
```

Use **PowerShell or CMD on Windows**, or **Terminal with Bash/Zsh on macOS/Linux**. All commands below work in those terminals unless a specific terminal is named. Python is installed inside the API image; you do not need Python on your computer. No account, token, or package installation is needed for this public-source exercise.

**Expected:** Git prints its version, Docker shows both Client and Server, and Compose prints a v2 version. Keep Docker Desktop running throughout the lab. Use `docker compose` (two words); you do not need the older `docker-compose` command.

## 1. Get the lab's feature branch

**Choose one route, not both.** The lab is on `feature/docker-compose-lab`; cloning only `main` will not include it.

### New checkout — recommended for students

Open your terminal in a folder where you keep projects. **Run:**

```text
git clone --branch feature/docker-compose-lab --single-branch https://github.com/DenisaEmilia/Master-The-Stack-Workshop.git
cd Master-The-Stack-Workshop
```

If a folder with that name already exists, use the existing-checkout route below, or choose a different parent folder for this fresh clone.

### If you already cloned the original workshop

Open a terminal in your existing `Master-The-Stack-Workshop` folder. **Check for your own changes first:**

```text
git status
```

If you have uncommitted edits from the earlier workshop, save your work in a commit before switching, or use a fresh checkout in another folder. Do not discard your changes to follow this lab.

**With a clean working tree, run:**

```text
git fetch origin feature/docker-compose-lab:refs/remotes/origin/feature/docker-compose-lab
git switch feature/docker-compose-lab
git pull --ff-only origin feature/docker-compose-lab
```

The fetch downloads this branch even if your original clone fetched only `main`. The switch selects the local feature branch, creating it from the remote tracking branch if necessary. If Git reports diverging history, stop and ask the instructor rather than resetting or force-pulling.

### Verify your branch

```text
git branch --show-current
```

**Expected:** `feature/docker-compose-lab`.

## 2. Enter the lab folder and check port 8080

**From the repository root, run:**

```text
cd exercises/docker-compose
```

**Run every Compose command from this folder.** Compose reads `compose.yaml` here and builds from the `web` and `api` subfolders, rather than the original root Dockerfile.

**Check for an earlier demo using port 8080:**

```text
docker ps
```

If your original `workshop-app` container is still using port 8080, stop only that demo:

```text
docker stop workshop-app
```

Skip that command if it is not running. Do not stop or remove unfamiliar containers. The Compose lab needs port 8080 free before starting.

## 3. Build and start both containers

**Run:**

```text
docker compose up -d --build
```

- `compose` manages the services in one YAML file.
- `up` creates the default network and the two containers.
- `--build` builds the images from this exercise's Dockerfiles.
- `-d` runs containers in the background; no new window opens.

Compose waits for the API's health check before starting the frontend. The first build downloads the official Nginx Alpine and Python Alpine images and may take longer.

**Verify the services:**

```text
docker compose ps
```

**Expected:** two services, `web` and `api`, both running; `api` should be healthy. Their generated container names may look like `docker-compose-web-1` and `docker-compose-api-1`. Use the service names in the commands below; you do not need to type the generated names.

## 4. Open the frontend and contact the backend

**Type this exact address in your browser, including `:8080`:**

```text
http://localhost:8080
```

Do not open `web/index.html` directly: this lab needs Nginx to forward the API requests. Open the localhost page, then click **Contact Backend**.

**Expected:** `Hello from the backend!`

### What just happened?

```text
Browser: http://localhost:8080/api/message
  → web (Nginx, port 80): forwards /api/message as /message
    → api (Python, port 5000): returns JSON
      → Nginx → browser: displays the message
```

Both services join Compose's **default network**. Docker's internal DNS turns the service name `api` into the API container's address. The frontend exposes only `127.0.0.1:8080:80`; the API has **no published host port**. `EXPOSE 5000` in its Dockerfile documents its internal port, but does not publish it.

The browser does not know the private hostname `api`. It always talks to Nginx on localhost, using the same origin as the page, so no CORS configuration is needed. Inside the web container, `localhost` would mean the web container itself, which is why Nginx uses `api:5000` instead.

The `resolver` in `web/nginx.conf` lets Nginx look up `api` again if Compose recreates it with a different address.

**Optional browser check:** right-click the webpage → **Inspect** → **Network**, then click **Contact Backend** again. Select the `message` request. Its URL should be `http://localhost:8080/api/message`, status **200**, and its response should contain the backend message. Your browser never requests `http://api:5000` directly.

## 5. Inspect the services and logs

```text
docker compose ps
docker compose logs web
docker compose logs api
```

Expect `web` to show a mapping for `127.0.0.1:8080`. `api` can show `5000/tcp`, but must not show a host mapping such as `0.0.0.0:5000->5000/tcp`.

The web logs show requests to `/api/message`; API logs show requests to `/message`. Requests to `/health` also appear because of the health check. Docker Desktop groups these containers under the Compose project.

## 6. Check the JSON endpoints

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

## 7. Stop the backend and observe the error

Leave the webpage open and stop only the backend:

```text
docker compose stop api
```

Click **Contact Backend** again. **Expected:** a friendly message explaining that the backend cannot be reached. The webpage remains available because Nginx is still running. A request to `/api/message` now returns a gateway error; that is the intentional failure for this exercise.

**Verify that only the backend stopped:**

```text
docker compose ps -a
```

Expect `web` to be running and `api` to be exited/stopped. Clicking the button is essential: an old successful message will not change by itself when you stop the API.

## 8. Restart the backend and recover

**Start the backend again:**

```text
docker compose start api
```

Wait a few seconds, then click the button. **Expected:** `Hello from the backend!` returns. No page rebuild is needed. Check `docker compose ps` and the logs if the API is still starting.

## 9. Optional exercise — change the backend's message

In `compose.yaml`, change the default message in this line:

```yaml
WELCOME_MESSAGE: "${WELCOME_MESSAGE:-Hello from the backend!}"
```

Replace that line with the following, preserving its existing indentation under `environment`:

```yaml
WELCOME_MESSAGE: "${WELCOME_MESSAGE:-My two containers are talking!}"
```

Leave the `${WELCOME_MESSAGE:-...}` structure intact. This reads an optional host environment variable and falls back to the message after `:-`.

Apply the configuration change:

```text
docker compose up -d
```

Click the button again. The API container is recreated to receive the new environment value. A plain `docker compose restart api` would reuse the old environment, so use `up -d` for configuration changes. If you already set a `WELCOME_MESSAGE` variable in your terminal, that value takes precedence over the default in this file.

**Expected:** `My two containers are talking!`. Restore the original message in `compose.yaml` and run `docker compose up -d` again if you want to repeat the lab with its original greeting.

## 10. Stop and clean up

**Run from the lab folder:**

```text
docker compose down
```

This removes this exercise's containers and default network, while keeping its images and your files. It leaves the root workshop and unrelated applications alone. To run the lab again, use `docker compose up -d --build` from this directory.

**Check cleanup:**

```text
docker compose ps -a
```

Expect no lab containers. If you stopped the original workshop in step 2, you can separately start it again with `docker start workshop-app` after the lab releases port 8080.

## Success checklist

- [ ] I checked out `feature/docker-compose-lab` and ran Compose from `exercises/docker-compose`.
- [ ] `docker compose ps` showed both `web` and `api` running.
- [ ] The page at `http://localhost:8080` displayed the backend message after I clicked **Contact Backend**.
- [ ] `/api/message` and `/api/health` returned the expected responses through Nginx.
- [ ] Only `web` had a published host port; `api` remained on the Compose network.
- [ ] Stopping `api` left the page available and produced a friendly error after a click.
- [ ] Starting `api` restored the response without rebuilding the frontend.
- [ ] `docker compose down` removed the lab containers and network.

You do not need to push code, publish images, configure GitHub Actions secrets, or create a pull request to complete this student lab.

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
