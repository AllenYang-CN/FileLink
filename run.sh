#!/bin/bash

# Java应用重启脚本
# 使用方法: ./restart_java_app.sh [start|stop|restart|status]

# 配置信息
APP_NAME="FileLink"          # 应用名称
APP_JAR="FileLink-1.0-SNAPSHOT.jar"            # JAR文件名
APP_ARGS=""                               # 启动参数
JAVA_OPTS="-Xmx64m -Xms64m"             # JVM参数
LOG_FILE="FlieLink.out"                # 日志文件
PID_FILE="FileLink.pid"                # PID文件
WORK_DIR=$(dirname "$0")                  # 工作目录

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色

# 检查命令行参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请指定操作 [start|stop|restart|status]${NC}"
    exit 1
fi

# 获取PID
get_pid() {
    if [ -f "$PID_FILE" ]; then
        echo $(cat "$PID_FILE")
else
echo ""
fi
}

# 检查应用是否正在运行
is_running() {
local pid=$(get_pid)
if [ -z "$pid" ]; then
        return 1
    fi
    
    # 检查进程是否存在
    ps -p $pid > /dev/null 2>&1
return $?
}

# 启动应用
start() {
if is_running; then
        echo -e "${YELLOW}应用已在运行中 (PID: $(get_pid))${NC}"
        return 0
    fi
    
    echo -e "${GREEN}正在启动应用...${NC}"
    
    # 启动Java应用
    cd "$WORK_DIR"
    nohup java -jar $JAVA_OPTS "$APP_JAR" $APP_ARGS > "$LOG_FILE" 2>&1 &

# 保存PID
echo $! > "$PID_FILE"

# 验证应用是否成功启动
sleep 2
if is_running; then
        echo -e "${GREEN}应用已启动 (PID: $(get_pid))${NC}"
        echo -e "${GREEN}日志文件: $LOG_FILE${NC}"
    else
        echo -e "${RED}应用启动失败${NC}"
        rm -f "$PID_FILE"
    fi
}

# 停止应用
stop() {
    if ! is_running; then
        echo -e "${YELLOW}应用未在运行${NC}"
        return 0
    fi
    
    echo -e "${GREEN}正在停止应用...${NC}"
    
    local pid=$(get_pid)

# 尝试正常停止应用
kill $pid

# 等待应用停止
local countdown=10
while is_running && [ $countdown -gt 0 ]; do
echo -e "${YELLOW}等待应用停止... ($countdown)${NC}"
        sleep 1
        countdown=$((countdown-1))
done

# 如果仍然在运行，则强制终止
    if is_running; then
        echo -e "${RED}应用未正常停止，正在强制终止...${NC}"
        kill -9 $pid
sleep 2
fi

if ! is_running; then
        echo -e "${GREEN}应用已停止${NC}"
        rm -f "$PID_FILE"
    else
        echo -e "${RED}无法停止应用 (PID: $pid)${NC}"
    fi
}

# 显示应用状态
status() {
    if is_running; then
        echo -e "${GREEN}应用正在运行 (PID: $(get_pid))${NC}"
        echo -e "${GREEN}日志文件: $LOG_FILE${NC}"
    else
        echo -e "${RED}应用未在运行${NC}"
    fi
}

# 根据命令行参数执行相应操作
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        status
        ;;
    *)
        echo -e "${RED}错误: 未知命令 '$1'${NC}"
        echo -e "${RED}可用命令: start|stop|restart|status${NC}"
        exit 1
        ;;
esac

exit 0


