function __git.default_branch -d "Use init.defaultBranch if set, otherwise detect main/master/trunk"
  command git rev-parse --git-dir &>/dev/null; or return
  if set -l default_branch (command git config --get init.defaultBranch)
    and command git show-ref -q --verify refs/heads/{$default_branch}
    echo $default_branch
    return
  end

  for branch in main master trunk
    if command git show-ref -q --verify refs/heads/$branch; or command git show-ref -q --verify refs/remotes/origin/$branch
      echo $branch
      return
    end
  end

  echo main
end
