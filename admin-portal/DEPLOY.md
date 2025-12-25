# Deployment Guide

## First Time Setup

```bash
./deploy.sh
```

The script will:

1. Ask for VPS IP and ports
2. Install dependencies
3. Build the app
4. Start with PM2

## Deploy New Source Code

After making changes to the source code:

```bash
./deploy-new.sh
```

This will:

1. Stop current deployment
2. Install dependencies (if package.json changed)
3. Build the app
4. Restart with PM2

## Manual Deploy

```bash
# 1. Set API URL
# If using nginx with domain (recommended): use relative path /api
echo "VITE_API_BASE_URL=/api" > .env
# OR if accessing directly (not through nginx): use full URL
# echo "VITE_API_BASE_URL=http://YOUR_VPS_IP:8080/api" > .env

# 2. Build
npm install
npm run build

# 3. Start with PM2
pm2 start ecosystem.config.cjs
pm2 save
```

## Important Notes

- **API URL**:
  - When using nginx with domain (e.g., https://ves-booking.io.vn): use relative path `/api` (default)
  - When accessing directly (not through nginx): use full URL `http://YOUR_VPS_IP:8080/api`
- **Ports**: Default frontend port is 3000, backend is 8080
- **Firewall**: Make sure port 3000 (or your frontend port) is open

## PM2 Commands

```bash
pm2 logs ves-admin-portal    # View logs
pm2 status                   # View status
pm2 restart ves-admin-portal # Restart
pm2 stop ves-admin-portal    # Stop
pm2 monit                    # Monitor resources
```

## Update

**Easy way:**

```bash
./deploy-new.sh
```

**Manual way:**

```bash
# 1. Update code
git pull  # or copy new files

# 2. Stop, rebuild, restart
pm2 stop ves-admin-portal
npm install
npm run build
pm2 restart ves-admin-portal
```

## Troubleshooting

**Can't access from browser:**

- Check PM2: `pm2 status`
- Check firewall: `sudo ufw status`
- View logs: `pm2 logs ves-admin-portal`

**API calls fail:**

- If using nginx: ensure `.env` has `VITE_API_BASE_URL=/api` (relative path)
- If accessing directly: ensure `.env` has full URL `VITE_API_BASE_URL=http://YOUR_VPS_IP:8080/api`
- Verify backend is running: `curl http://YOUR_VPS_IP:8080/api/health` or `curl https://ves-booking.io.vn/api/health`
- Rebuild after changing `.env`: `npm run build`
