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
          emit([doc.project_id, 'default', doc.demand_id], doc)
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
            })()
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
          result.lists[list].demands.hasOwnProperty(doc.id)) {
        delete result.lists[list].demands[doc.id];
      }
    }
    function assignToList (doc, list) {
      result.lists[list] = result.lists[list] || {demands: {}};
      doc.rank = Object.keys(result.vote[doc.id] || {}).length;
      result.lists[list].demands[doc.id] = doc.rank;
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
      log(["apply", docId, doc]);
      if (!doc){
        return;
      }
      curr_list_id = doc.list_id;
      if (doc.list_id != 'doing' && doc.list_id != 'done') {
        doc.list_id = 'idea'
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
      assignToList(doc, doc.list_id)
    }

    for(idx = 0 ; idx < values.length ; idx++){
      if (!rereduce) {
        doc = values[idx];
        switch(doc.type) {
          case 'demand_list':
            result.lists[doc.id] = result.lists[doc.id] || {demands: {}};
            for (e in doc) {
              result.lists[doc.id][e] = doc[e];
            }
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
            result.demands[doc.id] = doc;
            applyWorkflowRules(doc.id);
            break;
        }
      }
      else {
        if (!values[idx]) {
          continue;
        }
        // merge demand_lists
        for (id in values[idx].lists) {
          doc = values[idx].lists[id];
          result.lists[doc.id] = result.lists[doc.id] || {};
          for (e in doc) {
            result.lists[doc.id][e] = doc[e];
          }
        }
        // merge votes
        (function (votesBydemandId) {
          var demandId, votes;
          for (demandId in votesBydemandId) {
            votes = values[idx].vote[demandId];
            result.vote[demandId] = result.vote[demandId] || {};
            for (var voter in votes) {
              result.vote[demandId][voter] = votes[voter];
            }
            recalculateRank(id);
          }
        })(values[idx].vote)
        // merge cost_estimates
        for (id in values[idx].cost_estimate) {
          result.cost_estimate[id] = values[idx].cost_estimate[id];
          applyWorkflowRules(id);
        }
        // merge demands
        for (id in values[idx].demands) {
          result.demands[id] = values[idx].demands[id];
          applyWorkflowRules(doc.id);
        }
      }
    }
    return result;
  }
}

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

