# Verify Command

Run the app or its tests to confirm a change **actually works** — observed behavior, not just "it compiles." Compiling proves the types line up; it does not prove the feature does what you intended. This command makes you exercise the change and watch the result.

**Usage:** `/verify [what to check]`

Pairs with `/review-work`, which reads the diff for bugs *before* you run anything — `/verify` is the run-it-and-watch step that confirms the change behaves.

---

## This is a TEMPLATE

The kit is cross-stack, so this command ships with **no live commands** — every stack section below is a commented placeholder. Fill in the one(s) your project uses and delete the rest. Discover the real command from the repo (test runner in `package.json` / `Makefile` / `pyproject.toml` / `Cargo.toml` / a CI workflow, or your `docs/ai-context/*.md`) rather than hardcoding a guess. If you can't find one, ask the user instead of assuming.

## Process

1. **Identify what changed** — `git diff --stat HEAD` — and what behavior it should produce.
2. **Pick the verification path** for the stack(s) the diff touches (sections below).
3. **Run it and OBSERVE.** A green exit code is necessary, not sufficient — confirm the *behavior* (right output, right state, right pixels). A test that runs but asserts nothing meaningful has verified nothing.
4. **On failure, fix and re-run** until the observed behavior matches intent. Surface non-trivial fixes to the user.
5. **Report** what you ran, what you observed, and whether it matched intent.

## Customize per stack

Uncomment and complete the section(s) that apply to your project. These are EXAMPLES — replace with your repo's real commands.

<!-- Web (browser):   drive the page and assert on rendered state, not just HTTP 200.
                      e.g. headless browser automation (Playwright/Puppeteer) for a real UI flow,
                      or `curl -fsS <url>` piped into an assertion for an endpoint.
                      Check console errors and network failures, not only the happy path. -->

<!-- iOS / mobile:    build + run the test suite on a simulator/emulator, or launch the app and
                      walk the changed flow by hand.
                      e.g. an xcodebuild test invocation, or a simulator boot + UI test. -->

<!-- Android:         run instrumented/connected tests on a device or emulator.
                      e.g. a gradle connectedAndroidTest task, or `adb` install + launch the flow. -->

<!-- Server / API:    run the test suite, then hit the running service and assert on the response.
                      e.g. pytest / go test / your unit+integration suite, plus a health-check or
                      endpoint call that asserts status AND body shape. -->

<!-- Database:        dry-run the migration on a throwaway/copy, then assert post-state with queries.
                      e.g. apply the migration to a scratch DB, run SELECTs that confirm the
                      schema/data is what you expect, and check rollback works. -->

<!-- Other:           CLI tools, daemons, batch jobs, libraries — run the entrypoint or example,
                      feed it representative input, and assert on the actual output. -->

---

**What to verify:** $ARGUMENTS
