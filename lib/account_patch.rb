require "xmlrpc/client"
require "util"
require_dependency 'account_controller'

class AccountController

  #Called when a user log in
  def login_with_login_dokuwiki
    if request.get?
      if User.current.logged?
        login_without_login_dokuwiki
      end
    else
      lg = params[:username]
      pwd =  params[:password]
      login_without_login_dokuwiki
      login_dokuwiki(lg,pwd)
      puts "ok"
    end 
  end
  alias_method_chain :login, :login_dokuwiki
  
  
  #Called when a user log off
  def logout_with_logout_dokuwiki
    logout_without_logout_dokuwiki
    logoff_dokuwiki
  end
  alias_method_chain :logout, :logout_dokuwiki

end