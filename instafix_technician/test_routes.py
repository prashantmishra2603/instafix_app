import urllib.request, json

data = json.dumps({'status': 'in_progress'}).encode('utf-8')

# Try various possible routes
routes = [
    ('PUT',   'https://instafix-backend.onrender.com/api/bookings/14'),
    ('PATCH', 'https://instafix-backend.onrender.com/api/bookings/14'),
    ('POST',  'https://instafix-backend.onrender.com/api/bookings/14/status'),
    ('PUT',   'https://instafix-backend.onrender.com/api/bookings/14/status'),
    ('POST',  'https://instafix-backend.onrender.com/api/bookings/14/update'),
    ('POST',  'https://instafix-backend.onrender.com/api/update-booking/14'),
]

for method, url in routes:
    req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'}, method=method)
    try:
        res = urllib.request.urlopen(req)
        body = res.read().decode('utf-8')
        print('SUCCESS ' + method + ' ' + url + ': ' + body[:200])
    except urllib.error.HTTPError as e:
        print(method + ' ' + str(e.code) + ' - ' + url)
    except Exception as e:
        print(method + ' ERR - ' + url + ' - ' + str(e))
