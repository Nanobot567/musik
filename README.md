# musik
a music player for playdate

<img src ="https://img.shields.io/tokei/lines/github/nanobot567/musik"><img src="https://img.shields.io/github/downloads/nanobot567/musik/total"><img src="https://img.shields.io/github/v/release/nanobot567/musik">

<a href="https://github.com/nanobot567/musik/releases/latest"><div style="align: center;"><img src="https://github.com/Nanobot567/tAoHtH/blob/main/readme-graphics/Playdate-badge-download.png"></img></div></a>

## FAQ

### So how do I get this onto my Playdate?
Visit [this page](https://help.play.date/games/sideloading/) on Playdate's website for information on how to sideload.

### Why though?
There are no public music players out for playdate yet (except for Audition, but it wasn't made to be a music player), so I decided to make one.

### I just found a bug, where do I report it?
Head to the "issues" tab on Github and file a bug report.

### Why aren't my MP3s playing correctly?
Try dragging them into [Audacity](https://audacityteam.org/) and re-exporting them as MP3s with no metadata.

### My Playdate crashes when I try to skip a song...

Yeah, I don't exactly know what is going on there. I think that it's a buffer underflow issue, so as a temporary solution I have made it so you can only skip a song when it has been playing for 5.5 seconds or more, which should resolve most crashes.

## Controls

### Cranking

Cranking changes the play rate of the file. Un-docking it shows the current play rate, and docking hides it.

### When in the "files" screen:

- Up/Down - controls the file selection cursor
- Right/Left - skip +4 or -4 in the file list
- A - play song / enter folder
- B - up folder (or if at root of filesystem, you will go to "now playing")

### When in the "now playing" screen:
- A - play / pause song
- B - exit to files screen
- Right/Left - seek forward / backward 5 seconds (this works best when the song is paused)
- Up/Down - skip to previous/next song
    NOTE: skipping to the next song has a chance of causing your playdate to crash. See above for explanation.

In the system menu, there is an options menu item titled "mode". This controls the current playing mode. The options are:
- `none` - plays the song then stops
- `shuffle` - plays a random song in the current folder
- `loop folder` - plays all of the songs in the folder, then loops back to the top and continues
- `loop one` - loops one song

### Settings

Other settings can be accessed via the "settings" menu item. Here you will find various settings such as toggling dark mode and the 24 hour clock.

- Up/Down - select setting
- A - toggle setting
- B - return to last screen

## Adding songs

To add songs to musik, follow these steps:
1. Put your Playdate into data disk mode (you can do this by opening settings and navigating to `settings / system / reboot to data disk`)
2. Connect your Playdate to your computer and open the `PLAYDATE` drive
3. Navigate to `/Data/user.*****.musik/music/`
4. Drag and drop your MP3s / PDAs!

    NOTE: Musik also supports folders, so long file names shouldn't be a problem...? (Let me know if it is and I'll see what I can do)

<!--

upon a farmer's land
a horse removes a grain of sand
from the beach of the human race
and goes back to its home base

the humans know that something's off
but they don't know what, so they shrug it off
one badger, though, follows its trail
walks for hours and hours to no avail

until there it was, surrounded by dead trees and grass
but the badger stays hidden, as that day could be his last
when he stared into its eyes where fires burned
suddenly he knew horse the horse will return

-->