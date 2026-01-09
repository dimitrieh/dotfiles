#!/usr/bin/env bash

# <xbar.title>Docker Hetzner Monitor</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Docker Monitor</xbar.author>
# <xbar.author.github>dimitrie</xbar.author.github>
# <xbar.desc>Monitor Docker containers on Hetzner server via Tailscale proxy</xbar.desc>
# <xbar.dependencies>curl,jq</xbar.dependencies>
# <xbar.refreshInterval>120</xbar.refreshInterval>

# Configuration
DOCKER_PROXY_URL="http://docker-proxy.tailbfedba.ts.net:2375"
TIMEOUT=5
TAILSCALE="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Function to convert bytes to human readable
bytes_to_human() {
    local bytes=$1
    if [ -z "$bytes" ] || [ "$bytes" = "null" ]; then
        echo "0B"
        return
    fi
    
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes/1024))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$((bytes/1048576))MB"
    else
        echo "$((bytes/1073741824))GB"
    fi
}

# Function to get Docker info
get_docker_info() {
    curl -sf --connect-timeout $TIMEOUT "$DOCKER_PROXY_URL/info" 2>/dev/null
}

# Function to get containers
get_containers() {
    curl -sf --connect-timeout $TIMEOUT "$DOCKER_PROXY_URL/containers/json?all=true" 2>/dev/null
}

# Check if we can connect
if ! curl -sf --connect-timeout $TIMEOUT "$DOCKER_PROXY_URL/version" >/dev/null 2>&1; then
    echo "🐳 ❌"
    echo "---"
    echo "Cannot connect to Docker proxy"
    echo "Check Tailscale connection"
    exit 0
fi

# Get Docker info
docker_info=$(get_docker_info)
if [ -z "$docker_info" ]; then
    echo "🐳 ⚠️"
    echo "---"
    echo "Failed to get Docker info"
    exit 0
fi

# Parse system info
total_containers=$(echo "$docker_info" | jq -r '.Containers // 0')
running_containers=$(echo "$docker_info" | jq -r '.ContainersRunning // 0')
stopped_containers=$(echo "$docker_info" | jq -r '.ContainersStopped // 0')
total_images=$(echo "$docker_info" | jq -r '.Images // 0')
total_memory=$(echo "$docker_info" | jq -r '.MemTotal // 0')
ncpu=$(echo "$docker_info" | jq -r '.NCPU // 0')
server_version=$(echo "$docker_info" | jq -r '.ServerVersion // "unknown"')

# Convert memory to human readable
mem_human=$(bytes_to_human $total_memory)

# Get nr-experiment count from Tailscale
nr_experiment_count=0
if [ -x "$TAILSCALE" ]; then
    TAILSCALE_STATUS=$($TAILSCALE status --json 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$TAILSCALE_STATUS" ]; then
        nr_experiment_count=$(echo "$TAILSCALE_STATUS" | jq '[.Peer | to_entries[] | .value | select(.Tags[]? | contains("tag:nr-experiment")) | select(.Online == true)] | length' 2>/dev/null)
        if [ -z "$nr_experiment_count" ]; then
            nr_experiment_count=0
        fi
    fi
fi

# Menu bar icon with nr-experiment count and total containers
if [ $nr_experiment_count -gt 0 ] || [ $total_containers -gt 0 ]; then
    echo "🐳 ${nr_experiment_count}(${total_containers})"
else
    echo "🐳"
fi

echo "---"

# Dashboard link at the top
echo "Open Dashboard | href=https://dashboard.tailbfedba.ts.net"
echo "---"
# GitHub repository links
echo "GitHub Issues | href=https://github.com/dimitrieh/node-red/issues"
echo "GitHub PRs | href=https://github.com/dimitrieh/node-red/pulls"
echo "---"

# Server info
echo "Hetzner Docker Server"
echo "Docker $server_version"
echo "CPUs: $ncpu"
echo "Memory: $mem_human"
echo "---"

# Container summary
echo "Containers"
echo "▶ Running: $running_containers"
if [ $stopped_containers -gt 0 ]; then
    echo "◼ Stopped: $stopped_containers"
fi
echo "📦 Images: $total_images"
echo "---"

# Get nr-experiment devices from Tailscale
if [ -x "$TAILSCALE" ]; then
    TAILSCALE_STATUS=$($TAILSCALE status --json 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$TAILSCALE_STATUS" ]; then
        # Get all nr-experiment devices
        NR_DEVICES=$(echo "$TAILSCALE_STATUS" | jq -r '.Peer | to_entries[] | .value | select(.Tags[]? | contains("tag:nr-experiment")) | select(.Online == true) | .DNSName' 2>/dev/null | sed 's/\.$//' | sort)
        
        if [ -n "$NR_DEVICES" ]; then
            echo "NR Experiments"
            while IFS= read -r device; do
                # Extract the meaningful name from DNS name
                device_name=$(echo "$device" | cut -d'.' -f1)
                # Extract branch name by removing 'nr-' prefix and fixing claude-issue format
                branch_name=$(echo "$device_name" | sed 's/^nr-//' | sed 's/claude-issue/claude\/issue/')
                
                # Main item with link
                echo "• $device_name | href=https://$device"
                # Submenu with cleanup action
                echo "--Cleanup | shell=/opt/homebrew/bin/gh terminal=false param1=workflow param2=run param3=\"Deploy to Hetzner\" param4=--ref param5=\"$branch_name\" param6=--repo param7=dimitrieh/node-red param8=-f param9=\"branch=$branch_name\" param10=-f param11=\"action=cleanup\""
            done <<< "$NR_DEVICES"
            echo "---"
        fi
    fi
fi

# List containers by name only (no performance metrics)
containers=$(get_containers)
if [ -n "$containers" ] && [ "$containers" != "[]" ]; then
    echo "Running Containers"
    
    # Show running containers
    echo "$containers" | jq -r '.[] | select(.State == "running") | 
        "• \(.Names[0] | ltrimstr("/"))"' 2>/dev/null
    
    # Show stopped containers if any
    stopped_count=$(echo "$containers" | jq -r '[.[] | select(.State != "running")] | length')
    if [ "$stopped_count" -gt 0 ]; then
        echo "---"
        echo "Stopped Containers"
        echo "$containers" | jq -r '.[] | select(.State != "running") | 
            "• \(.Names[0] | ltrimstr("/"))"' 2>/dev/null
    fi
fi

echo "---"
echo "Refresh | refresh=true"
echo "Open Dashboard | href=https://dashboard.tailbfedba.ts.net"