define redmine::theme::remove (
        $user,
        $group          = $user,
        $home,
        $themes         = $title,
) {
        $home_path              = $home
        $redmine_path           = "${home_path}/redmine"
        $redmine_themes         = "${redmine_path}/public/themes"

        # Workaround to not use 'parser = future' and still be able to work with arrays effectively
        if '/' in $themes {
                $split  = split( $themes, "/" )
                $theme = $split[1]
        } else {
                $theme = $themes
        }

        file { "redmine::theme::remove::delete ${theme} ${user}":
                path    => "${redmine_themes}/${theme}",
		ensure	=> absent,
		force	=> true,
	}
}
