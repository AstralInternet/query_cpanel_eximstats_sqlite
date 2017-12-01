<?php
/**
 *  Demonstrate hos to use the cp_eximstats_query.pl script
 * 
 * This script was made to be executed from cPanel shell. Make sure the 
 * installed PHP executable have access to the "system()" function. If not, 
 * must enable the function.
 * 
 * @author   Astral Internet inc <info@astralinternet.com>
 * @link     https://github.com/AstralInternet/query_cpanel_eximstats_sqlite
 */

# Full path to the script
$script = "/root/cp_eximstats_query.pl";  

# Build a query to list all tables within the Eximstats SQLite database.
$query = "SELECT name FROM sqlite_master WHERE type='table'";

# Build the commande for the perl Script.
$command = "perl " . $script . ' "' . $query . '"';

# Call the perl script to get the resut in a json format
$json_records = json_encode(system($command));

echo "\n";
echo "\033[1;32mBold Php Output:\033[0m  \n";
echo "\033[32m". $json_records . "\033[0m \n";

?>