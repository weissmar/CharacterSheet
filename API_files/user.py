from google.appengine.ext import ndb
import webapp2
import db_models
import json 
from verifyToken import verifyToken
import datetime

class SignIn(webapp2.RequestHandler):
    def post(self):
        """
        Validates token from authorization header

        If the token is valid, checks user id

        Adds user if not already in datastore
        """
        if 'application/json' not in self.request.accept:
            self.response.status = 400
            self.response.write("Cannot complete request, API only supports application/json type")
            return
        if 'authorization' not in self.request.headers:
            self.response.status = 400
            self.response.write("Cannot complete request, token must be sent in Authorization header")
            return
        tokenString = self.request.headers['authorization']
        token = tokenString.split()
        if len(token) == 2:
            userID = verifyToken.verifyIDToken(token[1])
            if userID is not None:
                thisUser = ndb.Key('User', userID).get()
                if thisUser is None:
                    newUser = db_models.User(id=userID)
                    newUser.put()
                    self.response.write(json.dumps(newUser.to_dict()))
                    return
                else:
                    self.response.write(json.dumps(thisUser.to_dict()))
                    return
        self.response.status = 400
        self.response.write("Cannot complete request, token is invalid")

class Users(webapp2.RequestHandler):
    def post(self):
        """
        Adds a new party and assigns it to the user

        POST Body Variables:
        name - Required. Party name
        startDate - Date of first party meeting
        meetingDay - Day of the week for meetings
        meetingTime - Time of day for meetings
        """
        if 'application/json' not in self.request.accept:
            self.response.status = 400
            self.response.write("Cannot complete request, API only supports application/json type")
            return
        if 'authorization' not in self.request.headers:
            self.response.status = 400
            self.response.write("Cannot complete request, token must be sent in Authorization header")
            return
        tokenString = self.request.headers['authorization']
        token = tokenString.split()
        if len(token) == 2:
            userID = verifyToken.verifyIDToken(token[1])
            if userID is not None:
                thisUser = ndb.Key('User', userID).get()
                if thisUser is not None:
                    newParty = db_models.Party()
                    jsonObject = json.loads(self.request.body)
                    name = jsonObject.get('name')
                    startDate = jsonObject.get('startDate')
                    meetingDay = jsonObject.get('meetingDay')
                    meetingTime = jsonObject.get('meetingTime')
                    if name:
                        newParty.name = name
                    else:
                        self.response.status = 400
                        self.response.write("Invalid request, name is required")
                        return
                    if startDate:
                        try:
                            newParty.startDate = datetime.datetime.strptime(startDate, "%m/%d/%Y").date()
                        except ValueError:
                            self.response.status = 400
                            self.response.write("Invalid request, startDate must be in MM/DD/YYYY format")
                            return
                    if meetingDay:
                        newParty.meetingDay = meetingDay
                    if meetingTime:
                        try:
                            newParty.meetingTime = datetime.datetime.strptime(meetingTime, "%H:%M").time()
                        except ValueError:
                            self.response.status = 400
                            self.response.write("Invalid request, meetingTime must be in Hours:Minutes format")
                            return
                    partyKey = newParty.put()
                    thisUser.party = partyKey
                    thisUser.put()
                    self.response.write(json.dumps(newParty.to_dict()))
                    return
        self.response.status = 400
        self.response.write("Cannot complete request, token is invalid")


