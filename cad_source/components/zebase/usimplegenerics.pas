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
{$MODE OBJFPC}
unit usimplegenerics;
{$INCLUDE def.inc}

interface
uses strproc,LCLVersion,gdbase,gdbasetypes,
     sysutils,
     gutil,gmap,ghashmap,gvector;
type
{$IFNDEF DELPHI}
{$if LCL_FULLVERSION<1030000}//dumb check for old 2.7.1 fpc releases with problem in generic inheritance
  {$DEFINE OldIteratorDef}
{$ENDIF}
{$IF FPC_FULlVERSION<20701}
  {$DEFINE OldIteratorDef}  //check for 2.6.x fpc, coment this, or uncoment - generic inheritance not working
{$ENDIF}
//{$if LCL_FULLVERSION>=1030000}{$ENDIF}
LessPointer=specialize TLess<pointer>;
LessGDBString=specialize TLess<GDBString>;
LessDWGHandle=specialize TLess<TDWGHandle>;
LessObjID=specialize TLess<TObjID>;
LessInteger=specialize TLess<Integer>;

generic TMyMap <TKey, TValue, TCompare> = class(specialize TMap<TKey, TValue, TCompare>)
  function MyGetValue(key:TKey):TValue;inline;
  procedure MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);inline;
end;
generic TMyMapCounter <TKey, TCompare> = class(specialize TMyMap<TKey, SizeUInt, TCompare>)
  procedure CountKey(const key:TKey; const InitialCounter:SizeUInt);inline;
end;
generic GKey2DataMap <TKey, TValue, TCompare> = class(specialize TMap<TKey, TValue, TCompare>)
        procedure RegisterKey(const key:TKey; const Value:TValue);
        function MyGetValue(key:TKey; out Value:TValue):boolean;
        function MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;
        function MyContans(key:TKey):boolean;
end;
generic TMyVector <T> = class(specialize TVector<T>)
end;

generic TMyVectorArray <T> = class
        type
        TVec=specialize TMyVector <T>;
        TArrayOfVec=specialize TMyVector <TVec>;
        var
        VArray:TArrayOfVec;
        CurrentArray:SizeInt;
        constructor create;
        destructor destroy;virtual;
        function AddArray:SizeInt;
        procedure SetCurrentArray(ai:SizeInt);
        procedure AddDataToCurrentArray(data:T);
end;

generic TMyHashMap <TKey, TValue, Thash> = class(specialize THashMap<TKey, TValue, Thash>)
  function MyGetValue(key:TKey; out Value:TValue):boolean;
end;

GDBStringHash=class
  class function hash(s:GDBstring; n:longint):SizeUInt;
end;
generic TMyGDBStringDictionary <TValue> = class(specialize TMyHashMap<GDBString, TValue, GDBStringHash>)
end;


TGDBString2GDBStringDictionary=specialize TMyGDBStringDictionary<GDBString>;

TMapPointerToHandle=specialize TMyMap<pointer,TDWGHandle, LessPointer>;

TMapHandleToHandle=specialize TMyMap<TDWGHandle,TDWGHandle, LessDWGHandle>;
TMapHandleToPointer=specialize TMyMap<TDWGHandle,pointer, LessDWGHandle>;

TMapBlockHandle_BlockNames=specialize TMap<TDWGHandle,string,LessDWGHandle>;

TEntUpgradeKey=record
                      EntityID:TObjID;
                      UprradeInfo:TEntUpgradeInfo;
               end;
LessEntUpgradeKey=class
  class function c(a,b:TEntUpgradeKey):boolean;inline;
end;

{$ENDIF}

implementation
{uses
    log;}
constructor TMyVectorArray.create;
begin
     VArray:=TArrayOfVec.create;
end;
destructor TMyVectorArray.destroy;
begin
     VArray.destroy;
end;
function TMyVectorArray.AddArray:SizeInt;
begin
     result:=VArray.size;
     VArray.PushBack(TVec.create);
