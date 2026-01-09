#!/bin/bash

# Ensure GNU date is used if available (for correct UTC timestamp parsing)
# Support both Apple Silicon (/opt/homebrew) and Intel (/usr/local) paths
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [ -d "/usr/local/opt/coreutils/libexec/gnubin" ]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

# <xbar.title>GitHub Actions - Node-RED</xbar.title>
# <xbar.version>v2.0</xbar.version>
# <xbar.author>dimitrie</xbar.author>
# <xbar.author.github>dimitrieh</xbar.author.github>
# <xbar.desc>Continuously monitors GitHub Actions status for Node-RED repo with live notifications</xbar.desc>
# <xbar.dependencies>gh,jq</xbar.dependencies>

# Configuration
REPO="dimitrieh/node-red"
MENU_BAR_LENGTH=20

# State file for tracking changes
STATE_FILE="$HOME/.xbar-gh-actions-state"

# Dark mode detection and color setup
if [ "$BitBarDarkMode" ]; then
    # macOS Dark Mode is enabled
    TEXT_COLOR="black"  # Use black for better contrast in dark mode
    HEADER_COLOR="gray"
else
    # macOS Light Mode (or BitBarDarkMode not set)
    TEXT_COLOR="black"  # Use black for better visibility
    HEADER_COLOR="gray"
fi

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local subtitle="$3"
    local sound="$4"
    
    if [ -n "$subtitle" ]; then
        osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\" sound name \"$sound\""
    else
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
    fi
}

# Function to parse ISO 8601 timestamp to Unix timestamp
parse_timestamp() {
    local timestamp="$1"
    # Handle both with and without fractional seconds, with or without Z
    if [[ "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?Z?$ ]]; then
        # Remove fractional seconds but keep Z for UTC, or add Z if missing
        local clean_time=$(echo "$timestamp" | sed -E 's/\.[0-9]+//')
        if [[ ! "$clean_time" =~ Z$ ]]; then
            clean_time="${clean_time}Z"
        fi
        # Try GNU date first (if available), then BSD date with UTC timezone
        # GNU date: use -d flag
        # BSD date: use TZ=UTC to ensure UTC interpretation
        date -d "$clean_time" "+%s" 2>/dev/null || \
        TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%SZ" "$clean_time" "+%s" 2>/dev/null || \
        echo ""
    else
        echo ""
    fi
}

# Function to convert timestamp to relative time
get_relative_time() {
    local timestamp="$1"
    local current_time=$(date "+%s")
    local run_time=$(parse_timestamp "$timestamp")
    if [ -z "$run_time" ]; then
        run_time="$current_time"
    fi
    local diff=$((current_time - run_time))
    
    if [ $diff -lt 60 ]; then
        echo "${diff}s ago"
    elif [ $diff -lt 3600 ]; then
        echo "$((diff / 60))m ago"
    elif [ $diff -lt 86400 ]; then
        echo "$((diff / 3600))h ago"
    else
        echo "$((diff / 86400))d ago"
    fi
}

# Function to format columns using printf (inspired by GitLab BitBar scripts)
format_workflow_line() {
    local icon="$1"
    local workflow="$2" 
    local branch="$3"
    local time="$4"
    
    # Add ellipses if text is truncated
    if [ ${#workflow} -gt 28 ]; then
        workflow="${workflow:0:25}..."
    fi
    if [ ${#branch} -gt 25 ]; then
        branch="${branch:0:22}..."
    fi
    
    # Use printf with fixed widths and truncation like GitLab scripts
    # Add space after icon to match primary run formatting (two spaces)
    printf "%s  %-28.28s %-25.25s %15s" "$icon" "$workflow" "$branch" "$time"
}

# Fetch all workflow runs once and cache the data
ALL_RUNS_RAW=$(gh api "repos/$REPO/actions/runs?per_page=50")

if [ -z "$ALL_RUNS_RAW" ]; then
    echo "No runs"
    echo "---"
    echo "Failed to fetch GitHub Actions data"
    exit 0
fi

# Extract workflow runs array
ALL_RUNS=$(echo "$ALL_RUNS_RAW" | jq '.workflow_runs[]')

# Filter running workflows from cached data
RUNNING_RUNS=$(echo "$ALL_RUNS" | jq -s '.[] | select(.status == "in_progress")')

if [ -z "$RUNNING_RUNS" ]; then
    # No running jobs - show latest completed run from cached data
    LATEST_RUN=$(echo "$ALL_RUNS" | jq -s '[.[] | select(.conclusion != "skipped" and .conclusion != null)] | .[0]')
    
    if [ -z "$LATEST_RUN" ] || [ "$LATEST_RUN" = "null" ]; then
        echo "No runs"
        echo "---"
        echo "Failed to fetch GitHub Actions data"
        exit 0
    fi
    
    STATUS=$(echo "$LATEST_RUN" | jq -r '.status')
    CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')
    WORKFLOW_NAME=$(echo "$LATEST_RUN" | jq -r '.display_title')
    
    case "$STATUS-$CONCLUSION" in
        "completed-success")
            ICON="✅"
            ;;
        "completed-failure") 
            ICON="❌"
            ;;
        "completed-cancelled")
            ICON="🚫"
            ;;
        *)
            ICON="💤"
            ;;
    esac
    
    echo "💤"
    echo "---"
    echo "Recent Runs: | href=https://github.com/$REPO/actions"
    
    echo "$ALL_RUNS_RAW" | jq -r '.workflow_runs[] | select(.conclusion != "skipped" and .conclusion != null) | [(.status + "-" + (.conclusion // "null")), .display_title, .head_branch, (.id | tostring), .created_at, .updated_at] | @tsv' | head -10 | while IFS=$'\t' read -r run_status run_name run_branch run_id run_created run_updated; do
        case "$run_status" in
            "completed-success") run_icon="✅" ;;
            "completed-failure") run_icon="❌" ;;
            "completed-cancelled") run_icon="🚫" ;;
            *) run_icon="❓" ;;
        esac
        
        # Calculate duration
        run_start=$(parse_timestamp "$run_created")
        run_end=$(parse_timestamp "$run_updated")
        if [ -n "$run_start" ] && [ -n "$run_end" ]; then
            run_duration=$((run_end - run_start))
            if [ $run_duration -lt 60 ]; then
                duration_text="${run_duration}s"
            elif [ $run_duration -lt 3600 ]; then
                duration_text="$((run_duration / 60))m"
            else
                hours=$((run_duration / 3600))
                minutes=$(((run_duration % 3600) / 60))
                if [ $minutes -gt 0 ]; then
                    duration_text="${hours}h${minutes}m"
                else
                    duration_text="${hours}h"
                fi
            fi
            run_time="(${duration_text}) $(get_relative_time "$run_updated")"
        else
            run_time=$(get_relative_time "$run_updated")
        fi
        
        formatted_line=$(format_workflow_line "$run_icon" "$run_name" "$run_branch" "$run_time")
        echo "$formatted_line | href=https://github.com/$REPO/actions/runs/$run_id size=12 font=Monaco trim=false"
    done
    
    # Clear state file when no jobs are running
    rm -f "$STATE_FILE"
    exit 0
