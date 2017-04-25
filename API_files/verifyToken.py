from google.appengine.api import urlfetch
import json

class verifyToken():
    CLIENT_ID = 'CLIENT_ID.apps.googleusercontent.com'

    @classmethod
    def verifyIDToken(cls, token):
        baseURL = 'https://www.googleapis.com/oauth2/v3/tokeninfo?id_token='
        URL = baseURL + token
        r = urlfetch.fetch(URL)
        if r.status_code == 200:
            tokenBody = json.loads(r.content)
            if tokenBody.get('aud') == cls.CLIENT_ID:
                return tokenBody.get('sub')
        return None


