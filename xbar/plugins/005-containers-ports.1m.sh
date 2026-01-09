#!/bin/bash

# <xbar.title>Container & Port Monitor</xbar.title>
# <xbar.version>v1.1</xbar.version>
# <xbar.author>Dimitrie</xbar.author>
# <xbar.author.github>dimitrie</xbar.author.github>
# <xbar.desc>Monitor Docker/Podman containers and listening ports categorized by network exposure</xbar.desc>
# <xbar.dependencies>jq</xbar.dependencies>

# Full paths for binaries (xbar doesn't have full PATH)
PODMAN="/opt/homebrew/bin/podman"
DOCKER="/opt/homebrew/bin/docker"
JQ="/opt/homebrew/bin/jq"
TAILSCALE="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# Initialize port category outputs (using strings for bash 3.x compat)
PORTS_LOCALHOST=""
PORTS_TAILNET=""
PORTS_LOCAL=""
PORTS_ALL=""
COUNT_LOCALHOST=0
COUNT_TAILNET=0
COUNT_LOCAL=0
COUNT_ALL=0

# Track seen ports to avoid duplicates
SEEN_PORTS=""

# Initialize container tracking
CONTAINER_COUNT=0
CONTAINER_OUTPUT=""

# Check for container runtimes
HAS_PODMAN=false
HAS_DOCKER=false

if [ -x "$PODMAN" ]; then
    HAS_PODMAN=true
fi

if [ -x "$DOCKER" ]; then
    # Check if docker daemon is actually running
    if $DOCKER info &>/dev/null 2>&1; then
        HAS_DOCKER=true
    fi
fi

# Function to format port mappings from JSON
format_ports() {
    local ports_json="$1"
    if [ -z "$ports_json" ] || [ "$ports_json" = "null" ] || [ "$ports_json" = "[]" ]; then
        echo ""
        return
    fi

    # Parse JSON array of port objects and format nicely
    echo "$ports_json" | $JQ -r '
        if type == "array" then
            [.[] | "\(.host_ip // "*"):\(.host_port)->\(.container_port)/\(.protocol // "tcp")"] | join(", ")
        else
            .
        end
    ' 2>/dev/null
}

# Function to get containers from a runtime
get_containers() {
    local runtime="$1"
    local containers

    if [ "$runtime" = "podman" ]; then
        containers=$($PODMAN ps --format json 2>/dev/null)
    else
        containers=$($DOCKER ps --format json 2>/dev/null)
    fi

    if [ -z "$containers" ] || [ "$containers" = "[]" ] || [ "$containers" = "null" ]; then
        return
    fi

    # Handle both array format (podman) and line-by-line format (docker)
    if echo "$containers" | $JQ -e 'type == "array"' &>/dev/null; then
        # Podman format: single JSON array
        echo "$containers" | $JQ -r '.[] | "\(.Names[0] // .Names)|\(.Image)|\(.Ports | tojson)"' 2>/dev/null
    else
        # Docker format: one JSON object per line
        echo "$containers" | $JQ -r '"\(.Names)|\(.Image)|\(.Ports)"' 2>/dev/null
    fi
}

# Function to extract first port URL from ports JSON
get_port_url() {
    local ports_json="$1"
    if [ -z "$ports_json" ] || [ "$ports_json" = "null" ] || [ "$ports_json" = "[]" ]; then
        echo ""
        return
    fi

    # Extract first port mapping and build URL
    local host_ip host_port
    host_ip=$(echo "$ports_json" | $JQ -r '.[0].host_ip // "127.0.0.1"' 2>/dev/null)
    host_port=$(echo "$ports_json" | $JQ -r '.[0].host_port // empty' 2>/dev/null)

    if [ -n "$host_port" ]; then
        # Use localhost for 127.0.0.1, otherwise use the actual IP
        if [ "$host_ip" = "127.0.0.1" ] || [ "$host_ip" = "0.0.0.0" ] || [ "$host_ip" = "*" ]; then
            echo "http://localhost:${host_port}"
        else
            echo "http://${host_ip}:${host_port}"
        fi
    fi
}

