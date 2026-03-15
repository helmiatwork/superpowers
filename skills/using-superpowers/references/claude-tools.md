# Claude Code Tool Mapping

Skills use Claude Code tool names natively. No translation is needed — skill instructions map directly to your available tools:

| Skill references | Claude Code tool |
|-----------------|-----------------|
| `Read` (file reading) | `Read` |
| `Write` (file creation) | `Write` |
| `Edit` (file editing) | `Edit` |
| `Bash` (run commands) | `Bash` |
| `Grep` (search file content) | `Grep` |
| `Glob` (search files by name) | `Glob` |
| `TodoWrite` (task tracking) | `TodoWrite` |
| `Skill` tool (invoke a skill) | `Skill` |
| `WebSearch` | `WebSearch` |
| `WebFetch` | `WebFetch` |
| `Task` tool (dispatch subagent) | `Agent` (subagent_type parameter selects specialist) |

## Subagent support

Claude Code supports subagents via the `Agent` tool. Use the `subagent_type` parameter to select agent types, or omit it for general-purpose agents. Multiple `Agent` calls can be made in parallel for concurrent work.

| Skill concept | Claude Code usage |
|--------------|-------------------|
| Dispatch subagent | `Agent` tool with `prompt` and optional `subagent_type` |
| Parallel dispatch | Multiple `Agent` calls in a single response |
| Background work | `Agent` with `run_in_background: true` |
| Isolated work | `Agent` with `isolation: "worktree"` |

## Additional Claude Code tools

These tools are available in Claude Code and referenced in skills:

| Tool | Purpose |
|------|---------|
| `EnterPlanMode` / `ExitPlanMode` | Switch to read-only research mode before making changes |
| `NotebookEdit` | Edit Jupyter notebook cells |
| `AskUserQuestion` | Request structured input from the user |
