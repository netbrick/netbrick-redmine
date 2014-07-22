define redmine::database (
	$user		= $title,
	$group		= $user,
	$redmine_path,
	$ruby,
	$db_type,
	$db_password	= '',
) {
	# Generate random password for redmine database user, if not specified
	$rnd 		= fqdn_rand('999999999',"${user}${db_type}")
        $password_gen	= $db_password ? { '' => generate('/bin/bash', '-c', 'echo $rnd | md5sum | awk \'{print $1}\'' ), default => $db_password }
        $password  	= chomp($password_gen)

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
