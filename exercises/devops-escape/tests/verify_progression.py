"""Instructor regression test: real gates, real Docker, disposable starter copy.

This file contains solutions. Keep it with instructor materials when distributing.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import uuid

SOURCE = Path(__file__).resolve().parents[1]
REPO = SOURCE.parents[1]


def fingerprint():
    # Includes the starter, root app, README, scripts, and both workflows.
    return {
        str(p.relative_to(REPO)): (hashlib.sha256(p.read_bytes()).hexdigest(), p.stat().st_mode)
        for p in REPO.rglob("*")
        if p.is_file() and ".git" not in p.relative_to(REPO).parts
    }


def main():
    subprocess.run(["docker", "info"], check=True, stdout=subprocess.DEVNULL)
    before = fingerprint()
    token = uuid.uuid4().hex[:12]
    image_repo = "escape-room-test-" + token
    container = "devops-escape-test-" + token
    with tempfile.TemporaryDirectory(prefix="devops-escape-test-") as temp:
        work = Path(temp) / "starter"
        shutil.copytree(SOURCE, work)
        env = dict(os.environ, ESCAPE_REPOSITORY=image_repo, ESCAPE_SCOPE="test-" + token,
                   ESCAPE_CONTAINER=container, GITHUB_STEP_SUMMARY=str(Path(temp) / "summary.md"),
                   GITHUB_SHA=subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=REPO, text=True).strip())

        def run(script, expected=0):
            result = subprocess.run(["bash", str(work / script)], cwd=REPO, env=env,
                                    text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            if result.returncode != expected:
                raise AssertionError(f"{script}: expected exit {expected}, got {result.returncode}\n{result.stdout}")
            return result.stdout

        def edit(file, old, new):
            path = work / file
            original = path.read_text()
            assert old in original, (file, old)
            path.write_text(original.replace(old, new))

        def config(**updates):
            path = work / "release-config.json"
            data = json.loads(path.read_text())
            data.update(updates)
            path.write_text(json.dumps(data, indent=2) + "\n")

        def cleaned():
            result = subprocess.run(["docker", "container", "inspect", container],
                                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            assert result.returncode != 0, "Challenge container leaked after a run"

        try:
            assert not (work / "deployment-info.json").exists()
            assert not (work / "duck-answer.txt").exists()
            reasons = ["deployment-info.json is missing", "duck-answer.txt is missing", "Docker build failed",
                       "No HTTP 200", "HTTP 200 is not enough", "invalid releaseCode",
                       "required production environment", "did not create"]
            for gate in range(1, 10):
                # Deliberately pre-seed the correct tag before testing the broken
                # Gate 8: it must fail anyway, then restore that pre-existing tag.
                if gate == 8:
                    subprocess.run(["docker", "tag", image_repo + ":challenge", image_repo + ":v1.0.0"], check=True)
                output = run("scripts/run-local.sh", expected=gate if gate <= 8 else 0)
                completed = gate - 1 if gate <= 8 else 8
                assert f"Completed gates: {completed}/8" in output
                summary = Path(env["GITHUB_STEP_SUMMARY"]).read_text()
                assert f"Completed gates: {completed}/8" in summary
                assert "Commit SHA: " + env["GITHUB_SHA"] in summary
                if gate <= 8:
                    assert f"First failed gate: Gate {gate:02d}" in output
                    assert reasons[gate - 1] in output, output
                    assert f"::error title=Gate {gate:02d}" in output
                    if gate == 3:
                        assert "home.html" in output and "not found" in output, output
                    for later in range(gate + 1, 9):
                        assert f"===== Gate {later:02d} =====" not in output
                        assert f"| {later:02d} | skipped |" in summary
                    assert "CONGRATULATIONS!" not in output
                    if gate == 8:
                        subprocess.run(["docker", "image", "inspect", image_repo + ":v1.0.0"], check=True, stdout=subprocess.DEVNULL)
                    print(f"PASS: {completed} preceding fixes applied; Gate {gate} fails for its intended reason; later gates skipped", flush=True)
                else:
                    assert "CONGRATULATIONS! YOU ESCAPED THE DEVOPS PIPELINE!" in output
                    assert "8 / 8 GATES" in output
                    assert "Verified image tag: " + image_repo + ":v1.0.0" in summary
                    print("PASS: all 8 gates succeed, actual final image inspected, victory log and summary generated", flush=True)
                cleaned()
                Path(env["GITHUB_STEP_SUMMARY"]).unlink()
                if gate == 1:
                    (work / "deployment-info.json").write_text('{"appName":"workshop-app","version":"1.0.0"}\n')
                elif gate == 2:
                    (work / "duck-answer.txt").write_text("  RuBbEr DuCk \n")
                elif gate == 3:
                    edit("Dockerfile", "home.html", "index.html")
                elif gate == 4:
                    edit("scripts/start-container.sh", "8080:8080", "8080:80")
                elif gate == 5:
                    edit("index.html", "Hello from Version 1!", "Hello from Version 2!")
                elif gate == 6:
                    config(releaseCode="parrot")
                    assert json.loads((work / "release-config.json").read_text())["environment"] == "development"
                elif gate == 7:
                    config(environment="production")
                elif gate == 8:
                    edit("scripts/release.sh", ":latest", ":v1.0.0")

            # Additional malformed/wrong inputs must really fail, not merely exist.
            artifact = work / "deployment-info.json"
            artifact.write_text('\ufeff{"appName":"workshop-app","version":"1.0.0"}')
            run("scripts/gate-01.sh")
            (work / "duck-answer.txt").write_text("\ufeff  Rubber Duck\n")
            run("scripts/gate-02.sh")
            for invalid in ['{', '[]', '{"appName":"wrong","version":"1.0.0"}', '{"appName":"workshop-app","version":"2.0.0"}']:
                artifact.write_text(invalid)
                run("scripts/gate-01.sh", expected=1)
            answer = work / "duck-answer.txt"
            answer.write_text("a goose")
            run("scripts/gate-02.sh", expected=1)
            config_file = work / "release-config.json"
            for invalid in ["{", "[]", "{}"]:
                config_file.write_text(invalid)
                run("scripts/gate-06.sh", expected=1)
                run("scripts/gate-07.sh", expected=1)
            decoded = __import__("base64").b64decode((work / "pirate-note.txt").read_text()).decode()
            assert decoded == "Captain Dockerbeard says: the release code is parrot"
            print("PASS: bad JSON/values/answers rejected; mixed-case duck answer accepted; pirate clue decodes correctly", flush=True)
            # An unrelated name collision must never be deleted by safe cleanup.
            collision = subprocess.check_output(["docker", "create", "--name", container, image_repo + ":challenge"], text=True).strip()
            try:
                run("scripts/cleanup.sh", expected=1)
                actual = subprocess.check_output(["docker", "inspect", "--format", "{{.Id}}", container], text=True).strip()
                assert actual == collision
            finally:
                subprocess.run(["docker", "rm", container], check=True, stdout=subprocess.DEVNULL)
            print("PASS: cleanup refuses an unrelated container; UTF-8 BOM files are accepted", flush=True)
        finally:
            subprocess.run(["bash", str(work / "scripts/cleanup.sh")], env=env, check=True)
            # Only this test's random image repository is touched.
            tags = subprocess.check_output(["docker", "image", "ls", image_repo, "--format", "{{.Repository}}:{{.Tag}}"], text=True).splitlines()
            if tags:
                subprocess.run(["docker", "image", "rm", *tags], check=True, stdout=subprocess.DEVNULL)
            assert fingerprint() == before, "The real checkout changed during progression tests"
            cleaned()
    print("PASS: temporary fixtures removed, no leaked test containers/tags, actual starter and original root files unchanged", flush=True)


if __name__ == "__main__":
    main()
