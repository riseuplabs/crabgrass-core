require 'crabgrass/page/engine'

module CrabgrassTaskListPage
  class Engine < ::Rails::Engine
    include Crabgrass::Page::Engine

    register_page_type :TaskListPage,
      controller: ['task_list_page', 'tasks'],
      model: 'TaskList',
      icon: 'page_tasks',
      class_group: ['planning', 'task'],
      order: 3
  end
end

