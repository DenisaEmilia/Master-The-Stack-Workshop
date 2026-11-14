# From Code to Container

Build locally, run a container, then pull and run the instructor's published image.

## Git command reference

These are reference commands—follow the workshop steps below in order. Replace `your-name` with your own name when creating a personal branch.

| Command | What it does |
| --- | --- |
| `git clone https://github.com/DenisaEmilia/Master-The-Stack-Workshop.git` | Download the repository. |
| `git status` | See your current branch and changed files. |
| `git branch --show-current` | Show your current branch name. |
| `git branch -a` | List local and remote-tracking branches. |
| `git fetch origin` | Download remote branch updates without switching branches. |
| `git switch main` | Switch to an existing branch. |
| `git checkout main` | Older alternative to `git switch main`. |
| `git switch -c workshop/your-name` | Create and switch to a new branch from your current commit. |
| `git checkout -b workshop/your-name` | Older alternative for creating a branch; choose one command, not both. |
| `git pull --ff-only` | Update the current tracking branch without creating a merge commit; stops if histories diverge. |
| `git diff` | Show unstaged edits to tracked files. |
| `git add index.html` | Stage this file for the next commit. |
| `git diff --cached` | Review staged changes, including new files. |
| `git commit -m "Update the page"` | Save staged changes locally. |
| `git push -u origin workshop/your-name` | Publish your personal branch and set its upstream. |
| `git push` | Send new commits to the current branch's configured upstream. |
| `git log --oneline -5` | Show the five latest commits. |
| `git stash push -u -m "Save my workshop edits"` | Temporarily save unfinished changes, including new untracked files. |
| `git stash pop` | Restore the latest stash; resolve conflicts if Git reports any. |

Pushing to this shared repository requires collaborator access. Students use personal branches; only the instructor publishes changes to `main`.

## Docker command reference

`workshop-app:local` is your locally built image. `denisaemilia/workshop-app:latest` is the instructor's public Docker Hub image.

| Command | What it does |
| --- | --- |
| `docker version` | Check the Docker client and engine. |
| `docker build -t workshop-app:local .` | Build an image from the current project folder. |
| `docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 workshop-app:local` | Create a background container, available on localhost port 8080. |
| `docker image ls` | List downloaded and built images. |
| `docker ps` | List running containers. |
| `docker ps -a` | Include stopped containers. |
| `docker logs workshop-app` | Show this container's logs. |
| `docker stop workshop-app` | Stop the existing container. |
| `docker start workshop-app` | Restart the same container. |
| `docker rm -f workshop-app` | Stop and remove only this demo container; keep images and source files. |
| `docker pull denisaemilia/workshop-app:latest` | Download the instructor's published image. |
| `docker inspect workshop-app` | Inspect the container's image and configuration. |
| `docker context show` | Show which Docker engine your terminal uses. |
| `docker compose up -d --build` | Build/start the Compose lab from its folder containing `compose.yaml`. |
| `docker compose down` | Remove that Compose project's containers and network. |

## Before starting

