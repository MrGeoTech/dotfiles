#!/bin/bash

# Define paths for wallpapers
MORNING_WALLPAPER="/home/mrgeotech/.config/hypr/tropic_island_morning.jpg"
DAY_WALLPAPER="/home/mrgeotech/.config/hypr/tropic_island_day.jpg"
EVENING_WALLPAPER="/home/mrgeotech/.config/hypr/tropic_island_evening.jpg"
NIGHT_WALLPAPER="/home/mrgeotech/.config/hypr/tropic_island_night.jpg"

# Function to get the current wallpaper based on the hour
get_wallpaper() {
    local hr=$(date +%H)
    if (( hr > 7 && hr < 11 )); then
        echo "$MORNING_WALLPAPER"
    elif (( hr >= 11 && hr < 17 )); then
        echo "$DAY_WALLPAPER"
    elif (( hr >= 17 && hr < 19 )); then
        echo "$EVENING_WALLPAPER"
    else
        echo "$NIGHT_WALLPAPER"
    fi
}

# Initialize current wallpaper variable
current_wallpaper=""

sleep 1

# Apply the correct wallpaper at startup
new_wallpaper=$(get_wallpaper)
if [[ "$current_wallpaper" != "$new_wallpaper" ]]; then
    hyprctl hyprpaper wallpaper ",$new_wallpaper"
    current_wallpaper="$new_wallpaper"
fi

# Start loop to check and update wallpaper hourly
while true; do
    # Get the new wallpaper based on the current time
    new_wallpaper=$(get_wallpaper)

    # Check if the wallpaper needs to be updated
    if [[ "$current_wallpaper" != "$new_wallpaper" ]]; then
        hyprctl hyprpaper wallpaper ",$new_wallpaper"
        current_wallpaper="$new_wallpaper"
    fi

    # Sleep for a minute before checking again
    sleep 60
done
