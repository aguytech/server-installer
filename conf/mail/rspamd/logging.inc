# Relevant documentation: https://rspamd.com/doc/configuration/logging.html

# Defines logging type (file, console or syslog)
# For some types mandatory attributes may be required
type = "syslog";
# Path to log file for file logging (required for file type)
#filename =
# Logging facility for syslog type (required if this type is used)
facility = 2;
# Defines logging level (error, warning, info or debug)
level = "info";
# List that contains IP addresses for which debugging should be turned on.
#debug_ip = ;
# A list of modules that are enabled for debugging
# See https://rspamd.com/doc/configuration/logging.html#defined-debug-modules
# debug_modules = [];