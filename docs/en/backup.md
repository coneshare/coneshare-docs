# **Backup and Recovery**

To ensure data integrity and disaster recovery, you must regularly back up your Coneshare instance. The backup process involves saving the database, the data and media folders, and your configuration files.

!!! warning "Downtime Required for Backups"
    Creating a consistent backup requires stopping the application services. Plan for a brief maintenance window.

## **Backup Process**

Follow these steps to create a complete backup. All commands should be run from your installation directory (`/opt/coneshare`).

### **1. Stop the Services**
To prevent data corruption, stop all services except database before starting the backup.
```sh
cd coneshare-compose
./dc stop web celery redis
cd -
```

### **2. Back Up the Database**
This command dumps the entire PostgreSQL database into a compressed SQL file. The filename will include the current timestamp.
```sh
# This creates a file like coneshare-db_2024-10-26_14_30_00.sql.gz
docker exec -t coneshare-postgres pg_dumpall -c -U postgres | gzip > coneshare-db_`date +%Y-%m-%d"_"%H_%M_%S`.sql.gz
```

### **3. Back Up Data Files**
This command archives and compresses the `data` and `media` directories, which contain all user-uploaded files.
```sh
# This creates a file like coneshare-files_2024-10-26_14_30_00.tar.gz
tar czf coneshare-files_`date +%Y-%m-%d"_"%H_%M_%S`.tar.gz data media
```

### **4. Back Up Configuration Files**
Copy your environment configuration files to a safe location.
```sh
# Create a backups directory if it doesn't exist
mkdir -p backups

# Copy the config files
cp .env app.env backups/
```

### **5. Restart the Services**
Once the backups are complete, you can restart the services.
```sh
./start.sh
```
Store your backup files (`.sql.gz`, `.tar.gz`, and config files) in a secure, remote location.

---

## **Restore Process**

Use the following steps to restore a Coneshare instance from your backup files.

!!! danger "Data Overwritten"
    Restoring from a backup will **completely overwrite** all existing data in your current Coneshare instance.

### **1. Prepare for Restore**
Place your backup files (`.sql.gz`, `.tar.gz`, `app.env`, `.env`) in the root of your installation directory (`/opt/coneshare`).

### **2. Stop the Services**
Ensure all services are stopped before restoring.
```sh
cd coneshare-compose
./stop.sh
cd -
```

### **3. Restore Configuration Files**
Copy your backed-up configuration into place.
```sh
cp backups/app.env .
cp backups/.env .
```

### **4. Restore Data Files**
This command removes the existing `data` and `media` directories and then extracts your backup archive.
```sh
# Make sure your backup file (e.g., coneshare-files_....tar.gz) is in the current directory
FILES_BACKUP_FILE=$(ls -t coneshare-files_*.tar.gz | head -1)

# Remove old directories
rm -rf data media

# Extract the backup
tar xzf $FILES_BACKUP_FILE
```

### **5. Restore the Database**
This command restores the database from your SQL backup file.
```sh
# Make sure your backup file (e.g., coneshare-db_....sql.gz) is in the current directory
DB_BACKUP_FILE=$(ls -t coneshare-db_*.sql.gz | head -1)

gunzip < $DB_BACKUP_FILE | docker exec -i coneshare-postgres psql -U postgres
```

### **6. Restart and Verify**
Start the services and log in to the web interface to confirm that your data has been restored correctly.
```sh
./start.sh
```
