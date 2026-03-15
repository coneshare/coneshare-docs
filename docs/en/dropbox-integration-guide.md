# Integrating Dropbox

This guide explains how to configure Dropbox as a file import source in Coneshare. By following these steps, you will enable users in your organization to connect their Dropbox accounts and import files.

The process involves creating an application in the Dropbox App Console and copying the credentials into your Coneshare admin settings.

---

### Step 1: Create and Configure a Dropbox App

First, you need to set up an app in the Dropbox App Console to obtain the necessary API keys.

1.  **Go to Dropbox App Console**: Open your web browser and navigate to the [Dropbox App Console](https://www.dropbox.com/developers/apps). Sign in with your Dropbox account.

2.  **Create a New App**:
    *   Click the **Create app** button.
    *   **Choose an API**: Select **Scoped Access**.
    *   **Choose the type of access**: Select **Full Dropbox** to allow users to browse their entire Dropbox.
    *   **Name your app**: Give your app a unique name, such as "Coneshare-Importer". You will have to agree to Dropbox's terms and conditions.
    *   Click **Create app**.

3.  **Configure App Settings**:
    *   You will be redirected to your new app's settings page.
    *   **Configure Redirect URI**: In the "OAuth 2" section, find the **Redirect URIs** field. Add the following URL, replacing `<your-coneshare-domain>` with your actual Coneshare site domain:
        ```
        https://<your-coneshare-domain>/auth/dropbox/callback
        ```
        Click **Add** to save the URI.

    *   **Set Permissions**: Navigate to the **Permissions** tab. You need to grant the app permission to read files and user information. Check the following permissions:
        *   `account_info.read` - To get user account information.
        *   `files.metadata.read` - To list files and folders.
        *   `files.content.read` - To download files.
    *   Click **Submit** at the bottom of the page to save the permission changes.

### Step 2: Get Your App Key and App Secret

Now you will get the credentials that Coneshare needs to connect to Dropbox.

1.  **Navigate to App Settings**: Go back to the **Settings** tab for your Dropbox app.

2.  **Copy Your Credentials**:
    *   Locate the **App key**. This is your Client ID.
    *   Locate the **App secret**. This is your Client Secret.
    *   Copy both of these values to a secure location.

!!! danger "Important"
    Treat the Client Secret like a password. Do not share it publicly.
    

### Step 3: Add Credentials to Coneshare

Finally, enter the credentials you just created into the Coneshare admin panel.

1.  **Log in to Coneshare**: Sign in to your Coneshare instance with an administrator account.

2.  **Go to Admin Settings**: Navigate to the **Settings** page in the admin area.

3.  **Enter Credentials**:
    *   Find the **Cloud Services** section.
    *   Locate the following fields:
        *   `DROPBOX_APP_KEY`
        *   `DROPBOX_APP_SECRET`
    *   Paste the **App key** and **App secret** you copied from the Dropbox App Console into the corresponding fields.

4.  **Save Settings**: Click the **Save** or **Update** button to apply the changes.

The integration is now complete. Your users will see a "Dropbox" option in the "Upload" menu, allowing them to connect their accounts and import files.
