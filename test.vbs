Const n_TRE = 111100011                'Tree
Const n_PTR = 111100013                'Patricia Trie

dim sTracefile

dim depth
depth = 0

set o = WScript.CreateObject("StructureServer.Nary.1")


setTrace "test.txt"

trace "use constant CARET_SEPARATOR => 1;"
trace "use constant FS_SEPARATOR => 2;"
trace "use constant ARRAY_SEPARATOR => 3;"
trace "use constant LISP_SEPARATOR => 4;"
trace ""

'making the following tree to test traversals
'							mammals
'		cats							dogs											cows								rodents
'	tabby manx persian 	greyhound wolf chihuahua	jersey guernsey ais	rats mice

root = o.New( "哺乳動物 Mammals")
cats = o.Append_Data( root, "貓科動物 cats" )
dogs = o.Append_Data( root, "狗 dogs" )
cows = o.Append_Data( root, "奶牛 cows" )
rodents = o.Append_Data( root, "囓齒動物 rodents" )

tabby = o.Append_Data( cats, "平紋 tabby" )
manx = o.Append_Data( cats, "馬恩島 manx" )
persian = o.Append_Data( cats, "波斯語 persian" )

greyhound = o.Append_Data( dogs, "灰狗 greyhound" )
wolf = o.Append_Data( dogs, "狼來了 wolf" )
chihuahua = o.Append_Data( dogs, "奇瓦瓦 chihuahua" )

jersey = o.Append_Data( cows, "新澤西 jersey" )
guernsey = o.Append_Data( cows, "格恩西 guernsey" )
ais = o.Append_Data( cows, "短角 shorthorn" )

rats = o.Append_Data( rodents, "老鼠 rats" )
mice = o.Append_Data( rodents, "小鼠 mice" )

trace "Depth of root = " & o.Depth(root)
trace "Max_Height of root = " & o.Max_Height(root)

trace "Depth of cats = " & o.Depth(cats)
trace "Max_Height of cats = " & o.Max_Height(cats)

trace "Depth of dogs = " & o.Depth(dogs)
trace "Max_Height of dogs = " & o.Max_Height(dogs)

trace "number of nodes (traverse leafs)= " & o.N_Nodes( root, o.TRAVERSE_LEAFS )
trace "number of nodes (traverse non leafs)= " & o.N_Nodes( root, o.TRAVERSE_NON_LEAFS )
trace "number of nodes (traverse all)= " & o.N_Nodes( root, o.TRAVERSE_ALL )
trace "number of children of root = " & o.n_children(root)

trace "rodents is an ancestor of rats = " & o.is_ancestor( rodents, rats )

trace o.Children_ForEach( root, o.POST_ORDER, 1 )
trace "^ children_foreach post_order from room w/ caret"
trace ""

trace o.Children_ForEach( cats, o.POST_ORDER, 2 )
trace "^ children_foreach post_order from cats w/ fs"
trace ""

trace handler( o.Children_ForEach( rodents, o.POST_ORDER, 3 ))
trace "^ children_foreach post_order from rodents w/ array"
trace ""

trace o.Children_ForEach( dogs, o.POST_ORDER, 4 )
trace "^ children_foreach post_order from dogs w/ lisp"
trace ""


trace  o.Traverse( root, o.PRE_ORDER, o.TRAVERSE_ALL, -1,1 )
trace "^ traversal, pre_order, traverse_all, beginning at -1 w/ caret "
trace ""

trace  o.Traverse( root, o.POST_ORDER, o.TRAVERSE_ALL, -1,2 )
trace "^ traversal, post_order, traverse_all, beginning at -1 w/ fs "
trace ""

trace  o.Traverse( root, o.IN_ORDER, o.TRAVERSE_ALL, -1,4 )
trace "^ traversal, in_order, traverse_all, beginning at -1 w/ lisp "
trace ""

trace  o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_ALL, -1,1 )
trace "^ traversal, level_order, traverse_all, beginning at -1 w/ caret "
trace ""

trace  o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_LEAFS, -1,2 )
trace "^ traversal, level_order, traverse_leafs, beginning at -1 w/ fs "
trace ""

trace  o.Traverse( root, o.PRE_ORDER, o.TRAVERSE_NON_LEAFS, -1,4 )
trace "^ traversal, pre_order, traverse_non_leafs, beginning at -1 w/ lisp "
trace ""

o.TSort root
trace handler(  o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_ALL, -1,3 ))
trace "^ traversal, after tsort, level_order, traverse_all, beginning at -1 w/ array "

trace ""
trace "哺乳動物 Mammals(貓科動物 cats(平紋 tabby^馬恩島 manx^波斯語 persian)^狗 dogs(灰狗 greyhound&狼來了 wolf^奇瓦瓦 chihuahua)^奶牛 cows(新澤西 jersey^格恩西 guernsey^短角 shorthorn)^囓齒動物 rodents(老鼠 rats^小鼠 mice))"
o.LispToNary "哺乳動物 Mammals(貓科動物 cats(平紋 tabby^馬恩島 manx^波斯語 persian)^狗 dogs(灰狗 greyhound&狼來了 wolf^奇瓦瓦 chihuahua)^奶牛 cows(新澤西 jersey^格恩西 guernsey^短角 shorthorn)^囓齒動物 rodents(老鼠 rats^小鼠 mice))"
trace "Traversing LEVEL_ORDER, TRAVERSE_LEAFS"
trace o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_LEAFS, -1, 1 )

function handler( o )
  dim s
  s = ""
  If Right( Typename( o ), 2 ) = "()" Then ' give to handler 1 at a time
    s = s & "{"
    For Each oItem in o
      depth = depth + 1
      s = s & handler( oItem) 
      depth = depth - 1
    next
    s = s & "}"
  else
    '~ s = s & "(" & depth & ") "
    '~ s = s & "{"
    s = s &  "[" & typename(o) & "] "
    s = s &  o & " " 
    '~ s = s & vbnewline
  end if
  handler = s
end function

sub settrace( sFile )
  sTracefile = sFile
  
end sub

sub trace( sText )
  dim o
  dim f
  set o = CreateObject( "Scripting.FileSystemobject" )
  set f = o.OpenTextFile( sTracefile, 8, True, -1 )
  f.WriteLine sText
  f.Close
end sub
