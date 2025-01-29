# musik user manual

## Controls

### When in the "files" screen:

- Up/Down - controls the file selection cursor
- Right/Left - skip +4 or -4 in the file list
    - if left is pressed at the top of the file list, you will be sent up a folder.
- A - play song / enter folder
- B - up folder (or if at root of filesystem, you will go to "now playing")

### When in the "now playing" screen:
- A - play / pause song
- B - exit to files screen
- (Up / Left) / (Down / Right) - skip to previous/next song

> note: if you would like to change the volume without opening the Playdate menu, hold down `MENU` and press d-pad left or right!

In the system menu, there is an options menu item titled "mode". This controls the current playing mode. The options are:
- `none` - plays the song then stops
- `shuffle` - plays a random song in the current folder
- `loop folder` - plays all of the songs in the folder, then loops back to the top and continues
- `loop one` - loops one song
- `queue` - enters queue mode. more info on queue mode below.

### Queue mode

In queue mode, you can queue up songs to be played. Shuffles through songs in the last folder once the queue list is empty.

Controls:
- A - add song to queue (can be done multiple times for one song)
- B on italicised song - remove song from queue
- B on regular/bolded song - play queue (when in `/music/` directory) / up folder (any other directory)

Exiting queue mode (by going to 'now playing' screen) will switch the mode back to 'none' if no songs were selected.

### Settings

Other settings can be accessed via the "settings" menu item. Here you will find various settings such as toggling dark mode and the 24 hour clock.

- Up/Down - select setting
- A - toggle setting
- B - return to last screen

## Adding songs

To add songs to musik, follow these steps:
1. Put your Playdate into data disk mode (you can do this by opening settings and navigating to `settings / system / reboot to data disk`)
2. Connect your Playdate to your computer and open the `PLAYDATE` drive
3. Navigate to `/Data/user.*****.musik/music/` or `/Data/user.*****.com.nano.musik/music/`
4. Drag and drop your MP3s / PDAs!

    NOTE: Musik also supports folders, so long file names shouldn't be a problem...? (Let me know if it is and I'll see what I can do)
