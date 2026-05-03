# 🚂 Railway Deployment Guide - Pahina Connect

## Prerequisites
- GitHub account
- Railway account (railway.app) - sign up with GitHub

---

## STEP 1: Push to GitHub

Open **Git Bash** or **PowerShell** in the project root folder and run:

```bash
git init
git add .
git commit -m "Initial commit - Pahina Connect Library System"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/pahina-connect.git
git push -u origin main
```

> Replace `YOUR_USERNAME` with your actual GitHub username.
> Create the repo on GitHub first at: https://github.com/new

---

## STEP 2: Create Railway Project

1. Go to **https://railway.app**
2. Click **"Start a New Project"**
3. Select **"Deploy from GitHub repo"**
4. Connect your GitHub account if not yet connected
5. Select your **pahina-connect** repository
6. Railway will auto-detect the Dockerfile

---

## STEP 3: Add MySQL Database

1. In your Railway project, click **"+ New"**
2. Select **"Database"** → **"Add MySQL"**
3. Railway will create a MySQL instance automatically
4. Click on the MySQL service to see connection details

---

## STEP 4: Set Environment Variables

In your Railway **web service** (not the MySQL service):

1. Click on your web service
2. Go to **"Variables"** tab
3. Add these variables:

| Variable | Value |
|----------|-------|
| `MYSQL_URL` | Copy from MySQL service → `MYSQL_URL` (starts with `jdbc:mysql://...`) |
| `MYSQL_USER` | Copy from MySQL service → `MYSQLUSER` |
| `MYSQL_PASSWORD` | Copy from MySQL service → `MYSQLPASSWORD` |
| `UPLOAD_DIR` | `/usr/local/tomcat/pahina_uploads` |

> **How to get MySQL values:**
> Click on MySQL service → Variables tab → copy the values

---

## STEP 5: Set Up Database Schema

After deployment, you need to run the SQL setup:

1. In Railway, click on your **MySQL service**
2. Go to **"Connect"** tab
3. Click **"MySQL Client"** or use the connection string
4. Run the contents of `docs/sql/MASTER_SETUP_ALL.sql`

**OR** use a MySQL client like MySQL Workbench:
- Host: from Railway MySQL → `MYSQLHOST`
- Port: from Railway MySQL → `MYSQLPORT`
- User: from Railway MySQL → `MYSQLUSER`
- Password: from Railway MySQL → `MYSQLPASSWORD`
- Database: from Railway MySQL → `MYSQLDATABASE`

---

## STEP 6: Deploy

1. Railway will automatically build and deploy when you push to GitHub
2. Wait for the build to complete (3-5 minutes)
3. Click **"View Logs"** to monitor the build
4. Once deployed, click the generated URL to access your app

---

## STEP 7: Access Your App

Railway will give you a URL like:
```
https://pahina-connect-production.up.railway.app
```

Login with:
- **Admin:** admin@pahinaconnect.com / Admin@123
- **Student:** (register a new account)

---

## Troubleshooting

### Build fails
- Check the Dockerfile is in `PahinaConnect/` folder
- Check Railway build logs for errors

### Database connection error
- Verify all 3 env vars are set correctly
- Make sure MYSQL_URL starts with `jdbc:mysql://`

### App shows error page
- Check Railway deployment logs
- Make sure SQL schema was run

---

## Auto-Deploy on Push

Every time you push to GitHub, Railway will automatically redeploy:

```bash
git add .
git commit -m "Update: description of changes"
git push
```

Railway will rebuild and redeploy automatically! 🚀
