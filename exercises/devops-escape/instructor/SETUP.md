# Instructor setup — spoilers ahead

## Prepare before class

1. Review the escape workflow and the student artifacts. The prepared instructor branch is **feature/devops-escape-room**, based on `main`; the original workshop and its publishing workflow are preserved.
2. The implementation may initially exist only locally. **When authorized**, publish that feature branch to make it available to student forks/fetches. Do not merge to `main` merely to distribute the game. The student fetch commands require this prepared branch to exist on GitHub.
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
7. Review [SOLUTIONS.md](SOLUTIONS.md), [TROUBLESHOOTING.md](TROUBLESHOOTING.md), and the student mission hints. Rehearse a successful eight-commit sequence in a disposable team fork/branch when GitHub access and branch publication are authorized. Local verification does not prove a hosted Actions run occurred.

If Docker is unavailable, the harness fails its prerequisite check. Do not describe the Docker progression as verified. Gate 1/2/6/7 can be exercised independently with Bash/Python, but those checks do not replace Docker/HTTP validation.

## Distribute without conflicts

- One fork per team; one working `escape/team-name` branch per team. Teammates need write access to their own fork and should coordinate commits.
- When forking, include all branches if available, or use the README's `upstream` fetch to obtain the prepared feature branch even from a main-only fork.
- Enable Actions in the **team fork** before pushing. A first `escape/**` push runs the new workflow; it does not run the original main-push publishing job. Do not use a `main` push or a PR to `main` as the game's trigger.
- No Docker Hub account, repository secret, deployment environment, external dashboard, paid service, or GitHub environment approval is needed by this workflow. Hosted Actions availability/minute limits still follow the fork owner's GitHub plan and organization policies.
- The workflow grants `contents: read`, checks out without persisting credentials, and never logs in to a registry or pushes an image.

## Manual dispatch and default-branch registration

The workflow declares `workflow_dispatch` for manual runs. GitHub normally exposes the manual button/API dispatch only after the workflow is registered on the repository's default branch. Upstream `main` deliberately does not contain it yet. For this workshop, **push an `escape/**` branch** to start it. In a disposable team/instructor fork you control, making the prepared starter its default branch is another option; do not change upstream's default branch or merge upstream just to get a button.

## Keep solutions private if required

This repository's `instructor/` documents and `tests/verify_progression.py` intentionally contain complete repairs. A public repository cannot keep them secret. Student docs offer progressive hints and ask students not to read spoilers.

For a solution-private class, validate the complete source first, then prepare a **new sanitized template repository from a file snapshot**, omitting `exercises/devops-escape/instructor/` and `exercises/devops-escape/tests/`. Keep those folders privately for instructors. Preserve the workflow, gate validators, runtime/release scripts, clues, and broken starter artifacts. Remove links to the omitted instructor documents in the distributed student README. Use that template's source URL in the clone/fetch instructions.

Deleting solution files in a new commit on the same public history does **not** make earlier solutions private. Don't advertise a normal public fork as a private solution distribution. The regression harness is an instructor tool, so removing it from the sanitized student snapshot does not stop the actual gate workflow.

## Reset a stuck team without losing work

Prefer a fresh attempt branch over destructive resets. Students should commit or stash unfinished work first. From their fork checkout at its root:

```text
git status
git fetch upstream feature/devops-escape-room
git switch -c escape/team-alpha-retry FETCH_HEAD
git push -u origin escape/team-alpha-retry
```

The prepared feature branch must still contain the broken starter. The old attempt remains available, and no one else's work is overwritten. If the new branch name already exists, choose another name. Never force-push over a teammate's attempt. The instructor progression harness resets only temporary copies and is safe to rerun.

## Suggested pacing (75–100 minutes)

| Activity | Time |
| --- | --- |
| Fork, branch, first push, reading Actions | 10–15 min |
| Gate 1: artifact / JSON | 5–8 min |
| Gate 2: duck investigation | 3–5 min |
| Gate 3: Docker build | 8–10 min |
| Gate 4: ports and startup | 10–12 min |
| Gate 5: HTTP content | 5–8 min |
| Gate 6: Base64 investigation | 5–8 min |
| Gate 7: environment | 3–5 min |
| Gate 8: image tag and victory | 5–8 min |
| Recap and questions | 10 min |

Allow runner queue/build time. Ask teams to explain the failure before offering the next hint. Emphasize: Base64 isn't encryption; HTTP 200 isn't application correctness; a local tag isn't publication or deployment.

## Cleanup behavior

The local runner's EXIT trap and the workflow's `always()` cleanup remove only the labeled challenge container with the current scope/name. They refuse an unrelated name collision. Successful local runs retain `escape-room:challenge` and `escape-room:v1.0.0`; Gate 8 backs up a pre-existing final tag before testing for a newly produced tag and restores it if the gate fails. The test harness uses a random image repository and removes only its own tags. No broad `docker system prune`, arbitrary `docker rm`, destructive Git reset, push, or publication is part of verification.
