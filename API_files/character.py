from google.appengine.ext import ndb
import webapp2
import db_models
import json

class Characters(webapp2.RequestHandler):
	def get(self, **kwargs):
		"""
		Returns one or more Characters

		If pkey is specified, returns the keys for all Characters in that party,
		otherwise, if ckey is specified, returns that Character's details,
		else returns all Character keys
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'pkey' in kwargs:
			partyKey = ndb.Key(urlsafe=kwargs['pkey'])
			allPartyCharKeys = db_models.Character.query(ancestor=partyKey).fetch(keys_only=True)
			allPartyCharURLKeys = { 'keys' : [k.urlsafe() for k in allPartyCharKeys]}
			self.response.write(json.dumps(allPartyCharURLKeys))
		elif 'ckey' in kwargs:
			thisCharacter = ndb.Key(urlsafe=kwargs['ckey']).get()
			if thisCharacter is None:
				self.response.status = 400
				self.response.write("Invalid request, the specified character does not exist")
				return
			self.response.write(json.dumps(thisCharacter.to_dict()))
		else:
			allCharKeys = db_models.Character.query().fetch(keys_only=True)
			allCharURLKeys = { 'keys' : [k.urlsafe() for k in allCharKeys]}
			self.response.write(json.dumps(allCharURLKeys))

	def post(self, **kwargs):
		"""
		Creates new Character (in the given Party)

		If pkey is not specified, returns error message

		POST Body Variables:
		name - Required. Name of the character
		XP - Current experience point total
		IQ - Intelligence stat
		STR - Strength stat
		DEX - Dexterity stat
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'pkey' not in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot POST to this URI")
			return
		partyKey = ndb.Key(urlsafe=kwargs['pkey'])
		newCharacter = db_models.Character(parent=partyKey)
		jsonObject = json.loads(self.request.body)
		name = jsonObject.get('name')
		XP = jsonObject.get('XP')
		IQ = jsonObject.get('IQ')
		STR = jsonObject.get('STR')
		DEX = jsonObject.get('DEX')
		if name:
			newCharacter.name = name
		else:
			self.response.status = 400
			self.response.write("Invalid request, name is required")
			return
		if XP:
			try:
				newCharacter.XP = int(XP)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, XP must be an integer")
				return
		if IQ:
			try:
				newCharacter.IQ = int(IQ)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, IQ must be an integer")
				return
		if STR:
			try:
				newCharacter.STR = int(STR)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, STR must be an integer")
				return
		if DEX:
			try:
				newCharacter.DEX = int(DEX)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, DEX must be an integer")
				return
		newCharacter.put()
		self.response.write(json.dumps(newCharacter.to_dict()))

	def put(self, **kwargs):
		"""
		Updates existing Character

		If ckey is not specified, returns error

		PUT Body Variables:
		name - Character name
		XP - Current experience point total
		IQ - Intelligence stat
		STR - Strength stat
		DEX - Dexterity stat
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ckey' not in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot PUT to this URI")
			return
		updateCharacter = ndb.Key(urlsafe=kwargs['ckey']).get()
		if updateCharacter is None:
			self.response.status = 400
			self.response.write("Invalid request, the specified Character does not exist")
			return
		jsonObject = json.loads(self.request.body)
		name = jsonObject.get('name')
		XP = jsonObject.get('XP')
		IQ = jsonObject.get('IQ')
		STR = jsonObject.get('STR')
		DEX = jsonObject.get('DEX')
		if name:
			updateCharacter.name = name
		if XP:
			try:
				updateCharacter.XP = int(XP)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, XP must be an integer")
				return
		if IQ:
			try:
				updateCharacter.IQ = int(IQ)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, IQ must be an integer")
				return
		if STR:
			try:
				updateCharacter.STR = int(STR)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, STR must be an integer")
				return
		if DEX:
			try:
				updateCharacter.DEX = int(DEX)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, DEX must be an integer")
				return
		updateCharacter.put()
		self.response.write(json.dumps(updateCharacter.to_dict()))	

	def delete(self, **kwargs):
		"""
		Deletes one Character or all Characters within a Party

		If pkey is specified, deletes all Characters within a Party,
		otherwise, if ckey is specified, deletes specified Character,
		else returns error
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'pkey' in kwargs:
			partyKey = ndb.Key(urlsafe=kwargs['pkey'])
			characterKeys = db_models.Character.query(ancestor=partyKey).fetch(keys_only=True)
			ndb.delete_multi(characterKeys)
			deletedURLKeys = { 'deletedCharacterKeys' : [k.urlsafe() for k in characterKeys]}
			self.response.write(json.dumps(deletedURLKeys))		
		elif 'ckey' in kwargs:
			characterKey = ndb.Key(urlsafe=kwargs['ckey'])
			deleteCharacter = characterKey.get()
			if deleteCharacter is None:
				self.response.status = 400
				self.response.write("Invalid request, the specified Character doesn't exist")
				return
			characterKey.delete()
			deletedCharKey = { 'deletedCharacterKey' : characterKey.urlsafe() }
			self.response.write(json.dumps(deletedCharKey))
		else:
			self.response.status = 400
			self.response.write("Invalid request, cannot DELETE to this URI")

class CharacterItems(webapp2.RequestHandler):
	def get(self, **kwargs):
		"""
		Returns all keys of Items the specified Character is carrying

		If ikey is specified, returns error message
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ikey' in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot GET to this URI")
			return
		thisCharacter = ndb.Key(urlsafe=kwargs['ckey']).get()
		allCharItems = { 'itemKeys' : [k.urlsafe() for k in thisCharacter.inventory]}
		self.response.write(json.dumps(allCharItems))

	def put(self, **kwargs):
		"""
		Adds Item to Character's inventory

		If ikey is not specified, returns error
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ikey' not in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot PUT to this URI")
			return
		thisCharacter = ndb.Key(urlsafe=kwargs['ckey']).get()
		itemKey = ndb.Key(urlsafe=kwargs['ikey'])
		thisItem = itemKey.get()
		if thisCharacter is None:
			self.response.status = 400
			self.response.write("Invalid request, specified Character doesn't exist")
			return
		if thisItem is None:
			self.response.status = 400
			self.response.write("Invalid request, specified Item doesn't exist")
			return
		if itemKey not in thisCharacter.inventory:
			thisCharacter.inventory.append(itemKey)
			thisCharacter.put()
		allCharItems = { 'itemKeys' : [k.urlsafe() for k in thisCharacter.inventory]}
		self.response.write(json.dumps(allCharItems))

	def delete(self, **kwargs):
		"""
		Deletes one or all Items from Character's inventory

		If ikey is specified, deletes that Item from inventory,
		else deletes all items from inventory
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		thisCharacter = ndb.Key(urlsafe=kwargs['ckey']).get()
		if thisCharacter is None:
			self.response.status = 400
			self.response.write("Invalid request, specified Character doesn't exist")
			return
		if 'ikey' in kwargs:
			itemKey = ndb.Key(urlsafe=kwargs['ikey'])
			if itemKey not in thisCharacter.inventory:
				self.response.status = 400
				self.response.write("Invalid request, specified Item is not in inventory")
				return
			thisCharacter.inventory.remove(itemKey)
		else:
			thisCharacter.inventory[:] = []				
		thisCharacter.put()
		allCharItems = { 'itemKeys' : [k.urlsafe() for k in thisCharacter.inventory]}
		self.response.write(json.dumps(allCharItems))
