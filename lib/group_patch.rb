# Redmine - project management software
# Copyright (C) 2013  Mohamed Amine BERGAOUI
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require "util"

module DokuWikiPlugin
  module Patches
    module GroupsControllerPatch
      def self.included(base)
        base.class_eval do
          unloadable
        end

        # Edit adds new functionality, so don't silently fail!
        base.send(:alias_method_chain, :destroy, :destroy_dokuwiki)
        base.send(:alias_method_chain, :edit_membership, :edit_membership_dokuwiki)
        base.send(:alias_method_chain, :destroy_membership, :destroy_membership_dokuwiki)
        base.send(:alias_method_chain, :add_users, :add_users_dokuwiki)
        base.send(:alias_method_chain, :remove_user, :remove_user_dokuwiki)
      end

      #Called when a group is deleted
      def destroy_with_destroy_dokuwiki
        #Retrieving informations
        group_to_destroy = @group
        users_to_update = []
        group_to_destroy.users.each do|user_to_update|
          users_to_update << user_to_update
        end
        projects = []
        all_projects = Project.all
        all_projects.each do|project|
          member = Member.where("user_id = ? AND project_id = ?",group_to_destroy.id,project.id).first
          if member
          projects << project
          end
        end

        #Call to the orignial method
        destroy_without_destroy_dokuwiki

        #Synchronising the ACLs
        users_to_update.each do |user|
          projects.each do |project|
            roles = get_roles(user, project)
            permission = get_permission(roles)
            update_acl(project.name,user.login,permission)
          end
        end

      end

      #Called when adding a project to a group or editing its roles via the group administration interface
      def edit_membership_with_edit_membership_dokuwiki
        #Retrieving informations
        group = Group.find(params[:id])
        if params[:membership]["project_id"]
          project = Project.find(params[:membership]["project_id"])
        else
          project = Project.find(Member.find(params[:membership_id]).project_id)
        end

        #Call to the orignial method
        edit_membership_without_edit_membership_dokuwiki

        #Synchronising the ACLs
        group.users.each do|user|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          update_acl(project.name,user.login,permission)
        end
      end

      #Called when removing a project from the group assignations via the group administration interface
      def destroy_membership_with_destroy_membership_dokuwiki
        #Retrieving informations
        group = Group.find(params[:id])
        project = Project.find(Member.find(params[:membership_id]).project_id)

        #Call to the orignial method
        destroy_membership_without_destroy_membership_dokuwiki

        #Synchronising the ACLs
        group.users.each do|user|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          update_acl(project.name,user.login,permission)
        end
      end

      #Called when adding a user to a group via the group administration interface
      def add_users_with_add_users_dokuwiki
        #Retrieving informations
        group = Group.find(params[:id])
        users = []
        params[:user_ids].each do |user_id|
          users << User.find(user_id)
        end
        projects = []
        all_projects = Project.all
        puts all_projects
        all_projects.each do|project|
          member = Member.where("user_id = ? AND project_id = ?",group.id,project.id).first
          if member
          projects << project
          end
        end

        #Call to the orignial method
        add_users_without_add_users_dokuwiki

        #Synchronising the ACLs
        users.each do|user|
          projects.each do|project|
            roles = get_roles(user, project)
            permission = get_permission(roles)
            update_acl(project.name,user.login,permission)
          end
        end
      end

      #Called when removing a user from a group via the group administration interface
      def remove_user_with_remove_user_dokuwiki
        #Retrieving informations
        group = Group.find(params[:id])
        user = User.find(params[:user_id])
        projects = []
        all_projects = Project.all
        all_projects.each do|project|
          member = Member.where("user_id = ? AND project_id = ?",group.id,project.id).first
          if member
          projects << project
          end
        end

        #Call to the orignial method
        remove_user_without_remove_user_dokuwiki

        #Synchronising the ACLs
        projects.each do|project|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          update_acl(project.name,user.login,permission)
        end
      end

    end
  end
end

unless GroupsController.included_modules.include?(DokuWikiPlugin::Patches::GroupsControllerPatch)
  GroupsController.send(:include, DokuWikiPlugin::Patches::GroupsControllerPatch)
end