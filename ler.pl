#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV;
# THE PARTY IS ON!!!
# *************************
use MongoDB;
use MongoDB::OID;
# *************************
$|=1;
my $csv = Text::CSV->new({sep_char=> ','});

my $filename = 'teste.csv';
open(my $fh, '<:encoding(UTF-8)', $filename) or die "Não abriu arquivo: '$filename' $!";


my $client = MongoDB::MongoClient->new(auto_connect => 0);
$client->connect;
my $db = $client->get_database('cadastro');
my $users = $db->get_collection( 'usuCadastro' );

#contador
my $contador = 1;

my $sec;
my $min;
my $hour;
my $mday;
my $mon;
my $year;
my $wday;
my $yday;
my $isdst;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $agora = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon, $mday, $hour, $min, $sec);
print "\nInicio em : $agora\n";
while (my $row = <$fh>) {
	chomp $row;
	if($csv->parse($row)){
		my @fields = $csv->fields();
#		print "\n**************************************\n";		
		for(my $i = 0; $i < scalar(grep $_, @fields); $i++){
			if($i==2) # cpf
			{
				$fields[$i] =~ s/([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})/$1.$2.$3-$4/;
			}
			if($i==3) # tel res
			{
				$fields[$i] =~ s/([0-9]{4})([0-9]{4})/$1-$2/g;
			}
			if($i==4) # tel cel
			{
				$fields[$i] =~ s/([0-9]{5})([0-9]{4})/$1-$2/g;
			}
			if($i==5) # salario
			{
				$fields[$i] = sprintf("%.2f", $fields[$i]/100); #s/([0-9]{5})([0-9]{4})/$1.$2/g;
			}
			if($i==6) # dt
			{
				$fields[$i] =~ s/([0-9]{1})([0-9]{2})([0-9]{2})/$1-$2-$3/g;
			}

#			print "\n\r\t$fields[$i]\t\t\t $i";
			


		}
		#print "\nINSERINDO NO MONGODB\n";

my $sec;
my $min;
my $hour;
my $mday;
my $mon;
my $year;
my $wday;
my $yday;
my $isdst;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$agora = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon, $mday, $hour, $min, $sec);


		$users->insert({"contador" => "$contador", "nome" => "$fields[0]", "rg" => "$fields[1]", "cpf" => "$fields[2]", "telres" => "$fields[3]" , "telcel" => "$fields[4]" , "salario" => "$fields[5]", "dt" => "$fields[6]", "dtCadastro" => "$agora"}, );
$contador++;
print "\rcontador: $contador";
	}
}

undef $users;
undef $db;
undef $client;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$agora = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon, $mday, $hour, $min, $sec);
print "Finalizado em : $agora";
print "\n____________________________________________________________________\n";
print "Terminou o insert no banco\n";
