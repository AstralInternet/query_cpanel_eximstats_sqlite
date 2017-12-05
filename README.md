# Connect to cPanel EximStats Database from PHP or Perl 
=====

This script was created to solve the accessibility problem after cPanel change the EximStats database from MySQL to SQLite in version 64. ([Official Release Notes](https://documentation.cpanel.net/display/64Docs/64+Release+Notes)). 

The base code of the script will use the cPanel Perl executable (/usr/local/cpanel/3rdparty/bin/perl) and use the cPanel Perl package to access the SQLite DB. We used this package since all other attempts to connect directly to the eximstats SQLite database gave us the following error `file is encrypted or is not a database`. 

_The initial reason that have a read access to the database is to create an automatic SPAM filtering tools in PHP._ 

## Possible issue
=====

On some server, you might get the following error while executing the script : 

> Can't locate JSON.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /root/cp_eximstats_query.pl line 3.
> BEGIN failed--compilation aborted at /root/php/cp_eximstats_query.pl line 3.

If this is the case, you simply need to install the required Perl JSON library with the following command : 
```bash
cpan JSON
```

## eximstats SQLite DB structure
=====

Here is the SQLite table description, please note that this list need more input to be complete.

### Table "defers"

| Field name        | Field Type | Description                            |
|:----------------- |:----------:|:---------------------------------------|
| sendunixtime      | integer    | Time message was sent                  |
| msgid             | char(16)   | Exim message ID                        |
| email             | char(255)	 | problematique email                    |
| transport\_method |  char(45)  | dkim\_remote\_smtp, remote\_smtp       |
| host              | char(255)  | host responding                        |
| ip                | char(255)  | host IP                                |
| message           | char(240)  | Reject Message                         |
| router            | char(65)   | lookuphost,                            |
| deliveryuser      | char(30)   | "-system-" or cPanel user is available |
| deliverydomain    | char(255)  | host responding, if any                |


### Table "sends"

| Field name   | Field Type | Description                              |
|:------------ |:----------:|:-----------------------------------------|
| sendunixtime | integer    | Time message was sent                    | 
| msgid        | char(16)   | Exim message ID                          |
| email        | char(255)  | ...                                      |
| processed    | integer    | Always seen "0"                          |
| user         | char(30)   | cpanel user name, could be "-remote-"    |
| size         | integer    | message size                             |
| ip           | char(46)   | sender IP                                |
| auth         | char(30)   | - localuser, localdelivery, unauthorisez |
| host         | char(255)  | ? Sending host                           |
| domain       | char(255)  | sender domain                            |
| localsender  | integer    | Sent by local account ?                  |
| spamscore    | double     | Not sure, either 0 or unused             |
| sender       | char(255)  | account for sending the email            |

### Table "failures"

| Field name        | Field Type | Description                |
|:----------------- |:----------:|:---------------------------|
| sendunixtime      | integer    | Time message was sent      | 
| msgid             | char(16)   | Exim message ID            |
| email             | char(255)  | failled email address      |
| deliveredto       | char(255)  | email adresse sent to      |
| transport\_method | char(45)   | "remote_smtp"              |
| host              | char(255)  | Responding hosts           |
| ip                | char(255)  | host IP                    |
| message           | char(240)  | Error message from host    |
| router            | char(65)   | "lookupdhost"              |
| deliveryuser      | char(30)   | "-system-"                 |
| deliverydomain    | char(255)  | ? Only if sent from cPanel |

### Table "smtp"

| Field name            | Field Type | Description                                                 |
|:--------------------- |:----------:|:------------------------------------------------------------|
| sendunixtime          | integer    | Time message was sent                                       | 
| msgid                 | char(16)   | Exim message ID                                             |
| email                 | char(255)  | sending email                                               |
| processed             | integer    | ?                                                           |
| transport\_method     | char(45)   | dovecot_virtual_delivery','dovecot_delivery', 'remote_smtp' |
| transport\_is\_remote | integer    | 1 if transport is not local                                 |
| host                  | char(255)  | receiving host                                              |
| ip                    | char(46)   | host ip                                                     |
| deliveredto           | char(255)  | adresse message was sent to                                 |
| router                | char(65)   | "lookupdhost"                                               |
| deliveryuser          | char(30)   | -remote-' or cPanel accont                                  |
| deliverydomain        | char(255)  | null or the actual domain sending                           |
| countedtime           | integer    | ?                                                           |
| countedhour           | integer    | ?                                                           |
| counteddomain         | char(255)  | ?                                                           |


## Sample SQL Query tested :
====

### Query in PHP to get the top 10 email from the defers table

```php
$now= date("Y-m-d H:i:s");                       # Get and format today's date
$interval = new DateTime(date("Y-m-d H:i:s"));   # Create a new date object
$interval->modify('-24 hours');                  # set the interval to 24 hours
$interval=$interval->format('Y-m-d H:i:s');      # Format the interval date

$now = strtotime($now);                          # Change the date to Unix format
$interval = strtotime($interval);                # Change the interval date to unix format

# Builg the query
$query="SELECT email, COUNT( * ) c FROM defers WHERE ip!='127.0.0.1' AND sendunixtime BETWEEN  '$interval' AND '$now' GROUP BY email ORDER BY c DESC LIMIT 10";
```

### Query in PHP to get the top 10 email from the failures table

```php
$now= date("Y-m-d H:i:s");                       # Get and format today's date
$interval = new DateTime(date("Y-m-d H:i:s"));   # Create a new date object
$interval->modify('-24 hours');                  # set the interval to 24 hours
$interval=$interval->format('Y-m-d H:i:s');      # Format the interval date

$now = strtotime($now);                          # Change the date to Unix format
$interval = strtotime($interval);                # Change the interval date to unix format

# Builg the query
$query ="SELECT email, COUNT( * ) c FROM failures WHERE ip!='127.0.0.1' AND sendunixtime BETWEEN  '$interval' AND '$now' GROUP BY email ORDER BY c DESC LIMIT 10";
```