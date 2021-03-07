#!/bin/bash
sudo apt -y install apache2
cat << EOF > /tmp/index.html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <title>linux-forwarding httpd</title>
    <style type="text/css">
      body {
        font-family: sans-serif;
        color: #dddddd;
        background-color: #333333;
      }
      a {
        color: #eeeeee;
      }
      a.visited {
        color: #eeeeee;
      }
    </style>
  </head>
  <body>
    <h1>linux-forwarding httpd</h1>
    <hr />
    <p>If you can see this page then forwarding on the intermediate node is working.</p>
  </body>
</html>
EOF
sudo cp -f /tmp/index.html /var/www/html/index.html
rm /tmp/index.html
