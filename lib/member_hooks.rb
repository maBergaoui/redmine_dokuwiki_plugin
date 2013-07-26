require "xmlrpc/client"
require "acl_utils"
require_dependency 'members_controller'

class MembersController
    
=begin
    def get_user_roles (user, project)
      roles =[]
      h = project.users_by_role
      h.each do|role, users|
        if h[role].include?(user)
          roles << role
          puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        end
      end
    end
=end

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
  alias_method_chain :create, :create_dokuwiki
  
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
  alias_method_chain :update, :update_dokuwiki
  


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
  alias_method_chain :destroy, :destroy_dokuwiki

end