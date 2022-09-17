#!/usr/bin/env python3

import subprocess
from enum import Enum
import json
import socket
import os
import shutil

class WorkspaceStatus(Enum):
    free = "◇"
    occupied = "◈"
    selected = "◆"

def turnToWidget(all_status):
    widgets = "";

    for id, status in enumerate(all_status):

        widgets += f'(button :class "wp-{status.name} wp-{id}" "{status.value}")'

    return f'(box :class "wp" :orientation "v" :halign "start" :valign "center" :space-evenly "false" :spacing "-5" {widgets})'


def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line 
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

# WM Specific:
def i3():
    def status_from_wmctrl_symbol(symbol):
        match symbol:
            case "*":
                return WorkspaceStatus.selected;
            case "-":
                return WorkspaceStatus.occupied;
            case _:
                return WorkspaceStatus.free;
    
    def printWidget():
        all_status = [WorkspaceStatus.free for _ in range(9)] 
        wmctrl_info = subprocess.check_output([ "wmctrl", "-d" ], encoding="utf-8")

        for line in wmctrl_info.splitlines():
            all_status[int(line[-1]) - 1] = status_from_wmctrl_symbol(line[3])
    
        print(turnToWidget(all_status), flush=True)

    printWidget()
    for _ in execute(["i3-msg", "-t", "subscribe", "-m", '[ "workspace" ]']):
        printWidget()

def hyprland():
    WORKSPACES = 10
    all_status = [WorkspaceStatus.free for _ in range(WORKSPACES + 1)] 
    initial_workspaces = json.loads(subprocess.check_output(["hyprctl", "workspaces", "-j"]))
    initial_monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"]))

    for initial_workspace in initial_workspaces:
        all_status[initial_workspace["id"]] = WorkspaceStatus.occupied

    selectedWorkspaceId = initial_monitors[0]["activeWorkspace"]["id"]

    def onEvent(rawEvent: str):
        global selectedWorkspaceId
        (event, param) = rawEvent.split(">>");
        match event:
            case "createworkspace":
                all_status[int(param)] = WorkspaceStatus.occupied
                return 
            case "destroyworkspace":
                all_status[int(param)] = WorkspaceStatus.free
                return 
            case "workspace":
                selectedWorkspaceId = int(param)
                return 
            case _:
                return

    def printWidget():
        real_all_status = all_status.copy()
        real_all_status[selectedWorkspaceId] = WorkspaceStatus.selected
        real_all_status = real_all_status[1:]

        # pprint(real_all_status)
      
        print(turnToWidget(real_all_status), flush=True)

    printWidget()

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(f"/tmp/hypr/{os.environ.get('HYPRLAND_INSTANCE_SIGNATURE')}/.socket2.sock")

    while True:
        rawEvents = sock.recv(1024)
        for rawEvent in rawEvents.splitlines():
            rawEventStr = rawEvent.decode("utf-8");
            if (">>" in rawEventStr):
                onEvent(rawEventStr)

        printWidget()

if shutil.which("i3-msg"):
    i3()
elif shutil.which("hyprctl"):
    hyprland()

