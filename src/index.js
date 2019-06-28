require('bootstrap/scss/bootstrap.scss');

const { Elm } = require('./Main');

Elm.Main.init({
    node: document.getElementById('root'),
});
