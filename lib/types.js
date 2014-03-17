var reExports = require('./utils').reExports;

exports.project = require('modules/Project/types').Project();

reExports(exports, 'modules/Demand/types');

exports.comment = require('modules/Comment/types').Comment();

reExports(exports, 'modules/Forum/types');

reExports(exports, 'modules/Notification/types');

reExports(exports, 'modules/Login/types');

reExports(exports, 'modules/Subscription/types');
