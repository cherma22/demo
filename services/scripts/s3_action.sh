# !/bin/bash

# s3_sync_logs - A script to sync to an s3 bucket via AWS CLI

##### Functions

##### Help
function usage {
    echo "usage: s3_action [[[ -a sync-logs | backup-data ] [ -e environment ]] | [ -h ]]"
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

function sync-logs {
    mv logs/*.20*.log logs/archive
    aws s3 sync logs s3://$s3_backup_bucket/logs
}

function backup-datamart {
    aws s3 sync data s3://$s3_backup_bucket/data
    cd data
    rm -fr 20*
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
    done
fi

if [[ "$action" = "sync-logs" || "$action" = "backup-data" ]]; then
    echo "Action set to $action"
else
    echo "Action $action is incorrect"
    exit
fi

if [[ "$env" = "" ]]; then
    usage
    exit
else
    echo "Environment set to $env"
    parse-env
    
    cd $installdir/services
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

    echo "Executing $action"
    exists() { type -t "$1" > /dev/null 2>&1; }

    if exists aws; then
        echo 'aws cli available. Backing up to S3'
        $action
    fi

    if ! exists aws; then
        echo 'aws cli not available. Sourcing files'
        export PATH=~/.local/bin:$PATH
        source ~/.bash_profile
        #aws configure --output json 
        echo 'Backing up to S3'
        $action
    fi
fi