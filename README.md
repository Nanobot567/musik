# musik
a music player for playdate

<img src ="https://img.shields.io/tokei/lines/github/nanobot567/musik"><img src="https://img.shields.io/github/downloads/nanobot567/musik/total"><img src="https://img.shields.io/github/v/release/nanobot567/musik">

<div style="align: center;"><a href="https://codeberg.org/nanobot567/musik/releases/latest"><img src="https://github.com/Nanobot567/tAoHtH/blob/main/readme-graphics/Playdate-badge-download.png"></a></img></div>

## FAQ

### So how do I get this onto my Playdate?
Visit [this page](https://help.play.date/games/sideloading/) on Playdate's website for information on how to sideload.

### Why though?
When I first created musik, there were no public music players out for playdate (except for Audition, but it wasn't made to be an iPod type music player), so I decided to make one!

### How do I use this thing???

Check out the [user manual](https://github.com/Nanobot567/musik/blob/main/MANUAL.md)!

### I just found a bug, where do I report it?
Head to the "issues" tab on Github and file a bug report.

### Why aren't my MP3s playing correctly?
Try dragging them into [Audacity](https://audacityteam.org/) and re-exporting them as MP3s with no metadata.

### Sometimes an MP3 plays back slower/faster than the rest.
If one of your MP3s has a different audio rate than the others, it can play back slower or faster than the others.

To fix this, you can either (for all of your MP3s if you're unsure, or for the one MP3 that has a different play rate):

- drag your MP3 into something like [Audacity](https://audacityteam.org/)
- change the project rate (it should be in the bottom left corner) to 44100 Hz (or whichever you would like)
- re-export the MP3

or...

- change the sample rate with ffmpeg: `ffmpeg -i input.mp3 -ar 44100 output.mp3`

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
