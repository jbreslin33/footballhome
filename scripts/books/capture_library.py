#!/usr/bin/env python3
"""📚 Capture whole Coach Viewer books from the owner's phone over adb (mig 1928).

For each title, in order: find it in My Library, open it, close the All
Pages strip if it's open, go to page 1, then screenshot every page.  The
"N / total" counter is read off each screenshot (page_counter.py) and a page
is only saved once the counter says it is the page we want, so a missed or
doubled tap can't shift the numbering.  Then back to the library and load the
book into the DB (load_book.py).  Every page is kept.

  python3 scripts/books/capture_library.py titles.txt     # one title per line
Pages land in ~/football-data/books/<slug>/raw/pNNN.png (never git).
"""
import io, os, re, subprocess, sys, time, html
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import page_counter

ADB = os.path.expanduser("~/fh-android/sdk/platform-tools/adb")
BOOKS = os.path.expanduser("~/football-data/books")
NEXT, PREV, BACK, ALLPAGES = (992, 2115), (846, 2115), (94, 173), (99, 2110)

def adb(*a, out=False):
    r = subprocess.run([ADB, *a], capture_output=True)
    return r.stdout if out else r.returncode

def tap(xy): adb("shell", "input", "tap", str(xy[0]), str(xy[1]))
def swipe(y1, y2, ms=300): adb("shell", "input", "swipe", "540", str(y1), "540", str(y2), str(ms))
PHONE_FILE = os.path.join(BOOKS, "phone.txt")   # "ip:port" of the phone's Wireless debugging

def reconnect():
    """Wait (up to 2 h) for the phone to come back: adb connect to the
    ip:port in phone.txt (owner can update it) until a device answers."""
    for i in range(720):
        if b"\tdevice" in adb("devices", out=True): return
        try: adb("connect", open(PHONE_FILE).read().strip())
        except FileNotFoundError: pass
        if i % 30 == 0: print(time.strftime("%H:%M:%S ") + "waiting for the phone (adb)…", flush=True)
        time.sleep(10)
    raise RuntimeError("phone never came back")

def shot():
    for _ in range(6):
        b = adb("exec-out", "screencap", "-p", out=True)
        try: return Image.open(io.BytesIO(b)), b
        except Exception: time.sleep(1); reconnect()
    raise RuntimeError("screencap failed")

READER = b"soccer.tutor.reader"

def reader_on_top():
    out = adb("shell", "dumpsys", "window", out=True)
    return any(READER in l for l in out.splitlines() if b"mCurrentFocus" in l)

def wait_for_reader():
    """The owner may pick the phone up: never tap anything unless Coach
    Viewer is the app on screen — wait (no taps) until he goes back to it."""
    said = False
    while not reader_on_top():
        if not said:
            print(time.strftime("%H:%M:%S ") + "Coach Viewer not on screen — waiting, no taps", flush=True)
            said = True
        time.sleep(5)
    if said: time.sleep(3)

def counter():
    wait_for_reader()
    img, b = shot()
    return page_counter.read(img), img, b

COVER = [None]; LAST = [None]   # LAST = last page read inside a book; COVER = total pages when the book's page 1 shows "Cover", not "1 / N"

def book_counter():
    """Inside a book: wait (no taps) until the counter can be read — a
    picture-in-picture window or a zoomed page hides it; the owner fixes it."""
    said = False
    while True:
        c, img, b = counter()
        if c is None and COVER[0] and LAST[0] and LAST[0][0] <= 2 and reader_on_top():
            c = (1, COVER[0])   # "Cover" label = page 1 (only right after p1/p2)
        if c is not None:
            LAST[0] = c
            if said: print(time.strftime("%H:%M:%S ") + "counter readable again — carrying on", flush=True)
            return c, img, b
        if not said:
            print(time.strftime("%H:%M:%S ") + "can't read the page counter (pop-up over it? zoomed?) — waiting, no taps", flush=True)
            said = True
        time.sleep(5)

def strip_open(img):
    r, g, bl = img.convert("RGB").getpixel((160, 2150))
    return bl > r + 60

def slugify(t):
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", t.lower())).strip("-")[:80]

