#!/bin/bash

cd

echo 'install Java 1.8.x'
sudo amazon-linux-extras enable corretto8
sudo yum -y install java-1.8.0-amazon-corretto
java -version

echo 'install Minecraft server 1.16.5'
wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar
mkdir minecraft
mv server.jar minecraft/minecraft_server-1.16.5.jar

echo "set Minecraft server infrastructure"
chmod 755 minecraft.sh
mv minecraft.sh minecraft/.
chmod 755 maintenance.sh
mv maintenance.sh minecraft/.
sudo chown root minecraft.service
sudo chmod 644 minecraft.service
sudo mv minecraft.service /etc/systemd/system/minecraft.service

echo "initialize Minecraft server"
cd minecraft
java -Xmx512M -Xms512M -jar minecraft_server-1.16.5.jar --initSettings
sed -i -e "$ s/eula=false/eula=true/g" eula.txt

echo "register Minecraft server daemon"
sudo systemctl daemon-reload
sudo systemctl enable minecraft

echo "The Minecraft server setup is complete. After setting the details, you should execute 'sudo systemctl start minecraft'."
