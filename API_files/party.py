from google.appengine.ext import ndb
import webapp2
import db_models
import json
import datetime

class Parties(webapp2.RequestHandler):
	def get(self, **kwargs):
		"""
		Returns one or more Parties
		
		If pkey is specified, returns that Party's details,
		else returns all Party keys
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'pkey' in kwargs:
			thisParty = ndb.Key(urlsafe=kwargs['pkey']).get()
			if thisParty is None:
				self.response.status = 400
				self.response.write("Invalid request, the specified Party does not exist")
				return
			self.response.write(json.dumps(thisParty.to_dict()))
		else:
			allPartyKeys = db_models.Party.query().fetch(keys_only=True)
			allPartyURLKeys = { 'keys' : [k.urlsafe() for k in allPartyKeys]}
			self.response.write(json.dumps(allPartyURLKeys))		

	def post(self, **kwargs):
		"""
		Creates new Party

		If pkey is specified, returns error message

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
		if 'pkey' in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot POST to this URI")
			return
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
		newParty.put()
		self.response.write(json.dumps(newParty.to_dict()))

	def put(self, **kwargs):
		"""
		Updates existing Party

		If pkey is not specified, returns error

		PUT Body Variables:
		name - Party name
		startDate - Date of first party meeting
		meetingDay - Day of the week for meetings
		meetingTime - Time of day for meetings
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'pkey' not in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot PUT to this URI")
			return
		updateParty = ndb.Key(urlsafe=kwargs['pkey']).get()
		if updateParty is None:
			self.response.status = 400
			self.response.write("Invalid request, the specified Party does not exist")
			return
		jsonObject = json.loads(self.request.body)
		name = jsonObject.get('name')
		startDate = jsonObject.get('startDate')
		meetingDay = jsonObject.get('meetingDay')
		meetingTime = jsonObject.get('meetingTime')
		if name:
			updateParty.name = name
		if startDate:
			try:
				updateParty.startDate = datetime.datetime.strptime(startDate, "%m/%d/%Y").date()
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, startDate must be in MM/DD/YYYY format")
				return
		if meetingDay:
			updateParty.meetingDay = meetingDay
		if meetingTime:
			try:
				updateParty.meetingTime = datetime.datetime.strptime(meetingTime, "%H:%M").time()
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, meetingTime must be in Hours:Minutes format")
				return
		updateParty.put()
		self.response.write(json.dumps(updateParty.to_dict()))

	def delete(self, **kwargs):
		"""
		Deletes a Party and all Characters belonging to that Party
		
		If pkey is not specified, returns error
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'pkey' not in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot DELETE to this URI")
			return
		partyKey = ndb.Key(urlsafe=kwargs['pkey'])
		deleteParty = partyKey.get()
		if deleteParty is None:
			self.response.status = 400
			self.response.write("Invalid request, the specified Party doesn't exist")
			return
		characterKeys = db_models.Character.query(ancestor=partyKey).fetch(keys_only=True)
		ndb.delete_multi(characterKeys)
		partyKey.delete()
		allDeletedURLKeys = { 'deletedPartyKey' : partyKey.urlsafe(), 'deletedCharacterKeys' : [k.urlsafe() for k in characterKeys]}
		self.response.write(json.dumps(allDeletedURLKeys))		
		