# Collect containers from both runtimes
if [ "$HAS_PODMAN" = true ]; then
    while IFS='|' read -r name image ports_json; do
        [ -z "$name" ] && continue
        CONTAINER_COUNT=$((CONTAINER_COUNT + 1))
        # Truncate long image names
        short_image=$(echo "$image" | sed 's|.*/||' | cut -c1-30)
        # Format ports nicely
        formatted_ports=$(format_ports "$ports_json")
        port_url=$(get_port_url "$ports_json")

        if [ -n "$formatted_ports" ]; then
            if [ -n "$port_url" ]; then
                CONTAINER_OUTPUT+="$name ($short_image) - $formatted_ports | href=$port_url\n"
            else
                CONTAINER_OUTPUT+="$name ($short_image) - $formatted_ports\n"
            fi
        else
            CONTAINER_OUTPUT+="$name ($short_image)\n"
        fi
        # Add submenu items for shell and logs
        CONTAINER_OUTPUT+="--Open Shell | terminal=true shell=$PODMAN param1=exec param2=-it param3=$name param4=sh\n"
        CONTAINER_OUTPUT+="--View Logs | terminal=true shell=$PODMAN param1=logs param2=-f param3=$name\n"
    done < <(get_containers "podman")
fi

if [ "$HAS_DOCKER" = true ]; then
    while IFS='|' read -r name image ports; do
        [ -z "$name" ] && continue
        CONTAINER_COUNT=$((CONTAINER_COUNT + 1))
        # Truncate long image names
        short_image=$(echo "$image" | sed 's|.*/||' | cut -c1-30)
        if [ -n "$ports" ] && [ "$ports" != "null" ] && [ "$ports" != "" ]; then
            # Try to extract port for URL (docker format is different)
            first_port=$(echo "$ports" | grep -oE '[0-9]+->|:[0-9]+' | head -1 | tr -d ':' | tr -d '->')
            if [ -n "$first_port" ]; then
                CONTAINER_OUTPUT+="$name ($short_image) - $ports | href=http://localhost:$first_port\n"
            else
                CONTAINER_OUTPUT+="$name ($short_image) - $ports\n"
            fi
        else
            CONTAINER_OUTPUT+="$name ($short_image)\n"
        fi
        # Add submenu items for shell and logs
        CONTAINER_OUTPUT+="--Open Shell | terminal=true shell=$DOCKER param1=exec param2=-it param3=$name param4=sh\n"
        CONTAINER_OUTPUT+="--View Logs | terminal=true shell=$DOCKER param1=logs param2=-f param3=$name\n"
    done < <(get_containers "docker")
fi

# Get listening ports first (needed to identify incoming connections)
LISTENING_PORTS=$(lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | awk 'NR>1 {print $(NF-1)}' | grep -oE ':[0-9]+' | tr -d ':' | sort -u | tr '\n' '|' | sed 's/|$//')

# Collect incoming connections (ESTABLISHED connections TO our listening ports)
INCOMING_OUTPUT=""
COUNT_INCOMING=0
SEEN_CONNECTIONS=""

ESTABLISHED_OUTPUT=$(lsof -i -nP 2>/dev/null | grep ESTABLISHED)
while IFS= read -r line; do
    [ -z "$line" ] && continue

    COMMAND=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $NF}')

    # Parse connection: local->remote format
    # Format is typically: IP:PORT->IP:PORT
    if [[ "$NAME" == *"->"* ]]; then
        LOCAL_PART=$(echo "$NAME" | cut -d'>' -f1 | tr -d '-')
        REMOTE_PART=$(echo "$NAME" | cut -d'>' -f2)
    else
        continue
    fi

    # Extract ports and IPs
    LOCAL_PORT=$(echo "$LOCAL_PART" | rev | cut -d: -f1 | rev)
    REMOTE_IP=$(echo "$REMOTE_PART" | rev | cut -d: -f2- | rev | sed 's/\[//g;s/\]//g')

    # Only show if local port is a LISTENING port (= incoming connection)
    if ! echo "|${LISTENING_PORTS}|" | grep -q "|${LOCAL_PORT}|"; then
        continue
    fi

    # Skip localhost connections
    if [ "$REMOTE_IP" = "127.0.0.1" ] || [ "$REMOTE_IP" = "::1" ] || [[ "$REMOTE_IP" =~ ^127\. ]]; then
        continue
    fi

    # Skip duplicates
    KEY="${REMOTE_IP}_${LOCAL_PORT}"
    if echo "$SEEN_CONNECTIONS" | grep -q "|${KEY}|"; then
        continue
    fi
    SEEN_CONNECTIONS="${SEEN_CONNECTIONS}|${KEY}|"

    # Format entry: Remote IP -> Local Port (Process)
    ENTRY=$(printf "%-15s -> %-6s %-12s" "$REMOTE_IP" "$LOCAL_PORT" "($COMMAND)")
    INCOMING_OUTPUT="${INCOMING_OUTPUT}${ENTRY} | font=Monaco size=12 trim=false\n"
    COUNT_INCOMING=$((COUNT_INCOMING + 1))
