<?php

// DNS check when creating mailboxes or aliases,
// $CONF['emailcheck_resolve_domain']='NO';

// configuration
$CONF['configured'] = true;
// password for www access
$CONF['setup_password'] = '';

// Language files are located in './languages', change as required..
$CONF['default_language'] = 'en';

// Database
$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = '_DB_HOST';
$CONF['database_port'] = '3306';
$CONF['database_name'] = 'postfixadmin';
$CONF['database_user'] = '_DB_PFA_USER';
$CONF['database_password'] = '_DB_PFA_PWD';

// Encrypt
$CONF['encrypt'] = 'php_crypt:_SSL_SCHEME';
//$CONF['dovecotpw'] = "/usr/sbin/doveadm pw";
// Password validation
$CONF['password_validation'] = array(
#    '/regular expression/' => '$PALANG key (optional: + parameter)',
    '/.{5}/'                => 'password_too_short 5',      # minimum length 5 characters
    '/([a-zA-Z].*){2}/'     => 'password_no_characters 2',  # must contain at least 3 characters
    '/([0-9].*){2}/'        => 'password_no_digits 2',      # must contain at least 2 digits
);

// Define the Site Admin's email address below.
// This will be used to send emails from to create mailboxes...
$CONF['admin_email'] = 'postmaster@_DOMAIN_FQDN';
// This will be used as signature in notification messages
$CONF['admin_name'] = 'Postmaster';
// Define the smtp password for admin_email.
// This will be used to send emails from to create mailboxes...
$CONF['admin_smtp_password'] = '';
// Hostname (FQDN) of your mail server.
// This is used to send email to Postfix in order to create mailboxes.
$CONF['smtp_server'] = 'S_SERVICE[mail]';
$CONF['smtp_port'] = '25';
// Hostname (FQDN) of the server hosting Postfix Admin
// Used in the HELO when sending emails from Postfix Admin
$CONF['smtp_client'] = '';
// Set 'YES' to use TLS when sending emails.
$CONF['smtp_sendmail_tls'] = 'NO';

// Mailboxes
// The default aliases that need to be created for all domains
$CONF['default_aliases'] = array (
    'abuse' => 'postmaster',
    'hostmaster' => 'postmaster',
    'webmaster' => 'postmaster',
    'postmaster' => '_EMAIL_TECH',
    'root' => '_EMAIL_TECH',
);
// If you want to store the mailboxes per domain set this to 'YES'.
$CONF['domain_path'] = 'YES';
// If you don't want to have the domain in your mailbox set this to 'NO'.
$CONF['domain_in_mailbox'] = 'NO';
// If you want to define your own function to generate a maildir path set this to the name of the function.
$CONF['maildir_name_hook'] = 'NO';

// Sub-folders which should automatically be created for new users.
//$CONF['create_mailbox_subdirs'] = array('Drafts','Junk','Trash','Sent');
$CONF['create_mailbox_subdirs'] = array();
$CONF['create_mailbox_subdirs_host']='localhost';
// Show used quotas from Dovecot dictionary backend in virtual mailbox listing
$CONF['used_quotas'] = 'YES';
// Note about dovecot config: table 'quota' is for 1.0 & 1.1, table 'quota2' is for dovecot 1.2 and newer
$CONF['new_quota_table'] = 'YES';
// Allows a user to reset his forgotten password with a code sent by email/SMS
$CONF['forgotten_user_password_reset'] = true;
// Allows an admin to reset his forgotten password with a code sent by email/SMS
$CONF['forgotten_admin_password_reset'] = false;

// If you don't want fetchmail tab set this to 'NO';
$CONF['fetchmail'] = 'YES';
// fetchmail_extra_options allows users to specify any fetchmail options and any MDA
$CONF['fetchmail_extra_options'] = 'NO';
// Header
$CONF['show_header_text'] = 'NO';
$CONF['header_text'] = ':: Postfix Admin ::';
// Footer
$CONF['show_footer_text'] = 'YES';
$CONF['footer_text'] = 'Return to _DOMAIN_FQDN';
$CONF['footer_link'] = 'http://_DOMAIN_FQDN';

// Domain
// Specify your default values below. Quota in MB.
$CONF['aliases'] = '10';
$CONF['mailboxes'] = '10';
$CONF['maxquota'] = '10';
$CONF['domain_quota_default'] = '2048';

// Vacation
$CONF['vacation'] = 'NO';
// This domain must exclusively be used for vacation. Do NOT use it for 'normal' mail addresses.
$CONF['vacation_domain'] = 'autoreply._DOMAIN_FQDN';
// If you want users to take control of vacation set this to 'YES'.
$CONF['vacation_control'] ='YES';
// Set to 'YES' if your domain admins should be able to edit user vacation.
$CONF['vacation_control_admin'] = 'YES';
// reply
$CONF['vacation_choice_of_reply'] = array (
   0 => 'reply_once',        // Sends only Once the message during Out of Office
   1 => 'reply_every_mail',       // Reply on every email
   60*60 *24*7 => 'reply_once_per_week'        // Reply if last autoreply was at least a week ago
);

// Set the number of entries that you would like to see
$CONF['page_size'] = '10';

