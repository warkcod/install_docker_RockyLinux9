# Install Docker on Rocky Linux 9

This script replaces **Podman** with **Docker** for container management tasks. Docker is selected for its mature ecosystem, robust CI/CD integration, and advanced features, making it a better fit for many use cases, especially in multi-container setups.

## Features
- Seamlessly switches from **Podman** to **Docker**.
- Utilizes Docker's client-server architecture for easier container management.
- Leverages Docker tools like **Docker Compose** and **Docker Swarm** for container orchestration.
- Ensures better compatibility and integration with CI/CD workflows.

## Requirements
- Docker should be installed on your system.
- Ensure Podman is installed (for the script to replace it).

## Usage
1. Clone the repository:


   ```bash
   git clone https://github.com/warkcod/install_docker_RockyLinux9.git && cd install_docker_RockyLinux9 && ./install_docker_rockylinux9.sh
   
   ```
   
## License

This project is licensed under the MIT License - see the LICENSE file for details.


## Contributions

Feel free to fork the repository, raise issues, and submit pull requests. All contributions are welcome!
