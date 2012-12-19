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

unit colorwnd;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, {ColorBox,} ButtonPanel, Spin, ExtCtrls, ComCtrls,math,
  gdbase,zcadstrconsts;

type
  ColorGeometry=record
                      startx,starty,dx,dy:integer
                end;

  { TColorSelectWND }

  TColorSelectWND = class(TForm)
    ByBlock: TBitBtn;
    ByLayer: TBitBtn;
    ButtonPanel1: TButtonPanel;
    Label2: TLabel;
    Label3: TLabel;
    oddpalette: TPaintBox;
    evenpalette: TPaintBox;
    mainpalette: TPaintBox;
    graypalette: TPaintBox;
    PageControl1: TPageControl;
    SpinEdit1: TSpinEdit;
    TabSheet1: TTabSheet;
    procedure ByBlockCLC(Sender: TObject);
    procedure ByLayerCLC(Sender: TObject);
    procedure EvenMDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EvenPalettePaint(Sender: TObject);
    procedure GrayGeometryPaint(Sender: TObject);
    procedure grayMDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mainMdown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MainPalettePaint(Sender: TObject);
    procedure OddMDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OddPalettePaint(Sender: TObject);
    procedure resize(Sender: TObject);
    procedure testsetcolor(Sender: TObject);
    procedure _onCreate(Sender: TObject);
    procedure _onshow(Sender: TObject);
    function run(ci:integer;showBy:boolean):integer;
  private
    { private declarations }
    EvenGeometry,OddGeometry,MainGeometry,GrayGeometry:ColorGeometry;
    procedure PalettePainter(canvas:Tcanvas; StartIndex,IncIndex,startx,starty,dx,dy,cx,cy:integer);
  public
    ColorInfex:Integer;
    { public declarations }
  end;

var
  ColorSelectWND: TColorSelectWND=nil;

const
  xsize=50;
  ysize=50;

implementation

{$R *.lfm}

{ TColorSelectWND }

procedure TColorSelectWND.testsetcolor(Sender: TObject);
var
  s:string;
begin
     ColorInfex:=SpinEdit1.Value;
     {oddpalette.Repaint;
     evenpalette.Repaint;
     mainpalette.Repaint;
     graypalette.Repaint;}
     repaint;
     s:='#'+inttostr(ColorInfex)+' ';
     Case ColorInfex of
                       256:
                           s:=s+rsByLayer;
                       0:
                           s:=s+rsByBlock;
                       else
                           s:=s+'(Red='+inttostr(palette[ColorInfex].r)+' Green='+inttostr(palette[ColorInfex].g)+' Blue='+inttostr(palette[ColorInfex].b)+')';
     end;
     if ColorInfex=0 then
                         ByBlock.Caption:=rsByBlock+'(*)'
                     else
                         ByBlock.Caption:=rsByBlock;
     if ColorInfex=256 then
                         ByLayer.Caption:=rsByLayer+'(*)'
                     else
                         ByLayer.Caption:=rsByLayer;
     label3.Caption:=s;
end;

procedure TColorSelectWND._onCreate(Sender: TObject);
begin
     ByBlock.Caption:=rsByBlock;
     ByLayer.Caption:=rsByLayer;
end;
function TColorSelectWND.run(ci:integer;showBy:boolean):integer;
begin
     SpinEdit1.Value:=ci;
     if showBy then
                   begin
                        ByBlock.Visible:=true;
                        ByLayer.Visible:=true;
                        self.SpinEdit1.MaxValue:=256;
                        self.SpinEdit1.MinValue:=0;
                   end
               else
                   begin
                        ByBlock.Visible:=false;
                        ByLayer.Visible:=false;
                        self.SpinEdit1.MaxValue:=255;
                        self.SpinEdit1.MinValue:=1;
                   end;
     result:=showmodal;
end;
procedure TColorSelectWND.PalettePainter(canvas:Tcanvas; StartIndex,IncIndex,startx,starty,dx,dy,cx,cy:integer);
var
  x,y,xcoord,ycoord,cindex:integer;
begin
     if dy<0 then
                 dy:=dy;
     canvas.Pen.Width:=2;
     cindex:=StartIndex;
     for x:=0 to cx-1 do
     for y:=0 to cy-1 do
     begin
          if cindex=ColorInfex then
                                   begin
                                   canvas.Pen.Color:=clDefault;
                                   end
                               else
                                   begin
                                   canvas.Pen.Color:={clBackground}clBtnFace;
                                   end;
          xcoord:=startx+x*dx;
          ycoord:=starty+y*dy;
          canvas.Brush.Color:=RGBToColor(palette[cindex].r,palette[cindex].g,palette[cindex].b);
          canvas.Rectangle(xcoord+1,ycoord+1*sign(dy),xcoord+dx-1,ycoord+dy-1*sign(dy));
          cindex:=cindex+incindex;
     end;
