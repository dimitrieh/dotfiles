#!/bin/bash

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
    TEXT_COLOR=""  # Use system default color for better readability
    HEADER_COLOR="gray"
else
    # macOS Light Mode (or BitBarDarkMode not set)
    TEXT_COLOR=""  # Use system default color
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

# Function to convert timestamp to relative time
get_relative_time() {
    local timestamp="$1"
    local current_time=$(date "+%s")
    local run_time=$(date -d "$timestamp" "+%s" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%s" 2>/dev/null || echo "$current_time")
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
    
    # Use printf with fixed widths and truncation like GitLab scripts
    # Adjusted spacing: more between workflow/branch, less between branch/time
    printf "%s %-28.28s %-17.17s %15s" "$icon" "$workflow" "($branch)" "$time"
}

# Fetch all workflow runs once and cache the data
ALL_RUNS_RAW=$(gh api "repos/$REPO/actions/runs")

if [ -z "$ALL_RUNS_RAW" ]; then
    echo "🚫 No runs"
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
        echo "🚫 No runs"
        echo "---"
        echo "Failed to fetch GitHub Actions data"
        exit 0
    fi
    
    STATUS=$(echo "$LATEST_RUN" | jq -r '.status')
    CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')
    WORKFLOW_NAME=$(echo "$LATEST_RUN" | jq -r '.name')
    
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
    echo "Recent Runs:"
    
    echo "$ALL_RUNS_RAW" | jq -r '.workflow_runs[] | select(.conclusion != "skipped" and .conclusion != null) | [(.status + "-" + (.conclusion // "null")), .name, .head_branch, (.id | tostring), .created_at] | @tsv' | head -10 | while IFS=$'\t' read -r run_status run_name run_branch run_id run_created; do
        case "$run_status" in
            "completed-success") run_icon="✅" ;;
            "completed-failure") run_icon="❌" ;;
            "completed-cancelled") run_icon="🚫" ;;
            *) run_icon="❓" ;;
        esac
        
        run_time=$(get_relative_time "$run_created")
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
WORKFLOW_NAME=$(echo "$FIRST_RUN" | jq -r '.name')
BRANCH=$(echo "$FIRST_RUN" | jq -r '.head_branch')
CREATED_AT=$(echo "$FIRST_RUN" | jq -r '.created_at')

# Calculate duration
START_TIME=$(date -d "$CREATED_AT" "+%s" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED_AT" "+%s" 2>/dev/null || date "+%s")
CURRENT_TIME=$(date "+%s")
DURATION=$((CURRENT_TIME - START_TIME))
DURATION_MIN=$((DURATION / 60))
DURATION_SEC=$((DURATION % 60))

if [ $DURATION_MIN -gt 0 ]; then
    DURATION_TEXT="${DURATION_MIN}m${DURATION_SEC}s"
else
    DURATION_TEXT="${DURATION_SEC}s"
fi

# Get job details for running workflow
JOB_DATA=$(gh api "repos/$REPO/actions/runs/$RUN_ID/jobs" --jq '.jobs[0]')
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
if [ $RUNNING_COUNT -gt 1 ]; then
    echo "🔄 (+$((RUNNING_COUNT-1)))"
else
    echo "🔄"
fi

echo "---"

# Dropdown menu
echo "🔄 $WORKFLOW_NAME (Running $DURATION_TEXT)"
echo "Branch: $BRANCH"

if [ -n "$CURRENT_STEP" ]; then
    echo "Current: $CURRENT_STEP"
    echo "Progress: $COMPLETED_STEPS/$TOTAL_STEPS steps"
else
    echo "Starting up..."
fi

if [ $RUNNING_COUNT -gt 1 ]; then
    echo "$(($RUNNING_COUNT - 1)) other jobs running"
fi

echo "---"
echo "View on GitHub | href=https://github.com/$REPO/actions/runs/$RUN_ID"

# Show all running jobs if multiple
if [ $RUNNING_COUNT -gt 1 ]; then
    echo "---"
    echo "All Running Jobs:"
    
    echo "$RUNNING_RUNS" | jq -s '.[] | "\(.name)|\(.head_branch)|\(.id)|\(.created_at)"' | while IFS='|' read -r run_name run_branch run_id run_created; do
        run_start=$(date -d "$run_created" "+%s" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$run_created" "+%s" 2>/dev/null || date "+%s")
        run_duration=$((CURRENT_TIME - run_start))
        run_min=$((run_duration / 60))
        
        if [ $run_min -gt 0 ]; then
            run_time="${run_min}m"
        else
            run_time="${run_duration}s"
        fi
        
        formatted_line=$(format_workflow_line "🔄" "$run_name" "$run_branch" "$run_time")
        echo "$formatted_line | href=https://github.com/$REPO/actions/runs/$run_id size=12 font=Monaco trim=false"
    done
fi

echo "---"
echo "Recent Completed:"
echo "   St Workflow                      Branch           Time | color=$HEADER_COLOR font=Monaco trim=false"

echo "$ALL_RUNS_RAW" | jq -r '.workflow_runs[] | select(.status == "completed" and .conclusion != "skipped" and .conclusion != null) | [(.status + "-" + (.conclusion // "null")), .name, .head_branch, (.id | tostring), .created_at] | @tsv' | head -10 | while IFS=$'\t' read -r run_status run_name run_branch run_id run_created; do
    case "$run_status" in
        "completed-success") run_icon="✅" ;;
        "completed-failure") run_icon="❌" ;;
        "completed-cancelled") run_icon="🚫" ;;
        *) run_icon="❓" ;;
    esac
    
    run_time=$(get_relative_time "$run_created")
    formatted_line=$(format_workflow_line "$run_icon" "$run_name" "$run_branch" "$run_time")
    echo "$formatted_line | href=https://github.com/$REPO/actions/runs/$run_id size=12 font=Monaco"
done