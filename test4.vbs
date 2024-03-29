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

setTrace "test4.txt"

const CARET_SEPARATOR = 1
const FS_SEPARATOR = 2
const ARRAY_SEPARATOR = 3
const LISP_SEPARATOR = 4

dim src
src = "哺乳動物 Mammals(貓科動物 cats(平紋 tabby^馬恩島 manx^波斯語 persian)^狗 dogs(灰狗 greyhound^狼來了 wolf^奇瓦瓦 chihuahua)^奶牛 cows(新澤西 jersey^格恩西 guernsey^短角 shorthorn)^囓齒動物 rodents(小鼠 mice^老鼠 rats))"

trace "Given:"
trace src
root = o.LispToNary( src)
trace "stored in BOSS, known locally as 'root'"

trace ""
trace "As Lisp:"
trace o.AsLisp

trace ""
trace "NaryToLisp"
trace o.NaryToLisp(root)



