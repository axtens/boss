dim depth
depth = 0

Const n_TRE = 111100011                'Tree
Const n_PTR = 111100013                'Patricia Trie

set o = WScript.CreateObject("StructureServer.Trie.1")

t = o.New( )
o.Add t, "apples", "red"
o.Add t, "lemons", "yellow"
o.Add t, "oranges", "not blue"
o.Add t, "lemonade", "clear"

wscript.echo "Looking to see if it has 'oranges'"
a = o.Lookup(t, "oranges" ,1)
handler a
a = o.Lookup(t, "oranges" ,2)
handler a
a = o.Lookup(t, "oranges" ,3)
handler a

o.Remove t, "oranges"

a = o.Lookup(t, "oranges", 3 )
handler a


wscript.echo "caret-ed",o.GetAll( t,1 )
wscript.echo "FS'd", o.GetAll( t,2 )
wscript.stdout.write "as array "
handler o.GetAll( t,3 )
wscript.echo "lisp-ish",o.GetAll( t,4 )

sub handler( o )
  If Right( Typename( o ), 2 ) = "()" Then ' give to handler 1 at a time
    For Each oItem in o
      depth = depth + 1
      handler oItem
      depth = depth - 1
    next
  else
    wscript.stdout.write "(" & depth & ") "
    wscript.stdout.write typename(o) & " "
    wscript.stdout.write o
    wscript.echo
  end if
end sub

    
