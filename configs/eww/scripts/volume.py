#!/usr/bin/env python3

import sys
import subprocess
from typing import Iterable
import time

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line 
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

def getVolume() -> int:
    result = subprocess.run(["pamixer", "--get-volume-human"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    resultStr = result.stdout.decode("utf-8")[:-1]

    if resultStr == "muted":
        return 0

    return int(resultStr[:-1])

def listenVolume() -> Iterable[int]:
    for path in execute(["pactl", "subscribe"]):
        if "'change'" in path:
            yield getVolume()

def addVolume(num: int):
    subprocess.run(["pulsemixer", "--change-volume", str(num)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def volumeChangeWidget():
    def printWidget(vol: int):
        print(f'(box :class "volume {"warning" if vol > 100 or vol == 0 else ""}" (label :text "{vol}"))', flush=True)

    printWidget(getVolume())

    for newVolume in listenVolume():
        printWidget(newVolume)

    
match sys.argv[1]:
    case "listen":
        while True:
            try:
                volumeChangeWidget()
            except:
                pass
            time.sleep(2)
    case "add":
        addVolume(int(sys.argv[2]))
