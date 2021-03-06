#!/bin/sh

# set $platform to override
if [ -n "$platform" ]; then
   # detect platform
   unamestr=`uname`
   if [ "$unamestr" = 'Darwin' ]; then
      platform='osx'
   elif [ "$unamestr" = 'Linux' ]; then
      platform='linux'
   fi
fi

# handle dependencies
if [ "$platform" = 'osx' ]; then
   echo '- [OS X] Assuming you already have dependencies installed...'
   pg_user=`whoami`
elif [ "$platform" = 'linux' ]; then
   apt-get -y update

   echo "- installing postgres + postgis"
   apt-get install -y postgres-xc-client
   apt-get install -y libpq-dev libgeos-c1 libgeos++-dev proj-bin mapnik-utils postgresql-9.3 postgresql-9.3-postgis-2.1 postgresql-contrib-9.3 unzip postgresql-client-9.3 postgresql-common postgresql-client-common postgresql-plpython-9.3
   apt-get install -y zip git vim htop bzip2 curl gdal-bin s3cmd

   echo "- setting up postgres permissions + database"
   chmod a+rx $HOME

   echo "- installing node"
   apt-get install -y nodejs npm
   ln -s /usr/bin/nodejs /usr/bin/node

   pg_user='postgres'
fi


if [ "$platform" = 'linux' ]; then

   # play nicely with other users
   sh -c 'echo "
   local all postgres trust
   local all all trust
   host all all 127.0.0.1/32 trust
   host all all ::1/128 trust
   host replication postgres samenet trust
   " > /etc/postgresql/9.3/main/pg_hba.conf'

   sudo killall postgres

   cd /var/lib/postgresql/9.3
   mkdir -p /mnt/data/postgres
   cp -r main /mnt/data/postgres
   chown -R postgres:postgres /mnt/data/postgres
   rm -rf main
   ln -s /mnt/data/postgres/main main

   /etc/init.d/postgresql start

   # I don't know why but sometimes it doesn't start the first time :/
   sudo /etc/init.d/postgresql start

   if $(which s3cmd); then
      echo -e "-----\n\n"
      s3cmd --configure
      # fix permissions
      chown ubuntu:ubuntu ~/.s3cfg
   fi
fi
