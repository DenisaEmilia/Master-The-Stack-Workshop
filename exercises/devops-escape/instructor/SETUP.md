# Instructor setup — spoilers ahead

## Prepare before class

1. Review the escape workflow and the student artifacts. The prepared instructor branch is **feature/devops-escape-room**, based on `main`; the original workshop and its publishing workflow are preserved.
2. Confirm `feature/devops-escape-room` is published with the intentionally broken starter. Students fetch this branch or select it in GitHub's branch dropdown. Keep it unchanged; do not merge student solutions into it or into `main`.
3. Start Docker Desktop/Engine, ensure host port 8080 is free, and have Bash, Python 3, curl, Git, and Buildx available. Use Ubuntu/Linux or macOS for the local regression harness; Windows instructors can use a configured WSL/Linux environment or a dedicated Linux machine. Docker Desktop is not required on GitHub's hosted Ubuntu runners.
4. From the repository root, execute the full progression harness:

   ```bash
   bash exercises/devops-escape/tests/verify-progression.sh
   ```

5. Expect nine states: the first failure progresses through Gate 1, Gate 2, …, Gate 8, then all gates pass. The harness uses temporary copies, unique test image/container names, real Docker builds, HTTP, and image inspections. It checks cleanup after failure and success, plus a content/mode fingerprint of the entire real checkout. It must leave the actual starter broken.
6. Run the actual starter:

   ```bash
   bash exercises/devops-escape/scripts/run-local.sh
   ```

   Expect **exit 1**, Gate 01's missing `deployment-info.json` error, **0/8**, and no challenge container left. `duck-answer.txt` must also be absent. The exercise Dockerfile must reference the wrong source, runtime script the wrong container port, page the old greeting, config the wrong code/environment, and release script the wrong tag. Don't “repair” the starter to make setup look green.
7. Review [SOLUTIONS.md](SOLUTIONS.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md), and the student mission hints. Rehearse a successful eight-commit sequence on a separate `escape/instructor-rehearsal` branch when authorized. Local verification does not prove a hosted Actions run occurred.

If Docker is unavailable, the harness fails its prerequisite check. Do not describe the Docker progression as verified. Gate 1/2/6/7 can be exercised independently with Bash/Python, but those checks do not replace Docker/HTTP validation.

## Individual students in the shared repository

- No teams and no forks: each student creates one uniquely named `escape/<name-or-username>` branch in `DenisaEmilia/Master-The-Stack-Workshop`, directly from `feature/devops-escape-room`.
- Before class, use **Settings → Collaborators** (or the organization's equivalent access settings) to give students write access. Have each student accept their invitation. Cloning a public repository does not grant permission to create remote branches or push. No permissions are changed by the lab scripts.
- Enable Actions in the shared repository. Check that its rules allow students to push to their `escape/**` branches. Keep `main` and the prepared feature branch reserved for instructor changes; students must not modify another student's branch.
- Students may use local Git or GitHub's web editor. For the web route, create the branch from the prepared starter, then make a small first file commit on the personal branch to trigger the pipeline. Subsequent mission repair commits go directly to the same personal branch.
- A first `escape/**` push runs the escape workflow; it does not run the original main-push publishing job. Do not use a `main` push or a PR to `main` as the game's trigger.
- In **Actions → DevOps Escape Room**, students filter by their personal branch and select their latest commit. Pipeline runs are independent even though they share one repository. Hosted runner queues can delay a large class; a queued run is not a gate failure.
- No Docker Hub account, repository secret, deployment environment, external dashboard, paid service, or GitHub environment approval is needed by this workflow. Hosted Actions availability/minute limits follow this repository owner's GitHub plan and organization policies.
- The workflow grants `contents: read`, checks out without persisting credentials, and never logs in to a registry or pushes an image.

## Manual dispatch and default-branch registration

The workflow declares `workflow_dispatch` for manual runs. GitHub normally exposes the manual button/API dispatch only after the workflow is registered on the repository's default branch. `main` deliberately does not contain it yet. For this workshop, **push or commit to an `escape/**` branch** to start it. Do not change the repository's default branch or merge into `main` just to get a button.

## Keep solutions private if required

This repository's `instructor/` documents and `tests/verify_progression.py` intentionally contain complete repairs. A public repository cannot keep them secret. Student docs offer progressive hints and ask students not to read spoilers.

For a solution-private class, validate the complete source first, then prepare a **new sanitized template repository from a file snapshot**, omitting `exercises/devops-escape/instructor/` and `exercises/devops-escape/tests/`. Keep those folders privately for instructors. Preserve the workflow, gate validators, runtime/release scripts, clues, and broken starter artifacts. Remove links to the omitted instructor documents in the distributed student README. Use that template's source URL in the clone/fetch instructions.

Deleting solution files in a new commit on the same public history does **not** make earlier solutions private. For the shared-repository format, explain that instructor files are visible spoilers. The regression harness is an instructor tool, so removing it from a separate sanitized student snapshot does not stop the actual gate workflow.

## Reset a stuck student without losing work

Prefer a fresh personal attempt branch over destructive resets. Students should commit or stash unfinished work first. From their shared-repository checkout at its root, replacing `your-name` with their unique name:

```text
git status
git fetch origin feature/devops-escape-room
git switch -c escape/your-name-retry FETCH_HEAD
git push -u origin escape/your-name-retry
```

The prepared feature branch must still contain the broken starter. The old attempt remains available, and no one else's work is overwritten. If the new branch name already exists, choose another name. Never force-push over another student's attempt. Browser-only students can create a new personal retry branch from the prepared feature branch and commit a starter note there. The instructor progression harness resets only temporary copies and is safe to rerun.

## Suggested pacing (75–100 minutes)

| Activity | Time |
| --- | --- |
| Check access, create personal branch, first push, reading Actions | 10–15 min |
| Gate 1: artifact / JSON | 5–8 min |
| Gate 2: duck investigation | 3–5 min |
| Gate 3: Docker build | 8–10 min |
| Gate 4: ports and startup | 10–12 min |
| Gate 5: HTTP content | 5–8 min |
| Gate 6: Base64 investigation | 5–8 min |
| Gate 7: environment | 3–5 min |
| Gate 8: image tag and victory | 5–8 min |
| Recap and questions | 10 min |

Allow runner queue/build time. Ask each student to explain the failure before offering the next hint. Emphasize: Base64 isn't encryption; HTTP 200 isn't application correctness; a local tag isn't publication or deployment.

## Cleanup behavior

The local runner's EXIT trap and the workflow's `always()` cleanup remove only the labeled challenge container with the current scope/name. They refuse an unrelated name collision. Successful local runs retain `escape-room:challenge` and `escape-room:v1.0.0`; Gate 8 backs up a pre-existing final tag before testing for a newly produced tag and restores it if the gate fails. The test harness uses a random image repository and removes only its own tags. No broad `docker system prune`, arbitrary `docker rm`, destructive Git reset, push, or publication is part of verification.
