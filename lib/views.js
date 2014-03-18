var reExports = require('./utils').reExports;

exports.config = {
  map: function(doc){
    if(doc._id == 'config'){
      emit('categories', doc.categories);
      emit('statuses',   doc.statuses);
      emit('languages',  doc.languages);
    }
  }
};

reExports(exports, 'modules/Login/views');

reExports(exports, 'modules/Project/views');

reExports(exports, 'modules/Demand/views');

reExports(exports, 'modules/Comment/views');

reExports(exports, 'modules/Activity/views');

reExports(exports, 'modules/Forum/views');

//reExports(exports, 'modules/Notification/views');

reExports(exports, 'modules/Subscription/views');
