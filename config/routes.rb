Rails.application.routes.draw do
  resources :todos
 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
root 'todos#index'
get 'todos/download_verbatim'
get '/todos/new(.:format)' , to: 'todos#copy' , as: 'copy_todo'
end

