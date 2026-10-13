# Review

Review code changes for quality, best practices, and potential issues.

## Instructions

1. Get the current git diff:
   ```bash
   git diff --staged
   ```
   If nothing staged, check unstaged changes:
   ```bash
   git diff
   ```

2. Analyze the changes for:
   - Code correctness and logic errors
   - Language-appropriate best practices (null safety, exception handling, resource management)
   - Framework patterns and conventions consistent with the existing codebase
   - Test coverage for new code
   - Security vulnerabilities (SQL injection, XSS, path traversal, etc.)
   - Performance concerns

3. Check if tests exist for modified code:
   - For each modified file, verify a corresponding test file exists
   - Suggest missing test cases

4. Provide feedback organized by:
   - **Critical**: Must fix before commit
   - **Suggestions**: Recommended improvements
   - **Style**: Minor style/convention issues
