import time
import board
import busio
import adafruit_mpu6050
import math
import usb_hid
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode

##### CONFIG

loopWait = .02
cooldown = .25

hitLMinMag = 15
hitRMinMag = 15

##### CONFIG END

kbd = Keyboard(usb_hid.devices)

cooldownTimerL = 0
cooldownTimerR = 0

i2cl = busio.I2C(board.GP1, board.GP0)  # uses board.SCL and board.SDA
mpul = adafruit_mpu6050.MPU6050(i2cl)

i2cr = busio.I2C(board.GP3, board.GP2)  # uses board.SCL and board.SDA
mpur = adafruit_mpu6050.MPU6050(i2cr)

def GetMag(acc3d):
    return math.sqrt(pow(acc3d[0],2) + pow(acc3d[1],2) + pow(acc3d[2],2))

def GetMoveCali(acc3d, cali):
    x = (acc3d[0] - cali[0])
    y = (acc3d[1] - cali[1])
    z = (acc3d[2] - cali[2])
    ret = [x,y,z]
    return ret

def GetMagCali(acc3d, cali):
    return GetMag(acc3d) - cali


# Calibrate Start
caliVecL = mpul.acceleration
caliMagL = GetMag(caliVecL)
caliVecR = mpur.acceleration
caliMagR = GetMag(caliVecR)

for i in range(1,9):
    caliVecLT = mpul.acceleration
    caliMagL = (caliMagL + GetMag(caliVecLT)) / 2
    caliVecL = [((caliVecL[0] + caliVecLT[0]) / 2), ((caliVecL[1] + caliVecLT[1]) / 2), ((caliVecL[2] + caliVecLT[2]) / 2)]

    caliVecRT = mpur.acceleration
    caliMagR = (caliMagR + GetMag(caliVecRT)) / 2
    caliVecR = [((caliVecR[0] + caliVecRT[0]) / 2), ((caliVecR[1] + caliVecRT[1]) / 2), ((caliVecR[2] + caliVecRT[2]) / 2)]

    time.sleep(.3)

print(caliMagL)
print(caliVecL)
print(caliMagR)
print(caliVecR)
    
# Calibrate End

while True:
    moveL = GetMoveCali(mpul.acceleration, caliVecL)
    moveR = GetMoveCali(mpur.acceleration, caliVecR)
    
    magL = GetMag(moveL)
    magR = GetMag(moveR)
    
    #kbd.release(Keycode.S)
    #kbd.release(Keycode.K)
    
    if (cooldownTimerL <= 0 and magL > hitLMinMag):
        cooldownTimerL = cooldown
        print("HIT - Left")
        print(magL)
        kbd.press(Keycode.S)
        time.sleep(.01)
        kbd.release(Keycode.S)
                
    if (cooldownTimerR <= 0 and magR > hitRMinMag):
        cooldownTimerR = cooldown
        print("HIT - Right")
        print(magR)
        kbd.press(Keycode.K)
        time.sleep(.01)
        kbd.release(Keycode.K)
        
    time.sleep(loopWait)
    
    if (cooldownTimerL > 0):
        cooldownTimerL = cooldownTimerL - loopWait
    if (cooldownTimerR > 0):
        cooldownTimerR = cooldownTimerR - loopWait
        
