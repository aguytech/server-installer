# Redis configuration
# See https://rspamd.com/doc/workers/rspamd_proxy.html

bind_socket = "127.0.0.1:S_RSPAMD_PORT[proxy]";
# Enable milter mode
milter = yes;
# Needed for Milter usually
timeout = 120s;
upstream "local" {
	# Self-scan upstreams are always default
	default = yes;
	# Enable self-scan
	self_scan = yes;
}

# Spawn more processes in self-scan mode
count = 4;
# How many times master is queried in case of failure
max_retries = 5;
# Discard message instead of rejection
discard_on_reject = false;
# Tell MTA to quarantine rejected messages
quarantine_on_reject = false;
# Use the specific spam header
spam_header = "X-Spam";
# Use custom rejection message
reject_message = "Spam message rejected";
