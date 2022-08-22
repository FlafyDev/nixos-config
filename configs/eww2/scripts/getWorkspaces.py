import subprocess;
from enum import Enum
import json
import socket
from pprint import pprint

WORKSPACES = 10

class WorkspaceStatus(Enum):
    free = "◇"
    occupied = "◈"
    selected = "◆"

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

def turnToWidget(all_status):
    widgets = "";

    for id, status in enumerate(all_status):

        widgets += f'(button :class "wp-{status.name} wp-{id}" "{status.value}")'

    return f'(box :class "wp" :orientation "v" :halign "start" :valign "center" :space-evenly "false" :spacing "-5" {widgets})'


def printWidget():
    real_all_status = all_status.copy()
    real_all_status[selectedWorkspaceId] = WorkspaceStatus.selected
    real_all_status = real_all_status[1:]

    # pprint(real_all_status)
  
    print(turnToWidget(real_all_status), flush=True)

printWidget()

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.connect("/tmp/hypr/_1661156521/.socket2.sock")

while True:
    rawEvents = sock.recv(1024)
    for rawEvent in rawEvents.splitlines():
        onEvent(rawEvent.decode("utf-8"))

    printWidget()

