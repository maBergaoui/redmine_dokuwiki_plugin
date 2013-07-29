require 'redmine'
require 'member_patch'
require 'user_patch'
require 'group_patch'
require 'project_patch'
require 'account_patch'

Rails.logger.info 'Starting dokuWiki plugin for Redmine'

Redmine::Plugin.register :dokuwiki do
  name 'DokuWiki Plugin'
  author 'Eurogiciel'
  description 'A plugin which synchronize dokuwiki with a redmine project'
  version '1.0'

  settings :default => {}, :partial => 'settings/dokuwiki_settings'

  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :dokuwiki do
    # This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :view_tab, {:dokuwiki => :show}
  end

  # A new item is added to the project menu
  menu(:project_menu,
       :dokuwiki,
       { :controller => 'dokuwiki', :action => 'show' })
end