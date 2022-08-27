#!/usr/bin/env python3

import sys
import subprocess

def save(enable: bool):
    subprocess.check_output(["eww", "update", f"batterySaving={str(not enable).lower()}"])
    if enable:
        subprocess.check_output(["hyprctl", "keyword", "decoration:blur", "0"])
        subprocess.check_output(["hyprctl", "keyword", "animations:enabled", "0"])
    else:
        subprocess.check_output(["hyprctl", "reload", "config-only"])

save(sys.argv[1].lower() == "true")

