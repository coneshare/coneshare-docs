# **Uninstall Coneshare**

This guide will walk you through the complete removal of Coneshare and all its associated data from your system.

!!! danger "Permanent Data Loss"
    The following steps will permanently delete all Coneshare data, including uploaded files, the database, and configuration. This action cannot be undone. We strongly recommend you [back up your data](backup.md) before proceeding if you may need it in the future.

## **Step 1: Stop Services and Remove All Docker Data**

This single command will stop and remove all Coneshare containers, networks, Docker volumes (for the database and other services), and the Docker images used by the application.

1.  Navigate to your installation directory:
    ```sh
    cd /opt/coneshare/coneshare-compose
    ```

2.  Run the `down` command with options to remove volumes and images:
    ```sh
    ./dc down -v --rmi all
    ```
    - `-v`: Removes named volumes used for database storage.
    - `--rmi all`: Removes all Docker images used by the services.

## **Step 2: Remove Installation Directory**

After shutting down the services, the final step is to delete the installation directory, which contains configuration files and host-mounted data folders (`data`, `media`).

1.  Navigate out of the `coneshare-compose` directory:
    ```sh
    cd ..
    ```

2.  Remove the directory:
    ```sh
    rm -rf coneshare-compose data media logs
    ```

At this point, Coneshare has been completely removed from your system.
