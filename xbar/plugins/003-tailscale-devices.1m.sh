#!/usr/bin/env bash

# Required parameters for xbar:
# <xbar.title>Tailscale Devices</xbar.title>
# <xbar.version>1.0</xbar.version>
# <xbar.author>Dimitrie</xbar.author>
# <xbar.author.github>dimitrie</xbar.author.github>
# <xbar.desc>Displays Tailscale devices categorized by owner with network status</xbar.desc>
# <xbar.dependencies>tailscale, jq</xbar.dependencies>

# Use full path to tailscale
TAILSCALE="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Check if tailscale exists
if [ ! -x "$TAILSCALE" ]; then
    # Tailscale not installed, exit silently
    exit 0
fi

# Check if jq command exists
if ! command -v jq &> /dev/null; then
    echo "JQ Missing"
    echo "---"
    echo "jq is required but not installed"
    exit 1
fi

# Check if tailscale is running and connected
TAILSCALE_STATUS=$($TAILSCALE status --json 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$TAILSCALE_STATUS" ]; then
    # Exit silently if tailscale is not running or not connected
    exit 0
fi

# Check if we're connected to tailnet
BACKEND_STATE=$(echo "$TAILSCALE_STATUS" | jq -r '.BackendState' 2>/dev/null)
if [ "$BACKEND_STATE" != "Running" ]; then
    # Exit silently if not connected to tailnet
    exit 0
fi

# Count online devices
ONLINE_COUNT=$(echo "$TAILSCALE_STATUS" | jq '[.Self, .Peer[]] | map(select(.Online == true)) | length' 2>/dev/null)
if [ -z "$ONLINE_COUNT" ]; then
    ONLINE_COUNT=0
fi

# Try to get CPU metrics from Mac mini if available
PROMETHEUS_HOST="100.86.115.50"
PROMETHEUS_PORT="9090"

# Check if Prometheus is reachable - using simple query endpoint instead of range
PROMETHEUS_QUERY_ENCODED="100%20-%20%28avg%20by%20%28instance%29%20%28rate%28node_cpu_seconds_total%7Bmode%3D%22idle%22%7D%5B5m%5D%29%29%20%2A%20100%29"
PROMETHEUS_QUERY_URL="http://${PROMETHEUS_HOST}:${PROMETHEUS_PORT}/api/v1/query?query=${PROMETHEUS_QUERY_ENCODED}"

CPU_UTIL_JSON=$(curl -s --max-time 3 "${PROMETHEUS_QUERY_URL}" 2>/dev/null)
CPU_DISPLAY=""

if [ $? -eq 0 ]; then
    # Extract CPU percentage - using .value[1] for simple query endpoint
    CPU_PERCENTAGE=$(echo "${CPU_UTIL_JSON}" | jq -r '.data.result[0].value[1]' 2>/dev/null)
    if [[ -n "${CPU_PERCENTAGE}" && "${CPU_PERCENTAGE}" != "null" ]]; then
        CPU_PERCENTAGE=$(printf "%.0f" "${CPU_PERCENTAGE}")
        
        # Set color based on usage
        COLOR=""
        if (( CPU_PERCENTAGE >= 80 )); then
            COLOR=" | color=red"
        elif (( CPU_PERCENTAGE >= 50 )); then
            COLOR=" | color=orange"
        fi
        
        CPU_DISPLAY="(${CPU_PERCENTAGE}%)"
    fi
fi

# Display count and CPU metrics in menu bar
echo "${ONLINE_COUNT}${CPU_DISPLAY}${COLOR}"
echo "---"

# Create temp file for storing device data
TEMP_FILE=$(mktemp)

# Get self info
SELF_HOST=$(echo "$TAILSCALE_STATUS" | jq -r '.Self.HostName')
SELF_DNS=$(echo "$TAILSCALE_STATUS" | jq -r '.Self.DNSName' | sed 's/\.$//')
SELF_OWNER=$(echo "$TAILSCALE_STATUS" | jq -r '.Self.UserID')
SELF_IP=$(echo "$TAILSCALE_STATUS" | jq -r '.Self.TailscaleIPs[0]')

# Add self device to temp file
echo "${SELF_OWNER}|${SELF_HOST}|${SELF_DNS}|true|${SELF_IP}|true|false|user" >> "$TEMP_FILE"

# Process each peer device
echo "$TAILSCALE_STATUS" | jq -c '.Peer | to_entries[]' 2>/dev/null | while read -r peer; do
    DEVICE=$(echo "$peer" | jq -r '.value')
    
    HOST_NAME=$(echo "$DEVICE" | jq -r '.HostName')
    DNS_NAME=$(echo "$DEVICE" | jq -r '.DNSName' | sed 's/\.$//')
    OWNER=$(echo "$DEVICE" | jq -r '.UserID')
    ONLINE=$(echo "$DEVICE" | jq -r '.Online')
    TAILSCALE_IPS=$(echo "$DEVICE" | jq -r '.TailscaleIPs[0]')
    IS_EXIT_NODE=$(echo "$DEVICE" | jq -r '.ExitNode')
    
    # Get tags for the device
    TAGS=$(echo "$DEVICE" | jq -r '.Tags[]? // empty' 2>/dev/null | sed 's/^tag://' | tr '\n' ',' | sed 's/,$//')
    
    # Check if device is on local network (check for private IP addresses only)
    CURADDR=$(echo "$DEVICE" | jq -r '.CurAddr' 2>/dev/null)
    IS_LOCAL="false"
    if [[ "$CURADDR" != "null" && "$CURADDR" != "" ]]; then
        # Extract just the IP part (before the colon)
        IP_ADDR=$(echo "$CURADDR" | cut -d':' -f1)
        # Check if it's a private/local IP address
        if [[ "$IP_ADDR" =~ ^192\.168\. ]] || [[ "$IP_ADDR" =~ ^10\. ]] || [[ "$IP_ADDR" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
            IS_LOCAL="true"
        fi
    fi
    
    # If device has tags, use first tag as owner, otherwise use UserID
    if [ -n "$TAGS" ]; then
        # Use first tag as the category
        TAG_OWNER=$(echo "$TAGS" | cut -d',' -f1)
        echo "${TAG_OWNER}|${HOST_NAME}|${DNS_NAME}|${ONLINE}|${TAILSCALE_IPS}|${IS_LOCAL}|${IS_EXIT_NODE}|tag" >> "$TEMP_FILE"
    else
        echo "${OWNER}|${HOST_NAME}|${DNS_NAME}|${ONLINE}|${TAILSCALE_IPS}|${IS_LOCAL}|${IS_EXIT_NODE}|user" >> "$TEMP_FILE"
    fi
done

# Get unique owners and their names
OWNERS=$(cat "$TEMP_FILE" | cut -d'|' -f1 | sort -u)

# Find the dimitriehoekstra owner ID first
MY_OWNER_ID=""
for OWNER_ID in $OWNERS; do
    OWNER_NAME=$(echo "$TAILSCALE_STATUS" | jq -r ".User.\"${OWNER_ID}\".DisplayName" 2>/dev/null)
    if [ "$OWNER_NAME" = "dimitriehoekstra" ]; then
        MY_OWNER_ID="$OWNER_ID"
        break
    fi
done

# Display "My Devices" first if found
if [ -n "$MY_OWNER_ID" ]; then
    # Check if there are any online devices for this user
    ONLINE_COUNT=$(grep "^${MY_OWNER_ID}|" "$TEMP_FILE" | grep "|true|" | wc -l | tr -d ' ')
    if [ "$ONLINE_COUNT" -gt 0 ]; then
        echo "My Devices"
        
        # Display devices for dimitriehoekstra (only online ones)
        grep "^${MY_OWNER_ID}|" "$TEMP_FILE" | while IFS='|' read -r OWNER HOST_NAME DNS_NAME ONLINE TAILSCALE_IP IS_LOCAL IS_EXIT_NODE TYPE; do
        # Skip offline devices
        if [ "$ONLINE" != "true" ]; then
            continue
        fi
        
        # Build display name - use DNS name if hostname is localhost
        if [ "$HOST_NAME" = "localhost" ]; then
            # Extract meaningful name from DNS name (e.g., google-pixel-8 from google-pixel-8.tailbfedba.ts.net)
            DEVICE_NAME=$(echo "$DNS_NAME" | cut -d'.' -f1)
            DISPLAY_NAME="$DEVICE_NAME"
        else
            DISPLAY_NAME="$HOST_NAME"
        fi
        
        # Add exit node indicator if applicable
        if [ "$IS_EXIT_NODE" = "true" ]; then
            DISPLAY_NAME="$DISPLAY_NAME [exit]"
        fi
        
        # Add local network indicator for devices actually on local network
        if [ "$IS_LOCAL" = "true" ]; then
            DISPLAY_NAME="$DISPLAY_NAME (local)"
        fi
        
        # Create the menu item with link
        echo "  $DISPLAY_NAME | href=https://${DNS_NAME}"
    done
    echo "---"
    fi
fi

# Display other owners/tags
for OWNER_ID in $OWNERS; do
    # Skip if this is the dimitriehoekstra owner we already displayed
    if [ "$OWNER_ID" = "$MY_OWNER_ID" ]; then
        continue
    fi
    
    # Check if there are any online devices for this owner/tag
    ONLINE_COUNT=$(grep "^${OWNER_ID}|" "$TEMP_FILE" | grep "|true|" | wc -l | tr -d ' ')
    if [ "$ONLINE_COUNT" -eq 0 ]; then
        continue
    fi
    
    # Check if this is a tag or user category
    FIRST_DEVICE_TYPE=$(grep "^${OWNER_ID}|" "$TEMP_FILE" | head -1 | cut -d'|' -f8)
    
    if [ "$FIRST_DEVICE_TYPE" = "tag" ]; then
        # For tags, just display the tag name
        echo "$OWNER_ID"
    else
        # For users, get the display name
        OWNER_NAME=$(echo "$TAILSCALE_STATUS" | jq -r ".User.\"${OWNER_ID}\".DisplayName" 2>/dev/null)
        
        if [ "$OWNER_NAME" == "null" ] || [ -z "$OWNER_NAME" ]; then
            OWNER_NAME="Unknown"
        fi
        
        echo "$OWNER_NAME"
    fi
    
    # Display devices for this owner/tag (only online ones)
    grep "^${OWNER_ID}|" "$TEMP_FILE" | while IFS='|' read -r OWNER HOST_NAME DNS_NAME ONLINE TAILSCALE_IP IS_LOCAL IS_EXIT_NODE TYPE; do
        # Skip offline devices
        if [ "$ONLINE" != "true" ]; then
            continue
        fi
        
        # Build display name - use DNS name if hostname is localhost
        if [ "$HOST_NAME" = "localhost" ]; then
            # Extract meaningful name from DNS name (e.g., google-pixel-8 from google-pixel-8.tailbfedba.ts.net)
            DEVICE_NAME=$(echo "$DNS_NAME" | cut -d'.' -f1)
            DISPLAY_NAME="$DEVICE_NAME"
        else
            DISPLAY_NAME="$HOST_NAME"
        fi
        
        # Add exit node indicator if applicable
        if [ "$IS_EXIT_NODE" = "true" ]; then
            DISPLAY_NAME="$DISPLAY_NAME [exit]"
        fi
        
        # Add local network indicator for devices actually on local network
        if [ "$IS_LOCAL" = "true" ]; then
            DISPLAY_NAME="$DISPLAY_NAME (local)"
        fi
        
        # Create the menu item with link
        echo "  $DISPLAY_NAME | href=https://${DNS_NAME}"
    done
    echo "---"
done

# Clean up temp file
rm -f "$TEMP_FILE"

# Add admin and monitoring options
echo "Tailscale Admin | href=https://login.tailscale.com/admin/machines"
if [ -n "$CPU_DISPLAY" ]; then
    echo "Prometheus UI | href=http://${PROMETHEUS_HOST}:${PROMETHEUS_PORT}"
    echo "Node Exporter | href=http://${PROMETHEUS_HOST}:9100/metrics"
fi