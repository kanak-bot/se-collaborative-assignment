
3. Docker Compose – all important YAML files
Experiment A: Nginx + PostgreSQL
Create folder:
mkdir compose-lab
cd compose-lab


Create docker-compose.yml.

version: "3.9"

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: demo
      POSTGRES_PASSWORD: demo
      POSTGRES_DB: demo_db



Run:
docker compose up -d


Verify:
docker compose ps


Browser:
http://localhost:8080


Experiment B: Add Redis

version: "3.9"

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    depends_on:
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: demo
      POSTGRES_PASSWORD: demo
      POSTGRES_DB: demo_db

  redis:
    image: redis:alpine



Run:
docker compose up -d
docker compose ps


Experiment C: Custom network and volume

version: "3.9"

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    networks:
      - app-net
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: demo
      POSTGRES_PASSWORD: demo
      POSTGRES_DB: demo_db
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-net

networks:
  app-net:

volumes:
  db-data:



Run:
docker compose up -d


Stop:
docker compose down


Start again:
docker compose up -d


Remember:
- networks = Communication.
- volumes = Persistent storage.
- depends_on = Startup dependency.
Experiment D: Flask + Docker Compose
app.py:
from flask import Flaskapp = Flask(__name__)@app.route("/")def home():    return "Hello from Flask + Docker!"if __name__ == "__main__":    app.run(host="0.0.0.0", port=5000)



Dockerfile:

FROM python:3.10-slim

WORKDIR /app

COPY app.py /app/

RUN pip install flask

CMD ["python", "app.py"]



docker-compose.yml:

services:
  web:
    build: .
    ports:
      - "5000:5000"



Run:
docker compose up --build


Browser:
http://localhost:5000


Compose commands
docker compose up -d
docker compose down
docker compose ps
docker compose logs
docker compose logs -f
docker compose restart
docker compose stop
docker compose up --build
docker compose up --scale web=2 -d



4. Kubernetes – Minikube
Step 1: Install Minikube
PowerShell Administrator:
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe


.\minikube-installer.exe


Step 2: Start cluster
minikube start --driver=docker


Check:
minikube status


kubectl version --client


If kubectl is unavailable:
minikube kubectl -- get pods -A


Step 3: Create Nginx deployment
kubectl create deployment mynginx --image=nginx


Check:
kubectl get deployments


kubectl get pods


kubectl describe pods


Step 4: Expose deployment
kubectl expose deployment mynginx --type=NodePort --port=80 --target-port=80


Check:
kubectl get services


Step 5: Scale to four replicas
kubectl scale deployment mynginx --replicas=4


Check:
kubectl get pods


Expected: Four pods.
Step 6: Access application
kubectl port-forward svc/mynginx 8081:80


Browser:
http://localhost:8081


Alternative:
minikube tunnel


minikube service mynginx --url


Dashboard:
minikube dashboard


Step 7: Cleanup
kubectl delete deployment mynginx


kubectl delete service mynginx


minikube stop


Optional complete deletion:
minikube delete


Kubernetes commands to memorise
Command	Meaning
kubectl get pods	View pods
kubectl get deployments	View deployments
kubectl get services	View services
kubectl describe pods	Pod details
kubectl logs POD_NAME	Pod logs
kubectl scale deployment mynginx --replicas=4	Scale
kubectl delete deployment mynginx	Delete deployment
kubectl rollout status deployment/mynginx	Check rollout
kubectl rollout undo deployment/mynginx	Rollback
kubectl exec -it POD_NAME -- /bin/sh	Enter pod

Kubernetes and Nagios (2)(1).doc
 Kubernetes and Nagios (2)(1).doc


5. Nagios monitoring
Step 1: Pull image
docker pull jasonrivers/nagios:latest


Step 2: Run Nagios
docker run --name nagiosdemo -p 8888:80 jasonrivers/nagios:latest


Or background mode:
docker run -d --name nagiosdemo -p 8888:80 jasonrivers/nagios:latest


Step 3: Open dashboard
http://localhost:8888


Credentials:
Username: nagiosadmin
Password: nagios


Step 4: Explore
- Hosts – systems being monitored.
- Services – monitored services.
- Alerts – notifications.
- Host information – details about monitored systems.
Step 5: Stop
docker stop nagiosdemo


docker rm nagiosdemo


If name conflict occurs
docker ps -a


If container exists but is stopped:
docker start nagiosdemo


Viva
- Nagios = Infrastructure monitoring tool.
- Host = Machine being monitored.
- Service = Function/component being monitored.
- Alert = Notification of an issue.
- Nagios can monitor servers, networks, applications and services.
Kubernetes and Nagios (2)(1).doc

