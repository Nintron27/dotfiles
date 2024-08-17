#!/bin/sh

# Terminate already running bar instances
pkill polybar

# Launch Polybar
polybar mybar &
