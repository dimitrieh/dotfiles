#!/bin/bash

# Required parameters for xbar:
# <xbar.title>CPU Monitor</xbar.title>
# <xbar.version>1.2</xbar.version> # Updated version
# <xbar.author>Your Name</xbar.author>
# <xbar.author.github>yourgithub</xbar.author.github>
# <xbar.desc>Displays CPU usage from remote Prometheus instance with compact sparkline.</xbar.desc>
# <xbar.image>iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAABHklEQVRIx+WUTysFQRyFny4MihR5KBRXm1Qc0oT+A6hD8QkKHmE71JMUeCgVwUK+Cq6FwM7tJ5zJ2ZzMZu95eLwz53zPve8kI0lSRlQk+Q00oTjLqP1zQ9fI0l6Ew45I4/vLzWjWwF6f1gA2+l01B/19fW0kMvlmQAnl/f39+8D2o+w5W42y8vLq4D+K51O7QGkH2jY7vL5fL/y8vLyBng9L0k7kGg02n0B3i89w57j8dgOAEy32x0A/H6/P+h2uyg9h/4LwIeHhxWAw+FgpSgp/7Q0+2RkZATr6+v0kEqlx+Xl5dYJvR4dHv/Dw8PDYgDgeDx+JvG422yWlZU1uLy8/Gpgv9+fA8+p6UeA2dnZ24AvDweDg3g8fgHg8/l8B3x+fr6o+62urhIUCgUGfX194+np6fE8L0mS0vM0x3xOkgcTj/dGURRA+4G1f+0g6U3n+6z+mYjS9oSDP4D2EPRkO8+RJI1bW1ubB+2jL0lSdm0y/gAAAABJRU5ErkJggg==</xbar.image>
# <xbar.dependencies>curl, jq</xbar.dependencies>
# <xbar.timeout>10</xbar.timeout> # Increase timeout for Prometheus API call

# --- User Configuration ---
# Replace with the actual Tailscale IP or MagicDNS name of your remote Mac
PROMETHEUS_HOST="100.86.115.50" # <--- CONFIRM THIS IS YOUR REMOTE MAC'S TAILSCALE IP
PROMETHEUS_PORT="9090" # Prometheus UI port
NODE_EXPORTER_PORT="9100" # Node Exporter metrics port # Not directly used for query, but for dropdown link

# --- Sparkline Configuration for Compact Graph ---
GRAPH_WIDTH=8 # Reduced width to be more compact (try 5, 6, 7, or 8)
TIME_RANGE="1m" # Shortened time range for a more immediate view
STEP_INTERVAL="10s" # Adjusted step interval to get fewer, but still distinct, points over 1m

# --- Script Logic ---

# URL-encode the PromQL query for sparkline data
PROMETHEUS_RANGE_QUERY_ENCODED="100%20-%20%28avg%20by%20%28instance%29%20%28rate%28node_cpu_seconds_total%7Bmode%3D%22idle%22%7D%5B5m%5D%29%29%20%2A%20100%29"

# Calculate current timestamp in seconds
END_TIME=$(date +%s)
# Calculate start timestamp in seconds (subtract TIME_RANGE in seconds)
# Bash doesn't do date arithmetic well, so we'll rely on the Prometheus API 'range' endpoint
START_TIME=$((END_TIME - $(echo ${TIME_RANGE} | sed 's/m/*60/' | bc -l))) # Use bc -l for float support if needed, though for integer seconds it's fine

PROMETHEUS_RANGE_QUERY_URL="http://${PROMETHEUS_HOST}:${PROMETHEUS_PORT}/api/v1/query_range?query=${PROMETHEUS_RANGE_QUERY_ENCODED}&end=${END_TIME}&start=${START_TIME}&step=${STEP_INTERVAL}"

CPU_UTIL_JSON=$(curl -s --max-time 10 "${PROMETHEUS_RANGE_QUERY_URL}" 2>/dev/null)

if [ $? -ne 0 ]; then
    # Hide the plugin when there's no connection
    exit 0
fi

# Extract the most recent value for the percentage display
CPU_PERCENTAGE=$(echo "${CPU_UTIL_JSON}" | jq -r '.data.result[0].values[-1][1]' 2>/dev/null)
if [[ -z "${CPU_PERCENTAGE}" || "${CPU_PERCENTAGE}" == "null" ]]; then
    # Hide the plugin when there's no data
    exit 0
fi
CPU_PERCENTAGE=$(printf "%.0f" "${CPU_PERCENTAGE}")


# Extract all historical values for the sparkline
CPU_VALUES_RAW=$(echo "${CPU_UTIL_JSON}" | jq -r '.data.result[0].values[][1]' 2>/dev/null)

CPU_VALUES=()
while IFS= read -r value; do
    if [[ -n "$value" && "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        CPU_VALUES+=($(printf "%.0f" "${value}"))
    fi
done <<< "${CPU_VALUES_RAW}"

if [ ${#CPU_VALUES[@]} -eq 0 ]; then
    # Hide the plugin when there's no valid data
    exit 0
fi

# Sparkline generation logic
SPARKLINE_CHARS=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")
NUM_SPARK_LEVELS=${#SPARKLINE_CHARS[@]} # 8 levels
MAX_VAL=100 # CPU usage is 0-100%

SPARKLINE_STRING=""
# Only use the last GRAPH_WIDTH values for the sparkline to control its displayed length
LAST_N_VALUES=${CPU_VALUES[@]: -$GRAPH_WIDTH}

for val in ${LAST_N_VALUES[@]}; do
    CLAMPED_VAL=$(( val > MAX_VAL ? MAX_VAL : val ))
    INDEX=$(( CLAMPED_VAL * (NUM_SPARK_LEVELS - 1) / MAX_VAL ))
    SPARKLINE_STRING+="${SPARKLINE_CHARS[$INDEX]}"
done


# Set color based on usage (current percentage)
COLOR=""
if (( CPU_PERCENTAGE >= 80 )); then
  COLOR="color=red"
elif (( CPU_PERCENTAGE >= 50 )); then
  COLOR="color=orange"
fi

# Output for xbar menu bar
echo "${CPU_PERCENTAGE}% ${SPARKLINE_STRING} | ${COLOR}"
echo "---"
echo "Refresh | refresh=true"
echo "Prometheus UI | href=http://${PROMETHEUS_HOST}:${PROMETHEUS_PORT}"
echo "Node Exporter | href=http://${PROMETHEUS_HOST}:${NODE_EXPORTER_PORT}/metrics"
echo "---"
echo "Sparkline config:"
echo "  Width: ${GRAPH_WIDTH} characters"
echo "  Range: ${TIME_RANGE}"
echo "  Step: ${STEP_INTERVAL}"
echo "  Last value used: ${CPU_PERCENTAGE}%"
echo "---"
echo "Prometheus API Query URL (for debugging):"
echo "${PROMETHEUS_RANGE_QUERY_URL} | trim=false"
