# DevOps Escape Room — eight gates to a green pipeline

The release is trapped. A rubber duck refuses to approve it, Captain Dockerbeard has hidden a code, and the pipeline keeps finding another problem. Your mission is to repair **one gate at a time** until all eight pass.

**The starter is intentionally broken. Your first red run is expected.** The next gate becomes visible only after the current one passes. Repair the application/configuration files, not the gate validators or workflow conditions. There is no automatic deployment and nothing is pushed to Docker Hub.

## Before starting

- Have a GitHub account. For local work, install [Git](https://git-scm.com/downloads); browser-only students can use the GitHub editor route below instead.
- For local work, use PowerShell or CMD on Windows, or Terminal/Bash/Zsh on macOS/Linux.
- Work individually in `DenisaEmilia/Master-The-Stack-Workshop`, using your own uniquely named `escape/<your-name>` branch. No teams or forks are needed.
- Accept the instructor's collaborator invitation first: a public repository can be cloned by anyone, but creating branches and pushing requires write access.
- Docker Desktop is recommended for investigating Docker/HTTP failures locally. It is **not required** to participate: GitHub-hosted Ubuntu has Docker, Bash, Python, and curl.
- Keep an editor ready, and save text/JSON as UTF-8. JSON uses double quotes, has no comments, and does not permit trailing commas.

Already did the original workshop? Save any unfinished work there first. This exercise uses a **different branch** and its own folder. If the original demo or Compose lab is using port 8080, stop only your own demo before running this escape room locally. CI runs on a separate machine and is unaffected by ports on your laptop.

## 1. Create your personal branch from the prepared starter

Everyone works in the same repository, but each student keeps their own answers on a separate branch. Start from **feature/devops-escape-room**, not `main` or another student's branch. Keep the prepared starter unchanged for the next student.

**If you have not cloned the workshop yet**, run the following in PowerShell, CMD, Bash, or Zsh:

```text
git clone https://github.com/DenisaEmilia/Master-The-Stack-Workshop.git
cd Master-The-Stack-Workshop
```

**If you already completed the earlier workshop**, open a terminal in your existing `Master-The-Stack-Workshop` folder instead. Do not clone inside that folder again.

**Check before switching:**

```text
git status
git remote -v
```

Save any unfinished work in a commit or stash before switching. `origin` should point to `DenisaEmilia/Master-The-Stack-Workshop`; if you are using a different repository, use a fresh checkout as shown above. Do not discard old work or change another student's branch.

**With a clean working tree, fetch the prepared branch and create your own:**

```text
git fetch origin feature/devops-escape-room
git switch -c escape/your-name FETCH_HEAD
```

Replace `your-name` with your own unique name or GitHub username, for example `escape/alex-popescu`. Use that same branch name in every command below. The `escape/` prefix is required to trigger the pipeline. If your branch already exists, switch to it with `git switch escape/your-name` to continue your attempt; don't overwrite it or recreate it from the starter.

**Verify the branch:**

```text
git branch --show-current
```

Expected: `escape/your-name` with your actual name substituted.

**Why two names?** `feature/devops-escape-room` is the prepared instructor branch. Your `escape/**` branch is where you solve missions, and its name triggers the pipeline. Do not push your fixes to `main` or open a PR to `main` during the game; that belongs to the original delivery workshop.

The prepared feature branch also runs the workflow when the instructor pushes to it, so the class can see the initial failure before starting. Students still solve the missions only on their personal `escape/**` branches; keep the prepared starter broken.

## 2. Start the first run

The instructor enables Actions in the shared repository. **Publish only your personal branch:**

```text
git push -u origin escape/your-name
```

Use your actual personal branch in place of `escape/your-name`. GitHub may ask you to authenticate for this Git push; use your configured GitHub login/Git credential manager. Never paste tokens into a repository file. If GitHub rejects the push for lack of permission, ask the instructor to check your collaborator access; no Docker Hub credentials are involved.

Open [the shared repository's Actions tab](https://github.com/DenisaEmilia/Master-The-Stack-Workshop/actions) → **DevOps Escape Room** → filter by **your branch** → select the latest run → **Escape the eight gates** → **Gate 1 — The Missing Artifact**. Other students' red/green runs are separate attempts; compare the branch and commit SHA before reading logs.

**Expected first result:** Gate 1 is red because `deployment-info.json` is missing. Gates 2–8 are skipped. The run summary reports **0/8 completed** and **Gate 01** as the first failure. If no run appears after the instructor enables Actions, push a new commit on your personal branch:

```text
git commit --allow-empty -m "Start escape room"
git push
```

The workflow also supports `workflow_dispatch`, but GitHub normally shows **Run workflow** only when the workflow exists on the default branch. This new workflow isn't on `main`; **use the branch push above** rather than merging just to obtain a button.

### Alternative: work entirely through the GitHub website

If the instructor asks you to use GitHub's editor instead of local Git, follow this route rather than repeating the local branch-creation steps:

1. Open the repository's **Code** tab and select `feature/devops-escape-room` in the branch dropdown.
2. In that dropdown, enter your unique `escape/your-name` name and create the branch **from feature/devops-escape-room**.
3. Confirm the dropdown shows your personal branch. Create a small `exercises/devops-escape/student-notes.txt` file with a sentence about starting your attempt, and commit it directly to **your branch**. Creating a branch alone may not produce a run; this first file commit triggers the push workflow while leaving Gate 1 broken.
4. Open **Actions**, filter by your branch, and inspect the first red gate.
5. Create or edit that mission's file with GitHub's editor, then choose **Commit changes** directly to your personal branch. Each new commit triggers another pipeline. Do not choose another student's branch, `main`, the prepared starter, or a pull request for your repairs.

This browser route needs the same collaborator write access, but no local Git, Docker, or Bash installation. If alternating between browser and local edits, run `git pull --ff-only` on your personal local branch before editing to bring down the browser commits; resolve any divergence without force-pushing over work.

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

The exercise's official Nginx base is pinned to a manifest digest so everyone starts from the same base image. Keep that `FROM` line while investigating the broken `COPY` instruction.

## 7. Victory

A successful run shows **eight green gates**, an ASCII victory banner, and:

```text
CONGRATULATIONS! YOU ESCAPED THE DEVOPS PIPELINE!
```

The summary includes **8/8**, the run's commit SHA, and the verified local image tag `escape-room:v1.0.0`. This image exists on that runner, not on Docker Hub or automatically on your computer. GitHub's hosted machine is temporary. Local runs retain their challenge/release image tags, but remove their container.

Explain to the instructor why a successful build, a running container, HTTP 200, and a correct release are different checks. The duck will be listening.
