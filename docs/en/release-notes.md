## [1.1.2](https://github.com/coneshare/coneshare/compare/v1.1.1...v1.1.2) (2026-03-09)


### Features

* Make password validators configurable via environment ([7c6221c](https://github.com/coneshare/coneshare/commit/7c6221c0198989b8ac984be99f11b9975139c527))
* Match container uid/gid with host ([aae283e](https://github.com/coneshare/coneshare/commit/aae283e7cf77a261929723886b5c31c937221f40))


### Bug Fixes

* Encode Content-Disposition filename using RFC 5987 ([ab77812](https://github.com/coneshare/coneshare/commit/ab778128aa6d601ef52424822385ece6c12ace22))
* Enforce dataroom document visibility for downloads ([739cde3](https://github.com/coneshare/coneshare/commit/739cde33a73df7ade84e026caf8eff8ab6143133))
* Enforce default authenticated access for DRF views ([4ffa818](https://github.com/coneshare/coneshare/commit/4ffa818eae444b1e0be419c354e09562ed8b3da1))
* fix None puid and pgid ([61db674](https://github.com/coneshare/coneshare/commit/61db674d9d006cb3a5c43e2bc7e49b2980f0f948))
* fix security headers in nginx ([d07aff7](https://github.com/coneshare/coneshare/commit/d07aff740efa7a711c96d17d4702d3493a3e2d8c))
* Secure upload/download handlers against path traversal ([6b152ca](https://github.com/coneshare/coneshare/commit/6b152ca27e069bf9ff202a8f1dddcf156e533147))
* Use list-form `check_call` to avoid shell interpretation ([0d5e996](https://github.com/coneshare/coneshare/commit/0d5e9968d23c407372d804567d0309ea67dadc8d))
* Validate content ownership in dataroom add-content endpoint ([5993994](https://github.com/coneshare/coneshare/commit/59939946976faedf093cea54caeeacdffa047303))

## [1.1.1](https://github.com/coneshare/coneshare/compare/v1.1.0...v1.1.1) (2026-03-06)


### Features

* Add download action to documents list item dropdown menu ([5960eeb](https://github.com/coneshare/coneshare/commit/5960eebace693da2130f16b6175fd2b07578f1ed))
* Add file request feature to portal features ([f1bd2b6](https://github.com/coneshare/coneshare/commit/f1bd2b6674fc92c58641a576618f7bd6cb8231a9))
* Add new 'copy document' functionality, enabling users to duplicate their documents ([2a1894d](https://github.com/coneshare/coneshare/commit/2a1894dc2339a0ffe324c344f8b877a7dc59ece6))
* Force file download by setting Content-Disposition header ([60cbae8](https://github.com/coneshare/coneshare/commit/60cbae852fe61e1ae7328208e32faa7e6719addd))


### Bug Fixes

* Allow multiple users to create same-named folders ([7eceaa3](https://github.com/coneshare/coneshare/commit/7eceaa3fa49cdd3fd200694467d328bece8ad747))
* Reorder functions to prevent initialization error in DocumentsPage ([9917fe5](https://github.com/coneshare/coneshare/commit/9917fe589f6bbb7fbd711c34333e02488b250b57))


## [1.1.0](https://github.com/coneshare/coneshare/compare/v1.0.0...v1.1.0) (2026-02-18)


### Features

* Add Docs link to header navigation bar ([ae9ddf9](https://github.com/coneshare/coneshare/commit/ae9ddf98feeefa6d887479f1e34029757fdd4d81))
* Add 'File Requests' Feature: Share Upload Link for Collecting Files from Users ([#118](https://github.com/coneshare/coneshare/pull/118)) ([#119](https://github.com/coneshare/coneshare/pull/119))
* Implement Release Please workflow for automated releases ([b89d92c](https://github.com/coneshare/coneshare/commit/b89d92c68fa4ff123a7bf4d14272c03c39d1e4ca))


### Bug Fixes

* Ensure atomic transaction for file upload finalization ([445f2b6](https://github.com/coneshare/coneshare/commit/445f2b6fe2536e184e6d0000d7cc9e3cd4e59814))

## 1.0.0

### Core Features

Document & Folder Management

 • Full CRUD Operations: Create, rename, move, and delete documents and folders with ease.
 • Robust Uploading: Upload individual files, or entire folder structures using drag-and-drop. Duplicate file and folder names are automatically handled by appending a numeric suffix.
 • Selection & Bulk Actions: Select multiple items to perform bulk actions like moving or deleting.
 • Starred Items: Mark important documents and folders as "starred" for quick access and filtering.
 • Sorting: Organize your view by sorting items by name or file size.

Datarooms

 • Curated Collections: Group related documents and folders into secure Datarooms for organized sharing.
 • Flexible Content Management: A single document can be added to multiple folders within a Dataroom, acting like a shortcut. Items can be renamed and removed on a per-dataroom basis.
 • Hierarchical Structure: Create and manage a nested folder structure within each Dataroom.

Secure Sharing & Access Control

 • Shareable Links: Generate secure, unique links for individual documents or entire Datarooms.
 • Granular Link Settings:
    • Password Protection: Secure links with a password.
    • Expiration: Set an expiration date and time for links to automatically become inactive.
    • Active/Inactive Toggle: Manually enable or disable links at any time.
    • Download Control: Allow or prevent viewers from downloading the original file.
 • Viewer Identification:
    • Email Requirement: Optionally require viewers to provide an email address to access content.
    • Email Verification: Enforce email verification for an additional layer of security.
 • Dynamic Watermarking:
    • Apply dynamic watermarks to document previews and downloads to protect sensitive information.
    • Watermarks can include static text or dynamic variables like the viewer's IP address or email.

Analytics & Tracking

 • Central Dashboard: A main dashboard provides a summary of recent activity, including the latest view sessions and active share links.
 • View Session Tracking: See who has viewed your links, including their geographic location (country/city), device information (OS/browser), and whether they downloaded the file.
 • Granular Page-Level Analytics: For multi-page documents, see exactly which pages were viewed and for how long.
 • Dataroom Visit Tracking: Monitor visits to individual documents and folders within a Dataroom.

Cloud Storage Integration

 • Import from Cloud: Directly import files from connected cloud storage accounts, including Dropbox, Google Drive, and self-hosted Nextcloud instances.
 • Secure Connection Management: Securely connect and manage your cloud accounts via OAuth2.

⚙️ Administration & Management

 • Admin Panel: A dedicated admin panel for superusers to manage application-wide settings and users.
 • User Management: Admins can create, update, and delete users within their organization.
 • Login Activity: Track and review user login events for security and auditing purposes.
 • File Size Quotas: Enforce per-user storage quotas to manage system resources. Your current usage is displayed in the sidebar.
