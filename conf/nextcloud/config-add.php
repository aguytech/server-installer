 'trusted_domains' =>  array (
    0 => 'cloud._APA_DOM_FQDN',
    1 => 'nextcloud._APA_DOM_FQDN',
  ),
  'htaccess.RewriteBase' => '/',
  'overwrite.cli.url' => 'https://cloud._APA_DOM_FQDN',
  'overwriteprotocol' => 'https',
  'forwarded_for_headers' =>
  array (
    0 => 'HTTP_X_FORWARDED_FOR',
  ),
  // various
  'default_phone_region' => 'FR', // localization
  'localstorage.allowsymlinks' => true, // symlinks
  // cache
  'memcache.local' => '\OC\Memcache\Redis',
  'memcache.distributed' => '\OC\Memcache\Redis',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => [
    'host' => 'S_SERVICE[proxy]', // can also be a unix domain socket: '/tmp/redis.sock'
    'port' => 6379,
    'timeout' => 2.0,
    'read_timeout' => 2.0,
  ],
  // mail
  'mail_domain' => '_APA_DOM_FQDN',
  'mail_from_address' => 'nextcloud',
  'mail_smtpmode' => 'smtp',
  'mail_smtphost' => 'S_SERVICE[mail]',
  'mail_smtpport' => 25,
  'mail_smtptimeout' => 10,
  'mail_sendmailmode' => 'smtp',
  // log
  'log_type' => 'syslog',
  'loglevel' => 0,
  'syslog_tag' => 'cloud._APA_DOM_FQDN/nextcloud',
  'logtimezone' => 'Europe/Paris',
);
