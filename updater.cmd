@echo off
perlctrl --norunlib --xclude --force --info "CompanyName=Strapper Technologies;FileDescription=Wrapper for various Perl ADT modules;FileVersion=1.0;InternalName=BOSS;LegalCopyright=Strapper Technologies, 2008;OriginalFilename=BOSS.ctrl;ProductName=StructureServer;ProductVersion=1.0" --exe .\BOSS.dll .\BOSS.ctrl
regsvr32 /u /s BOSS.dll
regsvr32 /s BOSS.dll

