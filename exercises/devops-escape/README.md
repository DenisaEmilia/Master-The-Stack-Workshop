# DevOps Escape Room — eight gates to a green pipeline

The release is trapped. A rubber duck refuses to approve it, Captain Dockerbeard has hidden a code, and the pipeline keeps finding another problem. Your mission is to repair **one gate at a time** until all eight pass.

**The starter is intentionally broken. Your first red run is expected.** The next gate becomes visible only after the current one passes. Repair the application/configuration files, not the gate validators or workflow conditions. There is no automatic deployment and nothing is pushed to Docker Hub.

## Before starting

- Install [Git](https://git-scm.com/downloads) and have a GitHub account.
- Use PowerShell or CMD on Windows, or Terminal/Bash/Zsh on macOS/Linux.
- Use your own fork (one per team), with Actions enabled and permission to push.
- Docker Desktop is recommended for investigating Docker/HTTP failures locally. It is **not required** to participate: GitHub-hosted Ubuntu has Docker, Bash, Python, and curl.
- Keep an editor ready, and save text/JSON as UTF-8. JSON uses double quotes, has no comments, and does not permit trailing commas.

Already did the original workshop? Save any unfinished work there first. This exercise uses a **different branch** and its own folder. If the original demo or Compose lab is using port 8080, stop only your own demo before running this escape room locally. CI runs on a separate machine and is unaffected by ports on your laptop.

## 1. Fork and obtain the prepared starter

On GitHub, open `DenisaEmilia/Master-The-Stack-Workshop`, click **Fork**, and create your team's fork. If offered **Copy the main branch only**, uncheck it so the prepared feature branch is included. Each team should have a separate fork to avoid editing another team's answers.

**Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username.** From a folder where you keep projects, run the following in PowerShell, CMD, Bash, or Zsh:

```text
git clone https://github.com/YOUR_GITHUB_USERNAME/Master-The-Stack-Workshop.git
cd Master-The-Stack-Workshop
git remote add upstream https://github.com/DenisaEmilia/Master-The-Stack-Workshop.git
git fetch upstream feature/devops-escape-room
git switch -c escape/team-alpha FETCH_HEAD
```

Choose your own team name after `escape/`, such as `escape/team-duck`. The fetch selects the instructor's prepared starter even if your fork copied only `main`. `origin` remains your fork; `upstream` is the instructor's source. For an existing clone, inspect `git status` and `git remote -v` first; don't blindly add an already-configured remote or discard old work. If your team branch already exists, switch to it rather than recreating it.

**Verify the branch:**

```text
git branch --show-current
```

Expected: `escape/team-alpha` (or your chosen team name).

**Why two names?** `feature/devops-escape-room` is the prepared instructor branch. Your `escape/**` branch is where you solve missions, and its name triggers the pipeline. Do not push your fixes to `main` or open a PR to `main` during the game; that belongs to the original delivery workshop.

## 2. Start the first run

In **your fork's Actions tab**, enable GitHub Actions if GitHub asks. Do this before pushing. Then:

```text
git push -u origin escape/team-alpha
```

Use your actual team branch in place of `escape/team-alpha`. GitHub may ask you to authenticate for this Git push; use your configured GitHub login/Git credential manager. Never paste tokens into a repository file.

Open your fork on GitHub → **Actions → DevOps Escape Room** → the run for your team branch → **Escape the eight gates** → **Gate 1 — The Missing Artifact**.

**Expected first result:** Gate 1 is red because `deployment-info.json` is missing. Gates 2–8 are skipped. The run summary reports **0/8 completed** and **Gate 01** as the first failure. If you enabled Actions after your first push, push a new commit to trigger a fresh run:

```text
git commit --allow-empty -m "Start escape room"
git push
```

The workflow also supports `workflow_dispatch`, but GitHub normally shows **Run workflow** only when the workflow exists on the fork's default branch. This new workflow isn't on upstream `main`; **use the branch push above** rather than merging just to obtain a button.

## 3. Inspect your mission files

From the repository root:

```text
cd exercises/devops-escape
```

**Windows PowerShell:**

```powershell
Get-ChildItem
Get-Content MISSION-BRIEFING.md
```

**Windows CMD:**

```bat
dir
type MISSION-BRIEFING.md
```

**macOS/Linux Bash or Zsh:**

```bash
ls
cat MISSION-BRIEFING.md
```

Read [MISSION-BRIEFING.md](MISSION-BRIEFING.md) for the eight stories, expected behaviors, and progressive hints. Files missing at the start are intentional—don't download a “fixed” version of the exercise.

## 4. The repair loop

1. Open the **first red gate** in the latest Actions run. Read its error and the relevant mission.
2. Investigate and edit only that mission's artifact/configuration in your local exercise folder.
3. Inspect the diff and commit that repair.
4. Push and open the **new run for the new commit**.
5. Confirm the previous gate passes, then investigate the next red gate.

**From `exercises/devops-escape`, run after each repair:**

```text
git status
git diff
git add .
git commit -m "Repair the current escape-room gate"
git push
```

Because you're in the exercise folder, `git add .` stages changes under that folder; review them before committing. For a newly created file, `git diff` alone won't show it until staged; use your editor or `git diff --cached` after adding it. Do not commit credentials or edit the original root workshop.

Rerunning an **old** workflow run does not pick up your new code. Commit and push, then check the run with your new commit SHA.

## 5. What GitHub Actions is showing you

| Term | Meaning in this game |
| --- | --- |
| Workflow | The YAML recipe at `.github/workflows/devops-escape-room.yml` |
| Job | One Ubuntu machine running the eight gates |
| Step | One gate or supporting action; expand it to see its logs |
| Failed | A command returned a nonzero exit status; the gate needs investigation |
| Skipped | An earlier gate failed, so this gate hasn't run yet |
| Summary | Completed gates, first failure, commit, and (on victory) the verified image tag |

All gates are normal sequential steps in **one job**. A failure blocks later gates. Cleanup and summary use `if: always()` so they can still run. A later skipped gate is not a pass. The green result comes only after all eight gate steps succeed.

## 6. Optional local investigation

The gate scripts need **Bash, Python 3, curl, and Docker Engine/Buildx** for the full game. The normal CI route doesn't require these on your laptop.

**macOS/Linux Bash, or a configured WSL/Linux shell on Windows**, from the repository root:

```bash
bash exercises/devops-escape/scripts/run-local.sh
```

On Windows, PowerShell/CMD can run `git` and `docker` directly, but cannot interpret the `.sh` validators. Use GitHub Actions for those validators if you don't have a configured Linux/Bash environment. Git Bash is suitable for Git and reading files; Docker path conversion can make it unsuitable for this full runner without extra configuration. Do not assume `bash` launching through an unconfigured WSL will work.

The local runner behaves like CI: first failure stops the gates, it prints a summary, and it removes its labeled container even after a failure. A failing starter exits nonzero on purpose (exit code equals the first failed gate number). It rebuilds the image on each invocation, so an HTML repair is tested inside a newly built image.

For direct Docker investigation, from the repository root (PowerShell/CMD/Bash/Zsh):

```text
docker build -t escape-room:challenge exercises/devops-escape
docker image ls escape-room
```

The build initially fails at Mission 3's intentional defect. Building an image alone does not run the full game. Gate 4 leaves a container available for Gate 5 within the same run; `run-local.sh` cleans it up afterward. Directly running individual gates requires the earlier Docker gates' prerequisites and manual cleanup via `bash scripts/cleanup.sh` from the exercise directory in a Bash-capable environment.

The exercise's official Nginx base is pinned to a manifest digest so teams start from the same base image. Keep that `FROM` line while investigating the broken `COPY` instruction.

## 7. Victory

A successful run shows **eight green gates**, an ASCII victory banner, and:

```text
CONGRATULATIONS! YOU ESCAPED THE DEVOPS PIPELINE!
```

The summary includes **8/8**, the run's commit SHA, and the verified local image tag `escape-room:v1.0.0`. This image exists on that runner, not on Docker Hub or automatically on your computer. GitHub's hosted machine is temporary. Local runs retain their challenge/release image tags, but remove their container.

Explain to your partner why a successful build, a running container, HTTP 200, and a correct release are different checks. The duck will be listening.

Instructor solutions and regression-test fixes are in this repository for teaching. Treat those files as spoilers; use the mission hints first. See [instructor/SETUP.md](instructor/SETUP.md) for distribution/privacy guidance and [instructor/TROUBLESHOOTING.md](instructor/TROUBLESHOOTING.md) if platform/tool setup blocks you.
