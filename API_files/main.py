import webapp2

app = webapp2.WSGIApplication([
    webapp2.Route(r'/sign-in', handler='user.SignIn'),
    webapp2.Route(r'/users', handler='user.Users'),
	webapp2.Route(r'/parties', handler='party.Parties'),
	webapp2.Route(r'/parties/<pkey>', handler='party.Parties'),
	webapp2.Route(r'/parties/<pkey>/characters', handler='character.Characters'),
	webapp2.Route(r'/characters', handler='character.Characters'),
	webapp2.Route(r'/characters/<ckey>', handler='character.Characters'),
	webapp2.Route(r'/characters/<ckey>/items', handler='character.CharacterItems'),
	webapp2.Route(r'/characters/<ckey>/items/<ikey>', handler='character.CharacterItems'),
	webapp2.Route(r'/items', handler='item.Items'),
	webapp2.Route(r'/items/<ikey>', handler='item.Items'),
], debug=True)
