# Instructor guide: From Code to Container

Allow 60–90 minutes. Students should be able to explain **source → tests → image → registry → container**, and demonstrate that image publishing and deployment are separate actions. Keep the application small; the interesting behavior is in delivery.

## Before class

- Complete the [README publishing setup](README.md#configure-docker-hub-publishing-instructor-once), enable Actions, and run it on `main` with Version 1. Verify both jobs pass and Docker Hub contains `latest` and the commit tag. Record the exact Version 1 SHA tag for later.
- Start Docker Desktop on student computers with Linux containers. Test Intel/AMD and Apple Silicon computers if available; the published image supports both architectures.
- Pull images ahead of class, and rehearse on the actual classroom network. Shared-IP anonymous pull limits can affect a class; Docker Hub student accounts remain optional.
- Check ports 8080, 8081, and 8082. Leave the Version 1 container running during the Version 2 publish.
- Use Terminal/Bash for macOS/Linux, PowerShell for Windows. Commands in `text` fences work in either. Replace usernames and SHA placeholders with real values. Never display a token.

## Phase 1 — Running locally (10 minutes)

Open `index.html` directly in a browser. Identify the heading, Version 1 badge, blue theme, and message. Show that all application content is one file with no external requests.

From the repository root:

```text
docker build -t workshop-app:local .
docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 workshop-app:local
```

Visit `http://localhost:8080`. Expected: **Version 1**, **Hello from Version 1!**, blue. The source-file tab looks the same, but localhost is served by Nginx in a container. Use the localhost tab for the remaining demonstration.

```text
docker ps
docker image ls
docker logs workshop-app
```

**Ask:** “Why build an image for HTML?” It packages the page and web server so another computer can run the same artifact without setting up Nginx manually.

## Phase 2 — Understanding Docker (10 minutes)

Explain the Dockerfile line by line:

```dockerfile
FROM nginx:stable-alpine
COPY --chmod=644 index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

- `FROM` supplies the official lightweight Nginx server, configuration, and normal foreground startup command.
- `COPY` bakes this build's HTML into the image. `--chmod=644` makes it readable by Nginx even when the source file has restrictive permissions. A later source edit does not change an existing image or container.
- `EXPOSE` documents container port 80; the `docker run -p` argument publishes the host port.

Explain `-t` (image name/tag), `-d` (background), `--name` (container identity), the workshop label (helper safety), and **computer 8080 → container 80**. `.dockerignore` permits only the page and Dockerfile in the build context.

**Exercise:** Use the same image for a second container:

```text
docker run -d --name workshop-extra -p 127.0.0.1:8081:80 workshop-app:local
docker rm -f workshop-extra
```

**Ask:** “Can two containers share one image?” Yes. They have independent lifecycles but need distinct host ports.

## Phase 3 — Understanding CI (10 minutes)

Open `.github/workflows/ci-cd.yml`, show the triggers and `ci` job, then expand these steps in a real Actions run:

1. Checkout gets this run's source commit.
2. Validation checks required files, heading, and version marker.
3. Docker builds a test image.
4. A temporary Nginx container starts on the runner.
5. HTTP requests retry during startup, then verify the returned page.
6. Cleanup removes the container even on failure.

Run the same checks locally in Bash:

```bash
bash scripts/validate.sh
bash scripts/smoke-test.sh http://localhost:8080
```

Windows students without Bash can follow the checks in Actions and use `Invoke-WebRequest http://localhost:8080 -UseBasicParsing` locally.

**Exercise:** On a temporary branch, change the heading to `Broken heading`, commit, push that branch, and open a PR targeting `main`. Expected: validation fails, CI is red, and publishing is skipped. Restore the heading and push again: CI passes, publishing remains skipped. Close the demo PR without merging broken code. Do not break `main` for this exercise.

**Ask:** “Does a process ID prove readiness?” No. An HTTP request and expected content prove this page is actually being served.

## Phase 4 — Publishing (10 minutes)

Show `needs: ci`, the main/event condition, the variable and secret names (never their secret values), and official Docker actions. Buildx/QEMU publish AMD64 and ARM64 variants for students' different computers.

Select **Actions → From Code to Container → Run workflow → main**. Alternatively push a documentation change or merge a PR according to repository rules. Wait for CI and CD. Record the real tags from the successful summary:

```text
yourname/workshop-app:latest
yourname/workshop-app:sha-<actual-seven-character-commit>
```

Verify the tags in Docker Hub. `latest` is a convenient moving pointer. Treat commit tags as fixed workshop versions; use image digests when exact bytes must be guaranteed, since tags can be overwritten and base-image updates can alter a rebuild.

Switch the local demo to the published **Version 1** image:

```bash
# macOS / Linux
bash scripts/update-container.sh yourname
```

```powershell
# Windows
.\scripts\update-container.ps1 -Image yourname
```

Expected: Version 1 remains, now obtained from Docker Hub. Students without source can use the README's individual pull/run commands. Public pulls need neither GitHub access nor a Docker Hub account.

**Ask:** “Where is the app deployed when CD finishes?” The image has been delivered to Docker Hub. The classroom computer changes only after pulling and recreating a container.

## Phase 5 — Changing the application (10 minutes)

Leave Version 1 running. Find the three `WORKSHOP EDIT` comments in `index.html` and change the actual CSS and visible text:

```css
--primary: #15803d;
```

```html
<span id="app-version">Version 2</span>
<p id="app-message">Hello from Version 2! My pipeline works!</p>
```

Keep the heading and IDs unchanged. Inspect and commit:

```text
git diff
git add index.html
git commit -m "Show Version 2 in green"
git push origin main
```

If on a feature branch, push it and merge its PR instead. Watch CI then CD; record the **new** SHA tag and verify it in Docker Hub.

Refresh `http://localhost:8080` **before pulling**. Expected: **Version 1 stays blue**. If someone already sees Version 2, check they aren't viewing the source-file tab or using a source bind mount.

**Ask:** “Why is the app old when the pipeline is green?” The container was created from the old image. Publishing doesn't modify that running instance.

## Phase 6 — Updating the running app (10 minutes)

First pull, then pause:

```text
docker pull yourname/workshop-app:latest
```

Refresh: **still Version 1**. The new image is on disk while the running container uses its original image. Then:

```text
docker stop workshop-app
docker rm workshop-app
docker run -d --name workshop-app --label com.from-code-to-container.workshop=true -p 127.0.0.1:8080:80 yourname/workshop-app:latest
```

Refresh (hard-refresh if cached). Expected: **Version 2**, **Hello from Version 2! My pipeline works!**, **green**. Show `docker ps` and logs.

Rerun the OS-specific helper to demonstrate repeatability. It manages only the labeled demo, refuses unrelated name collisions, and leaves the previous container untouched on pull failure. A later start failure requires inspecting logs/ports; there is no automatic rollback.

**Exercise: compare versions.** Replace the placeholders with your recorded tags:

```text
docker run -d --name workshop-v1 -p 127.0.0.1:8081:80 yourname/workshop-app:sha-OLDHASH
docker run -d --name workshop-v2 -p 127.0.0.1:8082:80 yourname/workshop-app:sha-NEWHASH
```

Compare ports 8081 and 8082. Roll back the main demo without editing source or publishing:

```bash
bash scripts/update-container.sh yourname sha-OLDHASH
```

```powershell
.\scripts\update-container.ps1 -Image yourname -Tag sha-OLDHASH
```

Expected: Version 1 returns on port 8080 even while `latest` still refers to Version 2.

## Phase 7 — Discussion (10 minutes)

| Question | Explanation |
| --- | --- |
| Is CI deployment? | CI checks code; delivery stores a tested image; deployment creates/replaces a running instance. |
| Does pulling restart the app? | No. It downloads image data and updates local tag references, leaving running containers unchanged. |
| Why keep SHA tags? | They identify source versions for comparison and rollback. |
| Is the whole repository in the image? | Only `index.html` is copied into the Nginx base. The build context is restricted. |
| Why don't PRs publish? | The job condition permits only main pushes/manual main runs after CI succeeds. PRs get no publishing job. |
| What if the Docker Hub token is wrong? | CD fails; no new publication is confirmed; the old classroom container keeps running. |
| Can Windows and Macs use the same tag? | Yes. The multi-platform tag includes Linux AMD64 and ARM64 images; Docker Desktop selects the suitable variant. |
| What does latest mean? | A moving image tag, not automatic deployment or a version query by the webpage. |

Small exercises:

1. Change only the message. Predict which checks pass and discuss what they actually guarantee.
2. Create Version 3 with a different color; tell a partner its published commit tag.
3. Run two containers from one tag with distinct ports. Stop one; observe the other.
4. Explain the Dockerfile and port mapping without notes.
5. Draw the flow and circle the exact step where the computer's running app changes.

## Cleanup and recovery

```text
docker rm -f workshop-app
docker rm -f workshop-v1 workshop-v2
```

Run only commands for containers you created. A missing-container error means that demo wasn't started or is already removed. Keep images for another session or remove specific workshop images after class; avoid broad prune commands on student computers.

Use the [README troubleshooting table](README.md#troubleshooting) for port/name collisions, failed pulls, credentials, or old pages. Rehearse with the actual classroom account and network before presenting.
