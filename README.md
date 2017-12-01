# Connect to cPanel EximStats Database from PHP or Perl 

This script was created to solve the accessibility problem after cPanel change the EximStats database from MySQL to SQLite in version 64. ([Official Release Notes](https://documentation.cpanel.net/display/64Docs/64+Release+Notes)). 

The base code of the script will use the cPanel Perl executable (/usr/local/cpanel/3rdparty/bin/perl) and use the cPanel Perl package to access the SQLite DB. We used this package since all other attempts to connect directly to the eximstats SQLite database gave us the following error `file is encrypted or is not a database`. 

_The initial reason that have a read access to the database is to create an automatic SPAM filtering tools in PHP._ 

## Possible issue

On some server, you might get the following error while executing the script : 

> Can't locate JSON.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /root/cp_eximstats_query.pl line 3.
> BEGIN failed--compilation aborted at /root/php/cp_eximstats_query.pl line 3.

If this is the case, you simply need to install the required Perl JSON library with the following command : 
```bash
cpan JSON
```