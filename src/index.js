'use strict';

require('./index.html');
var Elm = require('./Main.elm');

// Get the DOM node to put the Elm app into. Clear it out
// in case there's a "Loading..." or similar inside it.
var node = document.getElementById('main');
while (node.lastChild) node.removeChild(box.lastChild);

Elm.Main.embed(node, {
  apiBaseUrl: process.env.API_BASE_URL
});
