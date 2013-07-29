require "util"

module DokuWikiPlugin
  module Patches
    module MembersControllerPatch
      def self.included(base)
        base.class_eval do
          unloadable
        end

        # Edit adds new functionality, so don't silently fail!
        base.send(:alias_method_chain, :create, :create_dokuwiki)
        base.send(:alias_method_chain, :update, :update_dokuwiki)
        base.send(:alias_method_chain, :destroy, :destroy_dokuwiki)
      end

      ##Called when adding a member to a project via the project settings page
      def create_with_create_dokuwiki
        #Retrieving informations
        user_ids = params[:membership].dup.delete(:user_ids)
        current_project = @project

        #Call to the orignial method
        create_without_create_dokuwiki

        #Synchronising the ACLs
        users =[]
        user_ids.each do |user_id|
          begin
            users << User.find(user_id)
          rescue
            users = users + Group.find(user_id).users
          end
        end
        users = users.uniq
        users.each do |user|
          roles = get_roles(user, current_project)
          permission = get_permission(roles)
          update_acl(current_project.name,user.login,permission)
        end

      end

      #Called when editing a member's role in a project via the project settings page
      def update_with_update_dokuwiki
        #Retrieving informations
        member_to_update = @member
        current_project = @project

        #Call to the orignial method
        update_without_update_dokuwiki

        #Synchronising the ACLs
        user_id = member_to_update.user_id
        users =[]
        begin
          users << User.find(user_id)
        rescue
          users = users + Group.find(user_id).users
        end
        users = users.uniq
        users.each do |user|
          roles = get_roles(user, current_project)
          permission = get_permission(roles)
          update_acl(current_project.name,user.login,permission)
        end

      end

      #Called when removing a project from a user/group assignations via the project setting page
      def destroy_with_destroy_dokuwiki
        #Retrieving informations
        member_to_destroy = @member
        current_project = @project

        #Call to the orignial method
        destroy_without_destroy_dokuwiki

        #Synchronising the ACLs
        user_id = member_to_destroy.user_id
        users =[]
        begin
          users << User.find(user_id)
        rescue
          users = users + Group.find(user_id).users
        end
        users = users.uniq
        users.each do |user|
          roles = get_roles(user, current_project)
          permission = get_permission(roles)
          update_acl(current_project.name,user.login,permission)
        end
      end

    end
  end
end

unless MembersController.included_modules.include?(DokuWikiPlugin::Patches::MembersControllerPatch)
  MembersController.send(:include, DokuWikiPlugin::Patches::MembersControllerPatch)
end
