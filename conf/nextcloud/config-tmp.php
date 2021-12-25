 'trusted_domains' =>  array (
    0 => 'cloud.ambau-fr.loc',
    1 => 'nextcloud.ambau-fr.loc',
  ),
  'htaccess.RewriteBase' => '/',
  'overwrite.cli.url' => 'https://cloud.ambau-fr.loc',
  'overwriteprotocol' => 'https',
  'forwarded_for_headers' => ['HTTP_X_FORWARDED_FOR'],
  // localization
  'default_phone_region' => 'FR',
  // cache
  'memcache.local' => '\OC\Memcache\Redis',
  'memcache.distributed' => '\OC\Memcache\Redis',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => [
    'host' => 'srv-haproxy', // can also be a unix domain socket: '/tmp/redis.sock'
    'port' => 6379,
    'timeout' => 2.0,
    'read_timeout' => 2.0,
  ],
  // mail
  'mail_domain' => 'ambau-fr.loc',
  'mail_from_address' => 'nextcloud',
  'mail_smtpmode' => 'smtp',
  'mail_smtphost' => 'srv-mail',
  'mail_smtpport' => 25,
  'mail_smtptimeout' => 10,
  'mail_sendmailmode' => 'smtp',
  // log
  'log_type' => 'syslog',
  'loglevel' => 0,
  'syslog_tag' => 'cloud.ambau-fr.loc/nextcloud',
  'logtimezone' => 'Europe/Paris',
);
