# 📤 GitHub Pages 部署指南

本指南将帮助您将 EvaShade 项目部署到 GitHub Pages，实现网页托管。

---

## 🎯 部署流程

### 第一步：在 GitHub 创建仓库

1. 访问 https://github.com/new
2. 仓库名称：`evashade`（或您喜欢的名称）
3. 设置为 **Public**（公开仓库才能使用免费的 GitHub Pages）
4. **不要**勾选 "Add a README file"
5. 点击 "Create repository"

### 第二步：本地 Git 配置

在项目目录执行以下命令：

```bash
# 进入项目目录
cd d:\KongYicheng\evashade_frontend

# 配置 Git 用户信息（如果还没配置过）
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 添加所有文件到暂存区
git add .

# 首次提交
git commit -m "Initial commit: EvaShade urban vegetation cooling research

- Added bilingual research showcase website (HTML5 + Tailwind CSS)
- Added data analysis pipeline (R scripts for statistics and visualization)
- Added sample dataset with recent sensor measurements (2026-02-23 to 2026-02-25)
- Added comprehensive research documentation
- Configured GitHub Pages deployment workflow
"

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/OpenQwert/evashade.git

# 推送到 GitHub
git push -u origin main
```

### 第三步：启用 GitHub Pages

1. 访问您的仓库：`https://github.com/OpenQwert/evashade`
2. 点击 **Settings**（设置）标签
3. 在左侧菜单找到 **Pages**
4. 在 "Build and deployment" 下：
   - **Source**: 选择 `GitHub Actions`（推荐，已自动配置）
   - 或选择 `Deploy from a branch` → `main` → `/ (root)`
5. 点击 **Save**

### 第四步：等待部署

- 如果使用 **GitHub Actions**：
  - 访问 **Actions** 标签查看部署进度
  - 大约需要 1-2 分钟完成
  - 成功后会显示绿色 ✅

- 如果使用 **Deploy from branch**：
  - 大约需要 1-2 分钟自动部署
  - 刷新 Pages 设置页面查看状态

### 第五步：访问网站

部署成功后，您的网站将可通过以下地址访问：

```
https://openqwert.github.io/evashade/
```

---

## 📊 GitHub Pages 特性

### ✅ 已自动配置的功能

1. **HTTPS 支持** - 自动 SSL 证书
2. **自定义域名** - 可绑定自己的域名（可选）
3. **自动部署** - 每次 `git push` 后自动更新网站
4. **访问统计** - 可在 Insights 中查看流量

### 🔄 更新网站

以后只需：

```bash
# 修改文件后
git add .
git commit -m "Update website content"
git push
```

GitHub Actions 会自动重新部署！

---

## 🌐 其他 GitHub 网页托管方案

### 方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **GitHub Pages** | 免费、自动化、与 Git 集成 | 仅静态网站 | ✅ EvaShade 项目 |
| **GitHub 仓库预览** | 快速预览 README 中的图片 | 需要特殊 URL | 临时分享 |
| **GitBook** | 文档友好、多格式支持 | 需要第三方服务 | 技术文档 |
| **GitHub Codespaces** | 完整开发环境 | 需要付费（超出配额） | 在线开发 |

### GitHub 仓库文件预览

如果想直接在 GitHub 仓库中预览 HTML 文件：

1. 在仓库中点击 `index.html`
2. 点击右上角的 **Preview** 按钮（如果有的话）
3. 或使用第三方工具：

**方法 1：使用 htmlpreview.github.io**

```
URL 格式：
https://htmlpreview.github.io/?https://github.com/OpenQwert/evashade/blob/main/index.html
```

**方法 2：直接查看 raw 文件**

```
https://raw.githubusercontent.com/OpenQwert/evashade/main/index.html
```

---

## 🎨 自定义域名（可选）

如果您有自己的域名：

1. 在域名注册商处添加 DNS 记录：
   ```
   类型: CNAME
   名称: www（或 @）
   值: openqwert.github.io
   ```

2. 在仓库 **Settings → Pages** → **Custom domain** 中输入您的域名

3. 等待 DNS 传播（最多 48 小时，通常几分钟）

---

## 📈 查看访问统计

GitHub Pages 不提供内置统计，但可以添加：

### 方法 1：Google Analytics

在 `<head>` 中添加：

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### 方法 2：Cloudflare Analytics（免费）

添加到网站后即可查看访问统计。

---

## 🐛 常见问题

### Q1: 部署后显示 404

**解决方法**：
- 确认仓库名称与 URL 匹配
- 检查文件是否在 `main` 分支
- 等待 2-3 分钟刷新

### Q2: 网站样式丢失

**解决方法**：
- 检查 CDN 链接是否正确
- 确认文件路径相对位置正确
- 清除浏览器缓存

### Q3: 如何设置默认分支为 main

```bash
git branch -M main
```

---

## 📚 推荐资源

- [GitHub Pages 官方文档](https://docs.github.com/en/pages)
- [GitHub Actions 部署文档](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [静态网站托管对比](https://www.staticgen.com/)

---

## 🎉 完成！

现在您的 EvaShade 项目已经可以在互联网上访问了！

**网站地址**：`https://openqwert.github.io/evashade/`

记得在申请材料中填写这个 URL 展示您的研究项目！ 🚀

---

**EvaShade Research Team** © 2026
