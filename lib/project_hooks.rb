require "xmlrpc/client"
require "acl_utils"
require_dependency 'projects_controller'

class ProjectsController
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
  alias_method_chain :create, :create_dokuwiki
  
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
  alias_method_chain :update, :update_dokuwiki
  

end