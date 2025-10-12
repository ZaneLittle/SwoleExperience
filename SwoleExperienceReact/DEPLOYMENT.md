## Building the Docker Container

### Step 1: Mount SMB Share
Ensure the SMB for the app is mounted:
```bash
sudo mount -t cifs -o credentials=~/.smb_creds,vers=3.0,uid=$(id -u),gid=$(id -g),rw,file_mode=0777,dir_mode=0777,sync //<server_ip>/SwoleExperience /mnt/SSD/SwoleExperience
```
**Note**: The `~/.smb_creds` file must contain your user's `username` and `password`.

### Step 2: Copy Project Files
**Option A: Using rsync (Recommended)**
```bash
rsync -av --progress --delete --exclude=node_modules /home/zane/git/SwoleExperience/SwoleExperienceReact/ /mnt/SSD/SwoleExperience/
```

**Option B: Using cp**
```bash
# Copy the files
cp -r ~/git/SwoleExperience/SwoleExperienceReact /mnt/SSD/SwoleExperience

# Remove node_modules
rm -rf /mnt/SSD/SwoleExperience/node_modules

# Sync the drive
sync
```

### Step 3: Build Docker Container in TrueNAS
1. In TrueNAS, open the shell and navigate to your project:
   ```bash
   cd /mnt/your-pool/SwoleExperience/SwoleExperienceReact
   ```

2. Build the docker container:
   ```bash
   sudo docker build -t swole-experience-react:latest .
   ```

## Setup the TrueNAS App - first time setup

### Step 1: Access TrueNAS Web Interface
1. Go to TrueNAS web interface
2. Navigate to **Apps** → **Available Applications**
3. Click **Custom App**

### Step 2: Configure Application Settings
- **Repository**: `swole-experience-react`
- **Tag**: `latest`
- **Pull Policy**: `Never`
- **Port Bind Mode**: `Publish port on the host for external access`
- **Container Port**: `42069`
- **Host Port**: `42069`
- **Protocol**: `TCP`

### Step 3: Deploy
1. Click **Save**
2. Click **Deploy**
3. Wait for deployment to complete
4. Access your app at: `http://your-truenas-ip:42069`

## Redeploying the TrueNAS App
1. Go to TrueNAS web interface
2. Navigate to Apps -> installed Applications
3. Find the Swole Experience Apps and click Edit and Update
4. Redeploy the application