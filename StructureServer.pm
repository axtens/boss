# Perl Library PerlCtrl.
#
# This control provides ...
#

package StructureServer;


use strict;
use warnings;

use Tree::Nary;
use Data::Trie;
use Win32::OLE::Variant;

use Lisp::Printer qw(lisp_print);
use Lisp::Symbol qw(symbol);

use constant STX => chr( 2 ); #[
use constant ETX => chr( 3 ); #]
use constant FS => chr( 28 ); #^
use constant RS => chr( 30 ); #~

use constant CARET_SEPARATOR => 1;
use constant FS_SEPARATOR => 2;
use constant ARRAY_SEPARATOR => 3;
use constant LISP_SEPARATOR => 4;

use constant n_1DF => 111100001;                #folded one dimensional structure
use constant n_TRE => 111100011;                #Tree
use constant n_BTR => 111100012;                #Balanced tree
use constant n_PTR => 111100013;                #Patricia Trie
use constant n_LSP => 111100014;                #LISP style nested list, suitable for complying with Greenspan#s law!!!!!
use constant n_1LF => 111110001;                #labelled folded one dimensional structure
use constant n_TDC => 111110011;                #Tree dictionary
use constant n_HVE => 111110021;                #Hive - tree dictionary with attached lists

use constant IN_ORDER => $Tree::Nary::IN_ORDER;
use constant PRE_ORDER => $Tree::Nary::PRE_ORDER; 
use constant POST_ORDER => $Tree::Nary::POST_ORDER; 
use constant LEVEL_ORDER => $Tree::Nary::LEVEL_ORDER;
use constant TRAVERSE_LEAFS => $Tree::Nary::TRAVERSE_LEAFS;
use constant TRAVERSE_NON_LEAFS => $Tree::Nary::TRAVERSE_NON_LEAFS;
use constant TRAVERSE_ALL => $Tree::Nary::TRAVERSE_ALL;
use constant TRAVERSE_MASK => $Tree::Nary::TRAVERSE_MASK;

our $AsLisp;
our %nodes;
our %tries;

sub nod {
  my $nodd = shift;
  $nodd = "" unless defined( $nodd );
  my $res;
  if ( $nodd ne "" ) {
    if ( $nodes{$nodd} ) {
      $res = $nodes{$nodd};
    } else {
      $res = undef;
    }
  }
  return $res
}

sub node_build_string() {

	my ($node, $ref_of_arg) = (shift, shift);
	my $p = $ref_of_arg;
	my $string;
	my $c;

	$c = $node->{data};
	if(defined($p)) {
		$string = $$p;
	} else {
		$string = "";
	}

	$string .= $c . "^";
	$$p = $string;
	
	return($Tree::Nary::FALSE);
}

sub New {
  my ($ss, $data ) = (shift, shift);
  my $obj;
  if ($ss eq n_TRE) {
    if (defined $data) {
      $obj = NewNary( $data );
    } else {
      $obj = NewNary();
    }
  } elsif ($ss eq n_PTR) {
    $obj = NewTrie();
  }
  return $obj
}
  
sub NewNary {
  my $data = shift;
  my $node;
  if ( ! defined( $data ) ) {
    $node = Tree::Nary->new();
  } else {
    $node = Tree::Nary->new($data);
  }
  $nodes{$node} = $node;
  return $node;
}

our $PLispResult;