end;

procedure TColorSelectWND.OddPalettePaint(Sender: TObject);
begin
     PalettePainter(TPaintBox(sender).Canvas,11,2,OddGeometry.startx,OddGeometry.starty,OddGeometry.dx,OddGeometry.dy,24,5);
end;

procedure TColorSelectWND.resize(Sender: TObject);
var
  h,hone:integer;
const
  hempty=10;
begin
     h:=SpinEdit1.Top-hempty*3;
     hone:=h div 14;

     oddpalette.height:=5*hone;

     evenpalette.height:=5*hone;
     evenpalette.top:=oddpalette.Top+evenpalette.height+hempty;

     mainpalette.height:=2*hone;
     mainpalette.top:=evenpalette.Top+evenpalette.height+hempty;

     graypalette.height:=2*hone;
     graypalette.top:=mainpalette.Top+mainpalette.height+hempty;

     //oddpalette.Height:=SpinEdit1.Top div 2;

     EvenGeometry.dx:=evenpalette.ClientWidth div 24;
     EvenGeometry.dy:=hone;
     EvenGeometry.startx:=0;
     EvenGeometry.starty:=0;

     oddGeometry.dx:=oddpalette.ClientWidth div 24;
     oddGeometry.dy:=-hone;
     oddGeometry.startx:=0;
     oddGeometry.starty:=-oddGeometry.dy*5;

     MainGeometry.dx:=2*EvenGeometry.dx;
     MainGeometry.dy:=2*hone;
     MainGeometry.startx:=0;
     MainGeometry.starty:=0;
     mainpalette.width:=MainGeometry.dx*9;
     mainpalette.Height:=MainGeometry.dy*2;

     GrayGeometry.dx:=2*EvenGeometry.dx;
     GrayGeometry.dy:=2*hone;
     GrayGeometry.startx:=0;
     GrayGeometry.starty:=0;
     graypalette.width:=GrayGeometry.dx*6;
     graypalette.Height:=grayGeometry.dy*2;

     caption:=inttostr(clientwidth)+' '+inttostr(clientheight);
end;

procedure TColorSelectWND.EvenPalettePaint(Sender: TObject);
begin
     PalettePainter(TPaintBox(sender).Canvas,10,2,EvenGeometry.startx,EvenGeometry.starty,EvenGeometry.dx,EvenGeometry.dy,24,5);
end;

procedure TColorSelectWND.GrayGeometryPaint(Sender: TObject);
begin
     PalettePainter(TPaintBox(sender).Canvas,250,1,GrayGeometry.startx,GrayGeometry.starty,GrayGeometry.dx,GrayGeometry.dy,6,1);
end;

procedure TColorSelectWND.MainPalettePaint(Sender: TObject);
begin
     PalettePainter(TPaintBox(sender).Canvas,1,1,MainGeometry.startx,MainGeometry.starty,MainGeometry.dx,MainGeometry.dy,9,1);
end;
function getImdexByXY(x,y,StartIndex,IncIndex,cx,cy:integer; Geom:ColorGeometry):integer;
begin
     if geom.dy<0 then
                      y:=geom.starty-y;
     result:=StartIndex+IncIndex*cy*(x div Geom.dx);
     result:=result+IncIndex*(y div abs(Geom.dy));
end;

procedure TColorSelectWND.OddMDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     SpinEdit1.Value:=getImdexByXY(x,y,11,2,24,5,oddGeometry);
     //testsetcolor(nil);
end;
procedure TColorSelectWND.EvenMDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     SpinEdit1.Value:=getImdexByXY(x,y,10,2,24,5,evenGeometry);
end;

procedure TColorSelectWND.ByBlockCLC(Sender: TObject);
begin
     SpinEdit1.Value:=0
end;

procedure TColorSelectWND.ByLayerCLC(Sender: TObject);
begin
     SpinEdit1.Value:=256
end;

procedure TColorSelectWND.mainMdown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     SpinEdit1.Value:=getImdexByXY(x,y,1,1,9,1,mainGeometry);
end;

procedure TColorSelectWND.grayMDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     SpinEdit1.Value:=getImdexByXY(x,y,250,1,6,1,grayGeometry);
end;

procedure TColorSelectWND._onshow(Sender: TObject);
begin
     testsetcolor(nil);
end;

end.

