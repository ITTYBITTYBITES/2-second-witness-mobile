# Human Project Workflow Guide

This document explains how the project owner manages the repository using the internal Command Center and AI-assisted development.

## The Simple Workflow

1.  **Open `PROJECT_COMMAND_CENTER.md`**
    - This is your dashboard. Review the "Current Status" and "Next Actions" to see where the project stands.
2.  **Review Current Status**
    - Check the roadmap and recent work. Ensure the AI hasn't drifted from the intended flagship vision.
3.  **Start AI Session**
    - Use the prompt provided in `docs/product/development-continuity/START_NEXT_SESSION.md` to bootstrap the next agent. This ensures they have the "external memory" of the project.
4.  **Complete Work**
    - The AI performs the tasks, updates the documentation, and prepares a Pull Request.
5.  **Review PR**
    - Inspect the PR. The AI should have updated the `PROJECT_COMMAND_CENTER.md` and `project-state.yml` as part of the PR.
6.  **Merge**
    - Once satisfied, merge the PR into `main`.
7.  **Let Automation Update Project Intelligence**
    - The GitHub workflows will run audits to ensure documentation health and track progress.

## Best Practices

- **The Command Center is Truth:** If the Command Center says we are on Update 1, don't let the AI jump to Update 5.
- **Protect Decisions:** If a decision is "Locked," it's for a reason. Use the Decision Log to understand the *why* behind the architecture.
- **One PR per Task:** Keep PRs focused on the current active update to make reviews easier and maintain clear history.
- **Trust the Roadmap:** The 10-update plan is designed to build a premium experience layer by layer. Avoid the temptation to add "just one more feature" that isn't in the plan.
