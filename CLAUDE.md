# Pickture

**Flutter gallery cleaning app** — helps users organize, review, and clean up their photo library.

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Architecture:** Clean Architecture (domain / data / presentation)
- **Targets:** iOS, Android

## Agent Team

This project uses 7 specialized agents:

| Agent | File | Role |
|-------|------|------|
| Architect | `.claude/agents/architect.md` | System design & architecture decisions |
| Infra | `.claude/agents/infra.md` | Build, CI/CD, environment setup |
| UI/UX | `.claude/agents/uiux.md` | Design system, components, UX |
| Developer | `.claude/agents/developer.md` | Core feature implementation |
| Tester | `.claude/agents/tester.md` | Test strategy & execution |
| Rules | `.claude/agents/rules.md` | Coding standards & linting |
| Docs | `.claude/agents/docs.md` | Documentation & knowledge management |

## Project Structure

```
lib/
  core/           # Shared utilities, theme, constants
    theme/        # Design tokens, colors, typography
  domain/         # Entities, repositories (interfaces), use cases
    entities/
    repositories/
    usecases/
  data/           # Repository implementations, data sources, models
    repositories/
    datasources/
    models/
  presentation/   # UI screens, widgets, Riverpod providers
    screens/
    widgets/
    providers/
  application/    # App-level providers, routing, DI setup
test/             # Unit & widget tests
integration_test/ # Integration tests
docs/             # ADRs, guides
assets/           # Images, fonts, etc.
scripts/          # Build & automation scripts
```

## Cross-Cutting Conventions

- **Language:** Code and agent instructions in English. User-facing communication in Korean.
- **Naming:** `snake_case` for files and directories, `camelCase` for variables/functions, `PascalCase` for classes/enums/typedefs.
- **Imports:** Dart imports first, then package imports, then relative imports. Each group separated by a blank line.
- **Riverpod:** Use code generation (`@riverpod`) where possible. Prefer `ref.watch` over `ref.read` in build methods.
- **Architecture layers:** Domain has zero dependencies on data or presentation. Data depends only on domain. Presentation depends on domain and application.
- **No circular dependencies** between features or layers.
- **Dart formatting:** Follow `dart format` defaults (line length 80).
- **Analysis:** Strict mode via `analysis_options.yaml`. Zero warnings policy.

## Agent Workflow Rules

All agents **must** follow these rules during every session:

### 1. Skill 적극 활용
- Use `/find-skills` to discover relevant local and global skills before starting work.
- When a skill matches the task (e.g., `ui-ux-pro-max` for design, `git-commit` for commits), **always invoke it** instead of doing the work manually.
- Periodically check for new skills that may have been added.

### 2. Agent Team 적극 활용
- Delegate tasks to the appropriate specialized agent. Do not do another agent's job.
- Use the `Task` tool to spawn sub-agents for parallel, independent work.
- When a task crosses ownership boundaries, coordinate by spawning the relevant agent rather than doing it yourself.

### 3. Efficient Context Management
- Use sub-agents (`Task` tool) for research, exploration, and isolated tasks to protect the main context window.
- Avoid dumping large file contents into the main conversation — read only what's needed, use targeted searches.
- Prefer `Glob` and `Grep` for quick lookups; use `Task(subagent_type=Explore)` for deep exploration.
- Keep responses concise. Do not repeat information already established in the conversation.

### 4. Session Handoff Protocol (Context 15% Rule)
When the session context reaches approximately **15% remaining**:
1. **Stop** current work at a safe checkpoint.
2. **Create a handoff summary** in `/Users/jaeppetto/.claude/projects/-Users-jaeppetto-pickture/memory/HANDOFF.md` containing:
   - **Completed:** What was accomplished in this session (bullet list).
   - **In Progress:** Any partially completed work and its current state.
   - **Next Steps:** Specific tasks/phases to continue in the next session.
   - **Key Decisions:** Any important decisions made that affect future work.
   - **Blockers:** Any unresolved issues or questions.
3. **Notify the user** in Korean that context is running low and the handoff file has been written.
4. The next session should **read `HANDOFF.md` first** and continue from where the previous session left off.
