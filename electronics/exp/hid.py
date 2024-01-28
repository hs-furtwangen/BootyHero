import usb_hid
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode
import time

kbd = Keyboard(usb_hid.devices)

kbd.press(Keycode.A)
time.sleep(.09)
kbd.release(Keycode.A)

