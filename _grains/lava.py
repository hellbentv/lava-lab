import os


def instances():
    insts = []
    instdir = '/srv/lava/instances'
    for f in os.listdir(instdir):
        p = os.path.join(instdir, f)
        if os.path.isdir(p):
            insts.append(p)
    return {'lava_instances': insts}
