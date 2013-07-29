require 'redmine'

class Dokuwiki
  # get the dokuwiki page
  def self.get_tab_text(project)
       tab_text = '<iframe src="http://' + Setting.plugin_dokuwiki['dokuwiki_site'] + '/doku.php?id='+project.name  + '" frameborder="0" width="100%" height="600" style="border: 0"/>'
  end

=begin
  def self.get_tab_text(project)
    http = Net::HTTP.new('127.0.0.1', 80)
    s = ''
    http.start do |http|
      request = Net::HTTP::Get.new('/dokuwiki/doku.php?do=login&sectok=aae51a7b9b12751eb49b58e087f7fd8c&id=start')
      request.basic_auth 'admin', 'admin'
      http.request(request)
    end     
    tab_text = '<iframe>'+s+'</iframe>' 
  end
=end
end
