function __git.develop_branch -d "Output git develop branch name"
  command git rev-parse --git-dir &>/dev/null; or return
  for branch in develop dev development
    if command git show-ref -q --verify refs/heads/$branch; or command git show-ref -q --verify refs/remotes/origin/$branch
      echo $branch
      return
    end
  end
  echo develop
end
