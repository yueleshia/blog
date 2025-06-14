#!/bin/sh

#run: ../pages/make.sh %

# Print 'a' to prevent `$( )` from stripping whitespace
wd="$( dirname "${0}"; printf a )"; wd="${wd%?a}"
cd "${wd}" || exit "$?"

#git reset --hard main
mkdir -p output
printf %s\\n final/*.adoc | parallel --will-cite --color-failed '
  path={}
  relpath="${path#final/}"

  printf %s\\n "=== ${relpath} ===" >&2
  cd "final" || exit "$?"
  IS_LOCAL=false tetra parse "${relpath}" >"../hugo/content/blog/${relpath}" || exit "$?"
'

exit

git add .
git commit --message "Publish $( date +"%Y-%m-%d" )"
git push --force origin pages
