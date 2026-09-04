# Agent TDD Workflow Prompt Template

When asking an AI Agent (like Antigravity) to build a feature or work on tasks using strict Test-Driven Development (TDD), provide the following prompt:

---

### Prompt for AI Agent:

> **Role & Protocol Instruction**:
> You MUST follow strict Test-Driven Development (TDD) enforced by the `agent-tdd` CLI tool.
> Note: `agent-tdd` outputs machine-readable JSON by default for all commands (pass `--no-json` for human-readable terminal text).
>
> **Execution Protocol**:
> 1. **Check Status**: Run `agent-tdd status` to get current phase and specs progress.
> 2. **Start Next Spec**: Run `agent-tdd next` to select the next pending feature spec.
> 3. **RED Phase**:
>    - Write ONLY a failing unit test for the active spec in the test directory.
>    - DO NOT edit or modify production source code under any circumstances (production code is strictly READ-ONLY). If your test passes before running verify-red, expand test assertions in test directory instead of breaking production code.
>    - Run `agent-tdd verify-red`. If verified, the test files will be snapshot-locked.
> 4. **GREEN Phase**:
>    - Test files are FROZEN. Do NOT edit any test files.
>    - Write the MINIMAL production implementation code needed to pass the failing test.
>    - Run `agent-tdd verify-green`.
> 5. **REFACTOR Phase**:
>    - Refactor code and test cleanups as needed.
>    - Run `agent-tdd verify-refactor`. Ensure 100% test pass AND 0 static analysis warnings/errors.
> 6. **COMPLETE Cycle**:
>    - Run `agent-tdd complete` to finalize the spec and create a Git micro-commit.
>    - Proceed to the next spec using `agent-tdd next`.