sub NaryToLisp {
  my $root = shift;
  my $type = shift;
  my $next;
  my $i;
  my $cnt;
  
  $type = 1 unless defined( $type );
  $root = nod( $root );
  if ($type eq 1) {
    $PLispResult .= $root->{data} unless ! defined( $root->{data});
  }
  if ( Tree::Nary->n_children($root) > 0 ) {
    $PLispResult .=  "(";
    $cnt = Tree::Nary->n_children($root);
    for ( $i = 0; $i < $cnt; $i++ ) {
      $next = Tree::Nary->nth_child($root, $i);
      $PLispResult .= $next->{data} unless ! defined( $next->{data});
      NaryToLisp( $next, 2 );
      if ( $i < $cnt - 1) { $PLispResult .= "^";}
    }
    $PLispResult .=  ")";
  }
  return $PLispResult;
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

  my $parent = $tree;
  my $item;
  $string = "";
  
  while ( $cursor <= length( $lispText ) ) {
    $here = substr( $lispText, $cursor, 1 );
    if ($here eq "(") {
      $AsLisp .= $string . $here;
      $node = Tree::Nary->append_data( $parent, $string); 
      $nodes{$node} = $node;
      push @stack, $parent;
      $string = "";
      $parent = $node;
    } elsif ($here eq "^") {
      if ($string eq "" ) {
        $AsLisp .= " ";
      } else {
        #~ print "caretted node=\"$root\" sibling=\"$string\"\n";
        $item = Tree::Nary->append_data( $parent, $string); 
        $nodes{$item} = $item;
        $AsLisp .= "\"" . $string . "\" ";
        $string = "";
      }
    } elsif ($here eq ")") {
      if ( $string eq "" ) {
        $AsLisp .= ")";
      } else {
        #~ print "close paren node=\"$root\" sibling=\"$string\"\n";
        $item = Tree::Nary->append_data( $parent, $string); 
        $nodes{$item} = $item;
        $AsLisp .= "\"" . $string . "\")";
        $string = "";
      }
      $parent = pop( @stack );
      #~ print "popped node=\"$root\"\n";
    } else {
      $string .= $here;
    }
    $cursor++;
  }
  return Tree::Nary->first_child($tree);
}

