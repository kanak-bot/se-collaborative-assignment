
## **1. Basic Docker commands**

```
# Check Docker version
docker --version

# Check whether Docker Engine is running
docker version

# Download an image
docker pull nginx

# Display downloaded images
docker images

# Run a container
docker run -d --name mycontainer -p 8080:80 nginx

# Display running containers
docker ps

# Display all containers (including stopped)
docker ps -a

# Stop a container
docker stop mycontainer

# Start a stopped container
docker start mycontainer

# Restart a container
docker restart mycontainer

# Remove a container
docker rm mycontainer

# Remove a running container forcefully
docker rm -f mycontainer

# View container logs
docker logs mycontainer

# Follow live logs
docker logs -f mycontainer

# Open a terminal inside a running container
docker exec -it mycontainer sh

# Remove an image
docker rmi nginx
```

**Remember:**

- `docker images` → displays images.
- `docker ps` → displays running containers.
- `docker ps -a` → displays all containers.
- `docker logs` → displays container logs.

## **2. Single-container Docker practical**

**Example scenario:** Run a Node.js application inside a Docker container.

### **Step 1: Create project structure**

```
NodeProject/
│
├── Dockerfile
├── package.json
└── server.js
```

### **Step 2: Create&#x20;**`package.json`

```
{
  "name": "node-project",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "latest"
  }
}
```

### **Step 3: Create&#x20;**`server.js`

```
const express = require("express");

const app = express();

app.get("/", (req, res) => {
    res.send("Hello from Docker!");
});

app.listen(5000, "0.0.0.0", () => {
    console.log("Server running on port 5000");
});
```

### **Step 4: Create&#x20;**`Dockerfile`

```
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
```

### **Step 5: Build and run**

Run these commands from the project directory:

```
# Build Docker image
docker build -t mynodeapp .

# Run container
docker run -d --name nodecontainer -p 5000:5000 mynodeapp

# Check container
docker ps

# View logs
docker logs nodecontainer
```

Open:

```
http://localhost:5000
```

### **Step 6: Stop and remove**

```
docker stop nodecontainer
docker rm nodecontainer
```

## **3. Important Dockerfile instructions**

| Instruction | Purpose                                                 |
| ----------- | ------------------------------------------------------- |
| `FROM`      | Selects the base image                                  |
| `WORKDIR`   | Sets the working directory                              |
| `COPY`      | Copies files into the image                             |
| `RUN`       | Executes commands while building the image              |
| `EXPOSE`    | Documents the application's port                        |
| `CMD`       | Specifies the default command when the container starts |

**Remember the order:**

```
FROM
WORKDIR
COPY
RUN
COPY
EXPOSE
CMD
```

## **4. Docker Compose – Multi-container application**

**Example scenario:** A Node.js backend communicates with a Python scheduled job.

### **Project structure**

```
NodePythonProject/
│
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
├── python-job/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── job.py
│
└── docker-compose.yml
```

### **Backend Dockerfile**

```
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
```

### **Python Dockerfile**

```
FROM python:3.11

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "job.py"]
```

### **Python&#x20;**`requirements.txt`

```
requests
```

### **Docker Compose YAML**

Create `docker-compose.yml` in the root folder:

```
services:

  backend:
    build: ./backend
    ports:
      - "5000:5000"

  python-job:
    build: ./python-job
    depends_on:
      - backend
```

### **Execute**

```
# Build images and start containers in background
docker compose up -d --build

# Check running containers
docker compose ps

# View logs
docker compose logs

# Follow logs
docker compose logs -f

# Stop containers
docker compose stop

# Restart containers
docker compose restart

# Stop and remove containers and network
docker compose down

# Stop and remove containers, network and volumes
docker compose down -v
```

Important command

```
docker compose up -d --build
```

- `up` → creates and starts services.
- `-d` → runs in the background.
- `--build` → builds/rebuilds images before starting.

The order of `-d` and `--build` does not matter.

## **5. MERN multi-container application**

**Example scenario:** A frontend, backend and MongoDB database must run together.

### **Project structure**

```
MERNProject/
│
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── source files
│
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
└── docker-compose.yml
```

### **Backend Dockerfile**

```
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
```

### **Backend&#x20;**`package.json`

```
{
  "name": "mern-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "latest",
    "mongoose": "latest"
  }
}
```

