# puppet-redmine

## Overview

Module to host redmine under specified user with specified plugins.
Currently supports only OS Debian Wheezy and Redmine version 2.x is supported

## Module Description

Module uses rbenv as ruby enviroment manager. It's recommended to run as new/nonexisting
user, module will autocreate this user and provides rbenv installation. In next step module
downloads redmine from redmine github(of course, you can specify your own source, including 
sourcing from ftp etc. module use wget, if source is not git/svn).

Multiple redmine instances under different users can be specified(limit is one instance per user)
and if you want to use same plugin under multiple users, you must specify plugin name by following
rule: `"some_unique_string/pluginname"`
Example: `"user1/plugin1", "user2/plugin1"` etc.

Module will automaticaly parse this string and use string after slash as plugin to install.

There is available only one method - `redmine::install { user: }` which manages whole set up of redmine
instance including installing, or deleting plugins. It's neccessary to have all plugins downloaded into
redmine module in puppet master server.  

## Setup

### What redmine affects

Module requires mysql/postgresql database to be installed. If no database is installed, module will
autoinstall it and provide initial setup. Redmine will also autoinstall rbenv and downloads relevant
ruby version. As last step module creates service called puma-"user-name" and sets autostart on system 
boot.

## Usage

To get your redmine depoloyed with default settings you have to add `redmine::install { "user": }`
to your node definition. There are various settings available.

If you don't specify user's database password, password has to be included in `/etc/puppet/modules/redmine/dbaccess`
file in following format: 

```
user1 password1
user2 password2
```

Example of module usage:

```
redmine::install { "user1":
  port            => 3000,
  redmine         => "2.4.5",
  ruby            => "1.9.3-p547",
  db_type         => 'mysql',
}
```

## Limitations

This module had been tested only on OS Debian Wheezy and supports only Redmine 
version 2.x

## Development

It's released under Apache 2.0 license.