sub Insert  {
  my ($parent, $position, $node) = (shift, shift, shift);
  $parent = nod( $parent );
  $node = nod( $node );
  my $inserted_node = Tree::Nary->insert($parent, $position, $node );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Insert_Before {
  my ($parent, $sibling, $node ) = (shift, shift, shift);
  $parent = nod($parent);
  $sibling = nod($sibling);
  $node = nod($node);
  my $inserted_node = Tree::Nary->insert_before($parent, $sibling, $node );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Append {
  my ($parent, $node) = (shift, shift);
  $parent = nod( $parent );
  $node = nod( $node );
  my $inserted_node = Tree::Nary->append($parent, $node );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Prepend {
  my ($parent, $node) = (shift, shift);
  $parent = nod( $parent );
  $node = nod( $node );
  my $inserted_node = Tree::Nary->prepend($parent, $node );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Insert_Data {
  my ($parent, $position, $data) = (shift, shift, shift);
  $parent = nod( $parent );
  my $inserted_node = Tree::Nary->insert_data($parent, $position, $data );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Insert_Data_Before {
  my ($parent, $sibling, $data ) = (shift, shift, shift);
  $parent = nod($parent);
  $sibling = nod($sibling);
  my $inserted_node = Tree::Nary->insert_data_before($parent, $sibling, $data );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Append_Data {
  my ($parent, $data) = (shift, shift);
  $parent = nod( $parent );
  my $inserted_node = Tree::Nary->append_data($parent, $data );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Prepend_Data { 
  my ($parent, $data) = (shift, shift);
  $parent = nod( $parent );
  my $inserted_node = Tree::Nary->prepend_data($parent, $data );
  $nodes{$inserted_node} = $inserted_node;
  return $inserted_node;
}

sub Reverse_Children {
  my $node = shift;
  $node = nod( $node );
  my $reversed_node = Tree::Nary->reverse_children($node );
  return $reversed_node;
}

sub Traverse {
  #~ my ($node, $order, $flags, $maxdepth, $funcref, $argref ) = (shift, shift, shift, shift, shift, shift );
  my ($node, $order, $flags, $maxdepth, $sepMode ) = (shift, shift, shift, shift, shift );
  $node = nod( $node );
  $sepMode = CARET_SEPARATOR unless defined( $sepMode );
  my $tstring;
  Tree::Nary->traverse( $node, $order, $flags, $maxdepth, \&node_build_string, \$tstring ); #defaults to CARET_SEPARATOR
  if ( $sepMode == FS_SEPARATOR ) {
    $tstring =~ s/\^/FS/eg;
  } elsif ( $sepMode == ARRAY_SEPARATOR ) {
    my @arr = split( /\^/, $tstring );
    $tstring = \@arr;
  } elsif ( $sepMode == LISP_SEPARATOR ) {
    my @arr = split( /\^/, $tstring );
    $tstring = lisp_print( \@arr );
  }
  return $tstring;
}

sub Children_ForEach {
  my ($node, $flags, $sepMode) = (shift, shift, shift);
  $node = nod( $node );
  $sepMode = CARET_SEPARATOR unless defined( $sepMode );
  my $tstring;
  Tree::Nary->children_foreach( $node, $flags, \&node_build_string, \$tstring );
  if ( $sepMode == FS_SEPARATOR ) {
    $tstring =~ s/\^/FS/eg;
  } elsif ( $sepMode == ARRAY_SEPARATOR ) {
    my @arr = split( /\^/, $tstring );
    $tstring = \@arr;
  } elsif ( $sepMode == LISP_SEPARATOR ) {
    my @arr = split( /\^/, $tstring );
    $tstring = lisp_print( \@arr );
  }
  return $tstring;
}

sub Get_Root {
  my $node = shift;
  $node = nod( $node );
  my $root_node = Tree::Nary->get_root( $node );
  return $root_node;
}

sub Find {
  my ($node, $order, $flags, $data) = (shift, shift, shift, shift );
  $node = nod( $node );
  my $found_node = Tree::Nary->find($node, $order, $flags, $data);
  return $found_node;
}

sub Find_Child {
  my ($node, $flags, $data) = (shift, shift, shift );
  $node = nod( $node );
  my $found_node = Tree::Nary->find_child($node, $flags, $data);
  return $found_node;
}

sub Child_Index {
  my ($node, $data) = (shift, shift);
  $node = nod( $node );
  my $index = Tree::Nary->child_index( $node, $data );
  return $index;
}

sub Child_Position {
  my ($node, $child) = (shift, shift);
  $node = nod( $node );
  $child = nod( $child );
  my $position = Tree::Nary->child_position( $node, $child );
  return $position;
}

sub First_Child {
  my $node = shift;
  $node = nod( $node );
  my $first_child_node = Tree::Nary->first_child( $node );
  return $first_child_node;
}

sub Last_Child {
  my $node = shift;
  $node = nod( $node );
  my $last_child_node = Tree::Nary->last_child( $node );
  return $last_child_node;
}

sub Nth_Child {
  my ($node, $index) = ( shift, shift );
  $node = nod( $node );
  my $nth_child_node = Tree::Nary->nth_child( $node, $index );
  return $nth_child_node;
}

sub First_Sibling {
  my $node = shift;
  $node = nod( $node );
  my $first_sibling_node = Tree::Nary->first_sibling( $node );
  return $first_sibling_node;
}

sub Previous_Sibling {
  my $node = shift;
  $node = nod( $node );
  my $prev_sibling_node = Tree::Nary->prev_sibling( $node );
  return $prev_sibling_node;
}

sub Next_Sibling {
  my $node = shift;
  $node = nod( $node );
  my $next_sibling_node = Tree::Nary->next_sibling( $node );
  return $next_sibling_node;
}

sub Last_Sibling {
  my $node = shift;
  $node = nod( $node );
  my $last_sibling_node = Tree::Nary->last_sibling( $node );
  return $last_sibling_node;
}

sub Is_Leaf {
  my $node = shift;
  $node = nod( $node );
  my $bool = Tree::Nary->is_leaf( $node );
  return $bool ? -1 : 0;
}

sub Is_Root {
  my $node = shift;
  $node = nod( $node );
  my $bool = Tree::Nary->is_root( $node );
  return $bool ? -1 : 0;
}

sub Depth {
  my $node = shift;
  $node = nod( $node );
  my $cnt = Tree::Nary->is_root( $node );
  return $cnt;
}

sub N_Nodes {
  my ($node, $method) = (shift, shift);
  $node = nod( $node );
  my $cnt = Tree::Nary->n_nodes( $node, $method );
  return $cnt;
}

sub N_Children {
  my $node = shift;
  $node = nod( $node );
  my $cnt = Tree::Nary->n_children( $node );
  return $cnt;
}

sub Is_Ancestor {
  my ($node, $descendant) = (shift, shift);
  $node = nod( $node );
  $descendant = nod( $descendant );
  my $bool = Tree::Nary->is_ancestor( $node, $descendant );
  return $bool ? -1 : 0;
}

sub Max_Height {
  my $node = shift;
  $node = nod( $node );
  my $cnt = Tree::Nary->max_height( $node );
  return $cnt;
}

sub TSort {
  my $node = shift;
  $node = nod( $node );
  Tree::Nary->tsort($node);
}

sub Normalize {
  my $node = shift;
  $node = nod( $node );
  my $normalized_node = Tree::Nary->normalize( $node );
  return $normalized_node;
}

sub Is_Identical {
  my ($node, $another_node) = (shift, shift);
  $node = nod( $node );
  $another_node = nod( $another_node );
  my $bool = Tree::Nary->is_identical( $node, $another_node );
  return $bool ? -1 : 0;
}

sub Has_Same_Struct {
  my ($node, $another_node) = (shift, shift);
  $node = nod( $node );
  $another_node = nod( $another_node );
  my $bool = Tree::Nary->has_same_struct( $node, $another_node );
  return $bool ? -1 : 0;
}

sub Unlink {
  my $node = shift;
  $node = nod( $node );
  Tree::Nary->unlink($node);  
}

sub Node_Data {
  my ($node,$data) = (shift,shift);
  $node = nod( $node );
  if ( defined $data ) {
    $node->{data} = $data;
  }
  my $res = $node->{data};
  return $res;
}

sub Node_Parent {
  my $node = shift;
  $node = nod( $node );
  my $res = $node->{parent};
  return $res;
}

sub Node_Children {
  my $node = shift;
  $node = nod( $node );
  my $res = $node->{children};
  return $res;
}

sub Node_Prev {
  my $node = shift;
  $node = nod( $node );
  my $res = $node->{prev};
  return $res;
}

sub Node_Next {
  my $node = shift;
  $node = nod( $node );
  my $res = $node->{next};
  return $res;
}

#--------------------------------------------------------------

sub tri {
  my $trii = shift;
  $trii = "" unless defined( $trii );
  my $res;
  if ( $trii ne "" ) {
    if ( $tries{$trii} ) {
      $res = $tries{$trii};
    } else {
      $res = undef;
    }
  }
  return $res
}

sub NewTrie {
  my $trie;
  $trie = Data::Trie->new;
  $tries{$trie} = $trie;
  return $trie;
}

sub Add  {
  my ($trie, $key, $data) = (shift, shift, shift);
  $trie = tri( $trie );
  if ( defined $data ) {
    $trie->add( $key, $data );
  } else {
    $trie->add( $key );
  }
  return $trie;
}

sub Lookup {
  my ($trie, $key, $retMode ) = (shift, shift, shift);
  $trie = tri($trie);
  $retMode = CARET_SEPARATOR unless defined( $retMode );
  
  my ($res, $dat) = $trie->lookup($key);
  if ( $retMode == CARET_SEPARATOR ) {
    return $res . "^" . $dat;
  } elsif ( $retMode == FS_SEPARATOR ) {
    return $res . FS . $dat;
  } elsif ( $retMode == ARRAY_SEPARATOR ) {
    my @r = ( $res, $dat );
    return \@r;
  } elsif ( $retMode == LISP_SEPARATOR ) {
    my @r = ( $res, $dat );
    return lisp_print( \@r );
  } else {
    return undef;
  }
}

sub Remove {
  my ($trie, $key ) = (shift, shift);
  $trie = tri($trie);
  $trie->remove($key);
  return $trie;
}

sub GetAll {
  my ($trie, $retMode) = (shift, shift);
  $trie = tri($trie);
  $retMode = CARET_SEPARATOR unless defined( $retMode );
  #~ my %try = %$trie;
  my @res = $trie->getAll();
  #~ return lisp_print( \@res ); 
  #~ return lisp_print( \%try ); 
  if ( $retMode == CARET_SEPARATOR ) {
    return join( "^", @res );
  } elsif ( $retMode == FS_SEPARATOR ) {
    return join( FS, @res );
  } elsif ( $retMode == ARRAY_SEPARATOR ) {
    return \@res;
  } elsif ( $retMode == LISP_SEPARATOR ) {
    return lisp_print( \@res );
  } else {
    return undef;
  }

}


1;

# Here is the %TypeLib hash.  See the PerlCtrl documentation for
# information about this hash.
#

=pod

=begin PerlCtrl

%TypeLib = (
  PackageName     => 'StructureServer',
	TypeLibGUID     => '{C1498BDD-64E3-40D1-A7D5-D9AF42FB3D7E}', # do NOT edit this line
	ControlGUID     => '{03F9BF65-5D80-4B6B-80F1-A8A34BFF909B}', # do NOT edit this line either
	DispInterfaceIID=> '{4CD55FEE-AD61-4CC2-9B1B-6422B2E25CB8}', # or this one
  ControlName     => 'StructureServer',
  ControlVer      => 1,  # increment if new object with same ProgID
  # create new GUIDs as well
  ProgID          => 'StructureServer.boss',
  DefaultMethod   => '',
  Methods         => {
    New => {
      #~ DocString           => "Creates a new Tree::Nary object. Used to create the first node in a tree. Insert optional DATA into new created node.",
      DocString           => "Creates a new Tree::Nary, or new Data::Trie, object. Used to create the first node in a tree. Insert optional DATA into new created Tree::Nary node.",
      HelpContext         => 101,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  1,
      ParamList           => [ 'package' => VT_I4, 'data' => VT_VARIANT ],
    },
    Insert => {
      DocString           => "Inserts a NODE beneath the PARENT at the given POSITION, returning inserted NODE. If POSITION is -1, NODE is inserted as the last child of PARENT.",
      HelpContext         => 102,
      RetType             =>  VT_BSTR,
      TotalParams         =>  3,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'position' => VT_I4, 'node' => VT_BSTR ],
    },
    Insert_Before => {
      DocString           => "Inserts a NODE beneath the PARENT before the given SIBLING, returning inserted NODE. If SIBLING is undef, the NODE is inserted as the last child of PARENT.",
      HelpContext         => 103,
      RetType             =>  VT_BSTR,
      TotalParams         =>  3,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'sibling' => VT_BSTR, 'node' => VT_BSTR ],
    },
    Append => {
      DocString           => "Inserts a NODE as the last child of the given PARENT, returning inserted NODE.",
      HelpContext         => 104,
      RetType             =>  VT_BSTR,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'node' => VT_BSTR ],
    },
    Prepend => {
      DocString           => "Inserts a NODE as the first child of the given PARENT, returning inserted NODE.",
      HelpContext         => 105,
      RetType             =>  VT_BSTR,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'node' => VT_BSTR ],
    },
    Insert_Data => {
      DocString           => "Inserts a new node containing DATA, beneath the PARENT at the given POSITION. Returns the new inserted node.",
      HelpContext         => 106,
      RetType             =>  VT_BSTR,
      TotalParams         =>  3,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'position' => VT_I4, 'data' => VT_VARIANT ],
    },
    Insert_Data_Before => {
      DocString           => "Inserts a new node containing DATA, beneath the PARENT, before the given SIBLING. Returns the new inserted node.",
      HelpContext         => 107,
      RetType             =>  VT_BSTR,
      TotalParams         =>  3,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'sibling' => VT_BSTR, 'data' => VT_VARIANT ],
    },
    Append_Data => {
      DocString           => "Inserts a new node containing DATA as the last child of the given PARENT. Returns the new inserted node.",
      HelpContext         => 108,
      RetType             =>  VT_BSTR,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'data' => VT_VARIANT ],
    },
    Prepend_Data => {
      DocString           => "Inserts a new node containing DATA as the first child of the given PARENT. Returns the new inserted node.",
      HelpContext         => 109,
      RetType             =>  VT_BSTR,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'parent' => VT_BSTR, 'data' => VT_VARIANT ],
    },
    Reverse_Children => {
      DocString           => "Reverses the order of the children of NODE. It doesn't change the order of the grandchildren.",
      HelpContext         => 110,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Traverse => {
      DocString           => "Traverses a tree starting at the given root NODE. It calls the given FUNCTION (with optional user DATA to pass to the FUNCTION) for each node visited.",
      HelpContext         => 111,
      RetType             =>  VT_ARRAY|VT_VARIANT,
      TotalParams         =>  5,
      NumOptionalParams   =>  1,
      #~ ParamList           => [ 'node' => VT_BSTR, 'order' => VT_I4, 'flags' => VT_I4, 'maxdepth' => VT_I4, 'function' => VT_VARIANT, 'data' => VT_VARIANT ],
      ParamList           => [ 'node' => VT_BSTR, 'order' => VT_I4, 'flags' => VT_I4, 'maxdepth' => VT_I4, 'sepMode' => VT_I4 ],
    },
    Children_ForEach => {
      DocString           => "Calls a FUNCTION (with optional user DATA to pass to the FUNCTION) for each of the children of a NODE. Note that it doesn't descend beneath the child nodes. FLAGS specifies which types of children are to be visited, one of TRAVERSE_ALL, TRAVERSE_LEAFS and TRAVERSE_NON_LEAFS.",
      HelpContext         => 112,
      RetType             =>  VT_ARRAY|VT_VARIANT,
      TotalParams         =>  3,
      NumOptionalParams   =>  1,
      #~ ParamList           => [ 'node' => VT_BSTR, 'flags' => VT_I4, 'function' => VT_VARIANT, 'data' => VT_VARIANT, 'sepMode' => VT_I4 ],
      ParamList           => [ 'node' => VT_BSTR, 'flags' => VT_I4, 'sepMode' => VT_I4 ],
    },
    Get_Root => {
      DocString           => "Gets the root node of a tree, starting from NODE.",
      HelpContext         => 113,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Find => {
      DocString           => "Finds a NODE in a tree with the given DATA.",
      HelpContext         => 114,
      RetType             =>  VT_BSTR,
      TotalParams         =>  4,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'order' => VT_I4, 'flags' => VT_I4, 'data' => VT_VARIANT ],
    },
    Find_Child => {
      DocString           => "Finds the first child of a NODE with the given DATA.",
      HelpContext         => 115,
      RetType             =>  VT_BSTR,
      TotalParams         =>  3,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'flags' => VT_I4, 'data' => VT_VARIANT ],
    },
    Child_Index => {
      DocString           => "Gets the position of the first child of a NODE which contains the given DATA. Returns the index of the child of node which contains data, or -1 if DATA is not found.",
      HelpContext         => 116,
      RetType             =>  VT_I4,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'data' => VT_VARIANT ],
    },
    Child_Position => {
      DocString           => "Gets the position of a NODE with respect to its siblings. CHILD must be a child of NODE. The first child is numbered 0, the second 1, and so on. Returns the position of CHILD with respect to its siblings.",
      HelpContext         => 116,
      RetType             =>  VT_I4,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'child' => VT_BSTR ],
    },
    First_Child => {
      DocString           => "Returns the first child of a NODE. Returns undef if NODE is undef or has no children.",
      HelpContext         => 117,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Last_Child => {
      DocString           => "Returns the last child of a NODE. Returns undef if NODE is undef or has no children.",
      HelpContext         => 118,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Nth_Child => {
      DocString           => "Gets a child of a NODE, using the given INDEX. The first child is at INDEX 0. If the INDEX is too big, undef is returned. Returns the child of NODE at INDEX.",
      HelpContext         => 119,
      RetType             =>  VT_BSTR,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'index' => VT_I4 ],
    },
    First_Sibling => {
      DocString           => "Returns the first sibling of a NODE. This could possibly be the NODE itself.",
      HelpContext         => 120,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Prev_Sibling => {
      DocString           => "Returns the previous sibling of a NODE.",
      HelpContext         => 121,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Next_Sibling => {
      DocString           => "Returns the next sibling of a NODE.",
      HelpContext         => 122,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Last_Sibling => {
      DocString           => "Returns the last sibling of a NODE. This could possibly be the NODE itself.",
      HelpContext         => 123,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Is_Leaf => {
      DocString           => "Returns TRUE if NODE is a leaf node (no children).",
      HelpContext         => 124,
      RetType             =>  VT_BOOL,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Is_Root => {
      DocString           => "Returns TRUE if NODE is a root node (no parent nor siblings).",
      HelpContext         => 125,
      RetType             =>  VT_BOOL,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Depth => {
      DocString           => "Returns the depth of NODE. If NODE is undef, the depth is 0. The root node has a depth of 1. For the children of the root node, the depth is 2. And so on.",
      HelpContext         => 126,
      RetType             =>  VT_I4,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    N_Nodes => {
      DocString           => "Returns the number of nodes in a tree.",
      HelpContext         => 126,
      RetType             =>  VT_I4,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'method' => VT_I4 ],
    },
    N_Children => {
      DocString           => "Returns the number of children of NODE.",
      HelpContext         => 127,
      RetType             =>  VT_I4,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Is_Ancestor => {
      DocString           => "Returns TRUE if NODE is an ancestor of DESCENDANT. This is true if NODE is the parent of DESCENDANT, or if NODE is the grandparent of DESCENDANT, etc.",
      HelpContext         => 128,
      RetType             =>  VT_BOOL,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'descendant' => VT_BSTR ],
    },
    Max_Height => {
      DocString           => "Returns the maximum height of all branches beneath NODE. This is the maximum distance from NODE to all leaf nodes.",
      HelpContext         => 129,
      RetType             =>  VT_I4,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    TSort => {
      DocString           => "Sorts all the children references of NODE according to the data field.",
      HelpContext         => 130,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Normalize => {
      DocString           => "Returns the normalized shape of NODE.",
      HelpContext         => 131,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Is_Identical => {
      DocString           => "Returns TRUE if NODE and ANOTHER_NODE have same structures and contents.",
      HelpContext         => 132,
      RetType             =>  VT_BOOL,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'another_node' => VT_BSTR ],
    },
    Has_Same_Struct => {
      DocString           => "Returns TRUE if the structure of NODE and ANOTHER_NODE are identical.",
      HelpContext         => 133,
      RetType             =>  VT_BOOL,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR, 'another_node' => VT_BSTR ],
    },
    Unlink => {
      DocString           => "Unlinks NODE from a tree, resulting in two separate trees. The NODE to unlink becomes the root of a new tree.",
      HelpContext         => 134,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Node_Data => {
      DocString           => "Returns NODE's data.",
      HelpContext         => 135,
      RetType             =>  VT_VARIANT,
      TotalParams         =>  2,
      NumOptionalParams   =>  1,
      ParamList           => [ 'node' => VT_BSTR, 'data' => VT_VARIANT ],
    },
    Node_Parent => {
      DocString           => "Returns NODE's parent.",
      HelpContext         => 136,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Node_Children => {
      DocString           => "Returns NODE's children (first child).",
      HelpContext         => 137,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Node_Prev => {
      DocString           => "Returns NODE's previous.",
      HelpContext         => 138,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    Node_Next => {
      DocString           => "Returns NODE's next.",
      HelpContext         => 139,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
    #~ New => {
      #~ DocString           => "Creates a new Data::Trie object.",
      #~ HelpContext         => 101,
      #~ RetType             =>  VT_BSTR,
      #~ TotalParams         =>  0,
      #~ NumOptionalParams   =>  0,
      #~ ParamList           => [ ],
    #~ },
    Add => {
      DocString           => "Add data to the trie.",
      HelpContext         => 140,
      RetType             =>  VT_BSTR,
      TotalParams         =>  3,
      NumOptionalParams   =>  1,
      ParamList           => [ 'node' => VT_BSTR, 'key' => VT_VARIANT, 'data' => VT_VARIANT ],
    },
    Lookup => {
      DocString           => "Lookup data and result in trie.",
      HelpContext         => 141,
      RetType             =>  VT_VARIANT | VT_ARRAY,
      TotalParams         =>  3,
      NumOptionalParams   =>  0,
      ParamList           => [ 'trie' => VT_BSTR, 'key' => VT_VARIANT, 'retMode' => VT_I4 ],
    },
    Remove => {
      DocString           => "Remove (but not prune) from trie.",
      HelpContext         => 142,
      RetType             =>  VT_ARRAY | VT_VARIANT,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'trie' => VT_BSTR, 'key' => VT_VARIANT ],
    },
    GetAll => {
      DocString           => "Get all data in trie.",
      HelpContext         => 143,
      RetType             =>  VT_ARRAY|VT_VARIANT,
      TotalParams         =>  2,
      NumOptionalParams   =>  0,
      ParamList           => [ 'trie' => VT_BSTR, 'retMode' => VT_I4 ],
    },
    LispToNary => {
      DocString           => "Convert Lisp structure into NAry Tree.",
      HelpContext         => 144,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'lispText' => VT_BSTR ],
    },
    NaryToLisp => {
      DocString           => "Convert NAry Tree to P-Lisp structure.",
      HelpContext         => 145,
      RetType             =>  VT_BSTR,
      TotalParams         =>  1,
      NumOptionalParams   =>  0,
      ParamList           => [ 'node' => VT_BSTR ],
    },
  },  # end of 'Methods'
  Properties        => {
    PRE_ORDER => {
      DocString  => "Visit a node, then its children.",
      HelpContext => 201,
      Type => VT_I4, 
      DispID => 2,
      ReadOnly => 1,
    },
    IN_ORDER => {
      DocString  => "Visit a node's left child first, then the node itself, then its right child. This is the one to use if you want the output sorted according to the compare function.",
      HelpContext => 202,
      Type => VT_I4, 
      DispID => 3,
      ReadOnly => 1,
    },
    POST_ORDER => {
      DocString  => "Visit the node's children, then the node itself",
      HelpContext => 203,
      Type => VT_I4, 
      DispID => 4,
      ReadOnly => 1,
    },
    LEVEL_ORDER => {
      DocString  => "Call the function for each child of the node, then recursively visit each child.",
      HelpContext => 204,
      Type => VT_I4, 
      DispID => 5,
      ReadOnly => 1,
    },
    TRAVERSE_LEAFS => {
      DocString  => "Specifies that only leaf nodes should be visited.",
      HelpContext => 205,
      Type => VT_I4, 
      DispID => 6,
      ReadOnly => 1,
    },
    TRAVERSE_NON_LEAFS => {
      DocString  => "Specifies that only non-leaf nodes should be visited.",
      HelpContext => 206,
      Type => VT_I4, 
      DispID => 7,
      ReadOnly => 1,
    },
    TRAVERSE_ALL => {
      DocString  => "Specifies that all nodes should be visited.",
      HelpContext => 207,
      Type => VT_I4, 
      DispID => 8,
      ReadOnly => 1,
    },
    TRAVERSE_MASK => {
      DocString  => "Combination of multiple traverse flags.",
      HelpContext => 208,
      Type => VT_I4, 
      DispID => 9,
      ReadOnly => 1,
    },
    'AsLisp' => {
      DocString  => "Result of converting P-Lisp to Lisp.",
      HelpContext => 209,
      Type => VT_BSTR, 
      DispID => 10,
      ReadOnly => 1,
    },
    
  },  # end of 'Properties'
);  # end of %TypeLib

=end PerlCtrl

=cut
