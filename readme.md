# Redmine DokuWiki Plugin #

# Author #
* Groupe Eurogiciel
# Installation #
### DokuWiki version > 2013-05-10a "Weatherwax" ###
1. Download the plugin source code to REDMINE_PATH/plugins/
2. Restart Redmine

### Other versions ###
1. Download the plugin source code to REDMINE_PATH/plugins/
2. Add remote.php to DOKUWIKI_PATH/lib/plugins/acl <pre>
    <?php
        class remote_plugin_acl extends DokuWiki_Remote_Plugin {
            function _getMethods() {
                return array(
                    'addAcl' => array(
                        'args' => array('string','string','int'),
                        'return' => 'int',
                        'name' => 'addAcl',
                        'doc' => 'Adds a new ACL rule.'
                    ), 'delAcl' => array(
                        'args' => array('string','string'),
                        'return' => 'int',
                        'name' => 'delAcl',
                        'doc' => 'Delete an existing ACL rule.'
                    ),
                );
            }
            function addAcl($scope, $user, $level){
                $apa = plugin_load('admin', 'acl');
                return $apa->_acl_add($scope, $user, $level);
            }
            function delAcl($scope, $user){
                $apa = plugin_load('admin', 'acl');
                return $apa->_acl_del($scope, $user);
            }
        }
    </pre>
3. Restart Redmine

#TODO#
* Automate DokuWiki login and logout
* Use group ACL rules instead of handling ACL rules user by user
