1. Make sure `NEWS.md` is up to date
2. `git pull` and `git push` from the main branch to make sure you are synced with GitHub
3. Run `usethis::use_version()` and choose the appropriate version change (major, minor, or patch)
4. It'll ask if you want to commit changes to DESCRIPTION and NEWS.md—say "no"!
5. Run the `update-citation.R` script
6. Commit all the changes with a commit message like "increment package version"
7. Push changes to GitHub
8. Run `usethis::use_github_release()`
9. Run `usethis::use_dev_version()` and push changes to main.