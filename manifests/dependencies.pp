class redmine::dependencies {	
	if ! defined( Package['git'] )				{ package { "git": 				ensure => installed, name => 'git-core' } }
	if ! defined( Package['subversion'] )			{ package { "subversion":			ensure => installed } }
	if ! defined( Package['sudo'] ) 			{ package { "sudo": 				ensure => installed } }
	if ! defined( Package['libmagickwand-dev'] ) 		{ package { "libmagickwand-dev": 		ensure => installed } }
	if ! defined( Package['libsqlite3-dev'] )		{ package { "libsqlite3-dev":			ensure => installed } }
	if ! defined( Package['libmysql-ruby'] )		{ package { "libmysql-ruby": 			ensure => installed } }
	if ! defined( Package['libmysqlclient-dev'] ) 		{ package { "libmysqlclient-dev": 		ensure => installed } }
	if ! defined( Package['libpgsql-ruby'] )		{ package { "libpgsql-ruby":			ensure => installed } }
	if ! defined( Package['postgresql-server-dev-all'] ) 	{ package { "postgresql-server-dev-all":	ensure => installed } }	
}
