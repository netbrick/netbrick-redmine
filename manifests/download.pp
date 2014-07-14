define redmine::download (
	$user		= $title,
	$group		= $user,
	$home,
	$redmine,
	$ruby,
	$db_type,
	$db_password,
	$sourcetype	= '',
	$source		= '',
) {

	# Set home path and redmine path
	$home_path      = $home
	$redmine_path	= "${home_path}/redmine"

	# Make path include rbenv to run commands
        $path           = [ "${home_path}/.rbenv/shims", "${home_path}/.rbenv/bin", '/bin', '/usr/bin', '/usr/sbin' ]

	# Allow downloading from custom sources
	$sourcetype_	= $sourcetype ? { '' => 'git', default => $sourcetype }
	$source_	= $source ? { '' => 'https://github.com/redmine/redmine.git', default => $source }

	# Select download module according to input
	if $sourcetype_ =~ /(git|svn)/ {
		vcsrepo { "redmine::download::vcsrepo ${user}":
			ensure		=> present,
			provider 	=> $sourcetype_,
                	path		=> $redmine_path,
			source		=> $source_,
			revision	=> $redmine,
			owner		=> $user,
			user		=> $user,
			group		=> $group,
			notify		=> Exec["redmine::download::gems ${user}"],
			before		=> Redmine::Download::Files[$user],
        	}
	} else {
		wget::fetch { "redmine::download::wget ${user}":
			destination	=> $redmine_path,
			source		=> $source_,
			verbose		=> false,
			execuser	=> $user,
			notify          => Exec["redmine::download::gems ${user}"],
                        before          => Redmine::Download::Files[$user],
		}
	}

	# Creates directories to complete installation
	redmine::download::files { $user:
		home		=> $home_path,
		ruby		=> $ruby,
		db_type		=> $db_type,
		before		=> Redmine::Database[$user],
	}
	
	# Sets up new database with user
	redmine::database { $user:
		redmine_path	=> $redmine_path,
		ruby		=> $ruby,
                db_type 	=> $db_type,
		db_password	=> $db_password,
                require 	=> Redmine::Download::Files[$user],
		before		=> Exec["redmine::download::gems ${user}"],
        }	

	# Provides initial redmine setup
	exec { "redmine::download::gems::update ${user}":
		command         => "bundle update",
                user            => $user,
		group		=> $group,
		environment     => [ "HOME=${home_path}" ],
                path            => $path,
		onlyif		=> "[ -e '${redmine_path}/Gemfile.lock' ]",
                timeout         => 250,
		refreshonly	=> true,
                cwd             => $redmine_path,
                require         => [ Redmine::Download::Files[$user], Redmine::Database[$user] ],
		subscribe	=> Vcsrepo["redmine::download::vcsrepo ${user}"],
                before		=> Exec["redmine::download::gems ${user}"],
        }

	exec { "redmine::download::gems ${user}":
		command 	=> "bash --login -c 'bundle install --without development test'",
                user    	=> $user,
		group		=> $group,
		environment     => [ "HOME=${home_path}" ],
                path    	=> $path,
                timeout 	=> 250,
		refreshonly	=> true,
                cwd     	=> $redmine_path,
                require 	=> [ Redmine::Download::Files[$user], Redmine::Database[$user] ],
		notify		=> Exec["redmine::download::gen_token ${user}"],
        } 

	exec { "redmine::download::gen_token ${user}":
                command         => "bundle exec rake generate_secret_token",
                user            => $user,
		group		=> $group,
		environment     => [ "HOME=${home_path}" ],
                path            => $path,
                timeout         => 250,
		refreshonly	=> true,
                cwd             => $redmine_path,
                require         => Exec["redmine::download::gems ${user}"],
		notify		=> Exec["redmine::download::migrate_db ${user}"],
        }	

	exec { "redmine::download::migrate_db ${user}":
		command         => "bundle exec rake db:migrate",
                user            => $user,
		group		=> $group,
		environment     => [ "HOME=${home_path}", "RAILS_ENV=production" ],
                path            => $path,
                timeout         => 250,
		refreshonly	=> true,
                cwd             => $redmine_path,
                require         => Exec["redmine::download::gen_token ${user}"],
		notify		=> Exec["redmine::download::load_defs ${user}"],
	}

	exec { "redmine::download::load_defs ${user}":
                command         => "bundle exec rake redmine:load_default_data",
                user            => $user,
		group		=> $group,
                environment     => [ "HOME=${home_path}", "RAILS_ENV=production", "REDMINE_LANG=cs" ],
                path            => $path,
                timeout         => 250,
		refreshonly	=> true,
                cwd             => $redmine_path,
                require         => Exec["redmine::download::migrate_db ${user}"],
		notify		=> Exec["redmine::plugin::migrate ${user}"],
        }

	exec { "redmine::plugin::migrate ${user}":
                command         => "bundle exec rake redmine:plugins:migrate",
                user            => $user,
		group		=> $group,
                environment     => [ "HOME=${home_path}", "RAILS_ENV=production" ],
                path            => $path,
                timeout         => 250,
                refreshonly     => true,
                cwd             => $redmine_path,
		notify		=> Service["puma-${user}"],
        }
}
