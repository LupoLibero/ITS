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
    var idx, id, e, doc;
    var result = {
      lists: {},
      demands: {},
      cost_estimate: {},
      vote: {}
    };
    function removeFromList (doc, list) {
      if (result.lists.hasOwnProperty(list) &&
          result.lists[list].hasOwnProperty('demands') &&
          result.lists[list].demands.hasOwnProperty(doc.id)) {
        delete result.lists[list].demands[doc.id];
      }
    }
    function assignToList (doc, listId) {
      result.lists[listId] = result.lists[listId] || {};
      result.lists[listId].demands = result.lists[listId].demands || {};
      doc.rank = Object.keys(result.vote[doc.id] || {}).length;
      result.lists[listId].demands[doc.id] = doc.rank;
    }
    function recalculateRank (docId) {
      var doc = result.demands[docId];
      if (doc && doc.hasOwnProperty('list_id')) {
        assignToList(doc, doc.list_id);
      }
    }
    function applyWorkflowRules (docId) {
      var doc = result.demands[docId];
      var curr_list_id;
      //log(["apply", docId, doc]);
      if (!doc){
        return;
      }
      curr_list_id = doc.list_id;
      if (doc.list_id != 'doing' && doc.list_id != 'done') {
        doc.list_id = 'ideas';
        if (doc.tag_list.length) {
          doc.list_id = 'todo';
          if (result.cost_estimate.hasOwnProperty(doc.id)) {
            doc.list_id = 'estimated';
            if (doc.hasOwnProperty('funds') &&
                doc.funds >= doc.cost_estimate) {
              doc.list_id = 'funded';
            }
          }
        }
      }
      if (doc.list_id != curr_list_id) {
        removeFromList(doc, curr_list_id);
      }
      assignToList(doc, doc.list_id);
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


    for(idx = 0 ; idx < values.length ; idx++){
      if (!rereduce) {
        doc = values[idx];
        switch(doc.type) {
          case 'demand_list':
            result.lists[doc.id] = result.lists[doc.id] || {};
            result.lists[doc.id].demands = result.lists[doc.id].demands || {};
            /*for (e in doc) {
              result.lists[doc.id][e] = doc[e];
            }*/
            var test = {}
            test[doc.id] = doc;
            //mergeDemandLists(result.lists, test);
            recursive_merge(result.lists, test, {});
            break;
          case 'cost_estimate':
            result.cost_estimate[doc.demand_id] = doc.estimate;
            applyWorkflowRules(doc.demand_id);
            break;
          case 'vote':
            result.vote[doc.demand_id] = result.vote[doc.demand_id] || {};
            result.vote[doc.demand_id][doc.voter] = doc.vote;
            recalculateRank(doc.demand_id);
            break;
          case 'demand':
            log("demand reduce");
            result.demands[doc.id] = doc;
            applyWorkflowRules(doc.id);
            break;
        }
      }
      else {
        if (values[idx] === null) {
          log(["null", keys, values]);
          continue;
        }
        // merge demand_lists
        recursive_merge(result.lists, values[idx].lists, {});
        // merge votes
        recursive_merge(result.votes, values[idx].votes, {});

        recursive_merge(result.cost_estimate, values[idx].cost_estimate, {});
        /*for (id in values[idx].cost_estimate) {
          result.cost_estimate[id] = values[idx].cost_estimate[id];
          applyWorkflowRules(id);
        }*/
        // merge demands
        recursive_merge(result.demands, values[idx].demands, {});
        /*for (id in values[idx].demands) {
          result.demands[id] = values[idx].demands[id];
          applyWorkflowRules(id);
        }*/
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

