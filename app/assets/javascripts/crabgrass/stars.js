//
// renderStars
//
// Will look for elements with [data-star=n] and prepend n div.star nodes
// to their content.
//
// This is triggered on dom:loaded so all data-star nodes will be filled.
// But when updating their content this needs to be triggered again.
//
// renderStars will check if an element already contains stars and move on
// if it does. This way it can process the entire dom again even if just
// a part of the page has been altered.
//

function renderStars() {

  function randomPercent() {
    return Math.floor(Math.random() * 101).toString() + '%';
  }

  function randomPosition() {
    var x = randomPercent();
    var y = randomPercent();
    return x + ' ' + y;
  }

  function newStar(index) {
    var star = document.createElement("div");
    star.classList.add('star');
    star.classList.add('star_' + index % 3);
    star.style.backgroundPosition = randomPosition();
    return star;
  }

  function addStar(elem, index) {
    // prepend the star so the absolute positioning works
    elem.insertBefore(newStar(index), elem.childNodes[0]);
  }

  function addStars(elem) {
    var count = JSON.parse(elem.readAttribute('data-stars'));
    // starred already...
    if (elem.children[0].classList.contains('star')) return;
    for (var i = 0; i < count; i++) addStar(elem, i);
  }

  function processDataStars(starredList) {
    // stupid NodeList does not understand forEach...
    for (var i = 0; i < starredList.length; ++i) addStars(starredList[i]);
  }

  var starredList = document.querySelectorAll("[data-stars]");
  processDataStars(starredList);
}

document.observe("dom:loaded", renderStars);
