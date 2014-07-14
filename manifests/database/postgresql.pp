define redmine::database::postgresql (
	$user		= $title,	
	$db_password	= '',
	$db_root,
) {
	if ! defined( Class['postgresql::server'] ) {
		class { 'postgresql::server': 
			postgres_password	=> $db_root,
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
