#!/bin/bash
#
# minecraft server manageing script
#

# mincraft_server.jar 実行ユーザ
USERNAME='ec2-user'
# screen名
SCNAME='minecraft'
# minecraft_serverディレクトリ
SERVER_PATH="/home/$USERNAME/minecraft"

# バックアップ取得時間
BK_TIME=`date +%Y%m%d-%H%M%S`
# バックアップ格納ディレクトリ
BK_DIR="/home/$USERNAME/minecraft/backup"
# バックアップ対象データ
BK_FILE="$SERVER_PATH/world \
  $SERVER_PATH/banned-ips.json \
  $SERVER_PATH/banned-players.json \
  $SERVER_PATH/ops.json \
  $SERVER_PATH/server.properties \
  $SERVER_PATH/usercache.json \
  $SERVER_PATH/whitelist.json"
# バックアップデータ名
BK_NAME="$BK_DIR/backup_${BK_TIME}.tar.gz"
# バックアップデータ保存期限(日)
BK_GEN="90"
# 操作ログファイルパス
OPS_PATH="/home/$USERNAME/minecraft/operation.log"


### 再起動操作
function restart() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "restart $SERVICE..."
    screen -p 0 -S $SCNAME -X eval 'stuff "say [MAINTENANCE ALART]"\015'
    sleep 5
    screen -p 0 -S $SCNAME -X eval 'stuff "say This world will SHUT DOWN after 5 minutes. (Cause: restart)"\015'
    sleep 300
    screen -p 0 -S $SCNAME -X eval 'stuff "say [MAINTENANCE ALART]"\015'
    sleep 5
    screen -p 0 -S $SCNAME -X eval 'stuff "say This world will SHUT DOWN right now. thank you."\015'
    sleep 5
    sudo systemctl stop minecraft
    sleep 300
    sudo systemctl start minecraft
    echo "Restart: compleate."
    return 0
  fi
  echo "$SERVICE process is not exist."
  return 1
}

### バックアップ操作
function backup() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    cd $SERVER_PATH
    if [ ! -d $BK_DIR ]; then
      mkdir $BK_DIR
    fi

    echo "backup minecraft data..."
    screen -p 0 -S $SCNAME -X eval 'stuff "say [MAINTENANCE ALART]"\015'
    sleep 5
    screen -p 0 -S $SCNAME -X eval 'stuff "say This world will SHUT DOWN after 5 minutes. (Cause: backup)"\015'
    sleep 300
    screen -p 0 -S $SCNAME -X eval 'stuff "say [MAINTENANCE ALART]"\015'
    sleep 5
    screen -p 0 -S $SCNAME -X eval 'stuff "say This world will SHUT DOWN right now. thank you."\015'
    sleep 5
    sudo systemctl stop minecraft
    sleep 300
    tar cfvz $BK_NAME $BK_FILE
    find $BK_DIR -name "backup_*.tar.gz" -type f -mtime +$BK_GEN -exec rm {} \;
    sleep 5
    sudo systemctl start minecraft
    echo "Backup: compleate."
    return 0
  fi
  echo "$SERVICE process is not exist."
  return 1
}

### ステータスチェック操作
function status() {
  if pgrep -u $USERNAME -f $SERVICE > /dev/null; then
    echo "$SERVICE is already running!"
    return 0
  fi
  echo "$SERVICE is not running!"
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
  restart|reload)
    echo `date`": restart" >> $OPS_PATH;
    restart
    ;;
  backup)
    echo `date`": backup" >> $OPS_PATH;
    backup
    ;;
  status)
    echo `date`": status" >> $OPS_PATH;
    status
    ;;
  *)
    echo  $"Usage: $0 {(reatart|reload)|backup|status}"
    ;;
esac