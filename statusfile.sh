#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
LINES_ADD=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_DEL=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
SEVEN_D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WORKTREE=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')

BOLD='\033[1m'; RESET='\033[0m'; DIM='\033[2m'
YELLOW='\033[33m'; GREEN='\033[32m'; RED='\033[31m'
BLUE='\033[34m'; PURPLE='\033[35m'; CYAN='\033[36m'
BG_GREEN='\033[42m'; BG_YELLOW='\033[43m'; BG_RED='\033[41m'

# Git branch
BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" ${YELLOW}$(git branch --show-current 2>/dev/null)${RESET}"

PROJECT="${DIR##*/}"

# EUR conversion (approx 1 USD = 0.92 EUR)
COST_EUR=$(echo "$COST_USD" | awk '{printf "%.2f", $1 * 0.92}')
COST_CU=$(echo "$COST_USD" | awk '{printf "%.2f", $1 * 10}')

# Bar: same logic as reference — FILLED = PCT/10, 10 chars wide
make_bar() {
    local pct=$1 width=${2:-10}
    local filled=$(( pct / (100 / width) ))
    local empty=$(( width - filled ))
    local bar=""
    [ "$filled" -gt 0 ] && printf -v F "%${filled}s" && bar="${F// /█}"
    [ "$empty" -gt 0 ] && printf -v E "%${empty}s" && bar="${bar}${E// /░}"
    if [ "$pct" -ge 90 ]; then printf '%b' "${RED}${bar}${RESET}"
    elif [ "$pct" -ge 70 ]; then printf '%b' "${YELLOW}${bar}${RESET}"
    else printf '%b' "${GREEN}${bar}${RESET}"; fi
}

# Worktree segment (only when present)
WT_SEG=""
[ -n "$WORKTREE" ] && WT_SEG=" 🌳 ${CYAN}${WORKTREE}${RESET}"

# Effort segment (only when present) — color by level
EFF_SEG=""
if [ -n "$EFFORT" ]; then
    case "$EFFORT" in
        high|xhigh|max) EFF_COL="$RED" ;;
        medium)         EFF_COL="$YELLOW" ;;
        *)              EFF_COL="$GREEN" ;;
    esac
    EFF_SEG=" | ${EFF_COL}${EFFORT}${RESET}"
fi

# Line 1: project | branch | worktree | ctx bar | ⚡ ctx%
echo -e "${BOLD}${YELLOW}${PROJECT}${RESET} |${BRANCH}${WT_SEG} | $(make_bar "$PCT") | ⚡ ctx ${BLUE}${PCT}%${RESET}"

# Line 2: cost CU · cost€ | +lines -lines | model (purple) | effort — usage KPIs blue
echo -e "🔁 ${BLUE}~${COST_CU} CU${RESET} · ${BLUE}~€${COST_EUR}${RESET} | ${GREEN}+${LINES_ADD}${RESET} ${RED}-${LINES_DEL}${RESET} | ${PURPLE}${MODEL}${RESET}${EFF_SEG}"

# Line 3: rate limits (Pro/Max only — absent when not subscriber)
if [ -n "$FIVE_H" ] || [ -n "$SEVEN_D" ]; then
    LINE3="$(printf '%b' "${DIM}Pro${RESET}") · "
    if [ -n "$FIVE_H" ]; then
        FH_INT=$(printf '%.0f' "$FIVE_H")
        LINE3+="Daily $(make_bar "$FH_INT") ${BLUE}${FH_INT}%${RESET}"
    fi
    if [ -n "$SEVEN_D" ]; then
        SD_INT=$(printf '%.0f' "$SEVEN_D")
        LINE3+=" | Monthly $(make_bar "$SD_INT") ${BLUE}${SD_INT}%${RESET}"
    fi
    echo -e "$LINE3"
fi
