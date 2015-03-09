﻿{
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

unit ugdbsimpledrawing;
{$INCLUDE def.inc}
interface
uses ugdbdimstylearray,GDBWithLocalCS,ugdbabstractdrawing,zcadsysvars,strproc,
     UGDBObjBlockdefArray,UGDBTableStyleArray,{UUnitManager,}UGDBNumerator, gdbase,
     varmandef,{varman,}sysutils, memman, geometry,gdbasetypes,sysinfo,
     GDBGenericSubEntry,UGDBLayerArray,ugdbltypearray,GDBEntity,
     UGDBSelectedObjArray,UGDBTextStyleArray,GDBCamera,UGDBOpenArrayOfPV,
     GDBRoot,ugdbfont,UGDBOpenArrayOfPObjects,abstractviewarea,gdbdrawcontext;
type
{EXPORT+}
PTSimpleDrawing=^TSimpleDrawing;
TSimpleDrawing={$IFNDEF DELPHI}packed{$ENDIF} object(TAbstractDrawing)
                       pObjRoot:PGDBObjGenericSubEntry;
                       mainObjRoot:GDBObjRoot;(*saved_to_shd*)
                       LayerTable:GDBLayerArray;(*saved_to_shd*)
                       ConstructObjRoot:GDBObjRoot;
                       SelObjArray:GDBSelectedObjArray;
                       pcamera:PGDBObjCamera;
                       OnMouseObj:GDBObjOpenArrayOfPV;

                       //OGLwindow1:toglwnd;
                       wa:TAbstractViewArea;

                       TextStyleTable:GDBTextStyleArray;(*saved_to_shd*)
                       BlockDefArray:GDBObjBlockdefArray;(*saved_to_shd*)
                       Numerator:GDBNumerator;(*saved_to_shd*)
                       TableStyleTable:GDBTableStyleArray;(*saved_to_shd*)
                       LTypeStyleTable:GDBLtypeArray;
                       DimStyleTable:GDBDimStyleArray;
                       function GetLastSelected:PGDBObjEntity;virtual;
                       function CreateBlockDef(name:GDBString):GDBPointer;virtual;abstract;
                       constructor init(pcam:PGDBObjCamera);
                       destructor done;virtual;
                       function myGluProject2(objcoord:GDBVertex; out wincoord:GDBVertex):Integer;virtual;
                       function myGluUnProject(win:GDBVertex;out obj:GDBvertex):Integer;virtual;
                       function GetPcamera:PGDBObjCamera;virtual;
                       function GetCurrentROOT:PGDBObjGenericSubEntry;virtual;
                       function GetCurrentRootSimple:GDBPointer;virtual;
                       function GetCurrentRootObjArraySimple:GDBPointer;virtual;
                       function GetBlockDefArraySimple:GDBPointer;virtual;
                       function GetConstructObjRoot:PGDBObjRoot;virtual;
                       function GetSelObjArray:PGDBSelectedObjArray;virtual;
                       function GetLayerTable:PGDBLayerArray;virtual;
                       function GetLTypeTable:PGDBLtypeArray;virtual;
                       function GetTableStyleTable:PGDBTableStyleArray;virtual;
                       function GetTextStyleTable:PGDBTextStyleArray;virtual;
                       function GetDimStyleTable:PGDBDimStyleArray;virtual;
                       function GetOnMouseObj:PGDBObjOpenArrayOfPV;virtual;
                       procedure RotateCameraInLocalCSXY(ux,uy:GDBDouble);virtual;
                       procedure MoveCameraInLocalCSXY(oldx,oldy:GDBDouble;ax:gdbvertex);virtual;
                       procedure SetCurrentDWG;virtual;
                       function StoreOldCamerapPos:Pointer;virtual;
                       procedure StoreNewCamerapPos(command:Pointer);virtual;
                       procedure rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);virtual;
                       procedure rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);virtual;
                       procedure PushStartMarker(CommandName:GDBString);virtual;
                       procedure PushEndMarker;virtual;
                       procedure SetFileName(NewName:GDBString);virtual;
                       function GetFileName:GDBString;virtual;
                       procedure ChangeStampt(st:GDBBoolean);virtual;
                       function GetUndoTop:TArrayIndex;virtual;
                       function CanUndo:boolean;virtual;
                       function CanRedo:boolean;virtual;
                       function GetUndoStack:GDBPointer;virtual;
                       function GetDWGUnits:{PTUnitManager}pointer;virtual;
                       procedure AssignLTWithFonts(pltp:PGDBLtypeProp);virtual;
                       function GetMouseEditorMode:GDBByte;virtual;
                       function DefMouseEditorMode(SetMask,ReSetMask:GDBByte):GDBByte;virtual;
                       function SetMouseEditorMode(mode:GDBByte):GDBByte;virtual;
                       procedure FreeConstructionObjects;virtual;
                       function GetChangeStampt:GDBBoolean;virtual;
                       function CreateDrawingRC(_maxdetail:GDBBoolean=false):TDrawContext;virtual;
                 end;
{EXPORT-}
function CreateSimpleDWG:PTSimpleDrawing;
implementation
uses log;
function TSimpleDrawing.CreateDrawingRC(_maxdetail:GDBBoolean=false):TDrawContext;
begin
  if assigned(wa)then
                     result:=wa.CreateRC(_maxdetail)
  else
  begin

  end;
