#!/bin/bash

# xbar runs with minimal PATH - add Homebrew paths for gh, jq, etc.
# Support both Apple Silicon (/opt/homebrew) and Intel (/usr/local) paths
if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
elif [ -d "/usr/local/bin" ]; then
    export PATH="/usr/local/bin:$PATH"
fi

# GNU coreutils PATH (for date parsing on macOS)
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [ -d "/usr/local/opt/coreutils/libexec/gnubin" ]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

# <xbar.title>GitHub Dashboard</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>dimitrie</xbar.author>
# <xbar.author.github>dimitrieh</xbar.author.github>
# <xbar.desc>Shows assigned issues, authored PRs, and review requests with project status</xbar.desc>
# <xbar.dependencies>gh,jq</xbar.dependencies>

# Configuration
FLOWFUSE_PROJECT_NUMBER=1

# Check if gh is available
if ! command -v gh &> /dev/null; then
    echo "gh not found"
    exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "jq not found"
    exit 0
fi

# Function to parse ISO 8601 timestamp to Unix timestamp
parse_timestamp() {
    local timestamp="$1"
    if [[ "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
        local clean_time=$(echo "$timestamp" | sed -E 's/\.[0-9]+//')
        if [[ ! "$clean_time" =~ Z$ ]]; then
            clean_time="${clean_time}Z"
        fi
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
    local item_time=$(parse_timestamp "$timestamp")
    if [ -z "$item_time" ]; then
        echo ""
        return
    fi
    local diff=$((current_time - item_time))

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

# Function to format issue line (with milestone)
# Columns: NUMBER  TYPE  TITLE  STATUS  MILESTONE  SIZE  TIME
format_issue_line() {
    local number="$1"
    local type="$2"
    local title="$3"
    local status="$4"
    local milestone="$5"
    local size="$6"
    local time="$7"

    if [ ${#title} -gt 40 ]; then
        title="${title:0:37}..."
    fi
    if [ ${#milestone} -gt 12 ]; then
        milestone="${milestone:0:9}..."
    fi

    printf "  #%-5d  %-8s  %-40.40s  %-12s  %-12s  %5s  %10s" "$number" "$type" "$title" "$status" "$milestone" "$size" "$time"
}

# Function to format PR line (aligned with issue line)
# Columns: NUMBER  TITLE  STATUS  (padding)  TIME
format_pr_line() {
    local number="$1"
    local title="$2"
    local status="$3"
    local time="$4"

    if [ ${#title} -gt 45 ]; then
        title="${title:0:42}..."
    fi

    # Padding of 19 chars to align with milestone+size columns (12+2+5)
    printf "  #%-5d  %-45.45s  %-12s  %19s  %10s" "$number" "$title" "$status" "" "$time"
}

# Function to format review request line (aligned with issue line)
# Columns: NUMBER  TITLE  @AUTHOR  (padding)  TIME
format_review_line() {
    local number="$1"
    local title="$2"
    local author="$3"
    local time="$4"

    if [ ${#title} -gt 45 ]; then
        title="${title:0:42}..."
    fi

    # Padding of 19 chars to align with milestone+size columns (12+2+5)
    printf "  #%-5d  %-45.45s  @%-11s  %19s  %10s" "$number" "$title" "$author" "" "$time"
}

# Function to map PR review decision to display text
get_pr_status() {
    local review_decision="$1"
    local is_draft="$2"

    if [ "$is_draft" = "true" ]; then
        echo "Draft"
    elif [ "$review_decision" = "APPROVED" ]; then
        echo "Approved"
    elif [ "$review_decision" = "CHANGES_REQUESTED" ]; then
        echo "Changes Req"
    elif [ "$review_decision" = "REVIEW_REQUIRED" ]; then
        echo "Needs Review"
    else
        echo ""
    fi
}

# GraphQL query to fetch all data in one call
GRAPHQL_QUERY='
query {
  assignedIssues: search(query: "is:issue is:open assignee:@me", type: ISSUE, first: 50) {
    nodes {
      ... on Issue {
        number
        title
        url
        updatedAt
        milestone { title }
        labels(first: 10) { nodes { name } }
        repository { nameWithOwner }
        projectItems(first: 3) {
          nodes {
            project { number }
            fieldValues(first: 10) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue {
                  name
                  field { ... on ProjectV2SingleSelectField { name } }
                }
                ... on ProjectV2ItemFieldNumberValue {
                  number
                  field { ... on ProjectV2Field { name } }
                }
              }
            }
          }
        }
      }
    }
  }
  authoredPRs: search(query: "is:pr is:open author:@me", type: ISSUE, first: 30) {
    nodes {
      ... on PullRequest {
        number
        title
        url
        isDraft
        reviewDecision
        updatedAt
        repository { nameWithOwner }
      }
    }
  }
  reviewRequested: search(query: "is:pr is:open review-requested:@me", type: ISSUE, first: 20) {
    nodes {
      ... on PullRequest {
        number
        title
        url
        isDraft
        updatedAt
        repository { nameWithOwner }
        author { login }
      }
    }
  }
}
'

# Fetch data
RESPONSE=$(gh api graphql -f query="$GRAPHQL_QUERY" 2>/dev/null)

if [ -z "$RESPONSE" ] || [ "$(echo "$RESPONSE" | jq -r '.data // empty')" = "" ]; then
    echo "GH Error"
    exit 0
fi

# Parse response
ISSUES=$(echo "$RESPONSE" | jq -c '.data.assignedIssues.nodes // []')
MY_PRS=$(echo "$RESPONSE" | jq -c '.data.authoredPRs.nodes // []')
REVIEWS=$(echo "$RESPONSE" | jq -c '.data.reviewRequested.nodes // []')

# Count items
ISSUE_COUNT=$(echo "$ISSUES" | jq 'length')
PR_COUNT=$(echo "$MY_PRS" | jq 'length')
REVIEW_COUNT=$(echo "$REVIEWS" | jq 'length')

# Menu bar
echo "I:$ISSUE_COUNT P:$PR_COUNT R:$REVIEW_COUNT"
echo "---"

# Review Requested Section (FIRST - most urgent)
echo "Review Requested ($REVIEW_COUNT)"
echo "---"

echo "$REVIEWS" | jq -r '
  group_by(.repository.nameWithOwner) |
  .[] |
  .[0].repository.nameWithOwner as $repo |
  "\($repo)",
  (.[] | "\(.number)\t\(.title)\t\(.url)\t\(.updatedAt)\t\(.author.login // "")")
' | while IFS= read -r line; do
    if [[ "$line" != *$'\t'* ]]; then
        echo "$line | color=gray href=https://github.com/$line"
    else
        IFS=$'\t' read -r number title url updated_at author <<< "$line"

        rel_time=$(get_relative_time "$updated_at")
        formatted=$(format_review_line "$number" "$title" "$author" "$rel_time")
        echo "$formatted | href=$url size=12 font=Monaco trim=false"
    fi
done

echo "---"

# Assigned Issues Section
echo "Assigned Issues ($ISSUE_COUNT) | href=https://github.com/issues/assigned"
echo "---"

# Group issues by repository and output
# Note: Using "_" as placeholder for empty fields to prevent bash IFS collapsing consecutive tabs
echo "$ISSUES" | jq -r '
  group_by(.repository.nameWithOwner) |
  .[] |
  .[0].repository.nameWithOwner as $repo |
  "\($repo)",
  (.[] | "\(.number)\t\(.title)\t\(.url)\t\(.updatedAt)\t\(.milestone.title // "_")\t\(.labels.nodes | map(.name) | tojson)\t\(.projectItems.nodes | tojson)")
' | while IFS= read -r line; do
    # Check if this is a repo header (no tab) or an issue line
    if [[ "$line" != *$'\t'* ]]; then
        # Repository header
        echo "$line | color=gray href=https://github.com/$line"
    else
        # Issue line - parse fields
        IFS=$'\t' read -r number title url updated_at milestone labels project_items <<< "$line"

        # Convert placeholder back to empty
        [ "$milestone" = "_" ] && milestone=""

        # Extract work type label (epic, story, task, bug, feature-request)
        work_type=""
        if [ -n "$labels" ] && [ "$labels" != "[]" ]; then
            work_type=$(echo "$labels" | jq -r '
                . as $labels |
                ["epic", "story", "task", "bug", "feature-request"] |
                map(select(. as $type | $labels | index($type))) |
                first // empty
            ' 2>/dev/null)
            # Capitalize first letter for display
            if [ -n "$work_type" ]; then
                work_type="$(echo "${work_type:0:1}" | tr '[:lower:]' '[:upper:]')${work_type:1}"
                # Shorten feature-request
                [ "$work_type" = "Feature-request" ] && work_type="Feature"
            fi
        fi

        # Extract project status and size from FlowFuse Development project
        status=""
        size=""
        if [ -n "$project_items" ] && [ "$project_items" != "[]" ]; then
            # Parse project items to find FlowFuse Development project (number 1)
            project_data=$(echo "$project_items" | jq -r --argjson proj_num "$FLOWFUSE_PROJECT_NUMBER" '
                .[] | select(.project.number == $proj_num) | .fieldValues.nodes[] |
                select(.name != null or .number != null) |
                if .field.name == "Status" then "status:\(.name)"
                elif .field.name == "Size" then "size:\(.number)"
                else empty end
            ' 2>/dev/null)

            while IFS= read -r field; do
                if [[ "$field" == status:* ]]; then
                    status="${field#status:}"
                elif [[ "$field" == size:* ]]; then
                    size_num="${field#size:}"
                    if [ -n "$size_num" ] && [ "$size_num" != "null" ]; then
                        size="${size_num%.*}pts"
                    fi
                fi
            done <<< "$project_data"
        fi

        rel_time=$(get_relative_time "$updated_at")
        formatted=$(format_issue_line "$number" "$work_type" "$title" "$status" "$milestone" "$size" "$rel_time")
        echo "$formatted | href=$url size=12 font=Monaco trim=false"
    fi
done

echo "---"

# My PRs Section
echo "My PRs ($PR_COUNT) | href=https://github.com/pulls"
echo "---"

echo "$MY_PRS" | jq -r '
  group_by(.repository.nameWithOwner) |
  .[] |
  .[0].repository.nameWithOwner as $repo |
  "\($repo)",
  (.[] | "\(.number)\t\(.title)\t\(.url)\t\(.updatedAt)\t\(.reviewDecision // "")\t\(.isDraft)")
' | while IFS= read -r line; do
    if [[ "$line" != *$'\t'* ]]; then
        echo "$line | color=gray href=https://github.com/$line"
    else
        IFS=$'\t' read -r number title url updated_at review_decision is_draft <<< "$line"

        status=$(get_pr_status "$review_decision" "$is_draft")
        rel_time=$(get_relative_time "$updated_at")
        formatted=$(format_pr_line "$number" "$title" "$status" "$rel_time")
        echo "$formatted | href=$url size=12 font=Monaco trim=false"
    fi
done

echo "---"
echo "Refresh | refresh=true"
echo "Open GitHub Issues | href=https://github.com/issues/assigned"
