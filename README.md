# 🚀 Django Notes App — Automated Deployment Script

A production-ready Bash script to **clone, build, and deploy** the [Django Notes App](https://github.com/LondheShubham153/django-notes-app) using **Docker** and **Nginx** on an Ubuntu EC2 instance — fully automated with logging, health checks, and cleanup.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [Usage](#usage)
- [Configuration](#configuration)
- [Logs](#logs)
- [Troubleshooting](#troubleshooting)

---

## 📖 Overview

`deploy_django.sh` automates the full deployment lifecycle of the Django Notes App on an AWS EC2 Ubuntu instance. It handles everything from dependency installation to container orchestration and health verification — eliminating manual steps and reducing human error.

---

## ✨ Features

- ✅ **Internet & disk space pre-checks** before deployment begins
- ✅ **Auto-installs** Docker, Docker Compose, and Nginx
- ✅ **Clones or updates** the repository automatically
- ✅ **Port conflict detection** on port 80
- ✅ **Docker-based deployment** via `docker compose`
- ✅ **Health check** to verify the app is running after deployment
- ✅ **Auto-cleanup** of dangling Docker images
- ✅ **Timestamped logging** to `/tmp/deployment.log`
- ✅ **Fail-fast error handling** with `set -euo pipefail`

---

## 🛠️ Prerequisites

| Requirement | Details |
|---|---|
| OS | Ubuntu 20.04 / 22.04 / 24.04 |
| Instance | AWS EC2 (or any Ubuntu server) |
| Access | `sudo` privileges |
| Network | Internet connectivity (to reach GitHub) |
| Disk Space | Minimum **1 GB** free on `/` |

> **Note:** Docker, Docker Compose, and Nginx are installed automatically by the script. No manual setup needed.

---

## 📁 Project Structure

```
~/test/
├── deploy_django.sh        # Main deployment script
└── django-notes-app/       # Auto-cloned by the script
    ├── Dockerfile
    ├── docker-compose.yml
    └── ...
```

---

## ⚙️ How It Works

The script executes the following stages in order:

```
check_prerequisites
        ↓
install_dependencies
        ↓
clone_or_update_repo
        ↓
check_port
        ↓
deploy (docker compose up)
        ↓
health_check (curl localhost:8000)
        ↓
cleanup (prune dangling images)
```

### Stage Breakdown

| Stage | Function | Description |
|---|---|---|
| 1 | `check_prerequisites` | Pings GitHub, checks ≥1 GB disk space |
| 2 | `install_dependencies` | Installs Docker, Nginx, Docker Compose v2 |
| 3 | `clone_or_update_repo` | Clones repo or runs `git pull` if it exists |
| 4 | `check_port` | Warns if port 80 is already occupied |
| 5 | `deploy` | Builds Docker image and runs `docker compose up -d` |
| 6 | `health_check` | Waits 60s, then curls `localhost:8000` |
| 7 | `cleanup` | Runs `docker image prune -f` |

---

## 🚀 Usage

### 1. Clone or copy the script to your EC2 instance

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@<your-ec2-public-ip>

# Create a working directory
mkdir ~/test && cd ~/test

# Create the script (paste contents) or upload via scp
scp -i your-key.pem deploy_django.sh ubuntu@<your-ec2-public-ip>:~/test/
```

### 2. Make the script executable

```bash
chmod +x deploy_django.sh
```

### 3. Run the deployment

```bash
./deploy_django.sh
```

### 4. Access the app

Once the health check passes, open your browser and visit:

```
http://<your-ec2-public-ip>:8000
```

> Make sure port **8000** (and optionally **80**) is open in your EC2 Security Group inbound rules.

---

## 🔧 Configuration

You can customize the following variables at the top of the script:

```bash
APP_NAME="django-notes-app"                                         # Local folder name for the cloned repo
REPO_URL="https://github.com/LondheShubham153/django-notes-app.git" # Repository to clone
IMAGE_NAME="notes-app"                                              # Docker image name
CONTAINER_NAME="notes-app-container"                                # Docker container name
LOG_FILE="/tmp/deployment.log"                                      # Path to log file
```

---

## 📄 Logs

All output is logged with timestamps to `/tmp/deployment.log`.

```bash
# View live logs during deployment
tail -f /tmp/deployment.log

# View full log after deployment
cat /tmp/deployment.log
```

**Sample log output:**
```
[2024-06-12 10:00:01] INFO : ############################# DEPLOYMENT STARTED #################################
[2024-06-12 10:00:02] INFO : Checking internet connectivity...
[2024-06-12 10:00:03] INFO : Checking available disk space....
[2024-06-12 10:00:04] INFO : Installing dependencies..
[2024-06-12 10:02:10] INFO : Cloning repository ...
[2024-06-12 10:02:30] INFO : Port 80 is free.
[2024-06-12 10:02:31] INFO : Building Docker Image....
[2024-06-12 10:04:15] INFO : Starting application....
[2024-06-12 10:05:15] INFO : Performing application health check....
[2024-06-12 10:06:15] INFO : Application is healthy.
[2024-06-12 10:06:16] INFO : Removing dangling Docker images...
[2024-06-12 10:06:17] INFO : ############################################## DEPLOYMENT SUCCESSFUL ################################
```

---

## 🐛 Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `Internet Connectivity unavailable` | EC2 can't reach GitHub | Check Security Group outbound rules & VPC routing |
| `Less than 1 GB disk space available` | Low disk | Run `df -h` and free up space or resize volume |
| `Health check failed` | App didn't start in time | Check `docker compose logs` inside the repo folder |
| Port 80 already in use | Another process on port 80 | Run `sudo lsof -i :80` and kill the conflicting process |
| Docker build fails | Missing Dockerfile or bad config | Ensure the repo cloned correctly and has a valid `Dockerfile` |

---

## 📜 License

This project is open-source and free to use under the [MIT License](LICENSE).

---

## 🙌 Acknowledgements

- App source: [LondheShubham153/django-notes-app](https://github.com/LondheShubham153/django-notes-app)
- Deployment script authored for automated CI/CD-style deployments on AWS EC2
