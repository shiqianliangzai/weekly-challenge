#!/bin/bash

# 🎯 GitHub Pages 自动部署脚本

set -e

echo "🚀 GitHub Pages 部署工具"
echo "========================"
echo ""

# 输入 Token
read -p "📝 请粘贴你的 GitHub Token: " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Token 不能为空！"
    exit 1
fi

# 仓库信息
REPO_NAME="weekly-challenge"
DESCRIPTION="🌟 每周挑战 - 打破惯性，活出精彩"
USERNAME=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*"' | cut -d'"' -f4)

if [ -z "$USERNAME" ]; then
    echo "❌ Token 无效，请检查后重试"
    exit 1
fi

echo "👤 用户: $USERNAME"
echo ""

# 检查仓库是否存在
EXIST=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$USERNAME/$REPO_NAME")

if [ "$EXIST" = "404" ]; then
    echo "📦 创建仓库..."
    curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
        -d "{\"name\":\"$REPO_NAME\",\"description\":\"$DESCRIPTION\",\"private\":false}" \
        https://api.github.com/user/repos
    echo "✅ 仓库创建成功"
else
    echo "📦 仓库已存在，跳过创建"
fi

echo ""
echo "🔧 配置 Git..."
cd /root/.openclaw/workspace/weekly-challenge
git config user.email "deploy@github.com"
git config user.name "Deploy Bot"
git remote get-origin &>/dev/null && git remote remove origin || true
git remote add origin "https://$USERNAME:$GITHUB_TOKEN@github.com/$USERNAME/$REPO_NAME.git"

echo ""
echo "📤 推送代码..."
git checkout -b gh-pages 2>/dev/null || git checkout gh-pages
git branch -D master 2>/dev/null || true
git add .
git commit -m "🚀 Deploy: $(date)" --allow-empty
git push -u origin gh-pages --force

echo ""
echo "✅ 部署完成！"
echo ""
echo "🌐 你的网站将在几分钟内可用："
echo "   https://$USERNAME.github.io/$REPO_NAME/"
echo ""
echo "⏰ 首次推送可能需要 1-2 分钟生效"
