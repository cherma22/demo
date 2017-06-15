#!/bin/bash

# servicecmd - A script to start/stop services

##### Functions

##### Help
function usage {
    echo "usage: servicecmd [[[ -a start | stop ] [ -e environment ]] | [ -h ]]"
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

##### Bring up services based upon what's available/defined, but use the $env variable for the correct config
function start-services {
    # For each defined or available service in either bin or lib
    # Start the service with the necessary parameters
}

##### Stop all of the running services
function stop-services {
    # For each defined and running service
    # Kill the service
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

if [[ "$action" = "start" || "$action" = "stop" ]]; then
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
    $action-services
fi