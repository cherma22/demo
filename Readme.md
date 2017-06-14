# Deploy
This repository is used as a demo to show deployment to a server.
An environment settings file is used to determine the proper settings for installation and runtime.
Any server pre-requisites are not covered by this project, and should be intialized by either template or user-data (e.g. Docker Engine, Docker-Compose).

## Concepts
* Docker Compose is used to run and link containers.
 * Cadvisor by Google is used to provide a webUI for monitoring the server/docker instance(s).
* Service binaries are exluded from the project, and should be injected prior to execution. This aspect is not considered or covered in the demo.
* Deploy script will install, remove, or update the server based on input.
* The deployed environment is determined by the requisite .setting file in ./env. This file will have all of the necessary details for the setup to function correctly.
* The project assumes that the servers are located on AWS and generate files for backup in both the data and logs folders of the "services" server.
* Additionally, the project assumes there are two types of servers being used, one "web" is the UI, the other "services" is the API/Backend for said UI.

## Notes
* There is a referenced command "servicecmd.sh" that is excluded as execution depends on the binaries being deployed.
* In the current state, this project is only a reference, as it will not sufficiently deploy service binaries or a working web environment. It is only demonstration of a deployment model.

## Initial Setup
1. SSH to desired server
2. git clone repo - use /env/$env.setting to determine git repo
3. run ./deploy -a install -e $env -t services to install

## Commands
* ./deploy.sh - command to install/remove/update the deployment

## File Structure
```
demo
├── Readme.md
├── deploy.sh
├── env
│   ├── beta.setting
│   ├── prod.setting
│   └── qa.setting
├── services
│   ├── bin
│   ├── docker-compose.yml
│   ├── lib
│   ├── logs
│   │   └── archive
│   ├── nginx
│   │   ├── nginx.conf
│   │   └── vhost.d
│   │       └── services.conf
│   ├── scripts
│   │   └── s3_action.sh
│   └── tools
└── web
    ├── docker-compose.yml
    ├── nginx
    │   ├── nginx.conf
    │   └── vhost.d
    │       └── web.conf
    └── rebuild-ui.sh
```