6. Jenkins – Maven Java and Maven Web
Your Jenkins jobs must use your repository URL:
https://github.com/kabrakanak26-pixel/Week4-Maven-Lab.git


A. Maven Java Build job
1. Open Jenkins:
http://localhost:8080


2. New Item.
3. Name: MavenJava_Build.
4. Freestyle Project.
5. Source Code Management → Git.
6. Repository URL: Your GitHub URL.
7. Branch: */main.
8. Build Steps → Invoke top-level Maven targets.
9. Select Maven installation configured in Jenkins.
10. Goals:
clean


Add another Maven build step:
install


11. Post-build Actions → Archive artifacts.

Files to archive:
**/*


12. Build other projects:
MavenJava_Test


Trigger only if build is stable.
B. Maven Java Test job
Create:
MavenJava_Test


Configure:
1. Delete workspace before build starts.
2. Copy artifacts from another project.
3. Project name: MavenJava_Build.
4. Stable build only.
5. Artifacts to copy:
**/*


6. Invoke Maven targets:
test


7. Archive artifacts:
**/*


C. Maven Java Pipeline View
1. Click + beside All.
2. Name: MavenJava_Pipeline.
3. Select Build Pipeline View.
4. Choose initial job: MavenJava_Build.
5. Save.
D. Maven Web Build, Test and Deploy
Create three jobs:
MavenWeb_Build
- Git repository: your Week4-Maven-Lab URL.
- Maven goals: clean, then install.
- Archive artifacts: **/*.
- Trigger MavenWeb_Test on stable build.

MavenWeb_Test
- Delete workspace.
- Copy artifacts from MavenWeb_Build.
- Maven goal: test.
- Archive artifacts: **/*.
- Trigger MavenWeb_Deploy after successful build.

MavenWeb_Deploy
- Copy artifacts from MavenWeb_Test.
- Archive or deploy the generated WAR.
- Deploy WAR/EAR to Tomcat 9.x remote if that plugin and deployment target are configured.

Tomcat deployment
Post-build Action:
Deploy WAR/EAR to a container


WAR/EAR file:
**/*.war


Context path:
Webpath


Container:
Tomcat 9.x Remote


Use the actual Tomcat URL, credentials and port configured on your machine.

Important: If your GitHub repository produces a JAR rather than a WAR, you cannot deploy it as a web application using the Tomcat WAR deployment action. Check the generated file under target.

7. Jenkins Pipeline – Groovy script
This is one of the most important things to memorise.
Step 1: Create Pipeline job
1. Jenkins → New Item.
2. Name: Maven_Pipeline.
3. Select Pipeline.
4. Click OK.
5. Pipeline → Definition → Pipeline script.
Step 2: Use this script for your GitHub repository

pipeline {
    agent any

    tools {
        maven 'MAVEN-HOME'
    }

    stages {

        stage('git repo & clean') {
            steps {
                bat 'git clone https://github.com/kabrakan26-pixel/Week4-Maven-Lab.git'
                bat 'mvn clean -f Week4-Maven-Lab/pom.xml'
            }
        }

        stage('install') {
            steps {
                bat 'mvn install -f Week4-Maven-Lab/pom.xml'
            }
        }

        stage('test') {
            steps {
                bat 'mvn test -f Week4-Maven-Lab/pom.xml'
            }
        }

        stage('package') {
            steps {
                bat 'mvn package -f Week4-Maven-Lab/pom.xml'
            }
        }
    }
}



This assumes the repository contains pom.xml at its root. If it is inside another directory, change the path.
Step 3: Save and execute
1. Apply.
2. Save.
3. Click Build Now.
4. Open the build.
5. Click Console Output.
6. Verify all stages are successful.
Understand the script
Code	Meaning
pipeline	Pipeline definition
agent any	Any available Jenkins agent
tools	Configured tools
maven 'MAVEN-HOME'	Maven installation name
stages	Collection of stages
stage	Individual stage
steps	Commands executed in stage
bat	Windows command
sh	Linux command

Extra script commands
Print welcome message:
echo "Welcome to Jenkins Pipeline"


Print build number:
echo "Build Number: ${env.BUILD_NUMBER}"


Compile Java:
bat "javac Hello.java"


On Linux, replace bat with sh.
Add deployment stage
Add this after the package stage:
stage('deploy') {
    steps {
        echo 'Deploying application'
    }
}


This is only a placeholder; actual deployment needs deployment commands or a configured deployment plugin.
Build triggers
Trigger	Meaning
Build periodically	Run at scheduled times
Poll SCM	Check repository for changes
GitHub hook trigger	Start from GitHub webhook
Upstream/downstream	Trigger from another job
Build Now	Manual build

