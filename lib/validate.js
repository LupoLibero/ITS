exports.validate_doc_update = function(newDoc, oldDoc, userCtx) {
	var e;
	function assert(assertion, message) {
		if(!assertion)
			throw({forbidden: message || 'unauth'});
	}
	function require(field, message) {
		message = 'missing_' + field;
		//if (!newDoc[field]) throw({forbidden : message});
		assert(newDoc[field], message)
	}
	function unchanged(field, message) {
		if (oldDoc && oldDoc[field] !== undefined 
				&& toJSON(oldDoc[field]) != toJSON(newDoc[field])
				&& !isDbAdmin())
			throw({forbidden: message || 'changed_' + field});
	}
	var hasRole = function() {
		var roles = {};
		for(var i in userCtx.roles) {
			roles[userCtx.roles[i]] = null;
		}
		return function(role) {
			return role in roles;
		};
	}();
	function isLoggedIn() {
		return Boolean(userCtx.name);
	}
	function loginRequired() {
		//if(!isLoggedIn())
		//	throw({forbidden: 'loginreq'})
		assert(isLoggedIn(), 'loginreq');
	}
	function isAuthorized(username) {
		log(username + " " + userCtx.name + " " + userCtx.roles);
		return isLoggedIn() && (userCtx.name == username || hasRole(username) || isDbAdmin());
	}
	function authorizationRequired(username) {
		//if(!isAuthorized(username))
		//	throw({forbidden: 'unauth'});
		assert(isAuthorized(username));
	}
	function isDbAdmin() {
		return hasRole('_admin');
	}
	function isAdmin() {
		return isDbAdmin();
	}
	require('_id');
	//require('type');
	unchanged('type');
	unchanged('id');
	switch(newDoc.type) {
		case 'project':
			loginRequired();
			require('id');
			unchanged('id');
			assert(newDoc['_id'] == 'project-' + newDoc['id'], '_id must be <"project-"+id>')
			break;
		case 'ticket':
			loginRequired();
			require('id');
			unchanged('id');
			require('category');
			require('created_at');
			unchanged('created_at');
			//require('init_lang');
			//unchanged('init_lang');
			require('status');
			/*require('translatable');
			for(e in newDoc.translatable) {
				require(e);
				require(e + '_versions');
			}*/
			require('votes');
			(function(newDoc, oldDoc) {
				var newLen, oldLen;
				if(!oldDoc){
					oldDoc = {'votes': []};
				}
				newLen = newDoc['votes'].length;
				oldLen = oldDoc['votes'].length;
				newLast = newDoc['votes'].slice(-1)[0];
				oldLast = oldDoc['votes'].slice(-1)[0];
				var votes_nb_diff = newDoc['votes'].length - oldDoc['votes'].length;
				if(newLen > oldLen){
					assert(newLen == oldLen + 1, "Adding more than one vote at a time");
					assert(newLast != oldLast, "Technical issue: new vote must be pushed at the end");
					assert(newLast == userCtx.name, "You can't vote for someone else");
				} else if(newLen < oldLen){
					assert(newLen + 1 == oldLen, "Removing more than one vote at a time");
					for(var key in oldDoc['votes']){
						if(oldDoc['votes'][key] != newDoc['votes'][key]){
							assert(userCtx.name == oldDoc[key], "You can't delete someone else's vote");
						}
					}
				}
			})(newDoc, oldDoc);
			
			if(oldDoc) {
				for(e in oldDoc._attachments) {
					if(!newDoc._attachments[e]) throw({forbidden: 'attachment_' + e});
				}
			}
			break;
		case 'worklog':
			loginRequired();
			require('declaredAt');
			//require('desc');
			require('duration');
			//require('start_date');
			require('ticketId');
			require('user');
			unchanged('user');
			//require('work_type');
			require('activityItems')
			break;
		case 'ticket-comment':
			loginRequired();
			require('created_at');
			unchanged('created_at')
			require('message');
			require('ticket_id');
			unchanged('ticket_id')
			require('user');
			unchanged('user')
			break;
	}
};
