import pwd
import logging

from salt import utils, exceptions

log = logging.getLogger(__name__)

USER='instance-manager'
LDT_BIN='/home/instance-manager/lava-deployment-tool/lava-deployment-tool'

def _check():
    utils.check_or_die('bzr')
    if not 'bzr.branch' in __salt__:
        raise exceptions.CommandNotFoundError('Missing bzr module')
def _run(cmd, cwd=None, **kwargs):
    '''
    simple, throw an exception with the error message on an error return code.

    this function may be moved to the command module, spliced with
    'cmd.run_all', and used as an alternative to 'cmd.run_all'. Some
    commands don't return proper retcodes, so this can't replace 'cmd.run_all'.
    '''
    result = __salt__['cmd.run_all'](cmd, cwd=cwd, **kwargs)

    retcode = result['retcode']

    if retcode == 0:
        return result['stdout']
    else:
        raise exceptions.CommandExecutionError(result['stderr'])


def setup(user=USER, ldt_bin=LDT_BIN):
    _check()
    pwd.getpwnam(user)

    cmd = '{0} setup'.format(ldt_bin)
    env = {'SKIP_ROOT_CHECK': 'yes'}
    _run(cmd, env=env)
    _run('chown -R {0} /srv/lava'.format(user))
    ret = {
        'location': '/srv/lava'
    }
    with open('/srv/lava/instances/.setup') as f:
        ret['version'] = int(f.read())
    return ret


def installworker(instance,
                  db_server, db_name, db_user, db_pass,
                  fs_server, fs_user, fs_dir,
                  server_ip,
                  proxy=None,
                  manifest_branch='lp:lava-manifest',
                  user=USER, ldt_bin=LDT_BIN):
    _check()
    pwd.getpwnam(user)

    params = {
        'LAVA_MANIFEST_BRANCH': manifest_branch,
        'LAVA_DB_SERVER': db_server,
        'LAVA_DB_NAME': db_name,
        'LAVA_DB_USER': db_user,
        'LAVA_DB_PASSWORD': db_pass,
        'LAVA_REMOTE_FS_HOST': fs_server,
        'LAVA_REMOTE_FS_USER': fs_user,
        'LAVA_REMOTE_FS_DIR': fs_dir,
        'LAVA_PROXY': proxy,
        'LAVA_SERVER_IP': server_ip,
        'SKIP_ROOT_CHECK': "yes",
    }

    cmd = '{0} installworker -n {1}'.format(ldt_bin, instance)
    _run(cmd, env=params)
    _run('chown -R {0} /srv/lava'.format(user))

    ret = {
        'location': '/srv/lava/instances/{0}'.format(instance)
    }
    with open('/srv/lava/instances/%s/home/.ssh/id_rsa.pub') as f:
        ret['pubkey'] = f.read()
    return ret

def pubkey(instance):
    return True
