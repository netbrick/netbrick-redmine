define redmine::plugin::install (
	$user,
	$group		= $user,
	$home,
	$redmine,
	$plugin_dir	= '',
	$plugins	= $title,
) {
	$home_path      	= $home
        $redmine_path   	= "${home_path}/redmine"
	$redmine_plugins	= "${redmine_path}/plugins"

	# If not specified redmine version, plugin source set to global
	$split_dir = split( $redmine, '\.' )
	$plugin_dir_		= $plugin_dir ? { '' => "${split_dir[0]}.${split_dir[1]}", default => 'all' }

	$path           	= ["${home_path}/.rbenv/bin", "${home_path}/.rbenv/shims", '/bin', '/usr/bin', '/usr/sbin']

	# Workaround to not use 'parser = future' and still be able to work with arrays effectively
	if '/' in $plugins {
		$split 	= split( $plugins, "/" )
		$plugin = $split[1]
	} else {
		$plugin = $plugins
	}	

	file { "redmine::plugin::install::download ${plugin} ${user}":
               	path 	=> "${redmine_plugins}/${plugin}",
		ensure	=> directory,
               	owner	=> $user,
		group	=> $group,
		recurse	=> true,
		source	=> "puppet:///modules/redmine/plugins/${plugin_dir_}/${plugin}",
		notify	=> Exec["redmine::plugin::install::gems ${plugin} ${user}"],
        }

	exec { "redmine::plugin::install::gems ${plugin} ${user}":
               	command 	=> "bash --login -c 'bundle install --without development test'",
               	user    	=> $user,
               	group   	=> $group,
		environment     => [ "HOME=${home_path}" ],
               	path    	=> $path,
               	timeout 	=> 250,
		refreshonly	=> true,
               	cwd     	=> $redmine_path,
		notify		=> Exec["redmine::plugin::install::migrate ${plugin} ${user}"],
        }

        exec { "redmine::plugin::install::migrate ${plugin} ${user}":
               	command 	=> "rake redmine:plugins:migrate",
               	user    	=> $user,
               	group   	=> $group,
		environment	=> [ "RAILS_ENV=production", "HOME=${home_path}" ],
               	path    	=> $path,
               	timeout 	=> 250,
		refreshonly	=> true,
               	cwd     	=> $redmine_path,
		notify		=> Service["puma-${user}"],
        }
}