end;

function TSimpleDrawing.GetChangeStampt:GDBBoolean;
begin
     result:=false;
end;

procedure TSimpleDrawing.FreeConstructionObjects;
begin
  ConstructObjRoot.ObjArray.cleareraseobj;
  ConstructObjRoot.ObjCasheArray.Clear;
  //ConstructObjRoot.ObjToConnectedArray.Clear;
  ConstructObjRoot.ObjMatrix:=onematrix;
end;

function TSimpleDrawing.GetMouseEditorMode:GDBByte;
begin
     if assigned(wa.getviewcontrol) then
                                 result:=wa.param.md.mode
                             else
                                 result:=0;
end;

function TSimpleDrawing.DefMouseEditorMode(SetMask,ReSetMask:GDBByte):GDBByte;
begin
     result:=GetMouseEditorMode;
     SetMouseEditorMode((result or setmask) and (not ReSetMask))
end;

function TSimpleDrawing.SetMouseEditorMode(mode:GDBByte):GDBByte;
begin
     if assigned(wa.getviewcontrol) then
                                 begin
                                      result:=wa.param.md.mode;
                                      wa.param.md.mode:=mode;
                                 end
                             else
                                 result:=0;
end;

procedure TSimpleDrawing.AssignLTWithFonts(pltp:PGDBLtypeProp);
var
   PSP:PShapeProp;
   PTP:PTextProp;
   ir2:itrec;
   pts:pGDBTextStyle;
procedure createstyle;
var
   tp:GDBTextStyleProp;
begin
     tp.oblique:=0;
     tp.size:=1;
     tp.wfactor:=1;
     pts:=TextStyleTable.addstyle(psp.FontName,psp.FontName,tp,true);
end;

begin
    PSP:=pltp.shapearray.beginiterate(ir2);
                                       if PSP<>nil then
                                       repeat
                                             pts:=TextStyleTable.FindStyle(psp.FontName,true);
                                             if pts=nil then
                                                            createstyle;
                                             PSP^.param.PStyle:=pts;
                                             PSP^.Psymbol:=pts^.pfont.font.findunisymbolinfos(psp.SymbolName);
                                             PSP:=pltp.shapearray.iterate(ir2);
                                       until PSP=nil;
   PTP:=pltp.textarray.beginiterate(ir2);
                                      if PTP<>nil then
                                      repeat
                                            pts:={TextStyleTable.getelement}(TextStyleTable.FindStyle(PTP.Style,false));
                                            if pts=nil then
                                                           pts:=TextStyleTable.getelement(0);
                                            PTP^.param.PStyle:=pts;
                                            {for i:=1 to length(PTP^.Text) do
                                            begin
                                                 if PTP^.param.PStyle<>nil then
                                                 begin
                                                 Psymbol:=PTP^.param.PStyle.pfont^.GetOrReplaceSymbolInfo(byte(PTP^.Text[i]),TDInfo);
                                                 sh:=abs(Psymbol.SymMaxY*PTP^.param.Height);
                                                 if h<sh then
                                                             h:=sh;
                                                 sh:=abs(Psymbol.SymMinY*PTP^.param.Height);
                                                 if h<sh then
                                                             h:=sh;
                                                 end;
                                            end;}
                                            PTP:=pltp.textarray.iterate(ir2);
                                      until PTP=nil;

end;


function TSimpleDrawing.GetDWGUnits:{PTUnitManager}pointer;
begin
     result:=nil;
end;

function TSimpleDrawing.GetLastSelected:PGDBObjEntity;
begin
     result:=wa.param.SelDesc.LastSelectedObject;
end;
procedure TSimpleDrawing.SetFileName(NewName:GDBString);
begin

