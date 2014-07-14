define redmine::database::mysql (
	$user		= $title,
	$db_password	= '',
	$db_root,	
) {
	if ! defined( Class['::mysql::server'] ) {
        	class { '::mysql::server': 
			root_password	=> $db_root,
		}
	}	
	
	mysql::db { "redmine-${user}":
  		user     => $user,
  		password => $db_password,
  		host     => 'localhost',
  		grant    => [ 'ALL' ],
	}
	
}
