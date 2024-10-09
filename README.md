# Torpod-http
This Dockerfile sets up a container using **Alpine Linux** with both **Tor** and **Nginx** services. It installs the necessary packages, creates a non-root user named `torrin`, and configures Tor as a hidden service that forwards traffic to Nginx.

The web content is served from `/var/www/html`, and both Tor and Nginx are configured to run with proper user permissions and directory structures.

The container exposes ports **80** and **9050**, and runs both Tor and Nginx in the foreground, allowing the server to be accessed through the **Tor network**.

Usage:

```bash
# Clone this repository:
$ git clone https://github.com/insidious-security.com/torpod-http

# Create a strong random password to use in the tor configuration:
$ TORPOD_KEY=$(openssl rand -base64 32)

# Update the Dockerfile on line 8
$ cd torpod-http/
$ sed -i "s|\"GENERATED_KEY_HERE\"|\"$TORPOD_KEY\"|" Dockerfile

# In the torpod-http directory, build the image:
torpod-http/:$ docker build -t torpod:latest .

# Run the container:
torpod-http/:$ docker run -d --name torpod torpod:latest 

# Get the onion address (hostname):
torpod-http/:$ docker exec -it torpod cat /var/lib/tor/hidden_service/hostname

# Clean up:
$ docker stop torpod && docker rm torpod && docker rmi torpod:latest
```

Key Components:
- **Base Image**: Uses `alpine:latest` as the base image for a lightweight container.
- **Installing Dependencies**: Installs **Tor** and **Nginx** via the Alpine package manager (`apk`) without caching the package list (`--no-cache`).
- **User Creation**: Adds a non-root user `torrin` and associates the user with the group `nginx` to ensure services run as a non-privileged user.
- **Tor Configuration**: 
  - Sets environment variables for user and group.
  - Verifies the Tor configuration and generates a hashed password.
  - Creates the directory for a **Tor hidden service** and sets the correct permissions.
  - Configures Tor to run as a hidden service by updating `/etc/tor/torrc`.
- **Exposed Ports**: Exposes ports **80** (HTTP) and **9050** (Tor SOCKS) for incoming connections.
- **Nginx Configuration**: 
  - Sets environment variables for user and group.
  - Creates necessary directories for serving web content and logging.
  - Copies a custom `nginx.conf` configuration file into the container.
  - Verifies Nginx's configuration.
- **Working Directory and Files**: Sets the working directory to `/var/www/html` and copies web content from the host.
- **Running the Container**: Runs both **Tor** and **Nginx** simultaneously, ensuring both services stay active.
