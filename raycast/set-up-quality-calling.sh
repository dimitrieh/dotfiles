#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set Up Quality Calling
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Set correct sound input and output devices
# @raycast.author dimitrieh
# @raycast.authorURL https://raycast.com/dimitrieh

osascript <<END
if application "Rode Connect" is running then
    return "RUNNING"
else
    tell application "Rode Connect" to activate
    delay 10
end if
END
if SwitchAudioSource -t output -u 00-C5-85-6C-08-8C:output && SwitchAudioSource -t input -u RodeConnectAudioDevice_UID ; then
    echo "Command succeeded"
else
    osascript -e 'display notification "Ideal sound devices could not be connected. Connect them and try again." with title "Failed to connect ideal sound devices" sound name "Sosumi"'
fi
osascript -e 'display notification "Ideal sound devices Connected" sound name "Blow"'
