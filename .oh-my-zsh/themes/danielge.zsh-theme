local user='%{$fg_bold[green]%}%n@%m:%{$reset_color%}'
local pwd='%{$fg[yellow]%}%~%{$reset_color%}'
local git_stuff='%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} %'
local arrow='%{$fg_bold[red]%} ➜  %{$reset_color%}'
PROMPT="${user} ${pwd} ${git_stuff} ${arrow}"

ZSH_THEME_GIT_PROMPT_PREFIX="git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