Every day at 6 PM:
0 18 * * *


WEEK-6 Jenkins Script and builds triggers (2).docx
 Jenkins Script and buils triggers(1).docx


8. Jenkins – GitHub webhook and ngrok
Step 1: Install ngrok
Download ngrokStep 2: Configure authentication
ngrok config add-authtoken YOUR_TOKEN


Step 3: Start tunnel
ngrok http 8080


Copy the generated HTTPS URL.

Example:
https://example.ngrok-free.app


Step 4: Configure GitHub webhook
Open your repository:
1. Settings.
2. Webhooks.
3. Add webhook.
Payload URL:
https://YOUR_NGROK_URL/github-webhook/


Content type:
application/json


Choose:
Just the push event


Click Add webhook.
Step 5: Configure Jenkins
1. Open Jenkins.
2. Select your job.
3. Configure.
4. Build Triggers.
5. Enable:
GitHub hook trigger for GITScm polling


6. Save.
Step 6: Test
Make a change to your local project:
git add .
git commit -m "Test webhook"
git push origin main


Jenkins should automatically trigger the build.
Git push

GitHub

Webhook

ngrok

Jenkins automatic build

Jenkins CICD with git Hooks(1).docx

9. Jenkins – Gmail email notifications
Step 1: Generate Gmail App Password
1. Open Google Account.
2. Security.
3. Enable 2-Step Verification.
4. Go to App passwords.
5. Create password named Jenkins-Demo.
6. Copy the generated password.
Never put your normal Gmail password into Jenkins.
Step 2: Install plugin
Jenkins → Manage Jenkins → Manage Plugins.

Install:
Email Extension Plugin


Step 3: Configure global email settings
Manage Jenkins → Configure System.

E-mail Notification
Setting	Value
SMTP Server	smtp.gmail.com
SMTP Authentication	Enabled
Username	Your Gmail ID
Password	Gmail App Password
SSL	Enabled
Port	465
Reply-To	Your Gmail ID

Test configuration by sending a test email.

Extended E-mail Notification
Setting	Value
SMTP Server	smtp.gmail.com
SMTP Port	465
SSL	Enabled
Credentials	Gmail ID + App Password
Content Type	text/html or default
Triggers	Success / Failure

Step 4: Configure job notification
1. Open Jenkins job.
2. Configure.
3. Post-build Actions.
4. Add Editable Email Notification.
5. Add recipient email address.
6. Select Success and/or Failure triggers.
7. Save.
8. Build the job.
If email doesn't arrive


# se-collaborative-assignment     AWS – EC2 cloud deployment
Step 1: Create an EC2 instance
1. Login to AWS.
2. Open EC2.
3. Launch Instance.
4. Select Ubuntu Server.
5. Choose an available eligible instance type.
6. Create/download .pem key pair.
7. Configure security group.
8. Allow SSH (22), HTTP (80), HTTPS (443), and your application port (6060) as required.
9. Launch instance.
Step 2: Connect through PowerShell
cd "$HOME\Downloads"


ssh -i "CSM-C.pem" ubuntu@YOUR_PUBLIC_DNS


Step 3: Install prerequisites
sudo apt update
sudo apt install docker.io -y
sudo apt install git -y
sudo apt install nano -y
sudo systemctl start docker
sudo systemctl enable docker


Step 4: Clone your Maven project
git clone https://github.com/kabrakanak26-pixel/Week4-Maven-Lab.git


cd Week4-Maven-Lab


Step 5: Create Dockerfile
Your exact Dockerfile depends on the artifact and project structure.

For a WAR application deployed to Tomcat:

FROM tomcat:9.0-jdk17-temurin

COPY target/your-app.war /usr/local/tomcat/webapps/your-app.war

EXPOSE 8080

CMD ["catalina.sh", "run"]



Replace your-app.war with the actual WAR filename.
Step 6: Build and run
sudo docker build -t mywebapp .


sudo docker images


sudo docker run -d --name app-demo -p 6060:8080 mywebapp


sudo docker ps


Step 7: Access publicly
http://YOUR_PUBLIC_IP:6060/your-app/


Make sure the security group allows inbound TCP 6060.
AWS scenario questions
Problem	Solution
SSH fails	Check key pair, username and port 22
Website doesn't load	Check container and security group
404 error	Check WAR filename and application path
Docker permission denied	Use sudo docker
Container name conflict	Check sudo docker ps -a
Need to save EC2 cost	Stop the instance when finished

Cloud Deployment using AWS.docx

- Check SMTP server.
- Check port 465.
- Check SSL.
- Check Gmail App Password.
- Check recipient.
- Check job-level email trigger.
- Check console output for SMTP errors.
