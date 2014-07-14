define redmine::install (
	$user		= $title,
	$group		= $user,
	$home		= '',
	$redmine	= '',
	$ruby		= '',
	$port		= '',
	$db_type	= '',
	$db_password	= '',
	$plugin_dir	= '',
	$plugins	= '',
	$plugins_del	= '',
	$sourcetype	= '',
	$source		= '',
) {
	# Directory for redmine apps
	$redmine_dir	= "/opt/redmine"

	# Set user home path and redmine path if not defined
	$home_path	= $home ? { '' => "${redmine_dir}/${user}", default => $home }
	$redmine_path	= "${home_path}/redmine"

	# Set default values if not specified
	$redmine_	= $redmine ? { '' => 'master', default => $redmine }
	$port_		= $port ? { '' => 3000, default => $port }
	
	$db_type_       = $db_type ? { 	''      => 'mysql',
                			'pgs'   => 'postgresql',
                			'pgsql' => 'postgresql',
                			default => $db_type }

	# Select ruby version to run redmine on
	$ruby_		= $ruby ? { '' => "1.9.3-p547", default => $ruby }

	# Install dependencies for redmine plugin
	if ! defined ( Class['redmine::dependencies'] ) {
		require	redmine::dependencies
	}

	if ! defined ( File[$redmine_dir] ) { 
		file { $redmine_dir:
			ensure	=> directory,
		}
	}

	user { $user:
		ensure		=> present,
		home		=> $home_path,
		managehome	=> true,
		shell		=> "/bin/bash",
		require		=> File[$redmine_dir],
		before		=> Rbenv::Install[$user],
	}

        rbenv::install { $user:
		home	=> $home_path,
		require	=> User[$user],
        }

        rbenv::compile { "${user}/${ruby}":
                user    => $user,
		home	=> $home_path,
                ruby    => $ruby_,
                global  => true,
                require => Rbenv::Install[$user],
		before	=> Redmine::Download[$user],
        }

	redmine::download { $user:	
		home		=> $home_path,
		redmine		=> $redmine_,
		ruby		=> $ruby,
		db_type		=> $db_type_,
		db_password	=> $db_password,
		sourcetype	=> $sourcetype,
		source		=> $source,
		require		=> Rbenv::Compile["${user}/${ruby}"],
		before		=> Redmine::Puma[$user],		
	}

	redmine::puma { $user:
		home		=> $home_path,
		port		=> $port_,
		require		=> Redmine::Download[$user],
	}

	# Check if any plugins had been entered
	if ! empty( $plugins ) {
		redmine::plugin::install { $plugins:
			user		=> $user,
			home		=> $home_path,
			redmine		=> $redmine_,
			plugin_dir	=> $plugin_dir,
			require		=> Redmine::Download[$user],
			before		=> Redmine::Puma[$user],
 		}
	}

	# Check for plugin delete requests
	if ! empty( $plugins_del ) {
                redmine::plugin::remove { $plugins_del:
                        user            => $user,
                        home            => $home_path,
                        require         => Redmine::Download[$user],
                        before          => Redmine::Puma[$user],
                }
        }
}
