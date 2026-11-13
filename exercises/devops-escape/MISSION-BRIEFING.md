# Mission briefing — read the first red gate

Each gate below starts broken. Solve the one your latest pipeline run reaches, commit/push your repair, and let the next run reveal your progress. The gates check real artifacts, builds, HTTP responses, and image tags. Expand hints one at a time.

## Gate 1 — The Missing Artifact

**Story:** The deployment system is looking for an important release artifact, but someone forgot to include it!

**Learn:** project structure, JSON, and CI validation.

**Investigate:** the error names a missing file in `exercises/devops-escape/`. The release contract requires an object with `appName` equal to `workshop-app` and `version` equal to the string `1.0.0`.

**Observe/verify:** the initial run fails before Docker is used. Your repair should make Gate 1 green and reveal Gate 2. Missing files, invalid JSON, and wrong values are different ways to violate the contract.

<details><summary>Hint 1</summary>

Check the exact path and filename in the error. The root workshop is a different directory.
</details>
<details><summary>Hint 2</summary>

The expected file extension describes its format. Use a JSON object, not prose or YAML.
</details>
<details><summary>Hint 3</summary>

Check key spelling, double quotes, and value types. Your editor may help validate JSON.
</details>

## Gate 2 — The Rubber Duck Approves Nothing

**Story:** The senior code reviewer has been replaced by a rubber duck. It refuses to approve your deployment until you answer its question.

**Learn:** read repository clues and interpret exact validation.

**Investigate:** read `duck.txt`, then create the answer artifact named in the error.

**Observe/verify:** the gate accepts the answer regardless of capitalization and surrounding whitespace. A different answer must fail. After a repair, Gate 3 should be the first failure.

<details><summary>Hint 1</summary>

Read the file instead of guessing from the pipeline title alone.
</details>
<details><summary>Hint 2</summary>

The riddle refers to a technique where explaining code aloud helps you find the bug.
</details>
<details><summary>Hint 3</summary>

Write the reviewer's two-word name as plain text in the answer file, without quotes or a JSON wrapper.
</details>

## Gate 3 — The Broken Dockerfile

**Story:** Your application is ready, but Docker cannot build its image. One instruction looks suspicious.

**Learn:** Dockerfiles, build contexts, and build logs.

**Investigate:** compare the exercise Dockerfile's `COPY` source with the actual application files. Remember that paths are relative to the exercise build context, not your terminal's current directory.

**Observe/verify:** an actual Docker build must succeed and produce `escape-room:challenge`. The pipeline then reaches the runtime gate.

<details><summary>Hint 1</summary>

Find the first build error, not just the final “build failed” line.
</details>
<details><summary>Hint 2</summary>

One filename in the Dockerfile is absent from the folder.
</details>
<details><summary>Hint 3</summary>

Keep the Nginx destination and readable permissions. Correct the source to the page you actually have.
</details>

## Gate 4 — The Server Is Alive but Unreachable

**Story:** The container is running. Everyone says the application is online. Nobody can reach it.

**Learn:** host/container ports and runtime troubleshooting.

**Investigate:** `scripts/start-container.sh` is the student-owned runtime configuration. Compare the published host port with the port Nginx listens on **inside** the image. Keep host port 8080 and the loopback binding.

**Observe/verify:** the validator starts your image with that script and waits for an actual HTTP 200 at `http://127.0.0.1:8080`. A PID or an “Up” status alone does not pass. Once repaired, the next content test should fail.

<details><summary>Hint 1</summary>

A successful `docker run -d` only means the process started.
</details>
<details><summary>Hint 2</summary>

In `host:container`, the two numbers have different meanings.
</details>
<details><summary>Hint 3</summary>

Check `EXPOSE` and the official Nginx default. Correct the container side, not the host URL or the validator.
</details>

## Gate 5 — The Application Is Lying

**Story:** Great news: HTTP 200! Bad news: the website is showing the wrong release.

**Learn:** smoke tests and application correctness.

**Investigate:** compare the greeting served over HTTP with the release requirement: **Hello from Version 2!** The page source is `exercises/devops-escape/index.html`.

**Observe/verify:** CI rebuilds and starts the image, then checks the actual HTTP response. Editing the source without rebuilding an existing local container won't change what it serves. This gate should pass before the pirate's puzzle is examined.

<details><summary>Hint 1</summary>

HTTP status says the request succeeded, not whether the content is the release you wanted.
</details>
<details><summary>Hint 2</summary>

Open the page source and find the visible greeting.
</details>
<details><summary>Hint 3</summary>

Repair the greeting in this exercise, leave validators alone, and let a new pipeline run rebuild it.
</details>

## Gate 6 — The Pirate's Secret Release

**Story:** Captain Dockerbeard stole the release code and left an encoded note. Decode it to unlock the next gate.

**Learn:** command-line investigation, Base64, and JSON configuration.

**Investigate:** decode `pirate-note.txt`, then update only `releaseCode` in `release-config.json`. Keep the environment value unchanged for now.

**Observe/verify:** syntactically valid JSON with the decoded code passes Gate 6, while Gate 7 still fails. This code is a teaching puzzle, **not a production credential**. Base64 is encoding, not secure encryption.

<details><summary>Hint 1</summary>

The note uses the Base64 alphabet. A text decoder can turn it back into a sentence.
</details>
<details><summary>Hint 2</summary>

Bash on Linux can use `base64 --decode pirate-note.txt`; macOS can use `base64 -D -i pirate-note.txt`.
</details>
<details><summary>Hint 3</summary>

In PowerShell, try `[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content pirate-note.txt -Raw).Trim()))`. Read the decoded sentence and copy only the code into the relevant JSON field.
</details>

## Gate 7 — Wrong Environment, Wrong Release

**Story:** The application is ready for production, but the release system thinks it is still in development.

**Learn:** environment configuration and separate release checks.

**Investigate:** inspect `environment` in `release-config.json`. The target release environment is **production**. Keep the code you recovered at the previous gate.

**Observe/verify:** valid JSON with the required environment passes this gate and reveals the final tagging defect. Changing the pirate code alone must not have solved this gate.

<details><summary>Hint 1</summary>

Look at configuration, not HTML or Docker ports.
</details>
<details><summary>Hint 2</summary>

The file has two independent release fields. Change only the field this gate checks.
</details>
<details><summary>Hint 3</summary>

Match the required environment exactly; preserve valid JSON and your previous repair.
</details>

## Gate 8 — Final Boss: Tag the Release Correctly

**Story:** The application works, but the final Docker image has the wrong release tag.

**Learn:** image tagging and artifact verification.

**Investigate:** `scripts/release.sh` prepares the final **local** image tag. The required tag is `escape-room:v1.0.0`.

**Observe/verify:** the gate executes the real release script, then inspects the expected image and checks that it is the image tested earlier. Merely writing the tag in a comment doesn't pass. Earlier successful local tags cannot hide a broken script.

<details><summary>Hint 1</summary>

Inspect what comes after the image repository's colon in the release command.
</details>
<details><summary>Hint 2</summary>

`latest` is a moving label; this release requires a specific version label.
</details>
<details><summary>Hint 3</summary>

Keep the source image and repository variable; repair the destination tag. Verify the artifact using `docker image inspect` after a full local run, or let CI verify it.
</details>

When all eight gates pass, the pipeline displays the victory banner and records your commit and verified image in its summary. Tell the duck how you escaped.
