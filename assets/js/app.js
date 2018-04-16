import Elm from './elm';
import 'phoenix_html';

const elmContainer = document.querySelector('#elm-container');
if (elmContainer) Elm.Main.embed(elmContainer);

const platformer = document.querySelector("#platformer");
if (platformer) Elm.Platformer.embed(platformer);