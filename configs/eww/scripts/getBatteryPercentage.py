#!/usr/bin/env python3

import psutil
import math
import random

def getPercentage():
    battery = psutil.sensors_battery()

    if (battery == None):
        print(100, flush=True)

    # plugged = battery.power_plugged != False
    # plugged = "Plugged In" if plugged else "Not Plugged In"
    print(math.floor(battery.percent), flush=True)

getPercentage()

