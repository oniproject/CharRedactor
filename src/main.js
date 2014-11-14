'use strict';

require('insert-css')(require('./app.styl'));

var Vue = require('vue');
var app = new Vue(require('./app.coffee')).$mount('#app');
