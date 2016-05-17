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

unit uzcshared;
{$INCLUDE def.inc}
interface
uses uzcfcommandline,uzclog,uzbpaths,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}Controls,uzcstrconsts,
     uzbtypesbase,Classes, SysUtils, {$IFNDEF DELPHI}fileutil,{$ENDIF}Forms,
     stdctrls, ExtCtrls{, ComCtrls}{$IFNDEF DELPHI},LCLProc{$ENDIF};

type
SimpleProcOfObject=procedure of object;

procedure HistoryOut(s: pansichar); export;
procedure HistoryOutStr(s:GDBString);
procedure StatusLineTextOut(s:GDBString);
procedure FatalError(errstr:GDBString);
procedure LogError(errstr:GDBString); export;
procedure ShowError(errstr:GDBString); export;
//procedure OldVersTextReplace(var vv:GDBString);
procedure DisableCmdLine;
procedure EnableCmdLine;
var
    HintText:TLabel;

    CursorOn:SimpleProcOfObject=nil;
    CursorOff:SimpleProcOfObject=nil;

implementation
procedure DisableCmdLine;
begin
  application.MainForm.ActiveControl:=nil;
  if assigned(uzcfcommandline.cmdedit) then
                                  begin
                                      uzcfcommandline.cmdedit.Enabled:=false;
                                  end;
  if assigned(uzcshared.HintText) then
                                   begin
                             uzcshared.HintText.Enabled:=false;
                                   end;
end;

procedure EnableCmdLine;
begin
  if assigned(uzcfcommandline.cmdedit) then
                                  begin
                                       uzcfcommandline.cmdedit.Enabled:=true;
                                       uzcfcommandline.cmdedit.SetFocus;
                                  end;
  if assigned(uzcshared.HintText) then
                                   uzcshared.HintText.Enabled:=true;
end;
procedure HistoryOut(s: pansichar); export;
var
   a:string;
begin
     {if sysvar.SYS.SYS_IsHistoryLineCreated<>nil then
     if sysvar.SYS.SYS_IsHistoryLineCreated^ then}
     if assigned(HistoryLine) then
     begin
          a:=(s);
               if HistoryLine.Lines.Count=0 then
                                            utflen:=utflen+{UTF8}Length(a)
                                        else
                                            utflen:=2+utflen+{UTF8}Length(a);
          {$IFNDEF DELPHI}
          HistoryLine.Append(a);
          CWMemo.Append(a);
          {$ENDIF}
          //application.ProcessMessages;

          //HistoryLine.SelStart:=utflen{HistoryLine.GetTextLen};
          //HistoryLine.SelLength:=2;
          historychanged:=true;
          //HistoryLine.SelLength:=0;
          //{CLine}HistoryLine.append(s);
          {CLine}//---------------------------------------------------------HistoryLine.repaint;
          //a:=CLine.HistoryLine.Lines[CLine.HistoryLine.Lines.Count];
     //SendMessageA(cline.HistoryLine.Handle, WM_vSCROLL, SB_PAGEDOWN	, 0);
     end;
     programlog.logoutstr('HISTORY: '+s,0,LM_Info);
end;
procedure HistoryOutStr(s:GDBString);
begin
     HistoryOut(pansichar(s));
end;
procedure StatusLineTextOut(s:GDBString);
begin
     if assigned(HintText) then
     HintText.caption:=(s);
     //HintText.{Update}repaint;
end;
procedure FatalError(errstr:GDBString);
var s:GDBString;
begin
     s:='FATALERROR: '+errstr;
     programlog.logoutstr(s,0,LM_Fatal);
     s:=(s);
     if  assigned(CursorOn) then
                                CursorOn;
     Application.MessageBox(@s[1],'',MB_OK);
     if  assigned(CursorOff) then
                                CursorOff;

     halt(0);
end;
procedure LogError(errstr:GDBString); export;
begin
     errstr:=rserrorprefix+errstr;
     if assigned(HistoryLine) then
     begin
     HistoryOutStr(errstr);
     end;
     programlog.logoutstr(errstr,0,LM_Error);
end;
procedure ShowError(errstr:GDBString); export;
var
   ts:GDBString;
begin
     LogError(errstr);
     ts:=(errstr);
     if  assigned(CursorOn) then
                                CursorOn;
     Application.MessageBox(@ts[1],'',MB_ICONERROR);
     if  assigned(CursorOff) then
                                CursorOff;
end;
begin
uzclog.HistoryTextOut:=@HistoryOutStr;
uzclog.MessageBoxTextOut:=@ShowError;
end.
