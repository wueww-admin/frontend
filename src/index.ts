import 'bootstrap/scss/bootstrap.scss';

import Elm from './Main.elm';

const node = document.getElementById('root');

if (node === null) {
    throw new Error('Unable to find root element to mount to');
}

Elm.Elm.Main.init({
    node,
    flags: {
        token: localStorage.getItem('de.metafnord.wueww-admin.token'),
    },
});
