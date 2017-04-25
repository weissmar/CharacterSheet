from google.appengine.ext import ndb
import webapp2
import db_models
import json

class Items(webapp2.RequestHandler):
	def get(self, **kwargs):
		"""
		Returns one or more Items

		If ikey is specified, returns that Item's details,
		else returns all Item keys
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ikey' in kwargs:
			thisItem = ndb.Key(urlsafe=kwargs['ikey']).get()
			if thisItem is None:
				self.response.status = 400
				self.response.write("Invalid request, the specified item doesn't exist")
				return
			self.response.write(json.dumps(thisItem.to_dict()))
		else:
			allItemKeys = db_models.Item.query().fetch(keys_only=True)
			allItemURLKeys = { 'keys' : [k.urlsafe() for k in allItemKeys]}
			self.response.write(json.dumps(allItemURLKeys))

	def post(self, **kwargs):
		"""
		Creates new Item

		If ikey is specified, returns error message

		POST Body Variables:
		name - Required. Name of item
		weight - Item weight
		value - Item value
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ikey' in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot POST to this URI")
			return
		newItem = db_models.Item()
		jsonObject = json.loads(self.request.body)
		name = jsonObject.get('name')
		weight = jsonObject.get('weight')
		value = jsonObject.get('value')
		if name:
			newItem.name = name
		else:
			self.response.status = 400
			self.response.write("Invalid request, name is required")
			return
		if weight:
			try:
				newItem.weight = float(weight)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, weight must be a floating point number")
				return
		if value:
			try:
				newItem.value = float(value)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, value must be a floating point number")
				return
		newItem.put()
		self.response.write(json.dumps(newItem.to_dict()))

	def put(self, **kwargs):
		"""
		Updates existing Item

		If ikey is not specified, returns error

		PUT Body Variables:
		name - Name of item
		weight - Item weight
		value - Item value
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ikey' not in kwargs:	
			self.response.status = 400
			self.response.write("Invalid request, cannot PUT to this URI")
			return
		updateItem = ndb.Key(urlsafe=kwargs['ikey']).get()
		if updateItem is None:
			self.response.status = 400
			self.response.write("Invalid request, the specified Item doesn't exist")
			return
		jsonObject = json.loads(self.request.body)
		name = jsonObject.get('name')
		weight = jsonObject.get('weight')
		value = jsonObject.get('value')
		if name:
			updateItem.name = name
		if weight:
			try:
				updateItem.weight = float(weight)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, weight must be a floating point number")
				return
		if value:
			try:
				updateItem.value = float(value)
			except ValueError:
				self.response.status = 400
				self.response.write("Invalid request, value must be a floating point number")
				return
		updateItem.put()
		self.response.write(json.dumps(updateItem.to_dict()))

	def delete(self, **kwargs):
		"""
		Deletes an Item and removes references to that Item from Characters

		If ikey is not specified, returns error
		"""
		if 'application/json' not in self.request.accept:
			self.response.status = 400
			self.response.write("Cannot complete request, API only supports application/json type")
			return
		if 'ikey' not in kwargs:
			self.response.status = 400
			self.response.write("Invalid request, cannot DELETE to this URI")
			return
		itemKey = ndb.Key(urlsafe=kwargs['ikey'])
		deleteItem = itemKey.get()
		if deleteItem is None:
			self.response.status = 400
			self.response.write("Invalid request, the specified Item doesn't exist")
			return
		matchCharacters = db_models.Character.query(db_models.Character.inventory == itemKey).fetch()
		characterKeyList = []
		for c in matchCharacters:
			c.inventory.remove(itemKey)
			c.put()
			characterKeyList.append(c.key.urlsafe())
		itemKey.delete()
		allDeletedURLKeys = { 'deletedItemKey' : itemKey.urlsafe(), 'characterKeysRemoved' : characterKeyList }
		self.response.write(json.dumps(allDeletedURLKeys))
