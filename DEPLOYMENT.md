# MoonFlow 部署指南

本指南将帮助您在不同环境中部署 MoonFlow 项目。

---

## 📋 目录

- [环境要求](#环境要求)
- [本地开发部署](#本地开发部署)
- [Docker 部署](#docker-部署)
- [生产环境部署](#生产环境部署)
- [Kubernetes 部署](#kubernetes-部署)
- [云平台部署](#云平台部署)
- [配置说明](#配置说明)
- [监控和日志](#监控和日志)
- [备份和恢复](#备份和恢复)
- [故障排除](#故障排除)

---

## 环境要求

### 系统要求

| 组件 | 最低要求 | 推荐配置 |
|------|---------|---------|
| CPU | 2 核 | 4 核+ |
| 内存 | 4 GB | 8 GB+ |
| 磁盘 | 20 GB | 50 GB+ |
| 操作系统 | Ubuntu 18.04+ / macOS 10.14+ / Windows 10+ |

### 软件依赖

| 软件 | 版本 | 说明 |
|------|------|------|
| Node.js | 18.x+ | 前端构建 |
| MoonBit | 最新版 | 后端运行时 |
| Git | 2.x+ | 版本控制 |
| Docker | 20.x+ | 容器化（可选） |
| Kubernetes | 1.24+ | 容器编排（可选） |

---

## 本地开发部署

### 前端

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:5173
```

### 后端 (MoonBit)

```bash
# 进入后端目录
cd core

# 类型检查
moon check

# 运行测试
moon test

# 构建发布版本
moon build

# 运行编译后的程序
moon run moonflow_core
```

### 同时启动前后端

```bash
# 终端 1: 启动前端
cd frontend && npm run dev

# 终端 2: 启动后端
cd core && moon run moonflow_core
```

---

## Docker 部署

### 前端 Dockerfile

创建 `frontend/Dockerfile`:

```dockerfile
# 构建阶段
FROM node:20-alpine AS builder

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖
RUN npm ci

# 复制源代码
COPY . .

# 构建
RUN npm run build

# 运行阶段
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Nginx 配置

创建 `frontend/nginx.conf`:

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # SPA 路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 代理（如果后端也在 Docker 中）
    location /api/ {
        proxy_pass http://backend:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### docker-compose.yml

创建项目根目录 `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # 前端服务
  frontend:
    build:
      context: .
      dockerfile: frontend/Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend
    environment:
      - NODE_ENV=production
    networks:
      - moonflow-network

  # 后端服务 (MoonBit)
  backend:
    image: moonbitlang/moonbit-runtime:latest
    working_dir: /app
    volumes:
      - ./core:/app
    command: moon run moonflow_core
    ports:
      - "3000:3000"
    environment:
      - MOONFLOW_ENV=production
      - LOG_LEVEL=info
    networks:
      - moonflow-network

networks:
  moonflow-network:
    driver: bridge
```

### 构建和运行

```bash
# 构建并启动所有服务
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重新构建
docker-compose up -d --build --force-recreate
```

---

## 生产环境部署

### 1. 构建前端

```bash
cd frontend

# 安装生产依赖
npm ci --only=production

# 构建生产版本
npm run build

# 输出在 dist/ 目录
```

### 2. 配置 Nginx

```bash
# 安装 Nginx
sudo apt update
sudo apt install nginx

# 复制配置
sudo cp deployment/nginx/moonflow.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/moonflow.conf /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

创建 `/etc/nginx/sites-available/moonflow.conf`:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL 配置
    ssl_certificate /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 前端静态文件
    root /var/www/moonflow/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # API 代理到后端
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;
}
```

### 3. 配置 Systemd 服务

创建 `/etc/systemd/system/moonflow.service`:

```ini
[Unit]
Description=MoonFlow Backend Service
After=network.target

[Service]
Type=simple
User=moonflow
Group=moonflow
WorkingDirectory=/opt/moonflow/core
ExecStart=/usr/local/bin/moon run moonflow_core
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=moonflow

# 环境变量
Environment="NODE_ENV=production"
Environment="LOG_LEVEL=info"
Environment="PORT=3000"

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/moonflow/core

[Install]
WantedBy=multi-user.target
```

### 4. 部署步骤

```bash
# 1. 创建用户
sudo useradd -r -s /bin/false moonflow

# 2. 创建目录
sudo mkdir -p /opt/moonflow
sudo chown moonflow:moonflow /opt/moonflow

# 3. 复制文件
sudo cp -r core /opt/moonflow/
sudo cp -r frontend/dist /var/www/moonflow/

# 4. 安装 MoonBit（如果尚未安装）
# 参考官方文档

# 5. 配置服务
sudo cp deployment/moonflow.service /etc/systemd/system/
sudo systemctl daemon-reload

# 6. 启动服务
sudo systemctl enable moonflow
sudo systemctl start moonflow

# 7. 检查状态
sudo systemctl status moonflow
sudo journalctl -u moonflow -f
```

---

## Kubernetes 部署

### 前端 Deployment

创建 `k8s/frontend-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: moonflow-frontend
  labels:
    app: moonflow
    component: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: moonflow
      component: frontend
  template:
    metadata:
      labels:
        app: moonflow
        component: frontend
    spec:
      containers:
      - name: frontend
        image: moonflow/frontend:latest
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: moonflow-frontend
spec:
  selector:
    app: moonflow
    component: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

### 后端 Deployment

创建 `k8s/backend-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: moonflow-backend
  labels:
    app: moonflow
    component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: moonflow
      component: backend
  template:
    metadata:
      labels:
        app: moonflow
        component: backend
    spec:
      containers:
      - name: backend
        image: moonbitlang/moonbit-runtime:latest
        workingDir: /app
        command: ["moon", "run", "moonflow_core"]
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: LOG_LEVEL
          value: "info"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: moonflow-backend
spec:
  selector:
    app: moonflow
    component: backend
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
```

### Ingress 配置

创建 `k8s/ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: moonflow-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - moonflow.example.com
    secretName: moonflow-tls
  rules:
  - host: moonflow.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: moonflow-frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: moonflow-backend
            port:
              number: 80
```

### 部署命令

```bash
# 应用配置
kubectl apply -f k8s/

# 查看部署状态
kubectl get pods -l app=moonflow
kubectl get svc

# 查看日志
kubectl logs -l app=moonflow,component=frontend
kubectl logs -l app=moonflow,component=backend

# 扩缩容
kubectl scale deployment moonflow-backend --replicas=5
```

---

## 云平台部署

### Vercel (前端推荐)

```bash
# 安装 Vercel CLI
npm install -g vercel

# 登录
vercel login

# 部署
cd frontend
vercel

# 生产环境部署
vercel --prod
```

### Railway (全栈推荐)

1. 连接 GitHub 仓库
2. Railway 自动检测并部署
3. 配置环境变量
4. 部署完成

### Render

1. 创建 Web Service
2. 连接 GitHub
3. 设置构建命令和运行环境
4. 部署

### AWS (EC2 + S3 + CloudFront)

```bash
# 1. 上传前端到 S3
aws s3 sync frontend/dist s3://moonflow-bucket --delete

# 2. 配置 CloudFront
aws cloudfront create-distribution \
  --origin-domain-name moonflow-bucket.s3.amazonaws.com

# 3. 配置 ALB
aws elbv2 create-load-balancer \
  --name moonflow-alb \
  --subnets subnet-xxx subnet-yyy
```

---

## 配置说明

### 环境变量

#### 前端环境变量

创建 `frontend/.env.production`:

```env
VITE_API_BASE_URL=https://api.moonflow.example.com
VITE_APP_NAME=MoonFlow
VITE_APP_VERSION=1.0.0
```

#### 后端环境变量

创建 `core/.env`:

```env
# 应用配置
NODE_ENV=production
LOG_LEVEL=info
PORT=3000

# 数据库（如果使用）
DATABASE_URL=postgresql://user:pass@localhost:5432/moonflow

# 密钥
JWT_SECRET=your-secret-key
ENCRYPTION_KEY=your-encryption-key

# API 密钥
OPENAI_API_KEY=sk-xxx
ANTHROPIC_API_KEY=sk-ant-xxx
```

### 配置文件

MoonFlow 支持 YAML 配置文件:

```yaml
# moonflow-config.yaml
app:
  name: moonflow
  version: 1.0.0
  port: 3000

logging:
  level: info
  format: json
  output: /var/log/moonflow

security:
  enable_approval: true
  require_auth: true
  allowed_origins:
    - https://moonflow.example.com

workflow:
  max_execution_time: 3600000
  max_concurrency: 10
  retry_attempts: 3

storage:
  type: local
  path: /var/moonflow/workflows
```

---

## 监控和日志

### 日志配置

```yaml
# 使用结构化日志
logging:
  level: info
  format: json
  outputs:
    - type: stdout
    - type: file
      path: /var/log/moonflow/app.log
      max_size: 100MB
      max_files: 10
    - type: syslog
      host: localhost
      port: 514
```

### Prometheus 指标

MoonFlow 暴露以下指标端点:

```
GET /metrics
```

可用的指标:
- `moonflow_workflow_executions_total`
- `moonflow_workflow_duration_seconds`
- `moonflow_node_executions_total`
- `moonflow_errors_total`

### Grafana Dashboard

导入 `deployment/grafana-dashboard.json` 到 Grafana 查看可视化指标。

### 健康检查

```bash
# 应用健康检查
curl http://localhost:3000/health

# 就绪检查
curl http://localhost:3000/ready
```

---

## 备份和恢复

### 数据库备份

```bash
# PostgreSQL 备份
pg_dump -U moonflow -d moonflow > backup_$(date +%Y%m%d).sql

# 压缩备份
pg_dump -U moonflow -d moonflow | gzip > backup_$(date +%Y%m%d).sql.gz
```

### 工作流配置备份

```bash
# 备份工作流文件
tar -czf workflows_backup_$(date +%Y%m%d).tar.gz /var/moonflow/workflows

# 备份配置
cp moonflow-config.yaml moonflow-config.yaml.backup
```

### 恢复

```bash
# 恢复数据库
psql -U moonflow -d moonflow < backup_20260402.sql

# 解压工作流
tar -xzf workflows_backup_20260402.tar.gz -C /
```

---

## 故障排除

### 常见问题

#### 1. 前端无法连接后端

```bash
# 检查后端是否运行
curl http://localhost:3000/health

# 检查 Nginx 配置
nginx -t

# 检查防火墙
sudo ufw status
```

#### 2. MoonBit 运行时错误

```bash
# 检查 MoonBit 安装
moon --version

# 更新 MoonBit
moon update

# 清除缓存
moon clean
```

#### 3. Docker 容器问题

```bash
# 查看容器日志
docker-compose logs -f

# 重启容器
docker-compose restart

# 完全重建
docker-compose down -v
docker-compose up -d --build
```

#### 4. 性能问题

```bash
# 检查资源使用
docker stats
kubectl top pods

# 检查慢查询
# 查看日志中的 slow_query 日志
```

### 日志分析

```bash
# 实时查看错误日志
tail -f /var/log/moonflow/app.log | grep ERROR

# 统计错误类型
grep ERROR /var/log/moonflow/app.log | awk '{print $NF}' | sort | uniq -c

# 查看特定工作流的日志
grep "workflow_id=xxx" /var/log/moonflow/app.log
```

### 性能优化

#### Nginx 优化

```nginx
# worker 进程数
worker_processes auto;

# 文件描述符限制
worker_rlimit_nofile 65535;

# 连接优化
keepalive_timeout 65;
keepalive_requests 100;
```

#### MoonBit 优化

```bash
# 使用优化编译
moon build --release

# 启用缓存
moon build --cache
```

---

## 安全检查清单

在生产部署前，确保完成以下安全检查:

- [ ] 启用 HTTPS (SSL/TLS)
- [ ] 配置安全响应头
- [ ] 使用环境变量存储密钥
- [ ] 限制 API 访问速率
- [ ] 配置防火墙规则
- [ ] 启用审计日志
- [ ] 定期更新依赖
- [ ] 备份重要数据

---

## 扩展阅读

- [MoonBit 官方文档](https://www.moonbitlang.cn/docs/)
- [React 部署指南](https://react.dev/learn/deployment)
- [Nginx 部署指南](https://docs.nginx.com/nginx/admin-guide/)
- [Kubernetes 官方文档](https://kubernetes.io/zh/docs/)

---

**维护者**: MoonFlow Team  
**最后更新**: 2026-04-02
