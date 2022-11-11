#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Launch Polybar, using default config location ~/.config/polybar/config
polybar mybar >>/tmp/polybar1.log 2>&1 &

echo "Polybar launched..."
