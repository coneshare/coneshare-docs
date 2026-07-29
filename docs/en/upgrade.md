# **Upgrading Coneshare**

We recommend upgrading regularly to get the latest features, bug fixes, and security updates.

!!! warning "Backup Before Upgrading"
    Before you begin, it is critical to **back up your data**. The upgrade process involves data migrations that are not easily reversible. Refer to the [Backup and Recovery](backup.md) guide.

!!! info "Expect Downtime"
    The upgrade process requires stopping all services to run data migrations. Plan for a maintenance window, as Coneshare will be unavailable during the upgrade.

## **Versioning**

We use [Semantic Versioning](https://semver.org/) (`MAJOR.MINOR.PATCH`).

- **MAJOR** versions include significant new features or breaking changes.

- **MINOR** versions add functionality in a backward-compatible manner.

- **PATCH** versions include backward-compatible bug fixes.

You can find the latest release on the [Coneshare Compose Releases](https://github.com/coneshare/coneshare-compose/releases) page.

## **Standard Upgrade Process**

The upgrade process uses `git` to pull the latest version and the installation script to apply any changes.

1.  **Navigate to the installation directory:**
    ```sh
    cd /opt/coneshare/coneshare-compose
    ```

2.  **Fetch the latest release tags from the repository:**
    ```sh
    git fetch --all --tags
    ```

3.  **Check out the version you want to upgrade to.** Replace `1.7.1` with your target version tag.
    ```sh
    # Example: Check out version 1.7.1
    git checkout 1.7.1
    ```

4.  **Run the installation script.** This script pulls the latest Docker images and performs necessary data migrations.
    ```sh
    ./install.sh
    ```

5.  **Restart the services** to apply the changes.
    ```sh
    ./start.sh
    ```

Your Coneshare instance is now upgraded.

## **Rolling / Nightly Builds (Edge Channel)**

Coneshare automatically generates rolling builds on every commit to the `main` branch, allowing you to test and preview the latest unreleased features before an official tag is released.

1.  **Navigate to your installation directory:**
    ```sh
    cd /opt/coneshare/coneshare-compose
    ```

2.  **Fetch and check out the latest `main` branch:**
    ```sh
    git fetch origin
    git checkout main
    git pull origin main
    ```

3.  **Run the installation and restart scripts:**
    ```sh
    ./install.sh
    ./start.sh
    ```

!!! warning "Use at Your Own Risk"
    Rolling builds contain unreleased code and bleeding-edge updates. They are intended for testing and previewing new features and may contain unresolved bugs or breaking changes. **Do not use rolling builds in critical production environments**, and always ensure you have a fresh [backup](backup.md) before upgrading.

## **Downgrading**

!!! danger "Downgrading is Not Supported"
    We do not support downgrading Coneshare. Attempting to run an older version after a newer version has run will likely corrupt your data due to database schema incompatibilities.

If you encounter a critical issue after an upgrade, the only safe way to "downgrade" is to restore your instance from the backup you took before the upgrade began.
