require "xmlrpc/client"
require "acl_utils"
require_dependency 'groups_controller'

class GroupsController
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
  alias_method_chain :destroy, :destroy_dokuwiki



  
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
  alias_method_chain :edit_membership, :edit_membership_dokuwiki



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
  alias_method_chain :destroy_membership, :destroy_membership_dokuwiki
  
  
  
  
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
  alias_method_chain :add_users, :add_users_dokuwiki
  
  

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
  alias_method_chain :remove_user, :remove_user_dokuwiki

end