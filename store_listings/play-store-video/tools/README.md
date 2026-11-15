# Promo video tools

These scripts built `../snake-classic-promo-landscape.mp4` (1920x1080, for Play and YouTube), `../snake-classic-promo.mp4` (1080x1920, for Shorts) and `../youtube-thumbnail-1280x720.png`. Raw recordings are not committed; record new ones into this folder.

## 1. Record

- Device: the A24 (`RR8W901JDRL`). Other sessions share it, so never restart adb or tcpip.
- Install the demo build from the `demo/autopilot` branch (never merge it): `flutter run --release --dart-define=DEMO_AUTOPILOT=true`. The snake steers itself, ads are off, and scores and stats are not posted. Reinstall the normal build when you're done.
- `record_modes.ps1` records Zen, Speed, Multi-Food and Power-Up Madness. `record_screens.ps1` records Daily, Season, Ranks, Store, Power-ups and Versus. Tap coordinates are for the A24 at 1080x2340. Pass `-d <serial>` for another device.
- Recording uses `screenrecord --bit-rate 8000000 --time-limit 178`, up to 180 s per clip. Stop with `pkill -INT screenrecord`, or the mp4 will not play.

## 2. Pick the cuts

`scenes.json` lists the segments: `src` clip, `a`/`b` trim in seconds, and `chip`/`color`/`title`/`sub` for the caption.

## 3. Render

```
FF=<python>/site-packages/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe
python render_landscape.py $FF scenes.json out-landscape.mp4
python render.py           $FF scenes.json out-portrait.mp4
python thumb.py
```

Both renderers do the following:

- Pillow draws the background, phone frame, mask, captions and intro and outro cards as PNGs.
- One ffmpeg filter graph trims and concats the clips (`fps=30` first, because screenrecord is variable frame rate), masks the phone, overlays fading captions and a progress bar, and adds the intro and outro.
- The music is `assets/audio/lb/music/run_loop_140bpm.wav`.
- Output is H.264 crf 19, 30 fps, AAC 192k.

## 4. Publish

- Upload the landscape video to YouTube, public or unlisted, with ads off and no age restriction.
- Paste the `youtube.com/watch?v=` URL (not `/shorts/`) into Play Console > Main store listing > Video.
- The Play app plays the video in a 16:9 slot, which is why a portrait video shows with empty bars on both sides.
