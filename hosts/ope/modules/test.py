import sys
import io
import select
from subprocess import Popen, PIPE
from sys import argv


def kill_when_found(process, needle, size=io.DEFAULT_BUFFER_SIZE):
    if isinstance(needle, str):
        needle = needle.encode()
    assert isinstance(needle, bytes)

    streams = [process.stdout, process.stderr]
    poll = select.poll()
    for stream in streams:
        if stream:
            poll.register(stream, select.POLLIN)

    output_buffers = {stream: b"" for stream in streams if stream}

    while process.poll() is None:
        events = poll.poll(100)
        if not events:
            continue

        for fd, _ in events:
            for stream in streams:
                if stream and stream.fileno() == fd:
                    output = stream.read1(size)
                    sys.stdout.buffer.write(output)
                    sys.stdout.buffer.flush()
                    output_buffers[stream] += output

                    if needle in output_buffers[stream]:
                        process.kill()
                        return process.poll()

                    if len(output_buffers[stream]) >= len(needle):
                        output_buffers[stream] = output_buffers[stream][
                            -len(needle):
                        ]

    return process.poll()


if __name__ == "__main__":
    if len(argv) <= 3:
        print(
            """
Usage: Pass in at least 2 arguments. The first argument is the search string;
the remaining arguments form the command to be executed (and watched over).
"""
        )
        sys.exit(0)
    else:
        process = Popen(argv[2:], stdout=PIPE, stderr=PIPE)
        retcode = kill_when_found(process, argv[1])
        sys.exit(retcode)
