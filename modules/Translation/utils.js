var fields = require('lib/types');

exports.registerTranslation = function (doc, form, type, element, lang) {
  // If the lang is not passed throw an error
  if(lang == undefined) {
    throw({forbidden: 'No language code'});
  }
  // If the is translatable
  if (!fields[type].fields[element].translatable) {
    return false
  }

  var value = null;
  if(form.hasOwnProperty(element)){
    value = form[element];
  } else {
    value = form.value;
  }

  // If field is not an object store the value an put
  // it into the init_lang or 'default' language
  if(typeof doc[element] != 'object') {
    var saved = doc[element];
    doc[element] = {}
    if(doc.hasOwnProperty('init_lang')){
      doc[element][doc.init_lang] = saved;
    } else {
      doc[element]['default'] = saved;
    }
  }
}
