# Docker Compose lab — frontend and backend

Start two containers, click a button, and test what happens when the backend stops.

## Git command reference

Reference only—follow the numbered lab steps below. No Git push is required to complete this lab.

| Command | What it does |
| --- | --- |
| `git status` | Show your current branch and unfinished changes. |
| `git fetch origin feature/docker-compose-lab:refs/remotes/origin/feature/docker-compose-lab` | Download the lab branch, including from a main-only clone. |
| `git switch feature/docker-compose-lab` | Switch to the prepared lab branch. |
| `git checkout feature/docker-compose-lab` | Older alternative for switching branches. |
| `git branch --show-current` | Check which branch you are using. |
| `git pull --ff-only origin feature/docker-compose-lab` | Update the lab branch without creating a merge commit. |
| `git switch -c compose/your-name` | Optionally create a personal branch from the current lab for your own edits. Replace `your-name`. |
| `git diff` | Review unstaged edits to tracked files. |
| `git add compose.yaml` | Stage your message/configuration changes when run from the lab folder. |
| `git commit -m "Change the backend message"` | Optionally save staged changes locally. |
| `git stash push -u -m "Save previous workshop edits"` | Save unfinished work before switching branches. |
| `git stash pop` | Restore the latest stash; resolve conflicts if Git reports any. |

## Docker and Compose command reference

Run **Compose commands from `exercises/docker-compose`**, where `compose.yaml` lives. `web` is the frontend service; `api` is the backend service.

| Command | What it does |
| --- | --- |
| `docker version` | Check that the Docker engine is available. |
| `docker compose version` | Check that Compose v2 is installed. |
| `docker ps` | Show running containers, including older workshop demos. |
| `docker stop workshop-app` | Stop the previous workshop demo if it is using port 8080. |
| `docker compose config --quiet` | Validate the Compose configuration. |
| `docker compose build` | Build both images without starting containers. |
| `docker compose up -d --build` | Build and start both services in the background. |
| `docker compose ps` | Show running lab services and published ports. |
| `docker compose ps -a` | Include stopped lab containers. |
| `docker compose logs web` | Show frontend/Nginx logs. |
| `docker compose logs api` | Show Python backend logs. |
| `docker compose logs -f` | Follow live logs; Ctrl+C stops following, not the containers. |
| `docker compose stop api` | Stop only the backend. |
| `docker compose start api` | Start the existing backend again. |
| `docker compose up -d` | Apply configuration changes and recreate affected containers. |
| `docker compose down` | Remove this lab's containers and network; keep images and files. |

## Before starting

