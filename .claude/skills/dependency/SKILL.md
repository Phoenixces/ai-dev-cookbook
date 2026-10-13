---
name: dependency
description: Analyze project dependencies — tree, conflicts, version mismatches. Works with Maven, npm, pip, or any package manager.
---

## Instructions

1. Detect the package manager and show the dependency tree:

   **Maven:**
   ```bash
   mvn dependency:tree
   ```
   **npm/pnpm:**
   ```bash
   npm ls --depth=3
   ```
   **pip:**
   ```bash
   pip show <package> && pip check
   ```

2. Filter for a specific dependency:

   **Maven:**
   ```bash
   mvn dependency:tree -Dincludes=<groupId>:<artifactId>
   ```
   **npm:**
   ```bash
   npm ls <package-name>
   ```

3. Check for conflicts or version mismatches.

4. Provide analysis of:
   - Direct vs transitive dependencies
   - Version conflicts
   - Unused or redundant dependencies
