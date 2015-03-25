
//
// TOP MENUS
// This uses the bootstrap css, but not the bootstrap js
//
// Structure:
//
//   %li.top-menu#menu_me
//     %a Me
//     %ul.dropdown-menu
//
var DropMenu = Class.create({
  initialize: function(menu_id) {
    if(!$(menu_id)) return;
    this.trigger = $(menu_id);
    this.menu = $(menu_id).down('.dropdown-menu');
    this.timeout = null;
    if(!this.trigger) return;
    if(!this.menu) return;
    this.trigger.observe('mouseover', this.showMenuEvent.bind(this));
    this.trigger.observe('mouseout', this.hideMenuEvent.bind(this));
    DropMenu.instances.push(this);
  },

  menuIsOpen: function() {
    return($$('.dropdown-menu').detect(function(e){return e.visible()}) != null);
  },

  clearEvents: function(event) {
    if (this.timeout) window.clearTimeout(this.timeout);
    event.stop();
  },

  showMenuEvent: function(event) {
    evalAttributeOnce(this.menu, 'data-onvisible');
    this.clearEvents(event);
    if (this.menuIsOpen()) {
      DropMenu.instances.invoke('hideMenu');
      this.showMenu();
    } else {
      this.timeout = this.showMenu.bind(this).delay(0.3);
    }
  },

  hideMenuEvent: function(event) {
    this.clearEvents(event);
    this.timeout = this.hideMenu.bind(this).delay(0.3);
  },

  showMenu: function() {
    this.menu.show()
    this.trigger.addClassName('menu-visible');
  },

  hideMenu: function() {
    this.menu.hide();
    this.trigger.removeClassName('menu-visible');
  }

});
DropMenu.instances = [];

document.observe('dom:loaded', function() {
  $$(".top-menu").each(function(element){
    new DropMenu(element.id);
  })
});