- Install [Git](https://git-scm.com/downloads) and [Docker Desktop](https://docs.docker.com/desktop/).
- Start Docker Desktop; select **Linux containers** on Windows. Linux users can use Docker Engine with the Compose plugin.
- Use **PowerShell/CMD on Windows** or **Terminal with Bash/Zsh on macOS/Linux**. Shared Git/Docker commands below work in all of them.
- No local Python installation, Docker Hub account, or GitHub Actions secrets are needed.

## 1. Get the lab branch

Check your tools:

```bash
git --version
docker version
docker compose version
```

**Expected:** Git and Compose versions, plus Docker Client and Server information.

**Already cloned the original workshop?** Open your existing `Master-The-Stack-Workshop` folder and run `git status`. Save unfinished edits in a commit or stash before switching. With a clean working tree:

```bash
git fetch origin feature/docker-compose-lab:refs/remotes/origin/feature/docker-compose-lab
git switch feature/docker-compose-lab
git pull --ff-only origin feature/docker-compose-lab
```

**New checkout instead?** From a folder where you keep projects:

```bash
git clone --branch feature/docker-compose-lab --single-branch https://github.com/DenisaEmilia/Master-The-Stack-Workshop.git
cd Master-The-Stack-Workshop
```

Choose one route, not both. Do not clone inside an existing copy of the repository.

**Verify and enter the exercise:**

```bash
git branch --show-current
cd exercises/docker-compose
```

Expected branch: **`feature/docker-compose-lab`**. Run every remaining Compose command from this exercise folder.

## 2. Free port 8080

```bash
docker ps
```

If your old `workshop-app` demo is still using port 8080:

```bash
docker stop workshop-app
```

Skip that command if the demo is not running. Leave unrelated containers alone.

## 3. Build and start both services

```bash
docker compose config --quiet
docker compose up -d --build
docker compose ps
```

**Expected:** `web` and `api` are running; `api` becomes healthy. The first build may take longer to download the base images. `web` publishes `127.0.0.1:8080`; `api` has no host port mapping.

## 4. Open the frontend and click the button

**Open:** `http://localhost:8080`.

Click **Contact Backend**.

**Expected:** `Hello from the backend!`

The request travels **browser → Nginx (`web`) → Python (`api`) → browser**. Open the localhost page, not `web/index.html` directly.

Optional: open your browser's **Inspect → Network** panel and click again. The `message` request should use `http://localhost:8080/api/message` and return **200**.

## 5. Check the API and logs

Open these browser addresses:

| Address | Expected response |
| --- | --- |
| `http://localhost:8080/api/message` | `{"message":"Hello from the backend!"}` |
| `http://localhost:8080/api/health` | `{"status":"UP"}` |

Or use your terminal:

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

**Show the logs:**

```bash
docker compose logs web
docker compose logs api
```

Expect `/api/message` in the web logs and `/message` in the API logs. The API is reached through Nginx; `localhost:5000` is not exposed.

## 6. Stop the backend, then recover

```bash
docker compose stop api
docker compose ps -a
```

Click **Contact Backend** again. **Expected:** the page still loads, but the button displays a friendly backend-unavailable error. `web` is running and `api` is stopped.

```bash
docker compose start api
docker compose ps
```

Wait a few seconds and click again. **Expected:** `Hello from the backend!` returns without rebuilding the frontend.

## 7. Change the backend message

In `compose.yaml`, replace the `WELCOME_MESSAGE` line with this, keeping its indentation under `environment`:

```yaml
WELCOME_MESSAGE: "${WELCOME_MESSAGE:-My two containers are talking!}"
```

**Apply the change:**

```bash
docker compose config --quiet
docker compose up -d
```

Click the button. **Expected:** `My two containers are talking!`

Use `up -d` to apply environment changes; restarting the old container alone keeps its old configuration. If your terminal already defines `WELCOME_MESSAGE`, that value overrides the default in the file.

To repeat the original greeting, restore `Hello from the backend!` in the same line and run `docker compose up -d` again.

## 8. Clean up

```bash
docker compose down
docker compose ps -a
```

**Expected:** no lab containers remain. Images and source files are kept. Start another session with `docker compose up -d --build` from this folder.

If you stopped the original demo in step 2, you can now bring it back:

```bash
docker start workshop-app
```

## Troubleshooting

| Problem | What to do |
| --- | --- |
| Docker engine unavailable | Start Docker Desktop; select Linux containers on Windows. |
| Lab folder missing | Check out `feature/docker-compose-lab`, not `main`. |
| Git reports divergent history | Stop and ask the instructor; preserve your edits and avoid force-pushing/resetting. |
| Port 8080 is allocated | Run `docker ps`; stop only your earlier demo using that port. |
| No Compose configuration found | Run Compose from `exercises/docker-compose`. |
| Button shows an error | Check `docker compose ps -a` and `docker compose logs api`; start a stopped API and retry. |
| Changed message does not appear | Run `docker compose up -d`; check for a terminal `WELCOME_MESSAGE` override. |
| API unavailable at localhost:5000 | Expected: use `http://localhost:8080/api/message` through Nginx. |

**Lab complete:** both services ran, the button received a backend response, stopping/restarting the API showed error/recovery, and cleanup removed the lab containers. No push, publication, or pipeline configuration is required.
