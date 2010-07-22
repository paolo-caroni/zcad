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

unit UGDBTextStyleArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,SysInfo,UGDBOpenArrayOfData, oglwindowdef,sysutils,gdbase, geometry,
     gl;
type
  //ptextstyle = ^textstyle;
{EXPORT+}
PGDBTextStyleProp=^GDBTextStyleProp;
  GDBTextStyleProp=record
                    size:GDBDouble;(*saved_to_shd*)
                    oblique:GDBDouble;(*saved_to_shd*)
              end;
  PGDBTextStyle=^GDBTextStyle;
  GDBTextStyle = record
    name: GDBString;(*saved_to_shd*)
    pfont: GDBPointer;
    prop:GDBTextStyleProp;(*saved_to_shd*)
  end;
GDBTextStyleArray=object(GDBOpenArrayOfData)(*OpenArrayOfData=GDBTextStyle*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);
                    constructor initnul;

                    function addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
                    function FindStyle(StyleName:GDBString):GDBInteger;
                    procedure freeelement(p:GDBPointer);virtual;
              end;
{EXPORT-}
implementation
uses UGDBDescriptor,io,log;
procedure GDBTextStyleArray.freeelement;
begin
  PGDBTextStyle(p).name:='';
end;
constructor GDBTextStyleArray.initnul;
begin
  inherited initnul;
  size:=sizeof(GDBTextStyle);
end;
constructor GDBTextStyleArray.init;
begin
  //Size := sizeof(GDBTextStyle);
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(GDBTextStyle));
  //addlayer('0',cgdbwhile,lwgdbdefault);
end;

{procedure GDBLayerArray.clear;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     if count>0 then
     begin
          tlp:=parray;
          for i:=0 to count-1 do
          begin
               tlp^.name:='';
               inc(tlp);
          end;
     end;
  count:=0;
end;}
{function GDBLayerArray.getLayerIndex(name: GDBString): GDBInteger;
var
  i: GDBInteger;
begin
  result := 0;
  for i := 0 to count - 1 do
    if PGDBLayerPropArray(Parray)^[i].name = name then
    begin
      result := i;
      exit;
    end;
end;}
function GDBTextStyleArray.addstyle(StyleName,FontFile:GDBString;tp:GDBTextStyleProp):GDBInteger;
var ts:GDBTextStyle;
    //p:GDBPointer;
begin
  ts.name:=stylename;
  ts.pfont:=FontManager.FindFonf(FontFile);
  if ts.pfont=nil then ts.pfont:=FontManager.FindFonf('normal.shx');
  ts.prop:=tp;
  add(@ts);
end;
function GDBTextStyleArray.FindStyle;
var
  pts:pGDBTextStyle;
  i:GDBInteger;
begin
  result:=-1;
  if count=0 then exit;
  pts:=parray;
  for i:=0 to count-1 do
  begin
       if pts^.name=stylename then begin
                                       result:=i;
                                       exit;
                                  end;
  end;
end;

{function GDBLayerArray.CalcCopactMemSize2;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     result:=0;
     objcount:=count;
     if count=0 then exit;
     result:=result;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          result:=result+sizeof(GDBByte)+sizeof(GDBSmallint)+sizeof(GDBWord)+length(tlp^.name);
          inc(tlp);
     end;
end;
function GDBLayerArray.SaveToCompactMemSize2;
var i:GDBInteger;
    tlp:PGDBLayerProp;
begin
     result:=0;
     if count=0 then exit;
     tlp:=parray;
     for i:=0 to count-1 do
     begin
          PGDBByte(pmem)^:=tlp^.color;
          inc(PGDBByte(pmem));
          PGDBSmallint(pmem)^:=tlp^.lineweight;
          inc(PGDBSmallint(pmem));
          PGDBWord(pmem)^:=length(tlp^.name);
          inc(PGDBWord(pmem));
          Move(GDBPointer(tlp.name)^, pmem^,length(tlp.name));
          inc(PGDBByte(pmem),length(tlp.name));
          inc(tlp);
     end;
end;
function GDBLayerArray.LoadCompactMemSize2;
begin
     {inherited LoadCompactMemSize(pmem);
     Coord:=PGDBLineProp(pmem)^;
     inc(PGDBLineProp(pmem));
     PProjPoint:=nil;
     format;}
//end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBTextStyleArray.initialization');{$ENDIF}
end.