### **Frontend Dockerfile (Vite)**

```
FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "start"]
```

### **Frontend&#x20;**`package.json`

```
{
  "name": "mern-frontend",
  "version": "1.0.0",
  "scripts": {
    "start": "vite --host 0.0.0.0"
  },
  "dependencies": {
    "@vitejs/plugin-react": "latest",
    "vite": "latest",
    "react": "latest",
    "react-dom": "latest"
  }
}
```

### `docker-compose.yml`

```
services:

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "5000:5000"
    depends_on:
      - mongo
    environment:
      MONGO_URL: mongodb://mongo:27017/mydb

  mongo:
    image: mongo:latest
    ports:
      - "27017:27017"
```

### **Execute**

```
docker compose up -d --build

docker compose ps

docker compose logs

docker compose down
```

**Important concepts:**

- `build: ./frontend` → builds the frontend using its Dockerfile.
- `build: ./backend` → builds the backend using its Dockerfile.
- `image: mongo:latest` → uses the MongoDB image directly.
- `depends_on` → controls service startup order.
- `environment` → passes environment variables to a container.
- `mongodb://mongo:27017/mydb` → uses the Compose service name `mongo` as the hostname.

## **6. Important differences to remember**

| Command                        | Meaning                                  |
| ------------------------------ | ---------------------------------------- |
| `docker compose up`            | Starts services in foreground            |
| `docker compose up -d`         | Starts services in background            |
| `docker compose up --build`    | Builds images and starts services        |
| `docker compose up -d --build` | Builds images and starts in background   |
| `docker compose stop`          | Stops containers but keeps them          |
| `docker compose start`         | Starts previously stopped containers     |
| `docker compose restart`       | Restarts containers                      |
| `docker compose down`          | Stops and removes containers and network |
| `docker compose down -v`       | Also removes Compose-managed volumes     |
| `docker compose ps`            | Displays Compose containers              |
| `docker compose logs`          | Displays service logs                    |

## **7. Common exam errors and solutions**

| Error                             | Reason                                    | Solution                                    |
| --------------------------------- | ----------------------------------------- | ------------------------------------------- |
| `package.json not found`          | Missing package.json in build context     | Create it inside the correct service folder |
| `port is already allocated`       | Another application uses that port        | Change host port, e.g. `3001:3000`          |
| `Cannot connect to Docker daemon` | Docker Engine is not running              | Start Docker Desktop                        |
| `container name already in use`   | A container with that name already exists | `docker rm -f containername`                |
| Container exits immediately       | Application stopped or crashed            | `docker logs containername`                 |
| Image build failed                | Dockerfile or dependency issue            | Read the first `ERROR` in the build output  |

**Remember the port format:**

```
ports:
  - "HOST_PORT:CONTAINER_PORT"
```

Example:

```
ports:
  - "3001:3000"
```

You access the application through `localhost:3001`, while it listens on port `3000` inside the container.

## **8. Exam execution sequence — memorize this!**

## **Docker / Compose workflow**

1. **Understand the scenario**

   Identify how many services are needed: backend, frontend, database, Python job, etc.
2. **Create project folders**

   Make one folder for each service.
3. **Create application files**

   Add `package.json`, `server.js`, `job.py`, and other required files.
4. **Create Dockerfiles**

   One Dockerfile for every service that needs to be built.
5. **Create docker-compose.yml**

   Define services, ports, dependencies and environment variables.
6. **Build and start**

   `docker compose up -d --build`
7. **Verify**

   `docker compose ps`
8. **Check logs**

   `docker compose logs`
9. **Clean up**

   `docker compose down`

## **9. Five things you must not forget**

1. Every `build: ./folder` must point to an existing folder containing its Dockerfile.
2. If your Dockerfile runs `npm install`, that folder must contain a valid `package.json`.
3. If your application listens on port 5000, expose/map the correct container port.
4. In Compose, containers communicate using service names, not `localhost`.
5. `depends_on` controls startup order; it does not guarantee that a database is ready to accept connections.

**One correction from our MERN practical:** your earlier build failed because the `package.json` files were missing. Creating only Dockerfiles is not enough. The application source files and dependency files must also exist.

**My advice for tomorrow:** Don't try to memorize every YAML file word for word. Memorize the execution sequence and understand what each service needs. The examiner can change the scenario, but the workflow remains mostly the same. 💪
