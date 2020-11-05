#! /bin/bash
sudo apt -y update
sudo apt -y install nginx
sudo service nginx start
sudo echo '<html><body><div><h1>Cisco SPL</h1></div></body></html>' | sudo tee /var/www/html/index.html