def ui_titles():
    adb("shell", "uiautomator", "dump", "/sdcard/ui.xml")
    xml = adb("exec-out", "cat", "/sdcard/ui.xml", out=True).decode("utf-8", "replace")
    out = {}
    for m in re.finditer(r'text="([^"]+)"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', xml):
        out[html.unescape(m.group(1))] = ((int(m.group(2)) + int(m.group(4))) // 2, (int(m.group(3)) + int(m.group(5))) // 2)
    return out

def to_library():
    wait_for_reader()
    for _ in range(3):
        c, img, _ = counter()
        if c is None: return
        tap(BACK); time.sleep(3)

def open_book(title):
    wait_for_reader()
    to_library()
    for _ in range(10): swipe(600, 1800, 150)
    time.sleep(1)
    for _ in range(40):
        wait_for_reader()
        t = ui_titles()
        if title in t:
            x, y = t[title]
            if y > 1900: swipe(1500, 900); time.sleep(1); continue
            tap((x, y)); time.sleep(5)
            return True
        swipe(1700, 900, 400); time.sleep(1.2)
    return False

def goto(page, total):
    for _ in range(12):
        c, img, b = book_counter()
        cur = c[0]
        if cur == page: return img, b
        step = NEXT if cur < page else PREV
        n = abs(cur - page)
        wait_for_reader()
        for _ in range(n if n < 40 else 40): tap(step); time.sleep(0.25)
        time.sleep(1.5)
    raise RuntimeError(f"could not reach page {page}")

def capture(title, log):
    tries = 0
    while not open_book(title):
        tries += 1
        log(f"NOT FOUND (try {tries}), waiting 60 s: {title}")
        if tries >= 30: return None
        time.sleep(60)
    c, img, _ = counter()
    # A newly bought book downloads on first open: give it up to 90 s
    # (the counter appears once the first page has rendered).
    for _ in range(18):
        if c is not None: break
        time.sleep(5); c, img, _ = counter()
    COVER[0] = None
    if c is None:
        # Some books open on page 1 labelled "Cover" (no number): step once,
        # and if that reads 2 / N, the cover is page 1.
        wait_for_reader(); tap(NEXT); time.sleep(2)
        c2, _, _ = counter()
        if c2 and c2[0] == 2:
            COVER[0] = c2[1]; LAST[0] = c2; c = (1, c2[1]); log(f"page 1 is labelled Cover: {title}")
        elif c2 and c2[0] == 1:
            c = c2; log(f"cover is unnumbered (before 1 / {c2[1]}): {title}")
    if c is None: log(f"no counter after opening: {title}"); return None
    if strip_open(img): tap(ALLPAGES); time.sleep(2)
    total = c[1]
    slug = slugify(title)
    raw = f"{BOOKS}/{slug}/raw"; os.makedirs(raw, exist_ok=True)
    log(f"{title}: {total} pages → {raw}")
    img, b = goto(1, total)
    p = 1
    while p <= total:
        path = f"{raw}/p{p:03d}.png"
        open(path, "wb").write(b)
        if p % 25 == 0: log(f"  {slug} {p}/{total}")
        if p == total: break
        wait_for_reader(); tap(NEXT); time.sleep(1.6)
        c, img, b = book_counter()
        if c != (p + 1, total):
            img, b = goto(p + 1, total)
        p += 1
    COVER[0] = None
    to_library()
    return slug, total

def main():
    titles = [l.strip() for l in open(sys.argv[1]) if l.strip()]
    logf = open(os.path.join(BOOKS, "capture.log"), "a")
    def log(s):
        line = time.strftime("%H:%M:%S ") + s
        print(line, flush=True); logf.write(line + "\n"); logf.flush()
    here = os.path.dirname(os.path.abspath(__file__))
    for t in titles:
        slug = slugify(t)
        done = subprocess.run(["sudo", "podman", "exec", "footballhome_db", "psql", "-Atq", "-U", "footballhome_user",
                               "-d", "footballhome", "-c",
                               f"SELECT count(*) FROM coaching_book_pages p JOIN coaching_books b ON b.id = p.book_id "
                               f"WHERE b.slug = '{slug}' AND p.page_no <= b.page_count HAVING count(*) = max(b.page_count)"],
                              capture_output=True, stdin=subprocess.DEVNULL).stdout.strip()
        if done: log(f"already loaded, skipping: {t}"); continue
        try:
            r = capture(t, log)
        except Exception as e:
            log(f"FAILED {t}: {e}")
            try: to_library()
            except Exception: pass
            continue
        if not r: continue
        slug, total = r
        n = len([f for f in os.listdir(f"{BOOKS}/{slug}/raw") if re.match(r"p\d{3}\.png$", f)])
        log(f"  captured {n}/{total}")
        rc = subprocess.run([sys.executable, os.path.join(here, "load_book.py"), slug,
                             "--title", t, "--author", ""]).returncode
        log(f"  loaded into DB rc={rc}")
    log("ALL DONE")

if __name__ == "__main__":
    main()
