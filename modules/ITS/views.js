var reExports = require('./utils').reExports;

//exports['lib'] = require('../Translation/views/lib/translation');


exports.config = {
  map: function(doc){
    if(doc._id == 'config'){
      emit('categories', doc.categories);
      emit('statuses',   doc.statuses);
      emit('languages',  doc.languages);
    }
  }
};

reExports(exports, '../Login/views');

reExports(exports, '../Project/views');

reExports(exports, '../Card/views');

reExports(exports, '../Comment/views');

reExports(exports, '../Activity/views');

reExports(exports, '../Subscription/views');

reExports(exports, '../Notification/views');

reExports(exports, '../Vote/views');
