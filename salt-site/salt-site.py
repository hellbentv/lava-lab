#!/usr/bin/env python

import argparse
import ConfigParser
import jinja2
import os
import shutil
import StringIO
import subprocess
import time

import salt.client as client


def _render(outname, tmpl, revinfo, args):
    args['revinfo'] = revinfo
    with open(tmpl, 'r') as f:
        template = jinja2.Template(f.read())
        content = template.render(**args)
        with open(outname, 'w') as of:
            of.write(content)

labconfig = {}
lavaconfig = {}


def get_user_config(lp_manage_local_buff):
    cp = ConfigParser.ConfigParser()
    cp.readfp(StringIO.StringIO(lp_manage_local_buff))
    sudoers = lp_groups = None
    if cp.has_option('__main__', 'sudoers'):
        sudoers = []
        for s in cp.get('__main__', 'sudoers').split(','):
            sudoers.append(s.strip())

    if cp.has_option('__main__', 'lp-groups'):
        lp_groups = []
        for g in cp.get('__main__', 'lp-groups').split(','):
            lp_groups.append(g.strip())

    return {'sudoers': sudoers, 'lp-groups': lp_groups}


def build_configured_users():
    ret = client.cmd('*', 'cmd.run', ['cat /etc/lp-manage-local.conf'])
    for k, v in ret.iteritems():
        labconfig[k] = {
            'id': k,
            'time': time.strftime('%Y-%m-%d %H:%M UTC', time.gmtime())
        }
        if not v.startswith('cat: '):  # ensure file exists
            cfg = get_user_config(v)
            labconfig[k]['configured_groups'] = cfg['lp-groups']
            labconfig[k]['configured_sudoers'] = cfg['sudoers']


def build_actual_users():
    ret = client.cmd('*', 'user.getent')
    for k, v in ret.iteritems():
        users = []
        for u in v:
            if u['gid'] == 1001 or 'lp-users' in u['groups']:
                users.append(u)
        labconfig[k]['users'] = users


def os_info():
    ret = client.cmd('*', 'grains.items')
    for k, v in ret.iteritems():
        labconfig[k]['grains'] = v

    ret = client.cmd('*', 'disk.usage')
    for k, v in ret.iteritems():
        labconfig[k]['disk'] = v


def lava_info():
    ret = client.cmd('*', 'lava.list_instances', [])
    for k, v in ret.iteritems():
        labconfig[k]['lava'] = {}
        for inst in v:
            ret = client.cmd(
                k, 'cmd.run', ['"%s/bin/lava devices"' % inst], timeout=15)
            if k not in ret:
                ret[k] = ''
            devices = ', '.join(sorted(ret[k].split('\n')))
            labconfig[k]['lava'][inst] = {'devices': devices}

            inst = os.path.basename(inst)
            if inst not in lavaconfig:
                lavaconfig[inst] = []
            lavaconfig[inst].append(k)


def _revno(bzrdir):
    rev = subprocess.check_output(['bzr', 'revno'], cwd=basedir).strip()
    return 'lp:~linaro-validation/lava-lab/salt-states revno(%s)' % rev


if __name__ == '__main__':
    client = client.LocalClient()

    parser = argparse.ArgumentParser(
        description='Builds out a summary of what we are managing')
    parser.add_argument('-o', dest='odir', default='/var/www/salt-site')
    args = parser.parse_args()

    basedir = os.path.split(__file__)[0]

    build_configured_users()
    build_actual_users()
    os_info()
    lava_info()

    revno = _revno(basedir)

    outfile = '{0}/index.html'.format(args.odir)
    tmplargs = {
        'hosts': labconfig.keys(),
        'lavaconfig': lavaconfig,
        'time': time.strftime('%Y-%m-%d %H:%M UTC', time.gmtime())
    }
    _render(outfile, '{0}/index.html'.format(basedir), revno, tmplargs)
    for host in labconfig.keys():
        outfile = '{0}/{1}.html'.format(args.odir, host)
        _render(outfile, '{0}/host.html'.format(basedir), revno, labconfig[host])

    shutil.copyfile('{0}/site.css'.format(basedir), '{0}/site.css'.format(args.odir))