end;
procedure TMyVectorArray.SetCurrentArray(ai:SizeInt);
begin
     CurrentArray:=ai;
end;
procedure TMyVectorArray.AddDataToCurrentArray(data:T);
begin
     (VArray[CurrentArray]){brackets for 2.6.x compiler version}.PushBack(data);
end;
function TMyHashMap.MyGetValue(key:TKey; out Value:TValue):boolean;
var i,h,bs:longint;
begin
  {$IF FPC_FULlVERSION<=20701}
  result:=contains(key);
  if result then value:=self.GetData(key);
  {$ELSE}
  h:=Thash.hash(key,FData.size);
  bs:=(FData[h]).size;
  for i:=0 to bs-1 do begin
    if (((FData[h])[i]).Key=key) then
                                     begin
                                          value:=((FData[h])[i]).Value;
                                          exit(true);
                                     end;
  end;
  exit(false);
  {$ENDIF}
end;
class function GDBStringHash.hash(s:GDBString; n:longint):SizeUInt;
begin
     result:=makehash(s) mod SizeUInt(n);
end;

class function LessEntUpgradeKey.c(a,b:TEntUpgradeKey):boolean;inline;
begin
  //c:=a<b;
  if a.UprradeInfo=b.UprradeInfo then
                                     exit(a.EntityID<b.EntityID)
  else result:=a.UprradeInfo<b.UprradeInfo;

end;
procedure GKey2DataMap.RegisterKey(const key:TKey; const Value:TValue);
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key,Value);
                       end
                   else
                       begin
                            Iterator.Value:=value;
                            Iterator.Destroy;
                       end;
end;
function GKey2DataMap.MyGetValue(key:TKey; out Value:TValue):boolean;
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=false
                   else
                       begin
                            Value:=Iterator.GetValue;
                            Iterator.Destroy;
                            result:=true;
                       end;
end;
function GKey2DataMap.MyGetMutableValue(key:TKey; out PValue:PTValue):boolean;
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=false
                   else
                       begin
                            PValue:=Iterator.MutableValue;
                            Iterator.Destroy;
                            result:=true;
                       end;
end;
function GKey2DataMap.MyContans(key:TKey):boolean;
var
   {$IF FPC_FULlVERSION<=20701}
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
   {$ELSE}
   Pair:TPair;
   Node: TMSet.PNode;
   {$ENDIF}
begin
  {$IF FPC_FULlVERSION<=20701}
  Iterator:=Find(key);
  if Iterator<>nil then
                           begin
                                result:=true;
                                Iterator.Destroy;
                           end
                       else
                           result:=false;
  {$ELSE}
  Pair.Key:=key;
  Node := FSet.NFind(Pair);
  Result := Node <> nil;
  {$ENDIF}
end;

function TMyMap.MyGetValue(key:TKey):TValue;
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       result:=TValue(0)
                   else
                       begin
                            result:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
procedure TMyMapCounter.CountKey(const key:TKey; const InitialCounter:SizeUInt);
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key, InitialCounter);
                       end
                   else
                       begin
                            Iterator.SetValue(Iterator.GetValue+1);
                            Iterator.Destroy;
                       end;
end;

procedure TMyMap.MyGetOrCreateValue(const key:TKey; var Value:TValue; out OutValue:TValue);
var
   {$IFDEF OldIteratorDef}
   TParent:specialize TMap<TKey, TValue, TCompare>;
   Iterator:TParent.TIterator;
   {$ELSE}
   Iterator:TIterator;
   {$ENDIF}
begin
  Iterator:=Find(key);
  if  Iterator=nil then
                       begin
                            Insert(Key, Value);
                            OutValue:=Value;
                            value:=value+1;
                            //inc(Value);
                       end
                   else
                       begin
                            OutValue:=Iterator.GetValue;
                            Iterator.Destroy;
                       end;
end;
begin
end.