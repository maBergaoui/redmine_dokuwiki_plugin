require "xmlrpc/client"
require "acl_utils"
require_dependency 'users_controller'

class UsersController
  def destroy_with_destroy_dokuwiki_rule
    #Retrieving informations
    user_to_destroy = @user
    
    #Syncing the ACLs
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
    destroy_without_destroy_dokuwiki_rule
    
  end
  alias_method_chain :destroy, :destroy_dokuwiki_rule
  
  def edit_membership_with_edit_membership_dokuwiki_rule
    #Retrieving informations
    user = User.find(params[:id])
    if params[:membership]["project_id"]
      project = Project.find(params[:membership]["project_id"])
    else
      project = Project.find(Member.find(params[:membership_id]).project_id);
    end
        
    #Call to the orignial method
    edit_membership_without_edit_membership_dokuwiki_rule
    
    #Syncing the ACLs
    roles = get_roles(user, project)
    permission = get_permission(roles)
    update_acl(project.name,user.login,permission)
  end
  alias_method_chain :edit_membership, :edit_membership_dokuwiki_rule

  def edit_with_edit_dokuwiki_rule
    #Retrieving informations
    user = User.find(params[:id])
    
    #Call to the orignial method
    edit_without_edit_dokuwiki_rule
    
    #Syncing the ACLs
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
  alias_method_chain :edit, :edit_dokuwiki_rule

end