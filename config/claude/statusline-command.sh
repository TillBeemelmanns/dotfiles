#!/bin/sh
# Claude Code status line — robbyrussell style + model + bars + session countdown

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')

dir=$(basename "$cwd")

branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null)
fi

if [ -n "$branch" ]; then
    printf "\033[1;36m%s\033[0m \033[1;34mgit:(\033[31m%s\033[1;34m)\033[0m" "$dir" "$branch"
    if git -C "$cwd" -c core.fsmonitor=false status --porcelain 2>/dev/null | grep -q .; then
        printf " \033[33m✗\033[0m"
    fi
else
    printf "\033[1;36m%s\033[0m" "$dir"
fi

model=$(echo "$input" | jq -r '.model.display_name // empty')
[ -n "$model" ] && printf " \033[2m%s\033[0m" "$model"

# Usage: make_bar LABEL PCT_VALUE
# Format:  C ▕████████░░▏ 80%
make_bar() {
    _label="$1"
    _pct="$2"
    _width=8
    _filled=$(echo "$_pct $_width" | awk '{n=int($1*$2/100+0.5); print (n>$2)?$2:(n<0?0:n)}')
    _empty=$((_width - _filled))

    _fill=""
    _i=0; while [ $_i -lt $_filled ]; do _fill="${_fill}█"; _i=$((_i+1)); done
    _i=0; while [ $_i -lt $_empty ];  do _fill="${_fill}░"; _i=$((_i+1)); done

    _pct_int=$(echo "$_pct" | awk '{printf "%d", int($1)}')
    if   [ "$_pct_int" -ge 90 ]; then _color="\033[31m"
    elif [ "$_pct_int" -ge 70 ]; then _color="\033[33m"
    else                               _color="\033[32m"
    fi

    printf "  \033[2m%s\033[0m\033[2m▕\033[0m${_color}%s\033[2m▏\033[0m\033[2m%d%%\033[0m" \
        "$_label" "$_fill" "$_pct_int"
}

# Context window bar
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
[ -n "$used" ] && make_bar "C" "$used"

# 5-hour session bar + reset countdown
# resets_at is a Unix epoch number (seconds), not an ISO string
session_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$session_pct" ]; then
    make_bar "S" "$session_pct"

    reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
    if [ -n "$reset_epoch" ] && [ "$reset_epoch" != "null" ]; then
        now=$(date +%s)
        remaining=$((reset_epoch - now))
        if [ "$remaining" -gt 0 ]; then
            h=$((remaining / 3600))
            m=$(( (remaining % 3600) / 60 ))
            printf " \033[2m↺%d:%02d\033[0m" "$h" "$m"
        fi
    fi
fi

# 7-day weekly bar
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
[ -n "$week_pct" ] && make_bar "W" "$week_pct"
