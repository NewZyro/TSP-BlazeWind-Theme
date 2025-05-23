#!/bin/bash
# PORTMASTER: cave.story-evo.zip, Cave Story-evo.sh

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
printf "\033c" > /dev/tty0
printf "\033c" > /dev/tty1

GAMEDIR=/$directory/ports/nxengine-evo
exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

# Check if settings.dat file doesn't exist
if [ ! -f "$GAMEDIR/conf/nxengine/settings.dat" ]; then
    # Determine which settings.dat file to use based on the display width
    if [ "$DISPLAY_WIDTH" -eq 1920 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.1920" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 960 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.960" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 1280 ] || [ "$DISPLAY_WIDTH" -eq 854 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.854" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 720 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.720" "$GAMEDIR/conf/nxengine/settings.dat"
    elif [ "$DISPLAY_WIDTH" -eq 480 ]; then
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.480" "$GAMEDIR/conf/nxengine/settings.dat"
    else
        # Default settings for other display widths
        mv -f "$GAMEDIR/conf/nxengine/settings.dat.640" "$GAMEDIR/conf/nxengine/settings.dat"
    fi

    # Remove any other settings.dat files
    rm -f "$GAMEDIR/conf/nxengine/settings.dat.*"
fi

bind_directories ~/.local/share/nxengine $GAMEDIR/conf/nxengine

export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "nxengine-evo" -c nxengine-evo.gptk &
./nxengine-evo

$ESUDO kill -9 $(pidof gptokeyb) & 
printf "\033c" >> /dev/tty1


