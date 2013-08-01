require "util"

module DokuWikiPlugin
  module Patches
    module UsersControllerPatch

      def self.included(base)
        base.class_eval do
          unloadable
        end

        base.send(:alias_method_chain, :destroy, :destroy_dokuwiki)
        base.send(:alias_method_chain, :destroy_membership, :destroy_membership_dokuwiki)
        base.send(:alias_method_chain, :edit_membership, :edit_membership_dokuwiki)
        base.send(:alias_method_chain, :edit, :edit_dokuwiki)
      end
      
      #Called when deleting a user
      def destroy_with_destroy_dokuwiki
        #Retrieving informations
        user_to_destroy = @user
        
        #Synchronising the ACLs
        scopes = []
        all_projects = Project.all
        all_projects.each do|project|
          member = Member.where("user_id = ? AND project_id = ?",user_to_destroy.id,project.id).first
          if member
            scopes << project.name
          end  
        end
        scopes.each do |scope|
          puts scope+"   "+user_to_destroy.login
          delete_acl(scope,user_to_destroy.login)
        end
        
        #Call to the orignial method
        destroy_without_destroy_dokuwiki
      end
      
      #Called when removing a user from a project via the user administration page
      def destroy_membership_with_destroy_membership_dokuwiki
        #Retrieving informations
        user = User.find(params[:id])
        project = Project.find(Member.find(params[:membership_id]).project_id)
            
        #Call to the orignial method
        destroy_membership_without_destroy_membership_dokuwiki
        
        #Synchronising the ACLs
        delete_acl(project.name,user.login)
      end
      
      
      #Called when adding a project to a user or editing its roles via the user administration page
      def edit_membership_with_edit_membership_dokuwiki
        #Retrieving informations
        user = User.find(params[:id])
        if params[:membership]["project_id"]
          project = Project.find(params[:membership]["project_id"])
        else
          project = Project.find(Member.find(params[:membership_id]).project_id);
        end
            
        #Call to the orignial method
        edit_membership_without_edit_membership_dokuwiki
        
        #Synchronising the ACLs
        roles = get_roles(user, project)
        permission = get_permission(roles)
        update_acl(project.name,user.login,permission)
      end
      
    
      #Called when adding/removing a user to/from a group via the user administration page
      def edit_with_edit_dokuwiki
        #Retrieving informations
        user = User.find(params[:id])
        
        #Call to the orignial method
        edit_without_edit_dokuwiki
        
        #Synchronising the ACLs
        projects = []
        all_projects = Project.all
        all_projects.each do|project|
          member = Member.where("user_id = ? AND project_id = ?",user.id,project.id).first
          if member
            projects << project
          end  
        end
        projects.each do |project|
          roles = get_roles(user, project)
          permission = get_permission(roles)
          update_acl(project.name,user.login,permission)
        end
      end
    end
  end
end


unless UsersController.included_modules.include?(DokuWikiPlugin::Patches::UsersControllerPatch)
  UsersController.send(:include, DokuWikiPlugin::Patches::UsersControllerPatch)
end





