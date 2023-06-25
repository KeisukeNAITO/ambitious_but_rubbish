#!/bin/bash
#
# minecraft server manageing script
#

# mincraft_server.jar 実行ユーザ
USERNAME='ec2-user'
# screen名
SCNAME='minecraft'
# minecraft_serverディレクトリ
SERVER_PATH='/home/ec2-user/minecraft'
# 実行するminecraft_server.jar
SERVICE='minecraft_server-1.16.5.jar'
# メモリ設定
XMX='1024M'
XMS='1024M'
# 操作ログファイルパス
OPS_PATH='/home/ec2-user/minecraft/operation.log'

### 起動操作
function start() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "$SERVICE process is already exist."
    return 0
  fi
  echo "Starting $SERVICE..."
  cd $SERVER_PATH
  screen -AmdS $SCNAME java -Xmx$XMX -Xms$XMS -jar $SERVICE nogui
  echo "Start: compleate."
  return 0
}

### 停止操作
function stop() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "Stopping $SERVICE..."
    screen -p 0 -S $SCNAME -X eval 'stuff "save-all flush"\015'
    screen -p 0 -S $SCNAME -X eval 'stuff "stop"\015'
    screen -p 0 -S $SCNAME -X eval 'stuff "exit"\015'
    echo "Stop: compleate."
    return 0
  fi
  echo "$SERVICE process is not exist."
  return 1
}


# ユーザチェック
OPERATOR=`whoami`
if [ $OPERATOR != $USERNAME ]; then
  echo "Please run the $USERNAME user."
  exit
fi

# 操作振り分け
case "$1" in
  start)
    echo `date`": start" >> $OPS_PATH;
    start
    ;;
  stop)
    echo `date`": stop" >> $OPS_PATH;
    stop
    ;;
  *)
    echo `date`": *" >> $OPS_PATH;
    echo  $"Usage: $0 {start|stop}"
    ;;
esac
