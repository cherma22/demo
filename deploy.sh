#!/bin/bash

# basesetup - A script to install/update Minerva Servers

##### Functions

##### Help
function usage {
    echo "usage: deploy [[[ -a install | update | remove ] [ -e environment ] [ -t type ]] | [ -h ]]"
}

##### Parse Environment File for Settings
function parse-env {
    echo "Loading settings for $env..."
    envfile="./env/$env.setting"
    if [[ -f ${envfile} ]]
    then
        source "$envfile"
    else
        echo "Cannot find environment $env..."
        exit 1
    fi
}

function install-cleanup {
    echo "Cleaning up install..."
    cd "$scriptdir"
    rm -rf *
    cd ..
    rm -rf deploy
}

##### Base install for all systems
function install-base {
    scriptdir="$(pwd)"
    echo "Starting base installation..."
    echo "Creating directory..."
    mkdir -p $installdir
    
    echo "Installing AWS CLI..."
    pip install --upgrade --user awscli
    export PATH=~/.local/bin:$PATH
    source ~/.bash_profile
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
    aws configure --output json

    echo "Adding common firewall rules..."
    firewall-cmd --add-port 9080/tcp --permanent
    firewall-cmd --reload
    
    echo "Changing to base directory..."
    cd $installdir/
}

function install-services {
    echo "Add S3 log sync to crontab"
    echo "# Backup logs to S3" >> /etc/crontab
    echo "*/5 * * * * root $installdir/services/scripts/s3_sync_logs.sh" >> /etc/crontab

    echo "Add S3 backups to crontab"
    echo "# Backup datamart to S3" >> /etc/crontab
    echo "0 0 * * * root $installdir/services/scripts/s3_backup.sh" >> /etc/crontab
    
    echo "Adding services firewall rules..."
    firewall-cmd --add-port 10000/tcp --permanent
    firewall-cmd --reload
    
    echo "Cloning Deployment repo..."
    git clone $git
    
    echo "Creating data directory"
    mkdir -p data/reports
    
    echo "Creating and entering symbolic link folder..."
    ln -s deploy/services/ services
    cd services

    echo "Creating symbolic link env folder"
    ln -s $installdir/deploy/env/ env

    echo "Bringing up containers with docker-compose..."
    docker-compose up -d
    
    echo "Verify all containers are running. Use docker-compose logs -t <container> if needed..."
    docker-compose ps
    
    echo "Bring up services..."
    cd scripts
    ./servicecmd.sh -a start -e $env

    echo "Services installed."
}

function install-web {
    echo "Adding web firewall rules..."
    firewall-cmd --add-port 8080/tcp --permanent
    firewall-cmd --reload

    echo "Cloning Deployment repo..."
    git clone $git
    
    echo "Creating and entering symbolic link folder..."
    ln -s deploy/web/ web
    cd web

    echo "Set Service IP in nginx config"
    sed -i -e "s/service_ip/$service_ip/g" nginx/vhost.d/web.conf
    
    echo "Docker login to Docker..."
    docker login $registry -u $dockeruser -p $dockerpass
    
    echo "Bringing up containers with docker-compose..."
    docker-compose up -d
    
    echo "Verify all containers are running. Use docker-compose logs -t <container> if needed..."
    docker-compose ps
    
    echo "Web installed."
}

function remove-services {
    echo "Changing to base directory..."
    cd $installdir/
    
    echo "Removing containers..."
    cd services
    docker-compose down
    
    echo "Stop services..."
    cd services/scripts
    ./servicecmd.sh -a stop -e $env
    cd ..
    
    echo "Removing linked directory..."
    cd ..
    rm -rf services
    
    echo "Removing Deployment repo..."
    rm -rf deploy
    
    echo "Removing base directory..."
    cd ~
    rm -rf $installdir

    echo "Services removed."
}

function remove-web {
    echo "Changing to base directory..."
    cd $installdir/
    
    echo "Removing containers..."
    cd web
    docker-compose down
    
    echo "Removing linked directory..."
    cd ..
    rm -rf web
    
    echo "Removing Deployment repo..."
    rm -rf deploy
    
    echo "Removing base directory..."
    cd ~
    rm -rf $installdir

    echo "Web removed."
}

function update-services {
    echo "Changing to base directory..."
    cd $installdir/

    echo "Stop services..."
    cd services/scripts
    ./servicecmd.sh -a stop -e $env
    cd ..
    
    echo "Update Deployment repo..."
    cd ../deploy
    git pull
    
    echo "Update services..."
    cd ../services/scripts
    ./servicecmd.sh -a start -e $env
    
    echo "Services updated."
}

function update-web {
    echo "Changing to base directory..."
    cd $installdir/
    
    echo "Update Deployment repo..."
    cd deploy
    git pull
    
    echo "Docker login to Docker..."
    docker login $registry -u $dockeruser -p $dockerpass
    
    echo "Update web UI dashboard..."
    cd ../web
    ./rebuild-ui.sh
    
    echo "Web updated."
}

##### Main

if [ "$1" = "" ]; then
    usage
    exit
else
    while [ "$1" != "" ]; do
        case $1 in
            -a | --action )         shift
                                    action=$1
                                    ;;
            -h | --help )           usage
                                    exit
                                    ;;
            * )                     usage
                                    exit 1
        esac
        shift

        case $1 in
            -e | --env )           shift
                                    env=$1
                                    ;;
            -h | --help )           usage
                                    exit
                                    ;;
            * )                     shift
				                    usage
                                    exit 1
        esac
        shift

        case $1 in
            -t | --type )           shift
                                    type=$1
                                    ;;
            -h | --help )           usage
                                    exit
                                    ;;
            * )                     shift
				                    usage
                                    exit 1
        esac
        shift
    done
fi

if [[ "$action" = "install" || "$action" = "update" || "$action" = "remove" ]]; then
    echo "Action set to $action"
    echo "Install directory defined as: $installdir"
else
    echo "Action $action is incorrect"
    exit
fi

if [[ "$type" = "" ]]; then
    usage
    exit
fi

if [[ "$type" = "services" ]]; then
    echo "Type set to $type"
    echo "Starting $action for $type"

    if [[ "$env" = "" ]]; then
        usage
        exit
    else
        echo "Environment set to $env"
        parse-env
    fi
    
    if [[ "$action" = "install" ]]; then
    	install-base
    	$action-$type
        install-cleanup
    else
    	$action-$type
    fi
else
    echo "Type $type is incorrect"
    exit
fi