end;
function TSimpleDrawing.GetFileName:GDBString;
begin
     result:=''
end;
procedure TSimpleDrawing.ChangeStampt;
begin
     if wa.getviewcontrol<>nil then
     wa.param.lastonmouseobject:=nil;
end;
function TSimpleDrawing.GetUndoTop:TArrayIndex;
begin
     result:=0;
end;
function TSimpleDrawing.GetUndoStack:GDBPointer;
begin
     result:=nil;
end;
function TSimpleDrawing.CanUndo:boolean;
begin
     result:=false;
end;
function TSimpleDrawing.CanRedo:boolean;
 begin
     result:=false;
end;

function CreateSimpleDWG:PTSimpleDrawing;
//var
   //ptd:PTSimpleDrawing;
begin
     gdBGetMem({$IFDEF DEBUGBUILD}'{2A28BFB9-661F-4331-955A-C6F18DE67A19}',{$ENDIF}GDBPointer(result),sizeof(TSimpleDrawing));
     //ptd:=currentdwg;
     //currentdwg:=pointer(result);
     result^.init(nil);//(@units);
     //self.AddRef(result^);
     //currentdwg:=pointer(ptd);
end;
procedure TSimpleDrawing.PushStartMarker(CommandName:GDBString);
begin

end;

procedure TSimpleDrawing.PushEndMarker;
begin

end;

procedure TSimpleDrawing.rtmodifyonepoint(obj:PGDBObjEntity;rtmod:TRTModifyData;wc:gdbvertex);
begin
     obj^.rtmodifyonepoint(rtmod);
     obj^.YouChanged(self);
end;
procedure TSimpleDrawing.rtmodify(obj:PGDBObjEntity;md:GDBPointer;dist,wc:gdbvertex;save:GDBBoolean);
var i:GDBInteger;
    point:pcontrolpointdesc;
    p:GDBPointer;
    m,m2,mt:DMatrix4D;
    t:gdbvertex;
    //tt:dvector4d;
    rtmod:TRTModifyData;
    //tum:TUndableMethod;
    dc:TDrawContext;
