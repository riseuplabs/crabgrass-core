Rails.application.routes.draw do
  scope path: 'pages' do
    resources :task_lists, controller: :task_list_page, only: :show
  end

  scope path: 'pages/:page_id' do
    resources :tasks, only: %i[create edit update destroy] do
      post :sort, on: :collection
    end
  end
end
