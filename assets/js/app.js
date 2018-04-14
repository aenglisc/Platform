import Elm from './main';
import 'phoenix_html';

const elmContainer = document.querySelector('#elm-container');
if (elmContainer) Elm.Main.embed(elmContainer);