begin
     if PSelectedObjDesc(md).pcontrolpoint^.count=0 then exit;
     if PSelectedObjDesc(md).ptempobj=nil then
     begin
          PSelectedObjDesc(md).ptempobj:=obj^.Clone(nil);
          PSelectedObjDesc(md).ptempobj^.bp.ListPos.Owner:=obj^.bp.ListPos.Owner;
          dc:=self.CreateDrawingRC;
          PSelectedObjDesc(md).ptempobj.{format}FormatFast(self,dc);
          PSelectedObjDesc(md).ptempobj.BuildGeometry(self);
     end;
     p:=obj^.beforertmodify;
     if save then PSelectedObjDesc(md).pcontrolpoint^.SelectedCount:=0;
     point:=PSelectedObjDesc(md).pcontrolpoint^.parray;
     for i:=1 to PSelectedObjDesc(md).pcontrolpoint^.count do
     begin
          if point.selected then
          begin
               if save then
                           save:=save;
               {учет СК владельца}
               m:=PSelectedObjDesc(md).objaddr^.getownermatrix^;
               MatrixInvert(m);
               t:=VectorTransform3D(dist,m);
               {учет СК владельца}

     (*          {учет своей СК  CalcObjMatrixWithoutOwner}
               if PSelectedObjDesc(md).objaddr^.IsHaveLCS then
               begin
               m2:=PGDBObjWithLocalCS(PSelectedObjDesc(md).objaddr)^.CalcObjMatrixWithoutOwner;
               //PGDBVertex(@m)^:=geometry.NulVertex;
               MatrixInvert(m2);
               t:=VectorTransform3D({dist}t,m2);

               m2:=m;
               end;
               {учет своей СК}
     *)
               rtmod.point:=point^;
               t:=point^.worldcoord;
               t:=VectorTransform3D(t,m);
               rtmod.point.worldcoord:=t;
               //t:=VectorTransform3D(t,mt);
               //rtmod.point.worldcoord:={point^}VectorTransform3D(point^.worldcoord,m);
               //rtmod.point.worldcoord:={point^}VectorTransform3D(rtmod.point.worldcoord,mt);
               mt:=m;

               mt[3][0]:=0;
               mt[3][1]:=0;
               mt[3][2]:=0;

               rtmod.dist:=VectorTransform3D(dist,mt);
               rtmod.wc:=VectorTransform3D(wc,m);

               rtmod.point.dcoord:=VectorTransform3D(rtmod.point.dcoord,mt);

                   {учет своей СК  CalcObjMatrixWithoutOwner}
                    if PSelectedObjDesc(md).objaddr^.IsHaveLCS then
                    begin
                    m2:=PGDBObjWithLocalCS(PSelectedObjDesc(md).objaddr)^.CalcObjMatrixWithoutOwner;
                    MatrixInvert(m2);
                    m2[3][0]:=0;
                    m2[3][1]:=0;
                    m2[3][2]:=0;

                    rtmod.dist:=VectorTransform3D(rtmod.dist,m2);
                    rtmod.wc:=VectorTransform3D(rtmod.wc,m2);

                    rtmod.point.worldcoord:=VectorTransform3D(rtmod.point.worldcoord,m2);

                    rtmod.point.dcoord:=VectorTransform3D(rtmod.point.dcoord,m2);
                    end;

                    {учет своей СК}
               if save then
                           begin
                                if obj^.IsRTNeedModify(point,p)then
                                                                   begin
                                                                        self.rtmodifyonepoint(obj,rtmod,wc);
                                                                        {tmethod(tum).Code:=pointer(obj.rtmodifyonepoint);
                                                                        tmethod(tum).Data:=obj;
                                                                        //tum:=tundablemethod(obj^.rtmodifyonepoint);
                                                                        with GetCurrentDWG.UndoStack.PushCreateTGObjectChangeCommand(rtmod,tmethod(tum))^ do
                                                                        begin
                                                                             comit;
                                                                             rtmod.wc:=rtmod.point.worldcoord;
                                                                             rtmod.dist:=nulvertex;
                                                                             StoreUndoData(rtmod);
                                                                        end;}
                                                                        {obj^.rtmodifyonepoint(rtmod);
                                                                        obj^.YouChanged;}
                                                                   end;
                                point.selected:=false;
                           end
                       else
                           begin
                                if PSelectedObjDesc(md).ptempobj^.IsRTNeedModify(point,p)then
                                begin
                                     PSelectedObjDesc(md).ptempobj^.SetFromClone(obj);
                                     PSelectedObjDesc(md).ptempobj^.rtmodifyonepoint(rtmod);
                                end;

                           end;
          end;
          inc(point);
     end;
     if save then
     begin
          //--------------(PSelectedObjDesc(md).ptempobj).rtsave(@self);

          //PGDBObjGenericWithSubordinated(obj^.bp.owner)^.ImEdited({@self}obj,obj^.bp.PSelfInOwnerArray);
          PSelectedObjDesc(md).ptempobj^.done;
          GDBFreeMem(GDBPointer(PSelectedObjDesc(md).ptempobj));
          PSelectedObjDesc(md).ptempobj:=nil;
     end
     else
     begin
          dc:=self.CreateDrawingRC;
          PSelectedObjDesc(md).ptempobj.FormatFast(self,dc);
          PSelectedObjDesc(md).ptempobj.BuildGeometry(self);
          //PSelectedObjDesc(md).ptempobj.renderfeedback;
     end;
     obj^.afterrtmodify(p);
end;
function TSimpleDrawing.StoreOldCamerapPos:Pointer;
begin
     result:=nil;
end;
procedure TSimpleDrawing.StoreNewCamerapPos(command:Pointer);
begin
end;

function TSimpleDrawing.GetOnMouseObj:PGDBObjOpenArrayOfPV;
begin
     result:=@OnMouseObj;
end;
function TSimpleDrawing.GetLayerTable:PGDBLayerArray;
begin
     result:=@LayerTable;
end;
function TSimpleDrawing.GetLTypeTable:PGDBLtypeArray;
begin
     result:=@LTypeStyleTable;
end;
function TSimpleDrawing.GetTableStyleTable:PGDBTableStyleArray;
begin
     result:=@TableStyleTable;
end;
function TSimpleDrawing.GetTextStyleTable:PGDBTextStyleArray;
begin
     result:=@TextStyleTable;
end;
function TSimpleDrawing.GetDimStyleTable:PGDBDimStyleArray;
begin
     result:=@self.DimStyleTable;
end;
procedure TSimpleDrawing.SetCurrentDWG;
begin

end;

procedure TSimpleDrawing.MoveCameraInLocalCSXY(oldx,oldy:GDBDouble;ax:gdbvertex);
var
    uc:pointer;
