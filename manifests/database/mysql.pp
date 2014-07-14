define redmine::database::mysql (
	$user		= $title,
	$db_password	= '',	
) {
	if ! defined( Class['::mysql::server'] ) {
		$password_      = generate('/bin/sh', '-c', '/bin/date | md5sum' )
        	$password       = chomp($password_)

        	class { '::mysql::server': 
			root_password	=> $password,
		}
	}	
	
	mysql::db { "redmine-${user}":
  		user     => $user,
  		password => $db_password,
  		host     => 'localhost',
  		grant    => [ 'ALL' ],
	}
	
}
