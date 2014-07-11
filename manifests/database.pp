define redmine::database (
	$user		= $title,
	$group		= $user,
	$redmine_path,
	$ruby,
	$db_type,
	$db_password	= '',
) {
	# File on puppet master server with database access
	$dbaccess	= "/etc/puppet/modules/redmine/dbaccess"

	# Generate random password for redmine database user
	$password_	= $db_password ? { '' => generate('/bin/sh', '-c', "cat ${dbaccess} | grep ${user}"), default => $db_password }
	$_password	= delete($password_, "${user} ")
	$password	= chomp($_password)

	# Download and set up database config file
	file { "${redmine_path}/config/database.yml":
            	ensure  => file,
              	owner   => $user,
               	group   => $group,
               	content => template("redmine/database/config_${db_type}.erb"),
       	}

	# According to database type, call relevant resources
	if $db_type == 'mysql' {
		redmine::database::mysql { $user: 
			db_password 	=> $password,
			require		=> File["${redmine_path}/config/database.yml"],
		}
	} elsif $db_type == 'postgresql' {
		redmine::database::postgresql { $user: 
			db_password 	=> $password,
			require		=> File["${redmine_path}/config/database.yml"],
		}
	} else {
		fail( 'Database not recognized' )
	}
}
