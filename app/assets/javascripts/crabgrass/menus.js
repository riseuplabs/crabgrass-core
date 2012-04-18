
//
// TOP MENUS
//

var DropMenu = Class.create({
  initialize: function(menu_id) {
    if(!$(menu_id)) return;
    this.trigger = $(menu_id);
    this.menu = $(menu_id).down('.menu_items');
    this.timeout = null;
    if(!this.trigger) return;
    if(!this.menu) return;
    this.trigger.observe('mouseover', this.showMenuEvent.bind(this));
    this.trigger.observe('mouseout', this.hideMenuEvent.bind(this));
    DropMenu.instances.push(this);
  },

  menuIsOpen: function() {
    return($$('.menu_items').detect(function(e){return e.visible()}) != null);
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
    this.menu.show();
    this.trigger.addClassName('menu_visible');
  },

  hideMenu: function() {
    this.menu.hide();
    this.trigger.removeClassName('menu_visible');
  }

});
DropMenu.instances = [];


document.observe('dom:loaded', function() {
  $$(".drop_menu").each(function(element){
    new DropMenu(element.id);
  })
});
