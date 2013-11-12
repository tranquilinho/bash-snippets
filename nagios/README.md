bash-snippets / nagios
=====================

Setup
-----

Copy the sample config file (custom_scripts_sample.cfg) to /etc/nagios/custom_scripts.cfg and
adapt it to your environment.

Copy the scripts to the local directory specified in the config file.

Add the scripts to your NRPE config file, for example:

command[check_down_nodes]=/usr/local/nagios/custom_scripts/check_down_nodes -w 1 -c 3

You can define the alert ranges with the -w (warning) and -c (critical) parameters.

Some scripts may require sudo (see the script comments).

Contact: jesus.cuenca@gmail.com

