import sys
import xmlrpclib

api_url = sys.argv[1]
server = xmlrpclib.ServerProxy(api_url)
x = server.system.listMethods()
assert(len(x) > 0)
