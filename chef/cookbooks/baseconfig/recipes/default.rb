# Make sure the Apt package lists are up to date, so we're downloading versions that exist.
cookbook_file "apt-sources.list" do
  path "/etc/apt/sources.list"
end
execute 'apt_update' do
  command 'apt-get update'
end



# Base configuration recipe in Chef.

package "wget"
package "ntp"

cookbook_file "ntp.conf" do
  path "/etc/ntp.conf"
end
execute 'ntp_restart' do
  command 'service ntp restart'
end

# Postgres
package "postgresql"
execute 'postgres_user' do
  command 'echo "CREATE DATABASE mydb; CREATE USER ubuntu; GRANT ALL PRIVILEGES ON DATABASE mydb TO ubuntu;" | sudo -u postgres psql'
end

#nginx
package "nginx"
cookbook_file "nginx-default" do
  path "/etc/nginx/sites-available/default"
end
service "nginx" do
  action :restart
end

# Django setup
package "postgresql-server-dev-all"
package "libpython-dev"
package "python-pip"

execute 'pip-install' do
  command "pip install django psycopg2 uwsgi"
end

execute 'makemigrations' do
  user 'ubuntu'
  cwd '/home/ubuntu/project/recipemanager/'
  command 'python ./manage.py makemigrations'
end

execute 'migrate' do
  user 'ubuntu'
  cwd '/home/ubuntu/project/recipemanager/'
  command 'python ./manage.py migrate'
end

execute 'fixture' do
  user 'ubuntu'
  cwd '/home/ubuntu/project/recipemanager/'
  command 'python ./manage.py loaddata recipe.json'
end

execute 'static' do
  user 'ubuntu'
  cwd '/home/ubuntu/project/recipemanager/'
  command 'python manage.py collectstatic --noinput'
end

cookbook_file "rc.local" do
  path "/etc/rc.local"
end

execute 'startup' do
  command '/etc/rc.local'
end
