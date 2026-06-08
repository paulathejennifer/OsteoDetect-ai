import requests
p=r'c:\Users\roone\OsteoDetect-ai\frontend\images\sample-result.jpg'
url='https://osteodetect-ai-production.up.railway.app/detect'
with open(p,'rb') as f:
    files={'file':f}
    r=requests.post(url, files=files, timeout=120)
    print('STATUS', r.status_code)
    print(r.text)
