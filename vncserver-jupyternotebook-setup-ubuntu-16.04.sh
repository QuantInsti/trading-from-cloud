#!/bin/bash

set -e

#installing packages

SCRIPT_USER=$USER
SCRIPT_HOME=$HOME

printf "\nInstalling required packages\n" 

sudo apt update && sudo apt -y install unzip xfce4 xfce4-goodies xfonts-base xfonts-75dpi xfonts-100dpi tightvncserver python2.7 python-pip 

sudo python2.7 -m pip install jupyter pandas


#killing services / processes

if systemctl is-active vncserver@1.service; then \
   sudo systemctl stop vncserver@1.service && printf "\vncserver@1.service stopped\n"; \
elif pgrep vnc; then \
	sudo pkill vnc;
fi

if systemctl is-active jupyter-notebook.service; then \
   sudo systemctl stop jupyter-notebook.service && printf "\jupyter-notebook.service stopped\n"; \
elif pgrep jupyter; then \
	sudo pkill jupyter;
fi

#setting up vnc server

touch $SCRIPT_HOME/.Xresources && touch $SCRIPT_HOME/.Xauthority

if [ ! -f $SCRIPT_HOME/.vnc/passwd ]; then 
	printf "\nEnter Password for VNC Dekstop\n" 
fi



vncserver :1 && vncserver -kill :1

if [ ! -f $SCRIPT_HOME/.vnc/xstartup.bk ]; then
	mv  $SCRIPT_HOME/.vnc/xstartup $SCRIPT_HOME/.vnc/xstartup.bk
fi

cat > $SCRIPT_HOME/.vnc/xstartup << EOL
#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
/etc/X11/Xsession
export XKL_XMODMAP_DISABLE=1

EOL

chmod a+x $SCRIPT_HOME/.vnc/xstartup






#setting up jupyter notebook
if [ ! -f $SCRIPT_HOME/.jupyter/jupyter_notebook_config.py ]; then
	jupyter notebook --generate-config
fi

if [ ! -f $SCRIPT_HOME/.jupyter/jupyter_notebook_config.json ]; then
	printf "\nEnter Password for Jupyter notebook\n" && jupyter notebook password
fi

printf "\nAdding services for VNC server and Jupyter Notebook\n"

sudo bash -c "cat >  /etc/systemd/system/vncserver@.service << EOL
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=${SCRIPT_USER}
PAMName=login
PIDFile=${SCRIPT_HOME}/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver  :%i
ExecStop=/usr/bin/vncserver -kill :%i
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

EOL"


sudo bash -c "cat >  /etc/systemd/system/jupyter-notebook.service << EOL
[Unit]
Description=Jupyter Notebook
After=syslog.target network.target

[Service]
Type=simple
User=${SCRIPT_USER}
PIDFile=${SCRIPT_HOME}/.jupyter/jupyter.pid
ExecStart=/usr/local/bin/jupyter notebook --config=${SCRIPT_HOME}/.jupyter/jupyter_notebook_config.py  --no-browser --ip=0.0.0.0 --port=8888
WorkingDirectory=${SCRIPT_HOME}
Restart=always
RestartSec=10


[Install]
WantedBy=multi-user.target

EOL"

sudo systemctl daemon-reload \
&& sudo systemctl enable vncserver@1.service && sudo systemctl enable jupyter-notebook.service \
&& sudo systemctl start vncserver@1  && sudo systemctl start jupyter-notebook.service

#setting up TWS and IBridgePy

#TWS
curl -s -O https://download2.interactivebrokers.com/installers/tws/stable/tws-stable-linux-x64.sh

chmod a+x tws-stable-linux-x64.sh
echo "n" | ./tws-stable-linux-x64.sh

#ibridgepy
mkdir -p i-bridge-py && curl -s http://www.ibridgepy.com/wp-content/uploads/2018/08/IBridgePy_Ubuntu_Python27_64.zip -o i-bridge-py/IBridgePy_Ubuntu_Python27_64.zip
unzip -o i-bridge-py/IBridgePy_Ubuntu_Python27_64.zip -d i-bridge-py/
