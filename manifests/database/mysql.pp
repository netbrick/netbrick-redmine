define redmine::database::mysql (
	$user		= $title,
	$db_password	= '',	
) {
	if ! defined( Class['::mysql::server'] ) {
        	class { '::mysql::server': }
	}	
	
	mysql::db { "redmine-${user}":
  		user     => $user,
  		password => $db_password,
  		host     => 'localhost',
  		grant    => [ 'ALL' ],
	}
	
}
