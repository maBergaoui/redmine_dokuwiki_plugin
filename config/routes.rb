RedmineApp::Application.routes.draw do  
  match 'dokuwiki/show', :to => 'dokuwiki#show'
end
