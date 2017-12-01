#!/usr/local/cpanel/3rdparty/bin/perl
# 
# Script used to query the cPanel EximStats SQLite database.
# Important : This script is depandant of the cPanel Perl Path.
# 
# @author   Astral Internet inc <info@astralinternet.com>
# @link     https://github.com/AstralInternet/query_cpanel_eximstats_sqlite

use strict;
use JSON;
use CGI;
use DBD::SQLite();  # cPanel Perl package to connect to SQLite (Must have a valid cPanel license to use).

# Connect to the EximStats SQLite database using the DBD::SQLite Package
my $dbh = DBI->connect('dbi:SQLite:/var/cpanel/eximstats_db.sqlite3', undef, undef,
        {
            sqlite_open_flags                => "DBD::SQLite::OPEN_READONLY",
            sqlite_use_immediate_transaction => 0,
            RaiseError                       => 1,
            PrintWarn                        => 0,
        }
    );
if ( not $dbh or $DBI::errstr ) {
    my $err = $DBI::errstr // q{something went wrong};
    print $err."\n";
    die qq{$err\n};
}

# Grab the query from the function argument
my ($query) = @ARGV;

# Prepare the SQL query
my $sth = $dbh->prepare( $query );

# Get the recordset by executing the query
my $rv = $sth->execute() or die $DBI::errstr;

# If there not record, print the error message
if($rv < 0) {
   print $DBI::errstr;
}

# Transform the recordset into a JSON format
my @output;
while ( my $row = $sth->fetchrow_hashref ){
    push @output, $row;
}

# Add a header to the output for better PHP interpretation
my $cgi = CGI->new;
print $cgi->header( 'application/json' );

# Output the JSON string
print to_json( { myData => \@output } );

# Close DB Connection
$dbh->disconnect();