#!/usr/bin/python3
# -*- coding: utf8 -*-

import urllib.request, json, re
from pprint import pprint, pformat
from dns import resolver

res = urllib.request.urlopen('https://www.privateinternetaccess.com/vpninfo/servers?version=76')
body = res.read()

j = json.JSONDecoder().raw_decode(body.decode('utf8'), 0)

print('\tlocal-zone: "pia." static')

hostprefixre = re.compile('^([^\.]+)')

for key in sorted(j[0], key=str.lower):
	value = j[0][key]
	if (key != 'info'):
		host = value.get('dns', None)
		if host is not None and host not in ('hk', 'turkey'):
			hostprefix = hostprefixre.match(host).group(1)
			for ip in resolver.query(host, 'A'):
				print('\tlocal-data: "' + hostprefix + '.pia IN A ' + str(ip) + '"')
