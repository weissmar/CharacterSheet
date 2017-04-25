from google.appengine.ext import ndb
import datetime

class Model(ndb.Model):
	def to_dict(self):
		modelDict = super(Model, self).to_dict()
		modelDict['urlsafeKey'] = self.key.urlsafe()
		return modelDict

class Party(Model):
	name = ndb.StringProperty(required=True)
	startDate = ndb.DateProperty()
	meetingDay = ndb.StringProperty()
	meetingTime = ndb.TimeProperty()

	def to_dict(self):
		modelDict = super(Party, self).to_dict()
		if modelDict['startDate']:
			modelDict['startDate'] = modelDict['startDate'].strftime("%m/%d/%Y")
		if modelDict['meetingTime']:
			modelDict['meetingTime'] = modelDict['meetingTime'].strftime("%H:%M")
		return modelDict

class Item(Model):
	name = ndb.StringProperty(required=True)
	weight = ndb.FloatProperty()
	value = ndb.FloatProperty()

class Character(Model):
	name = ndb.StringProperty(required=True)
	XP = ndb.IntegerProperty()
	IQ = ndb.IntegerProperty()
	STR = ndb.IntegerProperty()
	DEX = ndb.IntegerProperty()
	inventory = ndb.KeyProperty(kind=Item, repeated=True)

	def to_dict(self):
		modelDict = super(Character, self).to_dict()
		modelDict['inventory'] = [i.urlsafe() for i in modelDict['inventory']]
		return modelDict

class User(Model):
	party = ndb.KeyProperty(kind=Party)

	def to_dict(self):
		modelDict = super(User, self).to_dict()
		if modelDict['party'] is not None:
			modelDict['party'] = modelDict['party'].urlsafe()
		else:
			modelDict['party'] = ""
		return modelDict

