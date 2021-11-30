# Redis configuration
# See https://rspamd.com/doc/workers/controller.html

bind_socket = "*:S_RSPAMD_PORT[controller]";
# password for read-only commands
#password = ;
# password for write commands
#enable_password = ;
# list or map with IP addresses that are treated as secure
# so all commands are allowed from these IPs without passwords
#secure_ip = ;
