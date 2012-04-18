//
// This is a dummy json2.js with the same API, but it doesn't do anything.
// Created because I don't want or need the functionality it provides to history.js
//

if (!window.JSON) {
    window.JSON = {};
}

(function () {
    if (typeof JSON.stringify !== 'function') {
        JSON.stringify = function (value, replacer, space) {return "{}" }
    }

    if (typeof JSON.parse !== 'function') {
        JSON.parse = function (text, reviver) { return {} }
    }
}());
