define redmine::plugin::remove (
        $user,
        $group          = $user,
        $home,
        $plugins        = $title,
) {
        $home_path              = $home
        $redmine_path           = "${home_path}/redmine"
        $redmine_plugins        = "${redmine_path}/plugins"

        # If not specified redmine version, plugin source set to global
        $plugin_dir_            = $plugin_dir ? { '' => generate('/bin/sh', '-c', "echo ${redmine} | sed 's/\(^...\).*/\1/'"), default => 'all' }

        $path                   = ["${home_path}/.rbenv/bin", "${home_path}/.rbenv/shims", '/bin', '/usr/bin', '/usr/sbin']

        # Workaround to not use 'parser = future' and still be able to work with arrays effectively
        if '/' in $plugins {
                $split  = split( $plugins, "/" )
                $plugin = $split[1]
        } else {
                $plugin = $plugins
        }

        exec { "redmine::plugin::remove::migrate ${plugin} ${user}":
                command         => "rake redmine:plugins:migrate",
                user            => $user,
                group           => $group,
		onlyif		=> "[ -d '${redmine_plugins}/${plugin}' ]",
                environment     => [ "RAILS_ENV=production", "NAME=${plugin}", "VERSION=0" ],
                path            => $path,
                timeout         => 250,
                cwd             => $redmine_plugins,
                notify          => Service["puma-${user}"],
		before		=> File["redmine::plugin::remove::delete ${plugin} ${user}"],
        }

        file { "redmine::plugin::remove::delete ${plugin} ${user}":
                path    => "${redmine_plugins}/${plugin}",
                ensure  => absent,
                owner   => $user,
                group   => $group,
		force	=> true,
                require	=> Exec["redmine::plugin::remove::migrate ${plugin} ${user}"],
        }


}
