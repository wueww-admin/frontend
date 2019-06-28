import './bootstrap.scss';

import Elm from './Main.elm';

const TOKEN_KEY = 'de.metafnord.wueww-admin.token';

const node = document.getElementById('root');

if (node === null) {
    throw new Error('Unable to find root element to mount to');
}

const app = Elm.Elm.Main.init({
    node,
    flags: {
        token: localStorage.getItem(TOKEN_KEY),
    },
});

app.ports.token_.subscribe(newToken => localStorage.setItem(TOKEN_KEY, newToken));
