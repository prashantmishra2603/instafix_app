import urllib.request, json

data = json.dumps({'status': 'in_progress'}).encode('utf-8')

for method in ['PUT', 'PATCH']:
    req = urllib.request.Request(
        'https://instafix-backend.onrender.com/api/bookings/14',
        data=data,
        headers={'Content-Type': 'application/json'},
        method=method
    )
    try:
        res = urllib.request.urlopen(req)
        body = res.read().decode('utf-8')
        print(method + ' 200: ' + body)
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8')
        print(method + ' ' + str(e.code) + ': ' + body)
    except Exception as e:
        print(method + ' Error: ' + str(e))
