#!/bin/bash
# Создание сервиса

SERVICE_NAME="vsegost-web"


SERVICE_FNAME="./${SERVICE_NAME}.service"
# Затираем предыдыущий файл
sudo echo "" > ${SERVICE_FNAME}
# Добавляем строки в файл сервиса
sudo echo "[Unit]" >> ${SERVICE_FNAME}
sudo echo "Description=${SERVICE_NAME}" >> ${SERVICE_FNAME}
sudo echo "After=network.target" >> ${SERVICE_FNAME}
sudo echo "" >> ${SERVICE_FNAME}

sudo echo "[Service]" >> ${SERVICE_FNAME}
sudo echo "ExecStart=/usr/local/bin/vsegost-web.sh" >> ${SERVICE_FNAME}
# sudo echo "Type=simple" >> ${SERVICE_FNAME}
sudo echo "Type=forking" >> ${SERVICE_FNAME}
sudo echo "RemainAfterExit=yes" >> ${SERVICE_FNAME}

#sudo echo "Restart=always" >> ${SERVICE_FNAME}

sudo echo "User=root" >> ${SERVICE_FNAME}
#sudo echo "User=mna" >> ${SERVICE_FNAME}

sudo echo "WorkingDirectory=/usr/local/bin" >> ${SERVICE_FNAME}
sudo echo "StandardOutput=syslog" >> ${SERVICE_FNAME}
sudo echo "StandardError=syslog" >> ${SERVICE_FNAME}
sudo echo "" >> ${SERVICE_FNAME}

sudo echo "[Install]" >> ${SERVICE_FNAME}
sudo echo "WantedBy=multi-user.target" >> ${SERVICE_FNAME}
