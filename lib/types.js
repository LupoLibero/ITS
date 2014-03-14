var reExports = require('./utils').reExports;

exports.project = require('modules/Project/types').Project();

exports.demand = require('modules/Demand/types').Demand();

exports.comment = require('modules/Comment/types').Comment();

reExports(exports, 'modules/Forum/types');

reExports(exports, 'modules/Notification/types');

reExports(exports, 'modules/Login/types');

reExports(exports, 'modules/Subscription/types');
