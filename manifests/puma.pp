define redmine::puma (
	$user		= $title,
	$group		= $user,
	$home,
	$port,
	$socket,
) {
	# Set home path and redmine path
	$home_path      = $home
        $redmine_path   = "${home_path}/redmine"

        service { "puma-${user}":
                ensure          => running,
                enable          => true,
                hasrestart      => true,
                require         => File["/etc/init.d/puma-${user}"],
        }

	file { "${redmine_path}/puma.sh":
                ensure  => file,
                owner   => $user,
                mode    => 0755,
                group   => $group,
                content => template("redmine/puma/puma.sh.erb"),
                before  => Service["puma-${user}"],
        }

	file { "${redmine_path}/config/puma.rb":
                ensure  => file,
                owner   => $user,
                group   => $group,
                content => template("redmine/puma/puma.rb.erb"),
		before	=> Service["puma-${user}"],
        }

        file { "/etc/init.d/puma-${user}":
                ensure  => file,
                owner   => "root",
                group   => "root",
                content => template("redmine/puma/puma-init.erb"),
                mode    => 0755,
                before  => Service["puma-${user}"],
        }	
}
