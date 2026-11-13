# Escape-room troubleshooting

## No workflow run appears

- Check `git branch --show-current`. The branch must start with `escape/`, such as `escape/alex-popescu`, to match `escape/**`. The prepared `feature/devops-escape-room` branch itself does not automatically trigger a run.
- Check `git remote -v`: `origin` must point to the shared `DenisaEmilia/Master-The-Stack-Workshop` repository. Students need collaborator write access and must accept their invitation. A successful clone proves only read access; a denied push is not a pipeline defect.
- The instructor enables Actions in the shared repository before class. After it is enabled, push another commit on your own branch (an empty “Start escape room” commit is sufficient for local Git users).
- Confirm your branch contains `.github/workflows/devops-escape-room.yml`. Start personal branches from `feature/devops-escape-room`, not `main`. If a browser-created branch has no run, make a first file commit directly on that personal branch.
- A workflow YAML parse error may appear in the commit's checks instead of as a normal job. Restore the recipe from the prepared starter and keep indentation with spaces. The intentionally broken files are artifacts/runtime configuration, not the workflow YAML.
- Organization policy may block Actions, official actions, or hosted runners. Ask the repository/organization administrator for the specific required access; no Docker Hub secret fixes those restrictions.

## No “Run workflow” button

Manual `workflow_dispatch` requires GitHub to register the workflow on the repository's default branch. `main` doesn't contain this new workflow. Use a push or a browser file commit on your personal `escape/**` branch; do not merge into `main` or change the default branch just to get a button.

## The wrong workflow or old code is running

Choose **DevOps Escape Room**, not **From Code to Container**. Compare the run's branch and SHA with `git log -1`. Rerunning a failed run uses that old commit; make a repair commit and push for new source to be tested. Uncommitted laptop edits cannot change the runner's files. The original publishing workflow is unchanged and is not triggered by an `escape/**` push.

All students' runs appear in the same Actions list. Filter by your own branch and check its latest commit. A different student's red run does not mean your fix failed. If you edited through GitHub's website, check the branch dropdown before every commit, and pull those commits before continuing locally.

## Docker daemon unavailable locally

Start Docker Desktop, wait for the engine, and select Linux containers on Windows. Check `docker version` (both Client and Server) and `docker info`. The GitHub-hosted runner does not require Docker Desktop. Students without local Docker can investigate files locally and run the real gates through Actions. The instructor regression harness requires a working Docker daemon and must not be reported as passed if it couldn't run.

## Build context or COPY errors

The root workshop and escape room have different Dockerfiles. From the root, the relevant build is:

```text
docker build -t escape-room:challenge exercises/devops-escape
```

The initial missing COPY source is intentional at Gate 3. Read its build log and fix the **exercise** Dockerfile. Don't alter the root workshop or disable verification to work around a build error. Docker registry outages, pull limits, or proxies can independently prevent image downloads; distinguish them from the intentional filename defect.

## Container name collisions and stale containers

Names are scoped to the checkout and Actions run. `cleanup.sh` removes a matching container only if its `devops.escape-room` label matches the current scope. If it refuses, inspect the container and don't blindly remove it. Run the full local runner to get automatic EXIT cleanup. If you ran gates individually, run (from the exercise directory in Bash):

```bash
bash scripts/cleanup.sh
```

Abrupt machine termination or SIGKILL can prevent shell traps, as with any local process. Inspect your own leftover container before removing it manually. Do not use broad prune commands on student computers.

## Port 8080 is occupied

Run `docker ps` and inspect the port column. Stop only your own previous workshop/Compose application before testing locally. Leave unrelated applications alone. Keep host 8080 for this game because the HTTP validators use it. A Docker bind error occurs before the gate's HTTP check; don't confuse it with the intentionally wrong **container** port in Gate 4. Hosted runners do not share your laptop's port allocations.

## HTTP failures or old content

- Gate 4 tests reachability and HTTP **200**, with bounded retries. Inspect host versus container port mapping and Nginx logs.
- Gate 5 checks the **actual HTTP response** for the required greeting. HTTP 200 alone is insufficient.
- A source edit doesn't update an already-running container. The full runner rebuilds the image and starts a new container on every run. If experimenting manually, rebuild and recreate, then use the correct localhost tab rather than a source-file browser tab.
- Direct Gate 5 runs require Gate 3's image and Gate 4's running owned container. The full runner handles those prerequisites and later cleanup.

## JSON and text formatting

Use UTF-8, double-quoted keys/string values, no comments, and no trailing commas. Windows editors may append `.txt` to names—show file extensions. The duck file is plain text, not JSON. The JSON contracts check the expected fields/values, not merely file existence. Fix the requested release field without deleting the previous gate's solution.

## PowerShell versus Bash

Git and direct Docker commands work in PowerShell, CMD, Bash, and Zsh. `.sh` scripts require Bash; PowerShell cannot interpret them. A WSL `execvpe(/bin/bash)` error indicates the Windows `bash` launcher has no configured Bash environment. Use Actions for gate execution or configure an actual WSL/Linux environment. Don't ask beginners to disable security settings to make a shell script run.

Clue decoding differs by terminal. See Mission 6's hints for Linux, macOS, and PowerShell commands. Base64 is encoding and needs no credentials. Shell copy/paste should preserve `$ESCAPE_IMAGE` and other Bash variables in the student-owned scripts; do not replace them with PowerShell syntax.

## A local tag seems to bypass the final defect

Gate 8 preserves a pre-existing required tag, temporarily removes that tag reference, executes the release script, and inspects the resulting image ID. If the script fails or tags incorrectly, the prior reference is restored. A correct tag left from an older run does not solve the current attempt. Do not edit gate validators to accept `latest`.

## Cloud home directory is read-only

Some cloud shells cannot write Buildx settings under the home directory. Use a writable location outside the checkout, for example:

```bash
mkdir -p /tmp/escape-buildx
export BUILDX_CONFIG=/tmp/escape-buildx
```

Then retry the build/verification. This is a local tool setup adjustment, not a student gate repair, and does not disable artifact/TLS verification.

## Solutions are visible

Public repository history, validators, and tests are readable. The game is an educational exercise, not a secret-keeping mechanism. For private instructor materials, distribute a fresh sanitized snapshot in a separate template as described in [SETUP.md](SETUP.md); simply deleting files in the same history doesn't make them private.
