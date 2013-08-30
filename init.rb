require 'redmine'
require 'member_patch'
require 'user_patch'
require 'group_patch'
require 'project_patch'

Rails.logger.info 'Starting dokuWiki plugin for Redmine'

Redmine::Plugin.register :redmine_dokuwiki_plugin do
  name 'DokuWiki Plugin'
  author 'Groupe Eurogiciel'
  description 'A plugin which synchronize dokuwiki with a redmine project'
  version '0.1'

  settings :default => {}, :partial => 'settings/redmine_dokuwiki_plugin_settings'

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
