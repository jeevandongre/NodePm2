#
# Cookbook Name:: node-npm
# Recipe:: default
#
# Copyright (c) 2014 The Authors, All Rights Reserved.

include_recipe "application"
include_recipe "runit"
include_recipe "apt"
include_recipe "git"
include_recipe "nodejs" 
include_recipe "nginx"


execute "update" do 
   command "apt-get update"
end
package 'g++' do
   action :install
end   

service "nginx" do
   action :stop
end

Directory "/root/.ssh" do
   action :create
   mode 0700
end

File "/root/.ssh/config" do
   action :create
   content "Host *\nStrictHostKeyChecking no"
   mode 0600
end

execute "apps" do
   cwd "/current/working/dir"
   user "user"
   group "user"
   command "mkdir apps"
end

application 'st-angular' do
   group 'user'
   path  '/path/to/where/app/should/be/deployed'
   repository 'repo git url'
   revision   'branch_name'
end   

execute 'npm-pm2' do
   user 'user'
   group 'user'
   command 'sudo /usr/bin/npm install -g pm2'
   notifies :run,"execute[npm-install]",:immediately
end   

execute 'npm-install' do
   user 'user'
   group 'user'
   cwd '/path/of/the/app'
   command 'sudo /usr/bin/npm install'
   notifies :run, "execute[pm2-start]", :immediately
end

# execute 'pm2' do
#    user 'user'
#    group 'user'
#    cwd '/home/user/apps/st-angular/current/'
#    command 'sudo /usr/bin/pm2 startup ubuntu'
#    notifies :run, "execute[pm2-start]", :immediately
# end

execute 'pm2-start' do
   user 'user'
   group 'user'
   cwd '/path/of/the/app'
   command 'sudo pm2 start -f /path/of/the/app/bin/www'
end   

template "nginx.conf" do
   path "/etc/nginx/nginx.conf"
   source "nginx.conf"
   user "user"
   mode "0644"
   notifies :restart, "service[nginx]", :immediately
end
