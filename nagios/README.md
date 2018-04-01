bash-snippets / nagios
=====================

Setup
-----

Add the script you need to your NRPE config file, for example:

command[check_down_nodes]=/usr/local/bash_snippets/nagios/custom_scripts/check_down_nodes -w 1 -c 3

You can define the alert ranges with the -w (warning) and -c (critical) parameters.

Some scripts may require sudo (see each script comments).

Contact: jesus.cuenca@gmail.com

