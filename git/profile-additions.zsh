# https://gist.github.com/2897608
# Set these configs in git.
export GITHUB_TOKEN=$(git config --get github.token)
export GITHUB_USER=$(git config --get github.user)
export GIT_COMMITTER_NAME=${GITHUB_USER:-$(git config --get user.name)}
export GIT_COMMITTER_EMAIL=$(git config --get user.email)
export GIT_AUTHOR_NAME=${GITHUB_USER:-$(git config --get user.name)}
export GIT_AUTHOR_EMAIL=$(git config --get user.email)

alias authors="(echo "${GIT_AUTHOR_NAME} ${GIT_AUTHOR_EMAIL}"; git authors | grep -v "${GIT_AUTHOR_NAME}" | perl -pi -e 's|\([^\)]*\)||g' | sort | uniq)"

gam () {
  git ci -am "$@"
}

# gist and copy a git format-patch of the top commit
cpg () {
  rm *patch
  git format-patch HEAD^
  gist *patch | pbcopy
}

# git-style diff without it having to be a git thing
alias gdiff='git diff --no-index --color'

# Now that most markdowns support ```, the ind/und
# is not so relevant, but it's still handy for emails
# and stuff like that.
alias pbind="pbpaste | sed 's|^|    |g' | pbcopy"
alias pbund="pbpaste | sed 's|^    ||g' | pbcopy"

# convert to text.
alias pbtxt="pbpaste | pbcopy"

# paste to gist command, then copy and display the url
pbgist () {
  pbpaste | gist "$@" | pbcopy
  pbpaste
}

ghadd () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && echo "Please enter your github name as the github.user git config." && return 1
  # like: "git@github.com:$me/$repo.git"
  local mine="$( git config --get remote.origin.url )"
  local repo="${mine/git@github.com:$me\//}"
  local nick="$1"
  local who="$2"
  [ "$who" == "" ] && who="$nick"
  [ "$who" == "" ] && ( echo "usage: ghadd [nick] <who>" >&2 ) && return 1
  # eg: git://github.com/isaacs/jack.git
  local theirs="git://github.com/$who/$repo"
  git remote add "$nick" "$theirs"
  git fetch -a "$nick"
}

# Add the github origin remote
gho () {
  local me="$(git config --get github.user)"
  [ "$me" == "" ] && \
    echo "Please enter your github name as the github.user git config." && \
    return 1
  # like: "git@github.com:$me/$repo.git"
  local name="${1:-$(basename "$PWD")}"
  local repo="git@github.com:$me/$name"
  git remote add "origin" "$repo"
  git fetch -a "$origin"
}

gpa () {
  git push --all "$@"
}

gpt () {
  git push --tags "$@"
}

gps () {
  gpa "$@"
  gpt "$@"
}

# Look up any ref's sha, and also copy it for pasting into bugs and such
# gsh <commit-ish> --> copies 'c0ffeedecafbaddeadbeef15aac...' to the 
gsh () {
  local sha
  sha=$(git show ${1-HEAD} | grep commit | head -n1 | awk '{print $2}' | xargs echo -n)
  echo -n $sha | pbcopy
  echo $sha
}

npmgit () {
  local name=$1
  git clone $(npm view $name repository.url) $name
}

gf () {
  git fetch -a "$1"
}

# 1. Bump package.json version
# 2. run 'gv' to make a new commit and signed tag
# TODO: Get this functionality into the 'npm version' command.
gv () {
  local v=$(npm ls -pl | head -1 | awk -F: '{print $2}' | awk -F@ '{print $2}')
  git ci -am $v && git tag -sm $v $v
}

# Pull a submodule checked out into ./node_modules/xyz
nsp () {
  npm explore $1 -- git pull origin master
}

# I can't type
# turn 'gi tadd foo' to 'git add foo'
gi () {
  local c=${1}
  cmd=("$@")
  cmd[1]=${c:1}
  cmd[0]=git
  "${cmd[@]}"
}

# a context-sensitive rebasing git pull.
# usage:
# ghadd someuser  # add the github remote account
# git checkout somebranch
# gpm someuser    # similar to "git pull someuser somebranch"
# Remote branch is rebased, and local changes stashed and reapplied if possible.

gp () {
  local s
  local head
  s=$(git stash 2>/dev/null)
  head=$(basename $(git symbolic-ref HEAD 2>/dev/null) 2>/dev/null)
  if [ "" == "$head" ]; then
    echo_error "Not on a branch, can't pull"
    return 1
  fi
  git fetch -a $1
  git pull --rebase $1 "$head"
  [ "$s" != "No local changes to save" ] && git stash pop
}