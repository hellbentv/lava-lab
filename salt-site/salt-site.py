#!/usr/bin/env python

import argparse
import ConfigParser
import jinja2
import os
import shutil
import StringIO

import salt.client as client


def _render(outname, tmpl, args):
    with open(tmpl, 'r') as f:
        template = jinja2.Template(f.read())
        content = template.render(**args)
        with open(outname, 'w') as of:
            of.write(content)

'''
labconfig = {
    'dogfood': {
        'id': 'dogfood',
        'configured_sudoers': ['andy', 'tony'],
        'configured_groups': ['linaro-validation'],
        'users': [
            {
                'name': 'doanac',
                'groups': ['lp-users', 'sudo']
            },
        ],
    },
    'foobar': {
        'id': 'foobar',
        'configured_sudoers': ['andy', 'tony'],
        'configured_groups': ['linaro-validation'],
        'users': [
            {
                'name': 'doanac',
                'groups': ['lp-users']
            },
        ],
    }
}
'''

labconfig = {}

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

    return { 'sudoers': sudoers, 'lp-groups': lp_groups }


def build_configured_users():
    ret = client.cmd('*', 'cmd.run', ['cat /etc/lp-manage-local.conf'])
    for k,v in ret.iteritems():
        labconfig[k] = {'id': k}
        if not v.startswith('cat: '):  # ensure file exists
            cfg = get_user_config(v)
            labconfig[k]['configured_groups'] = cfg['lp-groups']
            labconfig[k]['configured_sudoers'] = cfg['sudoers']


def build_actual_users():
    ret = client.cmd('*', 'user.getent')
    for k,v in ret.iteritems():
        users = []
        sudo = []
        for u in v:
            if u['gid'] == 1001 or 'lp-users' in u['groups']:
                users.append(u)
        labconfig[k]['users'] = users


if __name__ == '__main__':
    client = client.LocalClient()

    parser = argparse.ArgumentParser(
        description='Builds out a summary of what we are managing')
    parser.add_argument('-o', dest='odir', default='/var/www/salt-site')
    args = parser.parse_args()

    basedir = os.path.split(__file__)[0]

    build_configured_users()
    build_actual_users()

    outfile = '{0}/index.html'.format(args.odir)
    _render(outfile, '{0}/index.html'.format(basedir), {'hosts': labconfig.keys()})
    for host in labconfig.keys():
        outfile = '{0}/{1}.html'.format(args.odir, host)
        _render(outfile, '{0}/host.html'.format(basedir), labconfig[host])

    shutil.copyfile('{0}/site.css'.format(basedir), '{0}/site.css'.format(args.odir))
