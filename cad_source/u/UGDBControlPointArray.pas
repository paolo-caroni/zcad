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

unit UGDBControlPointArray;
{$INCLUDE def.inc}
interface
uses gdbasetypes,UGDBOpenArrayOfData,sysutils,gdbase, geometry,
     gl,memman;
type
{Export+}
PGDBControlPointArray=^GDBControlPointArray;
GDBControlPointArray=object(GDBOpenArrayOfData)
                           SelectedCount:GDBInteger;
                           constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger);

                           destructor done;virtual;
                           procedure draw;virtual;
                           procedure getnearesttomouse(var td:tcontrolpointdist);virtual;
                           procedure selectcurrentcontrolpoint(key:GDBByte);virtual;
                           procedure freeelement(p:GDBPointer);virtual;
                     end;
{Export-}
implementation
uses UGDBDescriptor,OGLSpecFunc,log;
procedure GDBControlPointArray.freeelement;
begin
  pcontrolpointdesc(p):=pcontrolpointdesc(p);
end;
constructor GDBControlPointArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m,sizeof(controlpointdesc))
  {Count := 0;
  Max := m;
  Size := sizeof(controlpointdesc);
  GDBGetMem(PArray, size * max);}
end;
destructor GDBControlPointArray.done;
begin
  GDBFreeMem(PArray);
end;
procedure GDBControlPointArray.draw;
var point:^controlpointdesc;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       point:=parray;
       for i:=0 to count-1 do
       begin
            if point^.selected then glcolor3ub(255, 0, 0)
                               else glcolor3ub(0, 0, 255);
            //glvertex2iv(@point^.dispcoord);
            myglvertex3dv(@point^.worldcoord);
            inc(point);
       end;
  end;
end;
procedure GDBControlPointArray.getnearesttomouse;
var point:pcontrolpointdesc;
    d:single;
    i:GDBInteger;
begin
  if count<>0 then
  begin
       point:=parray;
       for i:=0 to count-1 do
       begin
            d := (vertexlen2id(GDB.GetCurrentDWG.OGLwindow1.param.md.mouse.x, GDB.GetCurrentDWG.OGLwindow1.param.md.mouse.y,point^.dispcoord.x,point^.dispcoord.y));
            if d < td.disttomouse then
                                      begin
                                           td.disttomouse:=round(d);
                                           td.pcontrolpoint:=point;
                                      end;
            inc(point);
       end;
  end;
end;
procedure GDBControlPointArray.selectcurrentcontrolpoint;
var point:pcontrolpointdesc;
//    d:single;
    i:GDBInteger;
begin
  SelectedCount:=0;
  if count<>0 then
  begin
       point:=parray;
       for i:=1 to count do
       begin
            if (GDB.GetCurrentDWG.OGLwindow1.param.md.mouseglue.x=point^.dispcoord.x)and
               (GDB.GetCurrentDWG.OGLwindow1.param.md.mouseglue.y=point^.dispcoord.y)
            then
            begin
            if (key and 128)<>0 then point.selected:=not point.selected
                                else point.selected:=true;
            end;
            if point.selected then inc(SelectedCount);
            inc(point);
       end;
  end;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBControlPointArray.initialization');{$ENDIF}
end.

