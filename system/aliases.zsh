alias ..='cd ..'
alias ...='cd ../..'

alias g='git'
alias s='subl .'

alias update='sudo softwareupdate -i -a; brew update; brew upgrade'

alias npmeu='npm --registry http://registry.npmjs.eu/'

# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
else
  alias l='ls -GlAh'
  alias ll='ls -Gl'
  alias la='ls -Gla'
fi
