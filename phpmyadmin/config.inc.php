<?php
/* phpMyAdmin basic configuration */

// Servers configuration
$i = 0;
$i++;
$cfg['Servers'][$i]['host'] = 'cnt-db';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = '';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['AllowNoPassword'] = true;
// Directory for saving/loading files from server
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

// Other basic settings
$cfg['blowfish_secret'] = 'your_random_blowfish_secret_here'; // Change this to a long random string