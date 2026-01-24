## Set values
# Hide welcome message & ensure we are reporting fish as shell
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT 1
set -x SHELL /usr/bin/fish

# nvim editor setup
# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# brave
set -gx BROWSER brave

# Use bat for man pages
set -xU MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -xU MANROFFOPT -c

# Hint to exit PKGBUILD review in Paru
set -x PARU_PAGER "less -P \"Press 'q' to exit the PKGBUILD review.\""

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end

## Starship prompt
if status --is-interactive
    source ("/usr/bin/starship" init fish --print-full-init | psub)
end

## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ]

    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (echo $argv[1] | string trim --right --chars=/)
        set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

# Cleanup local orphaned packages
function cleanup
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
        if test "$status" -eq 1
            break
        end
    end
end

# Replace some more things with better alternatives
abbr cat 'bat --style header,snip,changes'
if not test -x /usr/bin/yay; and test -x /usr/bin/paru
    alias yay paru
end

# Common use
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'
alias big 'expac -H M "%m\t%n" | sort -h | nl' # Sort installed packages according to size in MB (expac must be installed)
alias dir 'dir --color=auto'
alias fixpacman 'sudo rm /var/lib/pacman/db.lck'
alias gitpkg 'pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
alias grep 'ugrep --color=auto'
alias egrep 'ugrep -E --color=auto'
alias fgrep 'ugrep -F --color=auto'
alias grubup 'sudo update-grub'
alias hw 'hwinfo --short' # Hardware Info
alias ip 'ip -color'
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'
alias rmpkg 'sudo pacman -Rdd'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias upd /usr/bin/garuda-update
alias vdir 'vdir --color=auto'
alias wget 'wget -c '

# Get fastest mirrors
alias mirror 'sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
alias mirrora 'sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist'
alias mirrord 'sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist'
alias mirrors 'sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist'

# Help people new to Arch
alias apt 'man pacman'
alias apt-get 'man pacman'
alias please sudo
alias tb 'nc termbin.com 9999'
alias helpme 'echo "To print basic information about a command use tldr <command>"'
alias pacdiff 'sudo -H DIFFPROG=meld pacdiff'

# Get the error messages from journalctl
alias jctl 'journalctl -p 3 -xb'

# Recent installed packages
alias rip 'expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'

# fzf integration
if type -q fzf
    fzf --fish | source
end

# ============================
#     Aliases & Shortcuts
# ============================

# Directory listings (lsd)
# Directory listings (lsd)

alias l='lsd -lh --icon=auto'
alias ls='lsd'
alias ll='lsd -lha --icon=auto --group-directories-first'
alias ld='lsd -lh --directory-only --icon=auto'
alias lt='lsd --tree --depth=2 --icon=auto'

# EDITOR
alias vc='code'
alias c='clear'
alias x='exit'

# Git aliases
alias gs='git status'
alias gc='git commit -m'
alias ga='git add'
alias gaa='git add .'
alias gl='git log --oneline'

# mkdir with -p by default
abbr mkdir 'mkdir -p'

# ============================
#     Zoxide Integration
# ============================

# Initialize zoxide
if type -q zoxide
    zoxide init fish | source
end

# Replace cd with zoxide-powered cd
function cd
    if test (count $argv) -eq 0
        z
    else
        z $argv
    end
end

# fzf-powered interactive directory jump (zi)
if type -q fzf
    function zi
        set dir (zoxide query --interactive)
        if test -n "$dir"
            cd "$dir"
        end
    end
end

# Optional: Keybinding for fast interactive cd (Ctrl+o)
# if type -q fzf
#     bind \co 'zi'
# end

# ============================
#     File Opener (fzf + bat)
# ============================

if type -q fzf
    function fo
        # Fuzzy search file + preview with bat
        set file (fzf --preview "bat --color=always --style=plain --line-range=1:200 {}")
        if test -n "$file"
            if set -q EDITOR
                $EDITOR "$file"
            else
                nano "$file"
            end
        end
    end
end

# Optional: Keybinding (Ctrl+f) to trigger file opener
# bind \cf 'fo'

# ============================
#     zf — find + fzf + zoxide jump
# ============================

function zf
    # Prefer fd, fallback to find
    if type -q fd
        set target (fd --type d --hidden --exclude .git .)
    else
        set target (find . -type d 2> /dev/null)
    end

    if test (count $target) -eq 0
        echo "No directories found."
        return 1
    end

    # Pick directory using fzf
    set dir (printf '%s\n' $target | fzf --height 40% --reverse --prompt="Find dir > ")

    # If no selection, exit
    if test -z "$dir"
        return 0
    end

    # Normalize path (remove leading ./)
    set dir (string replace -r '^./' '' "$dir")

    # Jump using zoxide (updates ranking)
    if type -q zoxide
        zoxide add "$dir"
        z "$dir"
    else
        cd "$dir"
    end
end

# Go environment
set -x GOPATH $HOME/go
set -x GOBIN $GOPATH/bin
set -x PATH $PATH $GOBIN
