# Integrating Nextcloud

This guide explains how to configure a self-hosted Nextcloud instance as a file import source in Coneshare. By following these steps, you will enable users in your organization to connect their Nextcloud accounts and import files.

The process involves registering an OAuth 2.0 client in your Nextcloud instance and copying the credentials into your Coneshare admin settings.

---

### Step 1: Register an OAuth 2.0 Client in Nextcloud

First, you need to register Coneshare as an authorized application within your Nextcloud instance.

1.  **Log in to Nextcloud**: Sign in to your Nextcloud instance with an administrator account.

2.  **Navigate to Security Settings**:
    *   Click on your profile icon in the top-right corner and select **Administration settings**.
    *   In the left-hand navigation pane, under the "Administration" section, click on **Security**.

3.  **Add an OAuth 2.0 Client**:
    *   Scroll down to the **OAuth 2.0 clients** section.
    *   Click the **Add client** button.
    *   Fill in the form:
        *   **Name**: Enter a name that your users will recognize, such as `Coneshare`.
        *   **Redirect URI**: Enter the following URL, replacing `<your-coneshare-domain>` with your actual Coneshare site domain:
            ```
            https://<your-coneshare-domain>/auth/nextcloud/callback
            ```
    *   Click the Add button to save the new client.

### Step 2: Get Your Client ID and Secret

After creating the client, Nextcloud will display the credentials needed for the integration.

1.  **Find Your Client**: In the list of OAuth 2.0 clients, locate the `Coneshare` client you just created.

2.  **Copy Your Credentials**:
    *   The **Client Identifier** is your Client ID.
    *   The **Secret Key** is your Client Secret.
    *   Copy both of these values to a secure location. You will need them in the next step.

!!! danger "Important"
    Treat the Client Secret like a password. Do not share it publicly.


### Step 3: Add Credentials to Coneshare

Finally, enter your Nextcloud instance URL and the credentials you just created into the Coneshare admin panel.

1.  **Log in to Coneshare**: Sign in to your Coneshare instance with an administrator account.

2.  **Go to Admin Settings**: Navigate to the **Settings** page in the admin area.

3.  **Enter Credentials**:
    *   Find the **Cloud Services** section.
    *   Locate the following fields:
        *   `NEXT_CLOUD_HOST`: Enter the full URL to your Nextcloud instance (e.g., `https://cloud.yourcompany.com`).
        *   `NEXT_CLOUD_CLIENT_ID`: Paste the **Client Identifier** you copied.
        *   `NEXT_CLOUD_CLIENT_SECRET`: Paste the **Secret** you copied.

4.  **Save Settings**: Click the **Save** or **Update** button to apply the changes.

The integration is now complete. Your users will see a "Nextcloud" option in the "Upload" menu, allowing them to connect their accounts and import files.
