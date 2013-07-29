require "util"

module DokuWikiPlugin
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.class_eval do
          unloadable
        end

        # Edit adds new functionality, so don't silently fail!
        base.send(:alias_method_chain, :create, :create_dokuwiki)
        base.send(:alias_method_chain, :update, :update_dokuwiki)
        base.send(:alias_method_chain, :destroy, :destroy_dokuwiki)
      end

      #Called when creating a project (pertinent for roles inheritance)
      def create_with_create_dokuwiki
        #Call to the orignial method
        create_without_create_dokuwiki

        #Retrieving informations
        project = Project.find(:last)
        puts "ok"
        puts project
        users = []
        h = project.users_by_role
        h.each do|role,_|
          users=users+h[role]
        end
        users.uniq

        #Synchronising the ACLs
        users.each do |user|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          update_acl(project.name,user.login,permission)
        end

      end

      #Called when updating a project just after creating it (pertinent for roles inheritance)
      def update_with_update_dokuwiki
        #Call to the orignial method
        update_without_update_dokuwiki

        #Retrieving informations
        project = Project.find(params[:id])
        users = []
        h = project.users_by_role
        h.each do|role,_|
          users=users+h[role]
        end
        users.uniq

        #Synchronising the ACLs
        users.each do |user|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          update_acl(project.name,user.login,permission)
        end

      end

      #Called when deleteing a project
      def destroy_with_destroy_dokuwiki
        #Retrieving informations
        project = @project
        users = []
        h = project.users_by_role
        h.each do|role,_|
          users=users+h[role]
        end
        users.uniq

        #Synchronising the ACLs
        users.each do |user|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          delete_acl(project.name,user.login)
        end

        #Call to the orignial method
        destroy_without_destroy_dokuwiki
      end

    end
  end
end

unless ProjectsController.included_modules.include?(DokuWikiPlugin::Patches::ProjectsControllerPatch)
  ProjectsController.send(:include, DokuWikiPlugin::Patches::ProjectsControllerPatch)
end