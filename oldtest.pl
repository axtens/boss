#! perl 
#~ $VERSION = '0.01';

#~ use strict;
#~ require Data::Trie;
#~ my $f = Data::Trie->new();
#~ $f->add("foo");
#~ my @foo = $f->getAll();

use strict;
use warnings;
use Tree::Nary;

use constant IN_ORDER => $Tree::Nary::IN_ORDER;
use constant PRE_ORDER => $Tree::Nary::PRE_ORDER; 
use constant POST_ORDER => $Tree::Nary::POST_ORDER; 
use constant LEVEL_ORDER => $Tree::Nary::LEVEL_ORDER;
use constant TRAVERSE_LEAFS => $Tree::Nary::TRAVERSE_LEAFS;
use constant TRAVERSE_NON_LEAFS => $Tree::Nary::TRAVERSE_NON_LEAFS;
use constant TRAVERSE_ALL => $Tree::Nary::TRAVERSE_ALL;
use constant TRAVERSE_MASK => $Tree::Nary::TRAVERSE_MASK;

our $result;
our @foo;
my $AsLisp;
my %nodes;
our $PLispResult;
#~ our $depth;

sub NaryToLisp {
  my $root = shift;
  my $type = shift;
  my $next;
  my $i;
  my $cnt;
  #~ my @stack;
  
  if ( ! defined($type) ) {
    $result = "";
    $type = 1;
  }

  if ($type eq 1) {
    $result .= $root->{data} unless ! defined( $root->{data});
  }
  if ( Tree::Nary->n_children($root) > 0 ) {
    $result .=  "(";
    $cnt = Tree::Nary->n_children($root);
    #~ print "counting $root ($root->{data}) = $cnt\n";
    for ( $i = 0; $i < $cnt; $i++ ) {
      $next = Tree::Nary->nth_child($root, $i);
      $result .= $next->{data} unless ! defined( $next->{data});
      #~ $depth++;
      #~ push @stack, $root;
      #~ push @stack, $next;
      #~ push @stack, $i;
      #~ print "(before) @ $depth, $next->{data} of $next->{parent}->{data}\n";
      NaryToLisp( $next, 2 );
      #~ print "(after) @ $depth, $next->{data} of $next->{parent}->{data}\n";
      #~ $i = pop( @stack );
      #~ $next = pop( @stack );
      #~ $root = pop( @stack );
      #~ $depth--;
      if ( $i < $cnt - 1) { 
        $result .= "^";
      }
    }
    $result .=  ")";
  }
  return $result;
}



sub LispToNary {
  my $lispText = shift;
  $AsLisp = "";
  my @stack;
  my $cursor;
  my $string;
  my $here;
  #~ my $result;
  my $root;

  $cursor = 0;

  my $tree;
  $tree = Tree::Nary->new();
  my $node;
  my $parent;
  
  $parent = $tree;
  my $item;
  
  while ( $cursor <= length( $lispText ) ) {
    $here = substr( $lispText, $cursor, 1 );
    if ($here eq "(") {
      $AsLisp .= $string . $here;
      $node = Tree::Nary->append_data( $parent, $string); 
      print "$node = append_data( $parent, $string);\n";
      $nodes{$node} = $node;
      push @stack, $parent; #$node;
      $string = "";
      $parent = $node;
    } elsif ($here eq "^") {
      if ($string eq "" ) {
        $AsLisp .= " ";
      } else {
        $item = Tree::Nary->append_data( $parent, $string); 
        print "^ $item = append_data( $parent, $string);\n"; 
        $nodes{$item} = $item;
        $AsLisp .= "\"" . $string . "\" ";
        $string = "";
      }
    } elsif ($here eq ")") {
      if ( $string eq "" ) {
        $AsLisp .= ")";
      } else {
        $item = Tree::Nary->append_data( $parent, $string); 
        print ") $item = append_data( $parent, $string);\n"; 
        $nodes{$item} = $item;
        $AsLisp .= "\"" . $string . "\")";
        $string = "";
      }
      $parent = pop( @stack ); #???
    } else {
      $string .= $here;
    }
    $cursor++;
  }
  return Tree::Nary->first_child($tree);
}

  #~ my $parent = new Tree::Nary( "Mammals" );
  #~ my $cats = $parent->append_data($parent, "cats");
  #~ my $dogs = $parent->append_data($parent, "dogs");
  #~ my $cows = $parent->append_data($parent, "cows");
  #~ my $rodents = $parent->append_data($parent, "rodents");

  #~ Tree::Nary->append_data($cats, "tabby");
  #~ Tree::Nary->append_data($cats, "manx");
  #~ Tree::Nary->append_data($cats, "persian");

  #~ Tree::Nary->append_data($dogs, "greyhound");
  #~ Tree::Nary->append_data($dogs, "wolf");
  #~ Tree::Nary->append_data($dogs, "chihuahua");

  #~ Tree::Nary->append_data($cows, "jersey");
  #~ Tree::Nary->append_data($cows, "guernsey");
  #~ Tree::Nary->append_data($cows, "shorthorn");
  
  #~ Tree::Nary->append_data($rodents, "mice");
  #~ Tree::Nary->append_data($rodents, "rats");
  #~ print "NaryToLisp: " . NaryToLisp( $parent ), "\n";
  my $l;
  my $r1;
  my $r2;
  
  #~ $l = "哺乳動物 Mammals(貓科動物 cats(平紋 tabby^馬恩島 manx^波斯語 persian)^狗 dogs(灰狗 greyhound^狼來了 wolf^奇瓦瓦 chihuahua)^奶牛 cows(新澤西 jersey^格恩西 guernsey^短角 shorthorn)^囓齒動物 rodents(小鼠 mice^老鼠 rats))";
  #~ print $l, "\n\n";
  #~ $r1 = LispToNary($l);
  #~ print "\n";
  #~ print "As Lisp: " . $AsLisp, "\n";
  #~ print "NaryToLisp: " . NaryToLisp( $r1);
  #~ print "\n";


  #~ $l = "Mammals(cats(tabby^manx^persian)^dogs(greyhound^wolf^chihuahua)^cows(jersey^guernsey^shorthorn)^rodents(mice^rats))";
  #~ print $l, "\n\n";
  #~ $r2 = LispToNary($l);
  #~ print "\n";
  #~ print "As Lisp: " . $AsLisp, "\n";
  #~ print "NaryToLisp: " . NaryToLisp( $r2);
  #~ print "\n";

  $l = "(item(item(item^item^item)))";
  $r2 = LispToNary($l);
  print "As Lisp: " . $AsLisp, "\n";
  print "NaryToLisp: " . NaryToLisp( $r2) . "\n";
