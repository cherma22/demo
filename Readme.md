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
* There is a referenced command "servicecmd.sh" that, while present, should be updated as execution depends on the binaries being deployed.
* In the current state, this project is only a reference, as it will not sufficiently deploy service binaries or a working web environment. It is only demonstration of a deployment model.

## Initial Setup
1. SSH to desired server
2. cd to /tmp
3. git clone repo - use /env/$env.setting to determine git repo
4. run ./deploy -a install -e $env -t services to install

## Commands
* Each command has required input of -a (action) and -e (environment). Help may be displayed with -h.
* ./deploy.sh - command to install/remove/update the deployment. Script has additional input of -t for type of server.
* ./services/scripts/servicecmd.sh - command to start/stop services for the input environment.
* ./services/scripts/s3_action.sh - command to either sync logs or backup data to S3.

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
│   ├── docker-compose.yml
│   ├── nginx
│   │   ├── nginx.conf
│   │   └── vhost.d
│   │       └── services.conf
│   └── scripts
│       ├── s3_action.sh
│       └── servicecmd.sh
└── web
    ├── Dockerfile
    ├── app
    │   └── index.php
    ├── docker-compose.yml
    ├── nginx
    │   ├── nginx.conf
    │   └── vhost.d
    │       └── web.conf
    └── rebuild-ui.sh
```