- Install [Git](https://git-scm.com/downloads) and [Docker Desktop](https://docs.docker.com/desktop/).
- Start Docker Desktop; on Windows, select **Linux containers**.
- Use **PowerShell/CMD on Windows** or **Terminal with Bash/Zsh on macOS/Linux**. The shared Git/Docker commands below work in all of them. Windows students do not need Bash.
- Public image pulls need no Docker Hub account, password, or instructor token.

## Part 1 — Build and run locally

### 1. Check your tools

```bash
git --version
docker version
```

**Expected:** a Git version and Docker **Client** and **Server** information. If Server is unavailable, start Docker Desktop.

### 2. Get the project

**New checkout:**

```bash
git clone --branch main https://github.com/DenisaEmilia/Master-The-Stack-Workshop.git
cd Master-The-Stack-Workshop
```

**Already cloned?** Open your existing project folder, run `git status`, save unfinished work in a commit or stash, then:

```bash
git switch main
git pull --ff-only origin main
```

Run local builds from this folder, beside `Dockerfile` and `index.html`.

### 3. View the HTML source page

Choose the command for your terminal:

| Terminal | Command |
| --- | --- |
| Windows PowerShell | `Start-Process .\index.html` |
| Windows CMD | `start "" index.html` |
| macOS Bash/Zsh | `open index.html` |
| Linux desktop/Bash | `xdg-open index.html` |

This opens the source file. Use the **localhost tab** for the container steps below.

### 4. Build and run

```bash
docker build -t workshop-app:local .
docker image ls
docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 workshop-app:local
```

**Open:** `http://localhost:8080` — include `:8080`.

**Expected:** the page matches your HTML, initially blue with **Version 1**. If the repository has already been updated, it shows that newer source. The container runs in the background; no separate window opens.

```bash
docker ps
docker logs workshop-app
```

If the demo name or port is already in use, identify your old demo with `docker ps -a` before removing it. Leave unrelated containers alone.

### 5. Stop and restart

```bash
docker stop workshop-app
```

Refresh localhost: the server is unavailable.

```bash
docker ps -a
docker start workshop-app
```

Refresh again: the page returns.

### 6. Edit, rebuild, and replace

In `index.html`, change the visible text inside `<p id="app-message">` to **Hello from my local container!** Save it and refresh localhost: the old message remains.

```bash
docker build -t workshop-app:local .
```

Refresh: still the old message. **Recreate the container to use the rebuilt image:**

```bash
docker rm -f workshop-app
docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 workshop-app:local
```

**Expected:** refreshing localhost now shows your new message. This local exercise does not need a Git push.

## Part 2 — Run the Docker Hub image

### 7. Download the instructor's image

These commands work from **any folder**, without source code. Start the live update demonstration with the instructor's published Version 1.

```bash
docker pull denisaemilia/workshop-app:latest
```

After the pull succeeds, remove your Part 1 demo and start the published image:

```bash
docker rm -f workshop-app
docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 denisaemilia/workshop-app:latest
```

Skip the removal command if you never created `workshop-app`. Open `http://localhost:8080`; expect the instructor's published page, rather than your local edits.

### 8. Instructor: publish Version 2

Students leave their Version 1 container running. In a clean `main` publishing checkout, the instructor first runs:

```bash
git pull --ff-only origin main
```

Then edit `index.html`:

| Field | New value |
| --- | --- |
| `id="app-version"` | `Version 2` |
| `id="app-message"` | `Hello from Version 2! My pipeline works!` |
| CSS `--primary` | `#15803d` (green) |

**Instructor commands after editing:**

```bash
git diff
git add index.html
git diff --cached
git commit -m "Show Version 2 in green"
git push origin main
```

Follow repository branch rules if a pull request is required. In GitHub, open **Actions → From Code to Container** and wait for **CI** and **CD** to pass. Check Docker Hub for updated `latest` and the new `sha-...` tag. One-time publishing setup is below.

**Students refresh their existing page: Version 1 remains.**

### 9. Students: pull, pause, then update

```bash
docker pull denisaemilia/workshop-app:latest
```

Refresh localhost now: **still Version 1**. Pulling does not replace the running container.

```bash
docker rm -f workshop-app
docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 denisaemilia/workshop-app:latest
```

**Expected:** refresh and see **Version 2 in green**. Hard-refresh if your browser cached the page.

### 10. Clean up

```bash
docker rm -f workshop-app
docker ps -a
```

The demo container is gone; your images and source files remain.

## Optional — Update helpers

From the project folder, use one command for your terminal. Each helper pulls the public image and recreates the labeled demo container.

| Terminal | Command |
| --- | --- |
| macOS/Linux Bash or Zsh | `bash scripts/update-container.sh denisaemilia` |
| Windows PowerShell | `.\scripts\update-container.ps1 -Image denisaemilia` |
| Windows CMD | `powershell.exe -NoProfile -File .\scripts\update-container.ps1 -Image denisaemilia` |

If PowerShell policy blocks the helper, use the individual Docker commands above. Do not run the Bash helper through an unconfigured WSL installation.

## Configure Docker Hub publishing (instructor, once)

1. Create a **Public** Docker Hub repository named `workshop-app` under your username.
2. Generate a Docker Hub access token with **Read & Write** permission.
3. In GitHub, open **Settings → Environments → test**.
4. Add environment variable **DOCKERHUB_USERNAME** with your Docker Hub username.
5. Add environment secret **DOCKERHUB_TOKEN** with the token. Never commit or display its value.
6. Open **Actions → From Code to Container → Run workflow**, select **main**, and run it. Approve the `test` environment if its rules require approval.
7. Verify both jobs pass and Docker Hub shows `latest` plus `sha-...`.

The student commands use the instructor's namespace `denisaemilia`. If publishing under another account, replace that namespace in the pull/run/helper commands. PRs run CI without publishing; main pushes and manual main runs publish after CI succeeds. Images support Linux AMD64 and ARM64.

## Optional — Check the running page

From the project folder with the container running:

**Bash:**

```bash
bash scripts/validate.sh
bash scripts/smoke-test.sh http://localhost:8080
```

**Windows PowerShell:**

```powershell
(Invoke-WebRequest http://localhost:8080 -UseBasicParsing).StatusCode
```

**Windows CMD:**

```bat
curl.exe --fail http://localhost:8080
```

Expect HTTP **200** and the workshop page. The full instructor walkthrough is in [WORKSHOP.md](WORKSHOP.md).

## Troubleshooting

| Problem | What to do |
| --- | --- |
| Docker engine unavailable | Start Docker Desktop; select Linux containers on Windows. |
| Name/port already in use | Inspect `docker ps -a`; stop/remove only your old demo. |
| Page won't open | Use `http://localhost:8080`, check `docker ps`, then `docker logs workshop-app`. |
| Old page after a build or pull | Recreate the container, then hard-refresh. |
| Container missing from Docker Desktop | Clear filters; check `docker context show` for a different engine. |
| Pull denied or tag missing | Check the image address, Public visibility, and successful publication. |
| Red CI or CD | Read the first failing step; check `test` environment settings for publishing failures. |
| WSL/Bash error on Windows | Use PowerShell/CMD and the individual Docker commands. |
| Git push denied | Accept your collaborator invitation; authenticate with your own GitHub account. |

## Other workshop labs

- [Docker Compose — frontend and backend](https://github.com/DenisaEmilia/Master-The-Stack-Workshop/blob/feature/docker-compose-lab/exercises/docker-compose/README.md)
- [DevOps Escape Room — pipeline gates](https://github.com/DenisaEmilia/Master-The-Stack-Workshop/blob/feature/devops-escape-room/exercises/devops-escape/README.md)