fi

# Process running workflows
RUNNING_COUNT=$(echo "$RUNNING_RUNS" | jq -s 'length')
FIRST_RUN=$(echo "$RUNNING_RUNS" | jq -s 'sort_by(.created_at) | reverse | .[0]')

RUN_ID=$(echo "$FIRST_RUN" | jq -r '.id')
WORKFLOW_NAME=$(echo "$FIRST_RUN" | jq -r '.display_title')
BRANCH=$(echo "$FIRST_RUN" | jq -r '.head_branch')
RUN_STARTED_AT=$(echo "$FIRST_RUN" | jq -r '.run_started_at')

# Calculate duration (use run_started_at for re-runs, created_at as fallback)
START_TIME=$(parse_timestamp "$RUN_STARTED_AT")
if [ -z "$START_TIME" ]; then
    START_TIME=$(date "+%s")
fi
CURRENT_TIME=$(date "+%s")
DURATION=$((CURRENT_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

if [ $DURATION_MIN -gt 0 ]; then
    DURATION_TEXT="${DURATION_MIN}m${DURATION_SEC}s"
else
    DURATION_TEXT="${DURATION_SEC}s"
fi

# Get job details for running workflow - find the running job
JOBS_RESPONSE=$(gh api "repos/$REPO/actions/runs/$RUN_ID/jobs")
# First try to find a job that's currently in_progress, otherwise get the first job
JOB_DATA=$(echo "$JOBS_RESPONSE" | jq '[.jobs[] | select(.status == "in_progress")] | .[0]')
if [ -z "$JOB_DATA" ] || [ "$JOB_DATA" = "null" ]; then
    # No in_progress job found, get the first non-skipped job
    JOB_DATA=$(echo "$JOBS_RESPONSE" | jq '[.jobs[] | select(.conclusion != "skipped")] | .[0]')
fi
if [ -z "$JOB_DATA" ] || [ "$JOB_DATA" = "null" ]; then
    # Fallback to first job if nothing else works
    JOB_DATA=$(echo "$JOBS_RESPONSE" | jq '.jobs[0]')
fi
JOB_ID=$(echo "$JOB_DATA" | jq -r '.id')
JOB_NAME=$(echo "$JOB_DATA" | jq -r '.name')
CURRENT_STEP=$(echo "$JOB_DATA" | jq -r '.steps[] | select(.status == "in_progress") | .name' | head -1)
COMPLETED_STEPS=$(echo "$JOB_DATA" | jq -r '.steps[] | select(.conclusion == "success") | .name' | wc -l | tr -d ' ')
TOTAL_STEPS=$(echo "$JOB_DATA" | jq -r '.steps | length')

# Create current state identifier
CURRENT_STATE="$RUN_ID:$CURRENT_STEP"

# Check for state changes and send notifications
if [ -f "$STATE_FILE" ]; then
    PREV_STATE=$(cat "$STATE_FILE")
    if [ "$CURRENT_STATE" != "$PREV_STATE" ]; then
        if [ -n "$CURRENT_STEP" ]; then
            send_notification "GitHub Actions 🔄" "$CURRENT_STEP" "Job: $JOB_NAME ($COMPLETED_STEPS/$TOTAL_STEPS)" "Glass"
        else
            send_notification "GitHub Actions 🔄" "Job started" "$JOB_NAME" "Glass"
        fi
    fi
fi

# Save current state
echo "$CURRENT_STATE" > "$STATE_FILE"

# Menu bar display
if [ -n "$CURRENT_STEP" ] && [ "$TOTAL_STEPS" -gt 0 ]; then
    PERCENTAGE=$((COMPLETED_STEPS * 100 / TOTAL_STEPS))
    if [ $RUNNING_COUNT -gt 1 ]; then
        echo "🔄 ${PERCENTAGE}% (+$((RUNNING_COUNT-1)))"
    else
        echo "🔄 ${PERCENTAGE}%"
    fi
else
    if [ $RUNNING_COUNT -gt 1 ]; then
        echo "🔄($RUNNING_COUNT)"
    else
        echo "🔄"
    fi
fi

echo "---"

# Dropdown menu - show the primary run first with step counter
if [ -n "$CURRENT_STEP" ] && [ "$TOTAL_STEPS" -gt 0 ]; then
    WORKFLOW_WITH_STEPS="$WORKFLOW_NAME [$((COMPLETED_STEPS+1))/$TOTAL_STEPS]"
else
    WORKFLOW_WITH_STEPS="$WORKFLOW_NAME"
fi
# Format similar to steps with duration aligned on the right
if [ $DURATION_MIN -gt 0 ]; then
    DURATION_FORMATTED="${DURATION_MIN}m${DURATION_SEC}s"
else
    DURATION_FORMATTED="${DURATION_SEC}s"
fi
printf "🔄  %-28.28s %-25.25s %15s | href=https://github.com/$REPO/actions/runs/$RUN_ID size=12 font=Monaco trim=false\n" "$WORKFLOW_WITH_STEPS" "$BRANCH" "$DURATION_FORMATTED"

if [ -n "$CURRENT_STEP" ]; then
    # Display all steps with status
    step_counter=1
    while IFS='|' read -r step_name step_status step_conclusion step_started step_completed; do
        if [ "$step_conclusion" = "success" ]; then
            step_icon="✅"
        elif [ "$step_status" = "in_progress" ]; then
            step_icon="🔄"
        elif [ "$step_conclusion" = "failure" ]; then
            step_icon="❌"
        elif [ "$step_conclusion" = "cancelled" ]; then
            step_icon="🚫"
        elif [ "$step_status" = "queued" ]; then
            step_icon="⏳"
        else
            step_icon="⏳"
        fi
        
        # Calculate step duration
        step_duration=""
        if [ -n "$step_started" ] && [ "$step_started" != "null" ]; then
            step_start_time=$(parse_timestamp "$step_started")
            if [ -n "$step_completed" ] && [ "$step_completed" != "null" ]; then
                # Completed step - show actual duration
                step_end_time=$(parse_timestamp "$step_completed")
                if [ -n "$step_start_time" ] && [ -n "$step_end_time" ]; then
                    step_diff=$((step_end_time - step_start_time))
                    if [ $step_diff -lt 60 ]; then
                        step_duration="${step_diff}s"
                    else
                        step_min=$((step_diff / 60))
                        step_sec=$((step_diff % 60))
                        step_duration="${step_min}m${step_sec}s"
                    fi
                fi
            elif [ "$step_status" = "in_progress" ]; then
                # Running step - calculate duration from actual start time
                if [ -n "$step_start_time" ]; then
                    step_diff=$((CURRENT_TIME - step_start_time))
                    if [ $step_diff -lt 60 ]; then
                        step_duration="${step_diff}s"
                    else
                        step_min=$((step_diff / 60))
                        step_sec=$((step_diff % 60))
                        step_duration="${step_min}m${step_sec}s"
                    fi
                fi
            fi
        fi
        
        # Format with step number, aligned text, duration, and link to job
        # Add extra space after single-digit numbers to align emojis
        # Use same alignment as primary run and recent completed (total ~50 chars for content, 15 for duration)
        if [ $step_counter -lt 10 ]; then
            printf "%d.  %s %-50s %15s | size=12 font=Monaco href=https://github.com/$REPO/actions/runs/$RUN_ID/job/$JOB_ID\n" "$step_counter" "$step_icon" "$step_name" "$step_duration"
        else
            printf "%d. %s %-50s %15s | size=12 font=Monaco href=https://github.com/$REPO/actions/runs/$RUN_ID/job/$JOB_ID\n" "$step_counter" "$step_icon" "$step_name" "$step_duration"
        fi
        step_counter=$((step_counter + 1))
    done <<< "$(echo "$JOB_DATA" | jq -r '.steps[] | "\(.name)|\(.status)|\(.conclusion)|\(.started_at // "")|\(.completed_at // "")"')"
else
    echo "Starting up..."
fi

# if [ $RUNNING_COUNT -gt 1 ]; then
#     echo "$(($RUNNING_COUNT - 1)) other jobs running"
# fi

# Show other running jobs if multiple
if [ $RUNNING_COUNT -gt 1 ]; then
    echo "---"
    echo "Other Running Jobs:"
    
    echo "$RUNNING_RUNS" | jq -rs --arg exclude_id "$RUN_ID" '.[] | select(.id != ($exclude_id | tonumber)) | [.display_title, .head_branch, .id, .run_started_at] | @tsv' | while IFS=$'\t' read -r run_name run_branch run_id run_started; do
        run_start=$(parse_timestamp "$run_started")
        if [ -z "$run_start" ]; then
            run_start=$(date "+%s")
        fi
        run_duration=$((CURRENT_TIME - run_start))
        run_min=$((run_duration / 60))
        run_sec=$((run_duration % 60))
        
        if [ $run_min -gt 0 ]; then
            run_time="${run_min}m${run_sec}s"
        else
            run_time="${run_duration}s"
        fi
        
        formatted_line=$(format_workflow_line "🔄" "$run_name" "$run_branch" "$run_time")
        echo "$formatted_line | href=https://github.com/$REPO/actions/runs/$run_id size=12 font=Monaco trim=false"
    done
fi

echo "---"
echo "Recent Completed: | href=https://github.com/$REPO/actions"

echo "$ALL_RUNS_RAW" | jq -r '.workflow_runs[] | select(.status == "completed" and .conclusion != "skipped" and .conclusion != null) | [(.status + "-" + (.conclusion // "null")), .display_title, .head_branch, (.id | tostring), .created_at, .updated_at] | @tsv' | head -10 | while IFS=$'\t' read -r run_status run_name run_branch run_id run_created run_updated; do
    case "$run_status" in
        "completed-success") run_icon="✅" ;;
        "completed-failure") run_icon="❌" ;;
        "completed-cancelled") run_icon="🚫" ;;
        *) run_icon="❓" ;;
    esac
    
    # Calculate duration
    run_start=$(parse_timestamp "$run_created")
    run_end=$(parse_timestamp "$run_updated")
    if [ -n "$run_start" ] && [ -n "$run_end" ]; then
        run_duration=$((run_end - run_start))
        if [ $run_duration -lt 60 ]; then
            duration_text="${run_duration}s"
        elif [ $run_duration -lt 3600 ]; then
            duration_text="$((run_duration / 60))m"
        else
            hours=$((run_duration / 3600))
            minutes=$(((run_duration % 3600) / 60))
            if [ $minutes -gt 0 ]; then
                duration_text="${hours}h${minutes}m"
            else
                duration_text="${hours}h"
            fi
        fi
        run_time="(${duration_text}) $(get_relative_time "$run_updated")"
    else
        run_time=$(get_relative_time "$run_updated")
    fi
    
    formatted_line=$(format_workflow_line "$run_icon" "$run_name" "$run_branch" "$run_time")
    echo "$formatted_line | href=https://github.com/$REPO/actions/runs/$run_id size=12 font=Monaco"
done