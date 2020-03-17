#!/usr/bin/python3
# -*- coding: utf8 -*-

import urllib.request, json, re
from pprint import pprint, pformat
from dns import resolver
import datetime

res = urllib.request.urlopen('https://www.privateinternetaccess.com/vpninfo/servers?version=76')
body = res.read()

j = json.JSONDecoder().raw_decode(body.decode('utf8'), 0)

d = datetime.datetime.utcnow()

# print('\tlocal-zone: "pia." static')
print('$ORIGIN pia.')
print('$TTL 1W')
print('@    IN    SOA    localhost.    root.localhost.    (')
print('    %u ; serial'%(int(d.timestamp())))
print('    3600 ; refresh')
print('    3600 ; retry')
print('    3600 ; expire')
print('    3600 ; minimum')
print(')')
print('@    IN    NS    localhost.')

hostprefixre = re.compile('^([^\.]+)')

for key in sorted(j[0], key=str.lower):
	value = j[0][key]
	if (key != 'info'):
		host = value.get('dns', None)
		if host is not None and host not in ('hk', 'turkey'):
			hostprefix = hostprefixre.match(host).group(1)
			for ip in resolver.query(host, 'A'):
				# print('\tlocal-data: "' + hostprefix + '.pia IN A ' + str(ip) + '"')
				print(hostprefix + ' IN A ' + str(ip))
