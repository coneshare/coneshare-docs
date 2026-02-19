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

3.  **Check out the version you want to upgrade to.** Replace `1.1.0` with your target version tag.
    ```sh
    # Example: Check out version 1.1.0
    git checkout 1.1.0
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

## **Upgrade Paths for Major Versions**

When upgrading across multiple major or minor versions, you may need to upgrade to specific intermediate versions first. These "hard stops" are necessary to ensure critical database migrations are applied correctly.

Skipping a hard stop can lead to a broken installation.

### **Hard Stops**
When upgrading, you must upgrade to **each** hard stop in order between your current version and your target version.

-   `1.0.0`
-   `1.2.0`
-   *(More versions will be added here as they become hard stops)*

For example, to upgrade from `0.9.0` to `1.3.0`, you must follow this path:
```
# Example Path
0.9.0 -> 1.0.0 -> 1.2.0 -> 1.3.0
```
For each step in the path, you must follow the full [Standard Upgrade Process](#standard-upgrade-process).

## **Downgrading**

!!! danger "Downgrading is Not Supported"
    We do not support downgrading Coneshare. Attempting to run an older version after a newer version has run will likely corrupt your data due to database schema incompatibilities.

If you encounter a critical issue after an upgrade, the only safe way to "downgrade" is to restore your instance from the backup you took before the upgrade began.