begin
     uc:=StoreOldCamerapPos;
  //with UndoStack.PushCreateTGChangeCommand(GetPcamera^.prop)^ do
             begin
             GetPcamera.moveInLocalCSXY(oldx,oldy,ax);
             //ComitFromObj;
             end;
  //gdb.GetCurrentDWG.Changed:=true;
     StoreNewCamerapPos(uc);
end;

procedure TSimpleDrawing.RotateCameraInLocalCSXY(ux,uy:GDBDouble);
var
    uc:pointer;
begin
     uc:=StoreOldCamerapPos;
  //with UndoStack.CreateTGChangeCommand(GetPcamera^.prop)^ do
  begin
  //gdb.GetCurrentDWG.UndoStack.PushChangeCommand(gdb.GetCurrentDWG.pcamera,(ptrint(@gdb.GetCurrentDWG.pcamera^.prop)-ptrint(gdb.GetCurrentDWG.pcamera)),sizeof(GDBCameraBaseProp));
  GetPcamera.RotateInLocalCSXY(ux,uy);
  //ComitFromObj;
  end;
  StoreNewCamerapPos(uc);
  //changed:=true;
end;

function TSimpleDrawing.GetSelObjArray:PGDBSelectedObjArray;
begin
     result:=@SelObjArray;
end;
function TSimpleDrawing.GetConstructObjRoot:PGDBObjRoot;
begin
     result:=@ConstructObjRoot;
end;
function TSimpleDrawing.GetCurrentRootSimple:GDBPointer;
begin
     result:=self.pObjRoot;
end;
function TSimpleDrawing.GetCurrentRootObjArraySimple:GDBPointer;
begin
     result:=@pObjRoot.ObjArray;
end;

function TSimpleDrawing.GetBlockDefArraySimple:GDBPointer;
begin
     result:=@self.BlockDefArray;
end;
function TSimpleDrawing.GetCurrentROOT:PGDBObjGenericSubEntry;
begin
     result:=self.pObjRoot;
end;
function TSimpleDrawing.GetPcamera:PGDBObjCamera;
begin
     result:=pcamera;
end;
function TSimpleDrawing.myGluProject2;
begin
      objcoord:=vertexadd(objcoord,pcamera^.CamCSOffset);
     _myGluProject(objcoord.x,objcoord.y,objcoord.z,@pcamera^.modelMatrixLCS,@pcamera^.projMatrixLCS,@pcamera^.viewport,wincoord.x,wincoord.y,wincoord.z);
end;
function TSimpleDrawing.myGluUnProject(win:GDBVertex;out obj:GDBvertex):Integer;
begin
     _myGluUnProject(win.x,win.y,win.z,@pcamera^.modelMatrixLCS,@pcamera^.projMatrixLCS,@pcamera^.viewport, obj.x,obj.y,obj.z);
     OBJ:=vertexsub(OBJ,pcamera^.CamCSOffset);
end;
destructor TSimpleDrawing.done;
begin
     //undostack.done;
     mainObjRoot.done;
     LayerTable.FreeAndDone;
     //ConstructObjRoot.ObjArray.FreeAndDone;
     ConstructObjRoot.done;
     SelObjArray.FreeAndDone;
     //DWGUnits.FreeAndDone;
     OnMouseObj.ClearAndDone;
     TextStyleTable.FreeAndDone;
     BlockDefArray.FreeAndDone;
     Numerator.FreeAndDone;
     TableStyleTable.FreeAndDone;
     LTypeStyleTable.FreeAndDone;
     DimStyleTable.FreeAndDone;
     //FileName:='';
end;
constructor TSimpleDrawing.init;
var {tp:GDBTextStyleProp;}
    ts:PTGDBTableStyle;
    cs:TGDBTableCellStyle;
