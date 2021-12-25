<?php

$CONFIG = [

'trusted_domains' =>
   [
    'nextcloud._APA_DOM_FQDN',
    '_APA_SUB._APA_DOM_FQDN',
    '_CT_NAME'
  ],
'default_language' => 'en',
'force_language' => 'false',
'default_locale' => 'en_US',
'default_phone_region' => 'FR',
'force_locale' => 'false',
'defaultapp' => 'dashboard,files',
//'skeletondirectory' => '/path/to/nextcloud/core/skeleton',
//'templatedirectory' => '/path/to/nextcloud/templates',
'mail_domain' => '_APA_DOM_FQDN',
'mail_from_address' => 'nextcloud',
'mail_smtpmode' => 'smtp',
'mail_smtphost' => '${S_SERVICE[mail]}',
'mail_smtpport' => 25,
'mail_smtptimeout' => 10,
'mail_sendmailmode' => 'smtp',
'overwritehost' => 'cloud._APA_DOM_FQDN',
'overwriteprotocol' => 'https',
'overwritewebroot' => '',
'overwritecondaddr' => '',
'overwrite.cli.url' => 'https://cloud._APA_DOM_FQDN',
'htaccess.RewriteBase' => '/',
//'htaccess.IgnoreFrontController' => false,
'allow_local_remote_servers' => true,
'appcodechecker' => true,
'log_type' => 'syslog',
'loglevel' => 2,
'syslog_tag' => '_APA_DOM_FQDN/Nextcloud',
'logtimezone' => 'Europe/Paris',
'enable_previews' => true,
'preview_max_x' => 1024,
'preview_max_y' => 1024,
'preview_max_filesize_image' => 50,
'memcache.local' => '\OC\Memcache\Redis',
'memcache.distributed' => '\OC\Memcache\Redis',
'redis' => [
	'host' => 'S_SERVICE[proxy]', // can also be a unix domain socket: '/tmp/redis.sock'
	'port' => 6379,
	'timeout' => 2.0,
	'read_timeout' => 2.0,
	'user' =>  '', // Optional, if not defined no password will be used.
	'password' => '', // Optional, if not defined no password will be used.
	'dbindex' => 0, // Optional, if undefined SELECT will not run and will use Redis Server's default DB Index.
],
'tempdirectory' => 'S_VM_PATH_SHARE/php/_APA_DOM_FQDN/tmp',
//'share_folder' => '/',
//'theme' => '',
'localstorage.allowsymlinks' => false,
'trusted_proxies' => ['S_SERVICE[proxy]', 'S_SERVICE[proxy].lxd'],
'forwarded_for_headers' => ['HTTP_X_FORWARDED_FOR'],
'memcache.locking' => '\\OC\\Memcache\\Redis',
'login_form_autocomplete' => true,
];
