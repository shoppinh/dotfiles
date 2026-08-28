function __git.current_branch -d "Output git's current branch name"
  command git rev-parse --git-dir &>/dev/null; or return
  set -l branch (command git symbolic-ref --short HEAD 2>/dev/null)
  if test -n "$branch"
    echo $branch
  else
    command git rev-parse --short HEAD 2>/dev/null
  end
end
