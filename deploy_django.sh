#!/bin/bash

set -euo pipefail

#########################################################
# Configuration
#########################################################

APP_NAME="django-notes-app"
REPO_URL="https://github.com/LondheShubham153/django-notes-app.git"
IMAGE_NAME="notes-app"
CONTAINER_NAME="notes-app-container"
LOG_FILE="/tmp/deployment.log"

###########################################################
#Logging Functions
##########################################################

log() {
    echo "[$(date '+%F %T')] INFO : $1" | tee -a "$LOG_FILE"
}

error_exit() {
    echo "[$(date '+%F %T')] ERROR: $1" | tee -a "$LOG_FILE"
    exit 1
}



######################################################
#Pre-Chceks
######################################################

check_prerequisites(){
	log "Checking internet connectivity..."

	ping -c 1 github.com >/dev/null 2>&1 || \
		error_exit "Internet Connectivity unavailable."

	log "Checking available disk space...."

	AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')

	if [ "$AVAILABLE_SPACE" -lt 1048576 ]; then
		error_exit "Less than 1 GB disk space available."
	fi
}

##############################################################
# Install Dependencies
#################################################################

install_dependencies(){
	log "Installing dependencies.."

	sudo apt-get update -y

	sudo apt-get install -y\
	docker.io \
	nginx \
docker-compose-v2

	sudo systemctl enable docker
	sudo systemctl start docker

}

####################################################################
# Clone / Update Repository 
############################################################
clone_or_update_repo(){
	if [ -d "$APP_NAME" ]; then
		log "Repository exists. Pulling latest code..."

		cd "$APP_NAME"
	else
		log "Cloning repository ..."
		git clone "$REPO_URL"
		cd "$APP_NAME"
	fi
}
#####################################################################
# Check Port Availability
##########################################################################

check_port(){
	if sudo lsof -i :80 >/dev/null 2>&1; then
		log "Port 80 is already in use."

		sudo lsof -i :80
	else
		log "Port 80 is free."
	fi
}

###################################################################################
# Build and Deploy
############################################################################################

deploy(){
	log "Building Docker Image...."
docker build -t "$IMAGE_NAME" .

log "Stopping previous containers....."
docker compose down || true
log "Starting application...."
docker compose up -d --build
}

#######################################################################
# Health Check
############################################################################

health_check(){
	log "Performing application health check...."
	sleep 60
	if curl -f http://localhost:8000 >/dev/null 2>&1; then
		log "Application is healthy."
	else
		error_exit "Health check failed."
	fi 
}

###########################################################################
# Cleanup
##################################################################################

cleanup(){
	log "Removing dangling Docker images..."
docker image prune -f 
}

###################################################################
#Main Execution
##################################################################

main() {
	log "############################# DEPLOYMENT STARTED #################################"

	check_prerequisites
	install_dependencies
	clone_or_update_repo
	check_port
	deploy
	health_check
	cleanup

	log "############################################## DEPLOYMENT SUCCESSFUL ################################"

}
 main
