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

unit commandlinedef;
{$INCLUDE def.inc}
interface
uses gdbasetypes,gdbase{,UGDBOpenArrayOfPointer},oglwindowdef,log,UGDBOpenArrayOfPObjects;
const
     CADWG=1;
     CEDeSelect=1;
type
{Export+}
  TCStartAttr=GDBInteger;{атрибут разрешения\запрещения запуска команды}
    TCEndAttr=GDBInteger;{атрибут действия по завершению команды}
  PCommandObjectDef = ^CommandObjectDef;
  CommandObjectDef = object (GDBaseObject)
    CommandName:GDBString;(*hidden_in_objinsp*)
    CommandGDBString:GDBString;(*hidden_in_objinsp*)
    savemousemode: GDBByte;(*hidden_in_objinsp*)
    mouseclic: GDBInteger;(*hidden_in_objinsp*)
    dyn:GDBBoolean;(*hidden_in_objinsp*)
    overlay:GDBBoolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCEndAttr;
    procedure CommandStart(Operands:pansichar); virtual; abstract;
    procedure CommandEnd; virtual; abstract;
    procedure CommandCancel; virtual; abstract;
    procedure CommandInit; virtual; abstract;
    procedure DrawHeplGeometry;virtual;
    destructor done;virtual;
  end;
  CommandFastObjectDef = object(CommandObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  CommandRTEdObjectDef = object(CommandFastObjectDef)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
  end;
  pGDBcommandmanagerDef=^GDBcommandmanagerDef;
  GDBcommandmanagerDef=object(GDBOpenArrayOfPObjects)
                                  lastcommand:GDBString;
                                  pcommandrunning:PCommandRTEdObjectDef;
                                  function executecommand(const comm:pansichar): GDBInteger;virtual;abstract;
                                  procedure executecommandend;virtual;abstract;
                                  function executelastcommad: GDBInteger;virtual;abstract;
                                  procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record);virtual;abstract;
                                  procedure CommandRegister(pc:PCommandObjectDef);virtual;abstract;
                             end;
{Export-}
implementation
//uses oglwindow;
destructor CommandObjectDef.done;
begin
         //inherited;
         CommandName:='';
         CommandGDBString:='';
end;
procedure CommandObjectDef.DrawHeplGeometry;
begin
end;
function CommandRTEdObjectDef.BeforeClick;
begin
     result:=0;
end;
function CommandRTEdObjectDef.AfterClick;
begin
     if self.mouseclic=1 then
                             result:=0
                         else
                             result:=0;
end;
function CommandRTEdObjectDef.MouseMoveCallback;
begin
  //result:=0;
  {$IFDEF TOTALYLOG}programlog.logoutstr('CommandRTEdObjectDef.MouseMoveCallback',0);{$ENDIF}
     { if button =1  then
                        begin
                            button:=-button;
                            button:=-button;
                        end;}
    if mouseclic = 0 then
                         result := BeforeClick(wc, mc, button,osp)
                     else
                         result := AfterClick(wc, mc, button,osp);
  {if result=0 then
                  begin}
    {if button = 32 then
                       button:=1;}
                       if (button and MZW_LBUTTON)<>0 then
                                         begin
                                               inc(self.mouseclic);

                                               //button:=button+1;
                                               //button:=button-1;
{                  end
              else
                  begin
                       if button = 1 then begin
                                               mouseclic:=result;
                                          end;
                  end}

  {  if mouseclic <= 1 then result := BeforeClick(wc, mc, button,osp)
    else result := AfterClick(wc, mc, button,osp);
  end
  else if mouseclic > 0 then
    result := AfterClick(wc, mc, button,osp);}
    end;
end;
begin
     {$IFDEF DEBUGINITSECTION}LogOut('commandlinedef.initialization');{$ENDIF}
end.
