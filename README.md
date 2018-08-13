# trading-from-cloud
## Setup
### 1. You can use already build AMI available on AWS. <link>
### 2. You can use script to download and install everything on your ubuntu server. (commands below)

####  a. To setup

Run the below command and enter passwords for vncserver and jupyter notebook during installation. 

`bash -c "$(curl  https://raw.githubusercontent.com/QuantInsti/trading-from-cloud/master/vncserver-jupyternotebook-setup-ubuntu-16.04.sh)"` 



####  b. To change password of VNC server (optional)
`vncpasswd`

####  c. To change password of jupyter notebook (optional)
`jupyter notebook password`

## Usage
VNC Client - <server ip/host>:5901 (any VNC client)

Jupyter Notebook - <server ip/host>:8888 (Chrome / firefox browser)
