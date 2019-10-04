#! perl  
#~ $VERSION = '0.01';

#~ use strict;
#~ require Data::Trie;
#~ my $f = Data::Trie->new();
#~ $f->add("foo");
#~ my @foo = $f->getAll();

use strict;
use warnings;
use StructureServer;

my $l;
my $r2;

  $l = "(item(item(item^item^item)))";
  $r2 = StructureServer::LispToNary($l);
  print "AsLisp: " . $StructureServer::AsLisp . "\n";
  print "NaryToLisp: " . StructureServer::NaryToLisp( $r2) . "\n";
