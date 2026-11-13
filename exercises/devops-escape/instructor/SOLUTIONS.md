# Instructor solutions — do not use as the student walkthrough

All file paths below are relative to `exercises/devops-escape`. All command examples run **from the repository root in a Bash-capable terminal**, unless explicitly noted. Fix one gate per commit to demonstrate progression. Tests contain the same repairs but apply them only to temporary copies.

## Gate 1 — The Missing Artifact

- **Root cause:** `deployment-info.json` is absent.
- **File:** create `deployment-info.json` in the exercise folder, not at the repository root.
- **Fix:**

  ```json
  {
    "appName": "workshop-app",
    "version": "1.0.0"
  }
  ```

- **Verify:** `bash exercises/devops-escape/scripts/gate-01.sh`.
- **Actions result:** Gate 1 passes; Gate 2 is the first failure.
- **Common mistakes:** creating a `.json.txt` file, using single quotes/comments/trailing commas, version `1` instead of the string `1.0.0`, wrong appName, creating the file in the old workshop.

## Gate 2 — The Rubber Duck Approves Nothing

- **Root cause:** the answer file is absent; `duck.txt` is the clue, not the answer destination.
- **File:** create `duck-answer.txt`.
- **Fix:** plain text `rubber duck` (without quotes). Mixed capitalization and surrounding whitespace are accepted.
- **Verify:** `bash exercises/devops-escape/scripts/gate-02.sh`.
- **Actions result:** Gates 1–2 pass; Gate 3 fails at an actual Docker build.
- **Common mistakes:** renaming/removing the clue, writing JSON, answering with another bird, using `duck-answer.txt.txt`.

## Gate 3 — The Broken Dockerfile

- **Root cause:** the build context has `index.html`, but COPY requests `home.html`.
- **File:** exercise `Dockerfile`.
- **Fix:**

  ```dockerfile
  FROM nginx:stable-alpine@sha256:0e52bd054126cdc040b1276c0af347aeb02a41b9cfe305d6094767ac30e97949
  COPY --chmod=644 index.html /usr/share/nginx/html/index.html
  EXPOSE 80
  ```

- **Verify:** `docker build -t escape-room:challenge exercises/devops-escape`.
- **Actions result:** Gates 1–3 pass; Gate 4 starts the image but cannot reach Nginx through its wrong port mapping.
- **Common mistakes:** editing the root Dockerfile, building with the root context, changing the Nginx document root, removing readable file permissions. COPY uses paths inside its build context.

## Gate 4 — The Server Is Alive but Unreachable

- **Root cause:** the runtime script maps host 8080 to container 8080, while Nginx listens on 80.
- **File:** `scripts/start-container.sh` (not the gate validator or workflow).
- **Fix:** change only `--publish 127.0.0.1:8080:8080` to `--publish 127.0.0.1:8080:80`. Preserve the name, label, and image variables.
- **Verify:** `bash exercises/devops-escape/scripts/run-local.sh` after fixes 1–4. Gate 4 passes; the process exits **5** because Gate 5 still has wrong content. The container is cleaned up after reporting.
- **Actions result:** Gates 1–4 pass; Gate 5 fails despite HTTP 200.
- **Common mistakes:** changing the host URL/port, changing EXPOSE instead of Nginx's listening port, testing only `docker ps`, running the runtime script without its exported variables. Gate 4 calls the runtime script after setting its context.

## Gate 5 — The Application Is Lying

- **Root cause:** the served greeting is the old release.
- **File:** exercise `index.html`.
- **Fix:** replace the visible `Hello from Version 1!` with `Hello from Version 2!`.
- **Verify:** `bash exercises/devops-escape/scripts/run-local.sh` after fixes 1–5. Gate 5 passes; exit **6** is expected until the pirate puzzle is fixed.
- **Actions result:** Gates 1–5 pass; Gate 6 becomes the first failure.
- **Common mistakes:** editing the root HTML, adding a source comment rather than repairing visible content, searching only the source instead of testing HTTP, refreshing an old container without rebuilding/recreating it. The full runner builds a fresh tested image each time.

## Gate 6 — The Pirate's Secret Release

- **Root cause:** `releaseCode` is `unknown`.
- **Clue/file:** decode `pirate-note.txt`; modify only `releaseCode` in `release-config.json`.
- **Decoded text:** `Captain Dockerbeard says: the release code is parrot`.
- **Fix at this stage:**

  ```json
  {
    "releaseCode": "parrot",
    "environment": "development"
  }
  ```

- **Verify:** `bash exercises/devops-escape/scripts/gate-06.sh`.
- **Actions result:** Gates 1–6 pass; Gate 7 still fails. Keeping `development` here proves the two checks are independent.
- **Common mistakes:** copying the entire decoded sentence as the value, changing the environment early, treating Base64 as secure storage, invalid JSON. This is not a secret and never needs GitHub Actions Secrets.

## Gate 7 — Wrong Environment, Wrong Release

- **Root cause:** environment is `development`.
- **File:** `release-config.json`.
- **Fix:** change `environment` to `production`, retaining `releaseCode: parrot` as valid JSON.
- **Verify:** `bash exercises/devops-escape/scripts/gate-07.sh`.
- **Actions result:** Gates 1–7 pass; Gate 8 fails because the versioned tag is absent.
- **Common mistakes:** setting an unrelated process environment variable, editing a GitHub Environment, replacing the entire file and losing the pirate code, misspelling the required value. This gate checks a repository JSON field.

## Gate 8 — Final Boss: Tag the Release Correctly

- **Root cause:** `scripts/release.sh` creates `:latest`, not the required version tag.
- **File:** `scripts/release.sh`.
- **Fix:** retain its Bash setup and use:

  ```bash
  docker tag "$ESCAPE_IMAGE" "${ESCAPE_REPOSITORY}:v1.0.0"
  ```

- **Verify the entire repaired game:**

  ```bash
  bash exercises/devops-escape/scripts/run-local.sh
  docker image inspect escape-room:v1.0.0
  ```

- **Actions result:** eight successful gates, ASCII banner, victory text, completed count, commit SHA, and verified image tag in the summary.
- **Common mistakes:** spelling `v1.0.0` as `1.0.0`, changing the challenge image instead of the release target, putting the expected string only in a comment, assuming an old cached tag means the script works. The validator temporarily preserves/removes a pre-existing expected tag, executes the real script, and checks the new artifact's image ID against the tested challenge image.

No image is pushed. The successful tag exists only in that local Docker daemon (the hosted runner for CI, your computer for local validation). CI cleanup removes the container; GitHub later disposes of the runner.
