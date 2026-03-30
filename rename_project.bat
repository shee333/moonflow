@echo off
echo ======================================
echo MoonFlow 项目重命名脚本
echo ======================================
echo.

echo 步骤 1: 检查当前目录
if exist "d:\Project\moonbit" (
    echo   [OK] 找到目录: d:\Project\moonbit
) else (
    echo   [ERROR] 未找到目录: d:\Project\moonbit
    echo   请确保您在正确的位置
    pause
    exit /b 1
)

echo.
echo 步骤 2: 检查目标目录是否已存在
if exist "d:\Project\moonflow" (
    echo   [WARNING] 目标目录已存在: d:\Project\moonflow
    echo   将先删除旧目录...
    rmdir /s /q "d:\Project\moonflow"
    echo   [OK] 已删除旧目录
)

echo.
echo 步骤 3: 正在重命名目录...
move "d:\Project\moonbit" "d:\Project\moonflow"

if %errorlevel% equ 0 (
    echo   [OK] 重命名成功！
) else (
    echo   [ERROR] 重命名失败！
    echo   可能有其他程序正在使用该目录
    echo   请关闭所有相关程序后重试
    pause
    exit /b 1
)

echo.
echo ======================================
echo 重命名完成！
echo 新目录: d:\Project\moonflow
echo ======================================
echo.
echo 后续步骤:
echo 1. cd d:\Project\moonflow
echo 2. git status
echo 3. 创建 GitHub 仓库并推送
echo.
pause
