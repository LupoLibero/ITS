exports.demand_all = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    var rank, list_id;

    if (doc.type) {
      switch(doc.type) {
        case 'demand_list':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag],
            {
              id:    doc.id,
              name:  doc.name,
              type:  doc.type,
            },
            {name: true}
          );
          break;
        case 'demand':
          translation.emitTranslatedDoc(
            [doc.project_id, translation._keyTag, doc.id],
            {
              project_id:  doc.project_id,
              id:          doc.id,
              title:       doc.title,
              init_lang:   doc.init_lang,
              type:        doc.type,
              list_id:     doc.list_id,
              tag_list:    doc.tag_list,
            },
            {title: true}
          );
          break;
        case 'cost_estimate':
          emit([doc.project_id, 'default', doc.demand_id], doc);
          break;
        case 'payment':
          emit([doc.project_id, 'default', doc.demand_id], doc);
          break;
        case 'vote':
          if (doc.voted_doc_id.split('-')[0] == 'demand') {
            (function() {
              var demandId = doc.voted_doc_id.split('-')[1];
              emit(
                [
                  demandId.split('#')[0].toLowerCase(),
                  "default",
                  demandId
                ],
                {
                  voter: doc.voter,
                  vote: doc.vote,
                  demand_id: demandId,
                  type: doc.type
              });
            })();
          }
          break;
      }
    }
  },
  reduce: function (keys, values, rereduce) {
    var idx, id, e, i, doc;
    var result = {
      lists: [
        {id: 'ideas'},
        {id: 'todo'},
        {id: 'estimated'},
        {id: 'funded'},
        {id: 'doing'},
        {id: 'done'},
      ],
      demands: [],
      cost_estimate: {},
      vote: {},
      payment: {}
    };
    var reverseMapping = {};
    function demandIndexFromId (id) {
      return reverseMapping[id] || -1;
    }
    function recalculateRank (i) {
      var doc = result.demands[i];
      log(["rank", i]);
      if (doc) {
        doc.rank = Object.keys(result.vote[doc.id] || {}).length;
      }
    }
    function applyWorkflowRules (i) {
      if(i < 0) {
        return
      }
      var doc = result.demands[i];
      var curr_list_id;
      curr_list_id = doc.list_id;
      if (doc.list_id != 'doing' && doc.list_id != 'done') {
        doc.list_id = 'ideas';
        if (doc.tag_list.length) {
          doc.list_id = 'todo';
          if (result.cost_estimate.hasOwnProperty(doc.id)) {
            doc.list_id = 'estimated';
            if (result.payment.hasOwnProperty(doc.id) &&
                result.payment[doc.id] >= result.cost_estimate[doc.id]) {
              doc.list_id = 'funded';
            }
          }
        }
      }
    }
    recursive_merge = function(dst, src, special_merge){
			var e;
			if(!dst){
				return src
			}
			if(!src){
				return dst
			}
			if(typeof(src) == 'object'){
				for(e in src){
					if(e in special_merge){
						dst[e] = special_merge[e](e, dst, src);
					} else {
						dst[e] = recursive_merge(dst[e], src[e], special_merge)
					}
				}
			}
			return dst;
		}

    if (!rereduce) {
      for(idx = 0 ; idx < values.length ; idx++){
        doc = values[idx];
        switch(doc.type) {
          case 'demand_list':
            for (var id in result.lists) {
              if (doc.id == result.lists[id].id) {
                recursive_merge(result.lists[id], doc, {});
              }
            }
            break;
          case 'cost_estimate':
            result.cost_estimate[doc.demand_id] = doc.estimate;
            applyWorkflowRules(demandIndexFromId(doc.demand_id));
            break;
          case 'payment':
            result.payment[doc.demand_id] = doc.amount;
            applyWorkflowRules(demandIndexFromId(doc.demand_id));
            break;
          case 'vote':
            result.vote[doc.demand_id] = result.vote[doc.demand_id] || {};
            result.vote[doc.demand_id][doc.voter] = doc.vote;
            recalculateRank(demandIndexFromId(doc.demand_id));
            break;
          case 'demand':
            i = result.demands.push(doc);
            reverseMapping[doc.id] = i - 1;
            recalculateRank(i-1);
            applyWorkflowRules(i-1);
            break;
        }
      }
    }
    else {
      for(idx = 0 ; idx < values.length ; idx++){
        recursive_merge(result, values[idx], {});
        for (i = 0 ; i < result.demand ; i++) {
          recalculateRank(i);
          applyWorkflowRules(i);
        }
      }
    }
    return result;
  }
};

exports.demand_get = {
  map: function(doc) {
    var translation = require('views/lib/translation').translation();
    if(doc.type && doc.type == 'demand'){
      if(doc.project_id && doc.id) {
        translation.emitTranslatedDoc(
          [doc.id, translation._keyTag],
          {
            _rev:         doc._rev,
            _id:          doc._id,
            project_id:   doc.project_id,
            id:           doc.id,
            category:     doc.category,
            description:  doc.description,
            status:       doc.status,
            title:        doc.title,
            created_at:   doc.created_at,
            updated_at:   doc.updated_at,
            init_lang:    doc.init_lang,
          },
          {title: true, description:true}
        );
      }
    }
  }
}

exports.demand_ids = {
  map: function(doc) {
    if(doc.type && doc.type == "demand" && doc.project_id && doc.id){
      var splitId = doc.id.split('#');
      if(splitId.length == 2)
        emit(doc.project_id, parseInt(splitId[1]));
    }
  },
  reduce: "_stats"
}

exports.demand_votes = {
  map: function(doc) {
    if(doc.type){
      if(doc.type == 'demand_vote') {
        if(doc.demand_id && doc.user_id){
          emit(doc.demand_id, 1);
        }
      }
    }
  },
  reduce: "_sum"
}

