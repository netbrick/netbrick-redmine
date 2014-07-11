define redmine::download::files (
	$user		= $title,
	$group		= $user,
	$home		= '',
	$ruby,
	$db_type,
) {

	# Set home path and redmine path
	$home_path      = $home
        $redmine_path   = "${home_path}/redmine"	

	file { "${redmine_path}/Gemfile.local":
		ensure	=> file,
		owner	=> $user,
		group	=> $group,
		content	=> template("redmine/Gemfile.local.erb"),
	}

	file { "${redmine_path}/tmp":
                ensure  => directory,
                owner   => $user,
                group   => $group,
                mode    => 755,
        }

        file { "${redmine_path}/tmp/pdf":
                ensure  => directory,
                owner   => $user,
                group   => $group,
        }

        file { "${redmine_path}/tmp/pids":
                ensure  => directory,
                owner   => $user,
                group   => $group,
        }

	file { "${redmine_path}/public":
                ensure  => directory,
                owner   => $user,
                group   => $group,
        }

        file { "${redmine_path}/public/plugin_assets":
                ensure  => directory,
                owner   => $user,
                group   => $group,
                mode    => 755,
        }

        file { "${redmine_path}/files":
                ensure  => directory,
                owner   => $user,
                group   => $group,
                mode    => 755,
        }

	file { "${redmine_path}/log":
                ensure  => directory,
                owner   => $user,
                group   => $group,
                mode    => 755,
        }	
}
