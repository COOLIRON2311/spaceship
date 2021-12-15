import http.client
import urllib.parse

TOKEN = 'cc03e747a6afbbcbf8be7668acfebee5'
params = urllib.parse.urlencode({'token': TOKEN, 'name': 'test'})


con = http.client.HTTPConnection('127.0.0.1', 3000)
# con.connect()
con.request('POST', '/task/create', params)
print(con.getresponse().read().decode('utf8'))


