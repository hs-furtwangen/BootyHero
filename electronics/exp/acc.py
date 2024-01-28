import time
import board
import busio
import adafruit_mpu6050
import math

##### CONFIG

loopWait = .01
cooldown = .5

hitLMinMag = 3
hitRMinMag = 1

##### CONFIG END

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

def FindBiggestComp(acc3d):
    if (abs(acc3d[0]) > abs(acc3d[1]) and abs(acc3d[0]) > abs(acc3d[2])):
        return 0
    if (abs(acc3d[1]) > abs(acc3d[0]) and abs(acc3d[1]) > abs(acc3d[2])):
        return 1
    if (abs(acc3d[2]) > abs(acc3d[0]) and abs(acc3d[2]) > abs(acc3d[1])):
        return 2

def FindAxisR(moveR):
    moveRCom = moveR
    magR = GetMag(moveR)
    print("HIT - Right")
    print(moveR)
    print(FindBiggestComp(moveR))
    print(moveR[FindBiggestComp(moveR)])
    while magR > hitRMinMag:
        moveRT = GetMoveCali(mpur.acceleration, caliVecR)
        magR = GetMag(moveRT)
        moveRCom = [((moveRCom[0] + moveRT[0]) / 2), ((moveRCom[1] + moveRT[1]) / 2), ((moveRCom[2] + moveRT[2]) / 2)]
    print(FindBiggestComp(moveRCom))
    print(moveRCom[FindBiggestComp(moveRCom)])

        
while True:
    moveL = GetMoveCali(mpul.acceleration, caliVecL)
    moveR = GetMoveCali(mpur.acceleration, caliVecR)
    
    #if (cooldownTimerL <= 0 and GetMagCali(moveL, caliMagL) > hitLMinMag):
    #    cooldownTimerL = cooldown
    #    print("HIT - Left")
    #    print(GetMoveCali(moveL, caliVecL))
        
    if (cooldownTimerR <= 0 and GetMag(moveR) > hitRMinMag):
        cooldownTimerR = cooldown
        FindAxisR(moveR)

    
    time.sleep(loopWait)
    
    #if (cooldownTimerL > 0):
    #    cooldownTimerL = cooldownTimerL - loopWait
    if (cooldownTimerR > 0):
        cooldownTimerR = cooldownTimerR - loopWait
    


