set o = WScript.CreateObject("StructureServer.Nary.1")

'making the following tree to test traversals
'							mammals
'		cats							dogs											cows								rodents
'	tabby manx persian 	greyhound wolf chihuahua	jersey guernsey ais	rats mice

root = o.New("哺乳動物 Mammals")
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

wscript.echo "Depth of root = ", o.Depth(root)
wscript.echo "Max_Height of root = ", o.Max_Height(root)

wscript.echo "Depth of cats = ", o.Depth(cats)
wscript.echo "Max_Height of cats = ", o.Max_Height(cats)

wscript.echo "Depth of dogs = ", o.Depth(dogs)
wscript.echo "Max_Height of dogs = ", o.Max_Height(dogs)

wscript.echo "number of nodes (traverse leafs)= ", o.N_Nodes( root, o.TRAVERSE_LEAFS )
wscript.echo "number of nodes (traverse non leafs)= ", o.N_Nodes( root, o.TRAVERSE_NON_LEAFS )
wscript.echo "number of nodes (traverse all)= ", o.N_Nodes( root, o.TRAVERSE_ALL )
wscript.echo "number of children of root = ", o.n_children(root)

wscript.echo "rodents is an ancestor of rats = ", o.is_ancestor( rodents, rats )

msgbox o.Children_ForEach( root, o.POST_ORDER )
msgbox o.Children_ForEach( cats, o.POST_ORDER )
msgbox o.Children_ForEach( dogs, o.POST_ORDER )
msgbox o.Children_ForEach( rodents, o.POST_ORDER )

msgbox  o.Traverse( root, o.PRE_ORDER, o.TRAVERSE_ALL, -1 ),,"traversal, pre_order, traverse_all, beginning at -1 = "
msgbox  o.Traverse( root, o.POST_ORDER, o.TRAVERSE_ALL, -1 ),,"traversal, post_order, traverse_all, beginning at -1 = "
msgbox  o.Traverse( root, o.IN_ORDER, o.TRAVERSE_ALL, -1 ),,"traversal, in_order, traverse_all, beginning at -1 = "
msgbox  o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_ALL, -1 ),,"traversal, level_order, traverse_all, beginning at -1 = "
msgbox  o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_LEAFS, -1 ),,"traversal, level_order, traverse_leafs, beginning at -1 = "
msgbox  o.Traverse( root, o.PRE_ORDER, o.TRAVERSE_NON_LEAFS, -1 ),,"traversal, pre_order, traverse_non_leafs, beginning at -1 = "

o.TSort root
msgbox  o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_ALL, -1 ),,"traversal, after tsort, level_order, traverse_all, beginning at -1 = "


