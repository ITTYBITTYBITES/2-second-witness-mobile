# Project Audit Workflow Template

Due to GitHub App permission restrictions, this workflow cannot be automatically installed in `.github/workflows/`. 

To enable automated project auditing, manually create a file at `.github/workflows/project-audit.yml` with the following content:

```yaml
name: Project Intelligence Audit

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * *' # Daily at midnight

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Audit Repository Activity
        run: |
          echo "### Recent Activity"
          git log --since="7 days ago" --pretty=format:"- %s (%h)" || echo "No recent commits"
          
      - name: Audit Documentation Health
        run: |
          echo "Checking continuity documents..."
          FILES=(
            "PROJECT_COMMAND_CENTER.md"
            "docs/product/development-continuity/01_PROJECT_CONTEXT_BOOTSTRAP.md"
            "docs/product/development-continuity/02_CURRENT_IMPLEMENTATION_STATE.md"
            "docs/product/development-continuity/05_DECISION_LOG.md"
            ".github/project-state.yml"
          )
          for file in "${FILES[@]}"; do
            if [ -f "$file" ]; then
              echo "CHECK: $file exists."
            else
              echo "ERROR: $file is missing!"
              exit 1
            fi
          done

      - name: Identify Project Drift
        run: |
          echo "Checking for outdated status in Command Center..."
          # Check if PROJECT_COMMAND_CENTER.md was updated in the last commit
          if git diff --name-only HEAD~1 | grep -q "PROJECT_COMMAND_CENTER.md"; then
            echo "Command Center was updated in the last commit."
          else
            echo "WARNING: PROJECT_COMMAND_CENTER.md was NOT updated in the last commit. Possible documentation drift."
          fi

      - name: Generate Audit Report
        run: |
          REPORT_PATH="docs/product/development-continuity/AUTOMATED_PROJECT_AUDIT.md"
          echo "# Automated Project Audit Report" > $REPORT_PATH
          echo "Generated on: $(date)" >> $REPORT_PATH
          echo "" >> $REPORT_PATH
          echo "## Summary" >> $REPORT_PATH
          echo "The repository intelligence systems are active. This report is automatically generated to identify drift and documentation health." >> $REPORT_PATH
          echo "" >> $REPORT_PATH
          echo "## Repository Activity (Last 7 Days)" >> $REPORT_PATH
          git log --since="7 days ago" --pretty=format:"- %s (%h)" >> $REPORT_PATH
          echo "" >> $REPORT_PATH
          echo "## Documentation Status" >> $REPORT_PATH
          echo "- Command Center: Present" >> $REPORT_PATH
          echo "- Project State: Present" >> $REPORT_PATH
          echo "- Continuity System: Active" >> $REPORT_PATH
          echo "" >> $REPORT_PATH
          echo "## Recommendations" >> $REPORT_PATH
          echo "1. Ensure every PR updates PROJECT_COMMAND_CENTER.md." >> $REPORT_PATH
          echo "2. Keep .github/project-state.yml in sync with manual changes." >> $REPORT_PATH
          echo "3. Review the Decision Log regularly." >> $REPORT_PATH
```
