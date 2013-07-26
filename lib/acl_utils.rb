require "xmlrpc/client"

$role_permission = { "none" => 0,
                     "read" => 1,
                     "edit" => 2,
                     "create" => 4,
                     "upload" => 8,
                     "delete" => 16
                   }
                   
                   
#Call to the xmlrpc api to delete a rule
def delete_acl(scope,user)
  server = XMLRPC::Client.new(Setting.plugin_dokuwiki['dokuwiki_xmlrpc_host'],
                              Setting.plugin_dokuwiki['dokuwiki_xmlrpc_location'],
                              nil,
                              nil,
                              nil,
                              Setting.plugin_dokuwiki['dokuwiki_admin'],
                              Setting.plugin_dokuwiki['dokuwiki_password'],
                              nil,
                              nil)
  begin
    puts server.call("dokuwiki.delAcl",scope,user)
  rescue XMLRPC::FaultException => e
    puts "Error: "
    puts e.faultCode
    puts e.faultString
  end                          
end

#Call to the xmlrpc api to update/create a rule
def update_acl(scope,user,permission)
  server = XMLRPC::Client.new(Setting.plugin_dokuwiki['dokuwiki_xmlrpc_host'],
                              Setting.plugin_dokuwiki['dokuwiki_xmlrpc_location'],
                              nil,
                              nil,
                              nil,
                              Setting.plugin_dokuwiki['dokuwiki_admin'],
                              Setting.plugin_dokuwiki['dokuwiki_password'],
                              nil,
                              nil)
  begin
    puts server.call("dokuwiki.delAcl",scope,user)
    if permission != 0
      puts server.call("dokuwiki.addAcl",scope,user,permission)  
    end
  rescue XMLRPC::FaultException => e
    puts "Error: "
    puts e.faultCode
    puts e.faultString
  end                          
end

#Get the permission value for a list of roles
def get_permission(roles)
  permission = 0
  roles.each do|role|
    aux = $role_permission[Setting.plugin_dokuwiki['roles_'+role.name]]
    if aux > permission
      permission = aux
    end
  end
  return permission
end

#Get user roles for a project
def get_roles(user,project)
  roles = []
  begin
    member = Member.where("user_id = ? AND project_id = ?",user.id,project.id).first
  member_roles = MemberRole.where("member_id = ?", member.id).all
    member_roles.each do |mr|
      role = Role.find(mr.role_id)
      roles << role
    end
  rescue
    roles = []
  end
  return roles
end