done <<< "$ESTABLISHED_OUTPUT"

# Collect Tailnet peers
TAILNET_PEERS=""
COUNT_PEERS=0

if [ -x "$TAILSCALE" ]; then
    TAILSCALE_STATUS=$($TAILSCALE status --json 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$TAILSCALE_STATUS" ]; then
        # Get online peers (exclude self and nr-experiment tagged devices)
        while IFS='|' read -r hostname ip; do
            [ -z "$hostname" ] && continue
            ENTRY=$(printf "%-20s %s" "$hostname" "$ip")
            TAILNET_PEERS="${TAILNET_PEERS}${ENTRY} | font=Monaco size=12 trim=false\n"
            COUNT_PEERS=$((COUNT_PEERS + 1))
        done < <(echo "$TAILSCALE_STATUS" | $JQ -r '
            .Peer | to_entries[] | .value |
            select(.Online == true) |
            select((.Tags // []) | map(. == "tag:nr-experiment") | any | not) |
            "\(.HostName)|\(.TailscaleIPs[0])"
        ' 2>/dev/null)
    fi
fi

# Function to categorize an IP address
categorize_ip() {
    local ip="$1"

    # All interfaces
    if [ "$ip" = "*" ] || [ "$ip" = "0.0.0.0" ] || [ "$ip" = "::" ]; then
        echo "all"
        return
    fi

    # Localhost
    if [ "$ip" = "127.0.0.1" ] || [ "$ip" = "::1" ] || [[ "$ip" =~ ^127\. ]]; then
        echo "localhost"
        return
    fi

    # Tailnet (100.x.x.x range used by Tailscale)
    if [[ "$ip" =~ ^100\. ]]; then
        echo "tailnet"
        return
    fi

    # Local network (private IP ranges)
    if [[ "$ip" =~ ^192\.168\. ]] || [[ "$ip" =~ ^10\. ]] || [[ "$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
        echo "local"
        return
    fi

    # IPv6 link-local
    if [[ "$ip" =~ ^fe80: ]]; then
        echo "local"
        return
    fi

    # Default to all interfaces for unknown
    echo "all"
}

# Get listening ports using lsof
# Format: COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
LSOF_OUTPUT=$(lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | tail -n +2)

# Parse lsof output and categorize ports
while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Parse the line
    COMMAND=$(echo "$line" | awk '{print $1}')
    PID=$(echo "$line" | awk '{print $2}')
    # Get the NAME field (second to last) - skip the (LISTEN) part
    NAME=$(echo "$line" | awk '{print $(NF-1)}')

    # Extract IP and port from NAME (format: IP:PORT or *:PORT or [::1]:PORT)
    # Remove brackets for IPv6
    CLEAN_NAME=$(echo "$NAME" | sed 's/\[//g;s/\]//g')
    IP=$(echo "$CLEAN_NAME" | rev | cut -d: -f2- | rev)
    PORT=$(echo "$CLEAN_NAME" | rev | cut -d: -f1 | rev)

    # Skip if we've seen this exact port+process combo (bash 3.x compatible)
    KEY="${PORT}_${COMMAND}"
    if echo "$SEEN_PORTS" | grep -q "|${KEY}|"; then
        continue
    fi
    SEEN_PORTS="${SEEN_PORTS}|${KEY}|"

    # Categorize based on IP
    CATEGORY=$(categorize_ip "$IP")

    # Format entry with columns: port (left-aligned 6), process name (left-aligned)
    ENTRY=$(printf "%-6s  %-15s" "$PORT" "$COMMAND")

    # Build URL based on category
    case "$CATEGORY" in
        localhost)
            URL="http://localhost:${PORT}"
            PORTS_LOCALHOST="${PORTS_LOCALHOST}${ENTRY} | href=${URL} font=Monaco size=12 trim=false\n"
            COUNT_LOCALHOST=$((COUNT_LOCALHOST + 1))
            ;;
        tailnet)
            URL="http://${IP}:${PORT}"
            PORTS_TAILNET="${PORTS_TAILNET}${ENTRY} | href=${URL} font=Monaco size=12 trim=false\n"
            COUNT_TAILNET=$((COUNT_TAILNET + 1))
            ;;
        local)
            URL="http://${IP}:${PORT}"
            PORTS_LOCAL="${PORTS_LOCAL}${ENTRY} | href=${URL} font=Monaco size=12 trim=false\n"
            COUNT_LOCAL=$((COUNT_LOCAL + 1))
            ;;
        all)
            URL="http://localhost:${PORT}"
            PORTS_ALL="${PORTS_ALL}${ENTRY} | href=${URL} font=Monaco size=12 trim=false\n"
            COUNT_ALL=$((COUNT_ALL + 1))
            ;;
    esac
done <<< "$LSOF_OUTPUT"

# Calculate total unique ports
TOTAL_PORTS=$((COUNT_LOCALHOST + COUNT_TAILNET + COUNT_LOCAL + COUNT_ALL))

# Menu bar display
echo "🔌 ${CONTAINER_COUNT}(${TOTAL_PORTS})"
echo "---"

# Containers section
if [ "$HAS_PODMAN" = true ] || [ "$HAS_DOCKER" = true ]; then
    RUNTIME_INFO=""
    if [ "$HAS_PODMAN" = true ] && [ "$HAS_DOCKER" = true ]; then
        RUNTIME_INFO=" (Podman + Docker)"
    elif [ "$HAS_PODMAN" = true ]; then
        RUNTIME_INFO=" (Podman)"
    else
        RUNTIME_INFO=" (Docker)"
    fi

    echo "Containers${RUNTIME_INFO}"
    if [ "$CONTAINER_COUNT" -eq 0 ]; then
        echo "No running containers | color=gray"
    else
        echo -e "$CONTAINER_OUTPUT" | grep -v '^$'
    fi
else
    echo "Containers"
    echo "No container runtime found | color=gray"
fi

echo "---"

# Incoming Connections section
echo "Incoming Connections (${COUNT_INCOMING})"
if [ $COUNT_INCOMING -eq 0 ]; then
    echo "None | color=gray"
else
    echo -e "$INCOMING_OUTPUT" | grep -v '^$'
fi

echo "---"

# Ports: All Interfaces (most exposed, show first)
echo "Ports: All Interfaces (${COUNT_ALL})"
if [ $COUNT_ALL -eq 0 ]; then
    echo "None | color=gray"
else
    echo -e "$PORTS_ALL" | grep -v '^$'
fi

echo "---"

# Ports: Local Network
echo "Ports: Local Network (${COUNT_LOCAL})"
if [ $COUNT_LOCAL -eq 0 ]; then
    echo "None | color=gray"
else
    echo -e "$PORTS_LOCAL" | grep -v '^$'
fi

echo "---"

# Ports: Tailnet
echo "Ports: Tailnet (${COUNT_TAILNET})"
if [ $COUNT_TAILNET -eq 0 ]; then
    echo "None | color=gray"
else
    echo -e "$PORTS_TAILNET" | grep -v '^$'
fi

echo "---"

# Ports: Localhost Only (least exposed, show last)
echo "Ports: Localhost Only (${COUNT_LOCALHOST})"
if [ $COUNT_LOCALHOST -eq 0 ]; then
    echo "None | color=gray"
else
    echo -e "$PORTS_LOCALHOST" | grep -v '^$'
fi

echo "---"

# Tailnet Peers section
echo "Tailnet Peers Online (${COUNT_PEERS})"
if [ $COUNT_PEERS -eq 0 ]; then
    echo "None | color=gray"
else
    echo -e "$TAILNET_PEERS" | grep -v '^$'
fi

echo "---"
echo "Refresh | refresh=true"
