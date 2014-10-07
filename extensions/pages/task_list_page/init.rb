
define_page_type :TaskListPage, {
  controller: ['task_list_page', 'tasks'],
  model: 'TaskList',
  icon: 'page_tasks',
  class_group: ['planning', 'task'],
  order: 3
}

Crabgrass.mod_routes do
  scope path: 'pages' do
    resources :task_lists, controller: :task_list_page
  end

  scope path: 'pages/:page_id' do
    resources :tasks do
      post :sort, on: :collection
    end
  end
end

