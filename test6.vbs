set o = WScript.CreateObject("StructureServer.Nary.1")
dim src
dim root
dim dat
dim depth
depth = 0

src = "Tree of life(Eubacteria(Cyanobacteria^Spirochaetes^Purple Bacteria^Green Sulfur Bacteria^Green Nonsulfur Bacteria^Gram-positive Bacteria^Flavobacteria^Bacteroides^Thermatogales^Korarchaeota)^Eukaryotes(Chromista(Chrysophyta^Oomycota^Phaeophyta^Haptophyta^Sagenista^Bacillariophyta^Xanthophyta^Silicoflagellata)^Fungi(Chytridiomycota^Zygomycota^Glomeromycota^Ascomycota^Basidiomycota^Lichens)^Metazoa(Parazoa(Placozoa^Porifera)^Mesozoa(Mesozoa^Monoblastozoa^Bryozoa)^Vendian Animals(Cyclomedusa^Charnia^Pteridinium^Nemiana^Kimberella^Spriggina^Dickinsonia^Tribrachidium^Eoporpita^Arkarua)^Eumetazoa(Bilateria^Radiata))^Protista^Plantae(Spermatophytes(Magnoliophyta^Gymnosphyta)^Anthocerotophyta^Bryophyta(Polytrichopsida^Takakiales^Sphagnopsida^Bryopsida^Andreaeopsida)^Hepaticophyta^Lycophyta(Protolepidodendrales^Selaginellales^Lycopodiales^Lepidodendrales^Isoetales^Asteroxylales)^Progymnosperms^Rhyniophytes^Sphenophyta(Hyeniales^Archaeocalamitaceae^Equisetaceae^Pseudoborniales^Sphenophyllales^Calamitaceae)^Trimerophytes^Zosterophylls^Psilotophyta^Pteridophyta(Polypodiopsida^Marattiales^Filicales))))"
root = o.LispToNary( src)

'a = o.find( root, o.in_order, o.traverse_all, "guernsey")
wscript.echo o.in_order, o.traverse_all
a = o.find( root, 4, 3, "Archaeocalamitaceae")

do
	handler o.node_data(a,dat)
	a = o.node_parent(a)
	if o.is_root(a) then exit do
loop

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

wscript.echo o.NaryToLisp( root )
o.ClearNaryToLisp
wscript.echo o.NaryToLisp( root )
