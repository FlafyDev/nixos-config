#!/usr/bin/env python3

import psutil
import math
import sys


def getPercentage():
    battery = psutil.sensors_battery()

    if (battery == None):
        print(100, flush=True)

    print(math.floor(battery.percent), flush=True)

def getCharging():
    battery = psutil.sensors_battery()

    if (battery == None):
        print(100, flush=True)

    plugged = battery.power_plugged != False
    print(str(plugged).lower(), flush=True)

match sys.argv[1]:
    case "percentage":
        getPercentage()
    case "charging":
        getCharging()

