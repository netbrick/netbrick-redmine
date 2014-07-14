define redmine::database::postgresql (
	$user		= $title,	
	$db_password	= '',
) {
	if ! defined( Class['postgresql::server'] ) {
		$password_      = generate('/bin/sh', '-c', '/bin/date | md5sum' )
                $password       = chomp($password_)

		class { 'postgresql::server': 
			postgres_password	=> $password,
		}
	}	 

	postgresql::server::db { "redminedb-${user}":
		user		=> $user,
		password	=> postgresql_password( $user, $db_password ),
	}

	postgresql::server::role { "redmine-${user}":
  		password_hash => postgresql_password( "redmine-${user}", $db_password ),
	}

	postgresql::server::database_grant { "redminedb-${user}":
  		privilege => 'ALL',
  		db        => "redminedb-${user}",
  		role      => "redmine-${user}",
	}
}
