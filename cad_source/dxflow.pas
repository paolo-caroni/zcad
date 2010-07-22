{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}

unit dxflow;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbase,sysutils,UGDBOpenArrayOfByte{,ogltypes};



procedure dxfvertexout(outfile,dxfcode:GDBInteger;v:gdbvertex);
procedure dxfvertexout1(outfile,dxfcode:GDBInteger;v:gdbvertex);
procedure dxfvertex2dout(outfile,dxfcode:GDBInteger;v:gdbvertex2d);
procedure dxfGDBDoubleout(outfile,dxfcode:GDBInteger;v:GDBDouble);
procedure dxfGDBIntegerout(outfile,dxfcode:GDBInteger;v:GDBInteger);
procedure dxfGDBStringout(outfile,dxfcode:GDBInteger;v:GDBString);
function mystrtoint(s:GDBString):GDBInteger;
function readmystrtoint(var f:GDBOpenArrayOfByte):GDBInteger;
function readmystrtodouble(var f:GDBOpenArrayOfByte):GDBDouble;
function readmystr(var f:GDBOpenArrayOfByte):GDBString;
function dxfvertexload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:gdbvertex):GDBBoolean;
function dxfvertexload1(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:gdbvertex):GDBBoolean;
function dxfGDBDoubleload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBDouble):GDBBoolean;
function dxfGDBIntegerload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBInteger):GDBBoolean;
function dxfGDBStringload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBString):GDBBoolean;









implementation
uses
    log;
procedure dxfvertexout(outfile,dxfcode:GDBInteger;v:gdbvertex);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     WriteString_EOL(outfile,s);
     str(v.z:10:10,s);
     WriteString_EOL(outfile,s);
end;
procedure dxfvertexout1(outfile,dxfcode:GDBInteger;v:gdbvertex);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode);
     WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     inc(dxfcode);
     WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     WriteString_EOL(outfile,s);
     str(v.z:10:10,s);
     WriteString_EOL(outfile,s);
end;
procedure dxfvertex2dout(outfile,dxfcode:GDBInteger;v:gdbvertex2d);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     inc(dxfcode,10);
     WriteString_EOL(outfile,s);
     str(v.x:10:10,s);
     WriteString_EOL(outfile,s);
     s:=inttostr(dxfcode);
     WriteString_EOL(outfile,s);
     str(v.y:10:10,s);
     WriteString_EOL(outfile,s);
end;
procedure dxfGDBDoubleout(outfile,dxfcode:GDBInteger;v:GDBDouble);
var s:GDBString;
begin
     s:=inttostr(dxfcode);
     WriteString_EOL(outfile,s);
     str(v:10:10,s);
     WriteString_EOL(outfile,s);
end;
procedure dxfGDBIntegerout(outfile,dxfcode:GDBInteger;v:GDBInteger);
//var s:GDBString;
begin
     WriteString_EOL(outfile,inttostr(dxfcode));
     WriteString_EOL(outfile,inttostr(v));
end;
procedure dxfGDBStringout(outfile,dxfcode:GDBInteger;v:GDBString);
//var s:GDBString;
begin
     WriteString_EOL(outfile,inttostr(dxfcode));
     WriteString_EOL(outfile,v);
end;
function mystrtoint(s:GDBString):GDBInteger;
var code:GDBInteger;
begin
     //result:=0;
     val(s,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystrtoint(var f:GDBOpenArrayOfByte):GDBInteger;
var code:GDBInteger;
    s:GDBString;
begin
     //result:=0;
     s := f.readGDBSTRING;
     val(s,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystrtodouble(var f:GDBOpenArrayOfByte):GDBDouble;
var code:GDBInteger;
    s:GDBString;
begin
     //result:=0;
     s := f.readGDBSTRING;
     val(s,result,code);
     if code<>0 then
                    result:=0;
end;
function readmystr(var f:GDBOpenArrayOfByte):GDBString;
//var s:GDBString;
begin
     result := f.readGDBSTRING;
end;

function dxfvertexload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:gdbvertex):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v.x:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+10 then begin v.y:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+20 then begin v.z:=readmystrtodouble(f); result:=true end;
end;
function dxfvertexload1(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:gdbvertex):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v.x:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+1 then begin v.y:=readmystrtodouble(f); result:=true end
else if currentdxfcod=dxfcod+2 then begin v.z:=readmystrtodouble(f); result:=true end;
end;
function dxfGDBDoubleload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBDouble):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtodouble(f); result:=true end
end;
function dxfGDBIntegerload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBInteger):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin v:=readmystrtoint(f); result:=true end
end;
function dxfGDBStringload(var f:GDBOpenArrayOfByte;dxfcod,currentdxfcod:GDBInteger; var v:GDBString):GDBBoolean;
//var s:GDBString;
begin
     result:=false;
     if currentdxfcod=dxfcod then begin
                                       v:=v+readmystr(f); result:=true end
end;

begin
     {$IFDEF DEBUGINITSECTION}LogOut('dxflow.initialization');{$ENDIF}
end.