begin
  pcamera:=pcam;
  if pcamera=nil then
                     begin
                     GDBGetMem({$IFDEF DEBUGBUILD}'{4B7A0493-E8D6-4F24-BB70-C9C246A351BA}',{$ENDIF}pointer(pcamera), sizeof(GDBObjCamera));
                     pcamera^.initnul;

                       pcamera.fovy:=35.0;
                       pcamera.prop.point.x:=0.0;
                       pcamera.prop.point.y:=0.0;
                       pcamera.prop.point.z:=50.0;
                       pcamera.prop.look.x:=0.0;
                       pcamera.prop.look.y:=0.0;
                       pcamera.prop.look.z:=-1.0;
                       pcamera.prop.ydir.x:=0.0;
                       pcamera.prop.ydir.y:=1.0;
                       pcamera.prop.ydir.z:=0.0;
                       pcamera.prop.xdir.x:=-1.0;
                       pcamera.prop.xdir.y:=0.0;
                       pcamera.prop.xdir.z:=0.0;
                       pcamera.prop.zoom:=0.1;
                       pcamera.anglx:=-3.14159265359;
                       pcamera.angly:=-1.570796326795;
                       pcamera.zmin:=1.0;
                       pcamera.zmax:=100000.0;
                       pcamera.fovy:=35.0;
                     end;
  LTypeStyleTable.init({$IFDEF DEBUGBUILD}'{2BF47561-AEBD-4159-BF98-FCBA81DAD595}',{$ENDIF}100);
  LayerTable.init({$IFDEF DEBUGBUILD}'{6AFCB58D-9C9B-4325-A00A-C2E8BDCBE1DD}',{$ENDIF}200,LTypeStyleTable.GetSystemLT(TLTContinous));
  DimStyleTable.init({$IFDEF DEBUGBUILD}'{C354FF9D-E581-4E5A-AFE0-09AE87DEC2F0}',{$ENDIF}100);
  mainobjroot.initnul;
  mainobjroot.vp.Layer:=LayerTable.GetSystemLayer;
  pObjRoot:=@mainobjroot;
  ConstructObjRoot.initnul;
  ConstructObjRoot.vp.Layer:=LayerTable.GetSystemLayer;
  SelObjArray.init({$IFDEF DEBUGBUILD}'{0CC3A9A3-B9C2-4FB5-BFB1-8791C261C577} - SelObjArray',{$ENDIF}65535);
  OnMouseObj.init({$IFDEF DEBUGBUILD}'{85654C90-FF49-4272-B429-4D134913BC26} - OnMouseObj',{$ENDIF}20);

  //pcamera^.initnul;
  //ConstructObjRoot.init({$IFDEF DEBUGBUILD}'{B1036F20-562D-4B17-A33A-61CF3F5F2A90} - ConstructObjRoot',{$ENDIF}1);

  TextStyleTable.init({$IFDEF DEBUGBUILD}'{146FC836-1490-4046-8B09-863722570C9F}',{$ENDIF}200);
  //tp.size:=2.5;
  //tp.oblique:=0;

  //TextStyleTable.addstyle('Standart','normal.shp',tp);

  //TextStyleTable.addstyle('R2_5','romant.shx',tp);
  //TextStyleTable.addstyle('standart','txt.shx',tp);

  BlockDefArray.init({$IFDEF DEBUGBUILD}'{D53DA395-A6A2-4FDD-842D-A52E6385E2DD}',{$ENDIF}100);
  Numerator.init(10);

  TableStyleTable.init({$IFDEF DEBUGBUILD}'{E5CE9274-01D8-4D19-AF2E-D1AB116B5737}',{$ENDIF}10);

  PTempTableStyle:=TableStyleTable.AddStyle('Temp');

  PTempTableStyle.rowheight:=4;
  PTempTableStyle.textheight:=2.5;

  cs.Width:=1;
  cs.TextWidth:={cf.Width-2}0;
  cs.CF:=TTableCellJustify.jcc;
  PTempTableStyle.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('Standart');

  ts.rowheight:=4;
  ts.textheight:=2.5;

  cs.Width:=20;
  cs.TextWidth:={cf.Width-2}0;
  cs.CF:=jcc;
  ts.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('Spec');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_SPEC_HEAD';

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=130;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={UGDBTableStyleArray.TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=60;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={UGDBTableStyleArray.TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=35;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=45;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=40;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcc;
     ts.tblformat.Add(@cs);

  ts:=TableStyleTable.AddStyle('ShRaspr');

  ts.rowheight:=10;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_PSRS_HEAD';

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=33;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=33;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=5;
     cs.TextWidth:=cs.Width-1;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=17;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=23;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=13;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=16;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=12;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=12;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);

     cs.Width:=35;
     cs.TextWidth:=cs.Width-2;
     cs.cf:={TCellJustify.}jcl;
     ts.tblformat.Add(@cs);




  ts:=TableStyleTable.AddStyle('KZ');

  ts.rowheight:=8;
  ts.textheight:=3.5;

  ts.HeadBlockName:='TBL_KZ_HEAD';

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=46;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=46;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=20;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-1;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=40;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     {cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcm;
     ts.tblformat.Add(@cs);}

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=25;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

     cs.Width:=15;
     cs.TextWidth:=cs.Width-2;
     cs.cf:=jcc;
     ts.tblformat.Add(@cs);

end;

end.