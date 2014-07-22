define redmine::database::mysql (
	$user		= $title,
	$db_password	= '',
) {
	if ! defined( Class['::mysql::server'] ) {
		fail( 'Mysql server has to be configured' )
	}	
	mysql::db { "redmine-${user}":
  		user     => $user,
  		password => $db_password,
  		host     => 'localhost',
  		grant    => [ 'ALL' ],
	}
	
}
