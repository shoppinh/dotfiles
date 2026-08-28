function __git.init
  function __git.create_shortcut -d "Create Git shortcut as both abbreviation and alias"
    set -l name $argv[1]
    set -l body $argv[2..-1]

    # Fish abbreviation for interactive live expansion
    abbr -a -g $name $body

    # Fish alias for direct command execution / non-interactive / subshells
    alias $name="$body"
  end

  # Provide a smooth transition from universal to global abbreviations by
  # deleting the old universal ones.
  if set -q __git_plugin_initialized
    __git.destroy
  end

  # =============================================================================
  # 1. Base Git & Status
  # =============================================================================
  __git.create_shortcut g          git
  __git.create_shortcut gst        git status
  __git.create_shortcut gsb        git status -sb
  __git.create_shortcut gss        git status -s
  __git.create_shortcut gsh        git show
  __git.create_shortcut gshw       git show
  __git.create_shortcut gsps       "git show --pretty=short --show-signature"
  __git.create_shortcut gcount     git shortlog -sn
  __git.create_shortcut gcf        git config --list
  __git.create_shortcut gcl        git clone --recurse-submodules
  __git.create_shortcut gclean     git clean -di
  __git.create_shortcut gclean!    git clean -dfx
  __git.create_shortcut gclean!!   "git reset --hard; and git clean -dfx"
  __git.create_shortcut gpristine  "git reset --hard; and git clean -dffx"
  __git.create_shortcut gignored   "git status --ignored"
  __git.create_shortcut gignore    "git update-index --assume-unchanged"
  __git.create_shortcut gunignore  "git update-index --no-assume-unchanged"

  # =============================================================================
  # 2. Add / Stage
  # =============================================================================
  __git.create_shortcut ga         git add
  __git.create_shortcut gaa        git add --all
  __git.create_shortcut gau        git add --update
  __git.create_shortcut gav        git add --verbose
  __git.create_shortcut gapa       git add --patch
  __git.create_shortcut gap        git apply
  __git.create_shortcut gapt       git apply --3way

  # =============================================================================
  # 3. Branch & Switch & Checkout
  # =============================================================================
  __git.create_shortcut gb         git branch -vv
  __git.create_shortcut gba        git branch -a -v
  __git.create_shortcut gban       git branch -a -v --no-merged
  __git.create_shortcut gbd        git branch -d
  __git.create_shortcut gbD        git branch -D
  __git.create_shortcut gbm        git branch -m
  __git.create_shortcut gbM        git branch -M
  __git.create_shortcut gbnm       git branch --no-merged
  __git.create_shortcut gbr        git branch --remote
  __git.create_shortcut gbl        git blame -b -w
  __git.create_shortcut ggsup      "git branch --set-upstream-to=origin/(__git.current_branch)"
  __git.create_shortcut gco        git checkout
  __git.create_shortcut gcb        git checkout -b
  __git.create_shortcut gcd        "git checkout (__git.develop_branch)"
  __git.create_shortcut gcm        "git checkout (__git.default_branch)"
  __git.create_shortcut gcom       "git checkout (__git.default_branch)"
  __git.create_shortcut gcod       "git checkout (__git.develop_branch)"
  __git.create_shortcut gcor       git checkout --recurse-submodules
  __git.create_shortcut gsw        git switch
  __git.create_shortcut gswc       git switch --create
  __git.create_shortcut gswm       "git switch (__git.default_branch)"
  __git.create_shortcut gswd       "git switch (__git.develop_branch)"

  # =============================================================================
  # 4. Commit
  # =============================================================================
  __git.create_shortcut gc         git commit -v
  __git.create_shortcut gc!        git commit -v --amend
  __git.create_shortcut gcn!       git commit --no-edit --amend
  __git.create_shortcut gca        git commit -v -a
  __git.create_shortcut gca!       git commit -v -a --amend
  __git.create_shortcut gcan!      git commit -a --no-edit --amend
  __git.create_shortcut gcans!     git commit -v -a -s --no-edit --amend
  __git.create_shortcut gcam       git commit -a -m
  __git.create_shortcut gcmsg      git commit -m
  __git.create_shortcut gcs        git commit -S
  __git.create_shortcut gcs!       git commit -S --amend
  __git.create_shortcut gcsm       git commit -s -m
  __git.create_shortcut gcas       git commit -a -s
  __git.create_shortcut gcasm      git commit -a -s -m
  __git.create_shortcut gcv        git commit -v --no-verify
  __git.create_shortcut gcav       git commit -a -v --no-verify
  __git.create_shortcut gcav!      git commit -a -v --no-verify --amend
  __git.create_shortcut gcfx       git commit --fixup

  # =============================================================================
  # 5. Diff
  # =============================================================================
  __git.create_shortcut gd         git diff
  __git.create_shortcut gdca       git diff --cached
  __git.create_shortcut gds        git diff --staged
  __git.create_shortcut gdsc       git diff --stat --cached
  __git.create_shortcut gdt        git diff-tree --no-commit-id --name-only -r
  __git.create_shortcut gdw        git diff --word-diff
  __git.create_shortcut gdwc       git diff --word-diff --cached
  __git.create_shortcut gdcw       git diff --cached --word-diff
  __git.create_shortcut gdup       "git diff @{upstream}"
  __git.create_shortcut gdto       git difftool
  __git.create_shortcut gdg        git diff --no-ext-diff

  # =============================================================================
  # 6. Stash (Supports gstp = git stash pop)
  # =============================================================================
  __git.create_shortcut gsta       git stash
  __git.create_shortcut gstaa      git stash apply
  __git.create_shortcut gstp       git stash pop
  __git.create_shortcut gstl       git stash list
  __git.create_shortcut gstd       git stash drop
  __git.create_shortcut gstc       git stash clear
  __git.create_shortcut gsts       git stash show --text
  __git.create_shortcut gstu       git stash --include-untracked
  __git.create_shortcut gstall     git stash --all

  # =============================================================================
  # 7. Push / Pull / Fetch
  # =============================================================================
  __git.create_shortcut gp         git push
  __git.create_shortcut gp!        git push --force-with-lease
  __git.create_shortcut gpf        git push --force-with-lease
  __git.create_shortcut gpf!       git push --force
  __git.create_shortcut gpd        git push --dry-run
  __git.create_shortcut gpo        git push origin
  __git.create_shortcut gpo!       git push --force-with-lease origin
  __git.create_shortcut gpv        git push --no-verify
  __git.create_shortcut gpv!       git push --no-verify --force-with-lease
  __git.create_shortcut ggp        "git push origin (__git.current_branch)"
  __git.create_shortcut ggp!       "git push origin (__git.current_branch) --force-with-lease"
  __git.create_shortcut gpu        "git push origin (__git.current_branch) --set-upstream"
  __git.create_shortcut gpsup      "git push origin (__git.current_branch) --set-upstream"
  __git.create_shortcut gpoat      "git push origin --all; and git push origin --tags"
  __git.create_shortcut ggpnp      "git pull origin (__git.current_branch); and git push origin (__git.current_branch)"
  __git.create_shortcut gl         git pull
  __git.create_shortcut ggl        "git pull origin (__git.current_branch)"
  __git.create_shortcut gll        git pull origin
  __git.create_shortcut glr        git pull --rebase
  __git.create_shortcut gpr        git pull --rebase
  __git.create_shortcut gup        git pull --rebase
  __git.create_shortcut gupv       git pull --rebase -v
  __git.create_shortcut gprv       git pull --rebase -v
  __git.create_shortcut gupa       git pull --rebase --autostash
  __git.create_shortcut gpra       git pull --rebase --autostash
  __git.create_shortcut gupav      git pull --rebase --autostash -v
  __git.create_shortcut gprav      git pull --rebase --autostash -v
  __git.create_shortcut ggu        "git pull --rebase origin (__git.current_branch)"
  __git.create_shortcut glum       "git pull upstream (__git.default_branch)"
  __git.create_shortcut gprom      "git pull --rebase origin (__git.default_branch)"
  __git.create_shortcut gpromi     "git pull --rebase=interactive origin (__git.default_branch)"
  __git.create_shortcut gprum      "git pull --rebase upstream (__git.default_branch)"
  __git.create_shortcut gprumi     "git pull --rebase=interactive upstream (__git.default_branch)"
  __git.create_shortcut gf         git fetch
  __git.create_shortcut gfa        git fetch --all --prune
  __git.create_shortcut gfo        git fetch origin
  __git.create_shortcut gfm        "git fetch origin (__git.default_branch) --prune; and git merge FETCH_HEAD"

  # =============================================================================
  # 8. Rebase & Merge
  # =============================================================================
  __git.create_shortcut grb        git rebase
  __git.create_shortcut grba       git rebase --abort
  __git.create_shortcut grbc       git rebase --continue
  __git.create_shortcut grbi       git rebase --interactive
  __git.create_shortcut grbs       git rebase --skip
  __git.create_shortcut grbo       "git rebase origin/(__git.current_branch)"
  __git.create_shortcut grbd       "git rebase (__git.develop_branch)"
  __git.create_shortcut grbdi      "git rebase (__git.develop_branch) --interactive"
  __git.create_shortcut grbdia     "git rebase (__git.develop_branch) --interactive --autosquash"
  __git.create_shortcut grbm       "git rebase (__git.default_branch)"
  __git.create_shortcut grbmi      "git rebase (__git.default_branch) --interactive"
  __git.create_shortcut grbmia     "git rebase (__git.default_branch) --interactive --autosquash"
  __git.create_shortcut grbom      "git fetch origin (__git.default_branch); and git rebase FETCH_HEAD"
  __git.create_shortcut grbomi     "git fetch origin (__git.default_branch); and git rebase FETCH_HEAD --interactive"
  __git.create_shortcut grbomia    "git fetch origin (__git.default_branch); and git rebase FETCH_HEAD --interactive --autosquash"
  __git.create_shortcut gm         git merge
  __git.create_shortcut gma        git merge --abort
  __git.create_shortcut gmc        git merge --continue
  __git.create_shortcut gms        git merge --squash
  __git.create_shortcut gmt        git mergetool --no-prompt
  __git.create_shortcut gmtl       git mergetool --no-prompt
  __git.create_shortcut gmom       "git merge origin/(__git.default_branch)"
  __git.create_shortcut gmum       "git merge upstream/(__git.default_branch)"

  # =============================================================================
  # 9. Reset / Restore / Revert / WIP
  # =============================================================================
  __git.create_shortcut grev       git revert
  __git.create_shortcut greva      git revert --abort
  __git.create_shortcut grevc      git revert --continue
  __git.create_shortcut grh        git reset
  __git.create_shortcut grhh       git reset --hard
  __git.create_shortcut grhpa      git reset --patch
  __git.create_shortcut groh       "git reset origin/(__git.current_branch) --hard"
  __git.create_shortcut grs        git restore
  __git.create_shortcut grss       git restore --source
  __git.create_shortcut grst       git restore --staged
  __git.create_shortcut gunwip     "git rev-list --max-count=1 --format=\"%s\" HEAD | grep -q \"\\--wip--\" && git reset HEAD~1"
  __git.create_shortcut gwip       "git add -A; git rm (git ls-files --deleted) 2>/dev/null; git commit --no-verify --no-gpg-sign --message \"--wip-- [skip ci]\""

  # =============================================================================
  # 10. Log
  # =============================================================================
  __git.create_shortcut glo        "git log --oneline --decorate --color"
  __git.create_shortcut glog       "git log --oneline --decorate --color --graph"
  __git.create_shortcut gloga      "git log --oneline --decorate --color --graph --all"
  __git.create_shortcut glg        git log --stat
  __git.create_shortcut glgg       git log --graph
  __git.create_shortcut glgga      git log --graph --decorate --all
  __git.create_shortcut glgm       git log --graph --max-count=10
  __git.create_shortcut glom       "git log --oneline --decorate --color (__git.default_branch).."
  __git.create_shortcut glod       "git log --oneline --decorate --color (__git.develop_branch).."
  __git.create_shortcut gloo       "git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"
  __git.create_shortcut glol       "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %Cblue<%an>%Creset'"
  __git.create_shortcut glols      "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %Cblue<%an>%Creset' --stat"
  __git.create_shortcut glola      "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %Cblue<%an>%Creset' --all"
  __git.create_shortcut gwch       "git log -p --abbrev-commit --pretty=medium --raw --no-merges"

  # =============================================================================
  # 11. Cherry-Pick & Bisect
  # =============================================================================
  __git.create_shortcut gcp        git cherry-pick
  __git.create_shortcut gcpa       git cherry-pick --abort
  __git.create_shortcut gcpc       git cherry-pick --continue
  __git.create_shortcut gbs        git bisect
  __git.create_shortcut gbsb       git bisect bad
  __git.create_shortcut gbsg       git bisect good
  __git.create_shortcut gbsr       git bisect reset
  __git.create_shortcut gbss       git bisect start

  # =============================================================================
  # 12. Remote, Worktree, Submodules, Tags & Flow
  # =============================================================================
  __git.create_shortcut gr         git remote -vv
  __git.create_shortcut gra        git remote add
  __git.create_shortcut grm        git rm
  __git.create_shortcut grmc       git rm --cached
  __git.create_shortcut grmv       git remote rename
  __git.create_shortcut grpo       git remote prune origin
  __git.create_shortcut grrm       git remote remove
  __git.create_shortcut grset      git remote set-url
  __git.create_shortcut grup       git remote update
  __git.create_shortcut grv        git remote -v
  __git.create_shortcut gsi        git submodule init
  __git.create_shortcut gsu        git submodule update
  __git.create_shortcut gsur       git submodule update --recursive
  __git.create_shortcut gsuri      git submodule update --recursive --init
  __git.create_shortcut gts        git tag -s
  __git.create_shortcut gtv        "git tag | sort -V"
  __git.create_shortcut gwt        git worktree
  __git.create_shortcut gwta       git worktree add
  __git.create_shortcut gwtls      git worktree list
  __git.create_shortcut gwtlo      git worktree lock
  __git.create_shortcut gwtmv      git worktree move
  __git.create_shortcut gwtpr      git worktree prune
  __git.create_shortcut gwtrm      git worktree remove
  __git.create_shortcut gwtulo     git worktree unlock
  __git.create_shortcut gfb        git flow bugfix
  __git.create_shortcut gff        git flow feature
  __git.create_shortcut gfr        git flow release
  __git.create_shortcut gfh        git flow hotfix
  __git.create_shortcut gfs        git flow support
  __git.create_shortcut gfbs       git flow bugfix start
  __git.create_shortcut gffs       git flow feature start
  __git.create_shortcut gfrs       git flow release start
  __git.create_shortcut gfhs       git flow hotfix start
  __git.create_shortcut gfss       git flow support start
  __git.create_shortcut gfbt       git flow bugfix track
  __git.create_shortcut gfft       git flow feature track
  __git.create_shortcut gfrt       git flow release track
  __git.create_shortcut gfht       git flow hotfix track
  __git.create_shortcut gfst       git flow support track
  __git.create_shortcut gfp        git flow publish
  __git.create_shortcut gmr        "git push origin (__git.current_branch) --set-upstream -o merge_request.create"
  __git.create_shortcut gmwps      "git push origin (__git.current_branch) --set-upstream -o merge_request.create -o merge_request.merge_when_pipeline_succeeds"

  # Cleanup declared helper functions
  functions -e __git.create_shortcut
end
