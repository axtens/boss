set o = WScript.CreateObject("StructureServer.Nary.1")
dim sTracefile
dim root

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

setTrace "test3.txt"

const CARET_SEPARATOR = 1
const FS_SEPARATOR = 2
const ARRAY_SEPARATOR = 3
const LISP_SEPARATOR = 4

trace "From Lisp:"
trace "哺乳動物 Mammals(貓科動物 cats(平紋 tabby^馬恩島 manx^波斯語 persian)^狗 dogs(灰狗 greyhound^狼來了 wolf^奇瓦瓦 chihuahua)^奶牛 cows(新澤西 jersey^格恩西 guernsey^短角 shorthorn)^囓齒動物 rodents(老鼠 rats^小鼠 mice))"
root = o.LispToNary( "哺乳動物 Mammals(貓科動物 cats(平紋 tabby^馬恩島 manx^波斯語 persian)^狗 dogs(灰狗 greyhound^狼來了 wolf^奇瓦瓦 chihuahua)^奶牛 cows(新澤西 jersey^格恩西 guernsey^短角 shorthorn)^囓齒動物 rodents(老鼠 rats^小鼠 mice))" )

trace ""
trace "As Lisp:"
trace o.AsLisp

trace ""
trace "Traversing LEVEL_ORDER, TRAVERSE_LEAFS"
trace o.Traverse( root, o.LEVEL_ORDER, o.TRAVERSE_LEAFS, -1, CARET_SEPARATOR )
trace ""
trace "Traversing IN_ORDER, TRAVERSE_NON_LEAFS"
trace o.Traverse( root, o.IN_ORDER, o.TRAVERSE_NON_LEAFS, -1, CARET_SEPARATOR )
trace ""
trace "Traversing PRE_ORDER, TRAVERSE_ALL"
trace o.Traverse( root, o.PRE_ORDER, o.TRAVERSE_ALL, -1, CARET_SEPARATOR )


