{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2016 Spring4D Team                           }
{                                                                           }
{           http://www.spring4d.org                                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

{$I Spring.inc}
{$R-,Q-}

unit Spring.Data.ObjectDataSet.Abstract;

{$IFDEF DELPHIXE4_UP}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

interface

uses
  Classes,
  DB,
  Generics.Defaults,
  Spring.Collections,
  Spring.Data.ObjectDataSet.IndexList;

type
{$IFDEF NEXTGEN}
  TRecordBuffer = TRecBuf;
  PAnsiChar = MarshaledAString;
{$ENDIF !NEXTGEN}
{$IFNDEF DELPHIXE3_UP}
  TValueBuffer  = Pointer;
{$ENDIF}
  PVariantList = ^TVariantList;
  TVariantList = array[0..0] of OleVariant;
  PArrayRecInfo = ^TArrayRecInfo;

  TArrayRecInfo = record
    Index: Integer;
    BookmarkFlag: TBookmarkFlag;
  end;

  TAbstractObjectDataSet = class(TDataSet)
  private
    FRowBufSize: Integer;
    FFilterBuffer: TRecordBuffer;
    FOldValueBuffer: TRecordBuffer;
    FReadOnly: Boolean;
    FCurrent: Integer;
    FInternalOpen: Boolean;
    FModifiedFields: IList<TField>;
    FFieldsCache: IDictionary<string,TField>;
    FFilterCache: IDictionary<string, Variant>;
    FIndexList: TIndexList;
    FInsertIndex: Integer;
    {$IFDEF DELPHIXE3_UP}
    FReserved: Pointer;
    {$ENDIF}
    function GetIndex: Integer;
    procedure SetIndex(const Value: Integer);
  protected
    /// <summary>
    ///   Determines if filter is set filter text entered
    /// </summary>
    function IsFilterEntered: Boolean;

    /// <summary>
    ///   Determines if FilterIndexed fields are available
    /// </summary>
    function IsFiltered: Boolean;
    // Abstract methods
    procedure DoDeleteRecord(Index: Integer); virtual; abstract;
    procedure DoGetFieldValue(Field: TField; Index: Integer; var Value: Variant); virtual; abstract;
    procedure DoPostRecord(Index: Integer; Append: Boolean); virtual; abstract;
    function RecordConformsFilter: Boolean; virtual; abstract;
    procedure UpdateFilter; virtual; abstract;
    procedure RebuildPropertiesCache; virtual; abstract;

    // Basic overrides
    function GetCanModify: Boolean; override;
    function GetRecNo: Longint; override;
    function GetRecordCount: Integer; override;
    function GetFieldClass(FieldDef: TFieldDef): TFieldClass; override;
    procedure SetFiltered(Value: Boolean); override;

    procedure DoOnNewRecord; override;
    procedure InternalEdit; override;
    procedure SetRecNo(Value: Integer); override;
    procedure SetCurrent(AValue: Integer); virtual;
    procedure SetRecBufSize; virtual;
    procedure RebuildFieldCache;

    // Abstract overrides
    function AllocRecordBuffer: TRecordBuffer; {$IFNDEF NEXTGEN}override;{$ENDIF}
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); {$IFNDEF NEXTGEN}override;{$ENDIF}
    {$IFDEF NEXTGEN}
    function AllocRecBuf: TRecBuf; override;
    procedure FreeRecBuf(var Buffer: TRecBuf); override;
    {$ENDIF}
    {$IFDEF DELPHIXE4_UP}
    procedure GetBookmarkData(Buffer: TRecBuf; Data: TBookmark); override;
    {$ENDIF}
    {$IFNDEF NEXTGEN}
    {$IFDEF DELPHIXE3_UP}
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    {$ENDIF}
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    {$ENDIF}

    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode;
      DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure BindFields(Binding: Boolean); override;

    procedure InternalAddRecord(Buffer: {$IFDEF DELPHIXE3_UP}TRecordBuffer{$ELSE}Pointer{$ENDIF}; Append: Boolean); override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark(Bookmark: {$IFDEF DELPHIXE3_UP}TBookmark{$ELSE}Pointer{$ENDIF}); override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure InternalInsert; override;
    procedure DoBeforeInsert; override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalRefresh; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    function IsCursorOpen: Boolean; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;

    function InternalGetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; virtual;
    function FieldListCheckSum: NativeInt; virtual;
  protected
    property FilterCache: IDictionary<string, Variant> read FFilterCache write FFilterCache;
    {$IFDEF DELPHIXE3_UP}
    property Reserved: Pointer read FReserved write FReserved;
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    ///   Represents current cursor index in the dataset.
    /// </summary>
    property Current: Integer read FCurrent;

    /// <summary>
    ///   Represents the current index of the dataset.
    /// </summary>
    property Index: Integer read GetIndex write SetIndex;

    property IndexList: TIndexList read FIndexList;

    /// <summary>
    ///   Represents modified fields of the current record.
    /// </summary>
    property ModifiedFields: IList<TField> read FModifiedFields;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
  public
    function FindField(const FieldName: string): TField; reintroduce;

    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;

    procedure DataEvent(Event: TDataEvent; Info: {$IFDEF DELPHIXE2_UP}NativeInt{$ELSE}LongInt{$ENDIF}); override;

    function GetBlobFieldData(FieldNo: Integer; var Buffer: TBlobByteData): Integer; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
      const ResultFields: string): Variant; override;
    function GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean; virtual;
    function GetFieldData(Field: TField; {$IFDEF DELPHIXE4_UP}var{$ENDIF} Buffer: TValueBuffer): Boolean; override;
    function GetFieldData(Field: TField; {$IFDEF DELPHIXE4_UP}var{$ENDIF} Buffer: TValueBuffer; NativeFormat: Boolean): Boolean; override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean); override;
  published
    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterRefresh;
    property AfterScroll;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeRefresh;
    property BeforeScroll;

    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
  end;

resourcestring
  SUnsupportedFieldType = 'Unsupported field type (%s) in field %s';
  SIndexOutOfRange = 'Index out of range';
  SPropertyNotFound = 'Property ''%s'' not found';
  SColumnPropertiesNotSpecified = 'Type does not have column properties';

implementation

uses
{$IFNDEF DELPHIXE3_UP}
  Contnrs,
{$ELSE}
  Generics.Collections,
{$ENDIF}
  DBConsts,
  FmtBcd,
  Math,
  SysUtils,
  Variants,
  VarUtils,
  Spring,
  Spring.Data.ObjectDataSet.ActiveX,
  Spring.Data.ObjectDataSet.Blobs;

type
{$IF Defined(DELPHIXE3_UP) and not Defined(DELPHIXE8_UP)}
  TDBBitConverter = class
  private
    class procedure InternalFromMove<T>(const Value: T; var B: TArray<Byte>; Offset: Integer = 0); static; inline;
    class function InternalIntoMove<T>(const B: TArray<Byte>; Offset: Integer = 0): T; static; inline;
  public
    class procedure UnsafeFrom<T>(const Value: T; var B: TArray<Byte>; Offset: Integer = 0); static; inline;
    class function UnsafeInTo<T>(const B: TArray<Byte>; Offset: Integer = 0): T; static; inline;

    class procedure UnsafeFromVariant(const Value: Variant; var B: TArray<Byte>; Offset: Integer = 0); static; inline;
    class function UnsafeInToVariant(const B: TArray<Byte>; Offset: Integer = 0): Variant; static; inline;
  end;
{$IFEND}
  EAbstractObjectDataSetException = class(Exception);

function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  FieldCount: Integer;
  Fields: TObjectList{$IFDEF DELPHIXE3_UP}<TField>{$ENDIF};
  Fld: TField;
  Bookmark: TBookmark;

  function CompareField(var Field: TField; Value: Variant): Boolean;
  var
    S: string;
  begin
    if Field.DataType in [ftString, ftWideString] then
    begin
      if Value = Null then
        Result := Field.IsNull
      else
      begin
        S := Field.AsString;
        if loPartialKey in Options then
          Delete(S, Length(Value) + 1, MaxInt);
        if loCaseInsensitive in Options then
          Result := AnsiSameText(S, Value)
        else
          Result := AnsiSameStr(S, Value);
      end;
    end
    else
      Result := (Field.Value = Value);
  end;

  function CompareRecord: Boolean;
  var
    I: Integer;
  begin
    if FieldCount = 1 then
    begin
      Fld := TField(Fields.First);
      Result := CompareField(Fld, KeyValues)
    end
    else
    begin
      Result := True;
      for I := 0 to FieldCount - 1 do
      begin
        Fld := TField(Fields[I]);
        Result := Result and CompareField(Fld, KeyValues[I]);
      end;
    end;
  end;

begin
  Result := False;
  DataSet.CheckBrowseMode;
  if DataSet.IsEmpty then
    Exit;

  Fields := TObjectList{$IFDEF DELPHIXE3_UP}<TField>{$ENDIF}.Create(False);
  try
    DataSet.GetFieldList(Fields, KeyFields);
    FieldCount := Fields.Count;
    Result := CompareRecord;
    if Result then
      Exit;
    DataSet.DisableControls;
    try
      Bookmark := DataSet.Bookmark;
      try
        DataSet.First;
        while not DataSet.Eof do
        begin
          Result := CompareRecord;
          if Result then
            Break;
          DataSet.Next;
        end;
      finally
        if not Result and DataSet.BookmarkValid(TBookmark(Bookmark)) then
          DataSet.Bookmark := Bookmark;
      end;
    finally
      DataSet.EnableControls;
    end;
  finally
    Fields.Free;
  end;
end;

{$IF Defined(DELPHIXE3_UP) and not Defined(DELPHIXE8_UP)}
class procedure TDBBitConverter.InternalFromMove<T>(const Value: T;
  var B: TArray<Byte>; Offset: Integer);
begin
  Move(Value, B[Offset], SizeOf(T));
end;

class function TDBBitConverter.InternalIntoMove<T>(const B: TArray<Byte>;
  Offset: Integer): T;
begin
  Move(B[Offset], Result, SizeOf(T));
end;

class procedure TDBBitConverter.UnsafeFrom<T>(const Value: T;
  var B: TArray<Byte>; Offset: Integer);
type
  PT = ^T;
begin
  PT(@B[Offset])^ := Value;
end;

class function TDBBitConverter.UnsafeInTo<T>(const B: TArray<Byte>;
  Offset: Integer): T;
type
  PT = ^T;
begin
  Result := PT(@B[Offset])^;
end;

class procedure TDBBitConverter.UnsafeFromVariant(const Value: Variant;
  var B: TArray<Byte>; Offset: Integer);
begin
  InternalFromMove<Variant>(Value, B, Offset);
end;

class function TDBBitConverter.UnsafeInToVariant(const B: TArray<Byte>;
  Offset: Integer): Variant;
begin
  InternalIntoMove<Variant>(B, Offset);
end;
{$IFEND}


{$REGION 'TAbstractObjectDataSet'}

constructor TAbstractObjectDataSet.Create(AOwner: TComponent);
var
  LCaseInsensitiveComparer: IEqualityComparer<string>;
begin
  inherited Create(AOwner);
  FInternalOpen := False;
  FReadOnly := False;
  FModifiedFields := TCollections.CreateList<TField>;
  FIndexList := TIndexList.Create;

  LCaseInsensitiveComparer := TStringComparer.OrdinalIgnoreCase;
  FFieldsCache := TCollections.CreateDictionary<string,TField>(500, LCaseInsensitiveComparer);
  FFilterCache := TCollections.CreateDictionary<string,Variant>(500, LCaseInsensitiveComparer);
end;

destructor TAbstractObjectDataSet.Destroy;
begin
  FIndexList.Free;
  inherited Destroy;
end;

function TAbstractObjectDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  if not (csDestroying in ComponentState) then
  begin
    Pointer(Result) := AllocMem(FRowBufSize);
    Initialize(PVariantList(Result + SizeOf(TArrayRecInfo))^, Fields.Count);
  end
  else
    Pointer(Result) := nil;
end;

{$IFDEF NEXTGEN}
function TAbstractObjectDataSet.AllocRecBuf: TRecBuf;
begin
  Result := AllocRecordBuffer;
end;
{$ENDIF}

procedure TAbstractObjectDataSet.BindFields(Binding: Boolean);
begin
  inherited BindFields(Binding);
  RebuildFieldCache;
end;

function TAbstractObjectDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  Result := Assigned(Bookmark) and Assigned(PObject(Bookmark)^)
    and IndexList.ContainsModel(PObject(Bookmark)^);
end;

function TAbstractObjectDataSet.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
const
  RetCodes: array[Boolean, Boolean] of ShortInt = ((2, -1), (1, 0));
begin
  Result := RetCodes[Bookmark1 = nil, Bookmark2 = nil];
  if Result = 2 then
    if PNativeUInt(Bookmark1)^ < PNativeUInt(Bookmark2)^ then
      Result := -1
    else if PNativeUInt(Bookmark1)^ > PNativeUInt(Bookmark2)^ then
      Result := 1
    else
      Result := 0;
end;

function TAbstractObjectDataSet.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TODBlobStream.Create(Field as TBlobField, Mode);
end;

procedure TAbstractObjectDataSet.DataEvent(Event: TDataEvent;
  Info: {$IFDEF DELPHIXE2_UP}NativeInt{$ELSE}LongInt{$ENDIF});
begin
  case Event of
    deLayoutChange:
      if Active then
        if Assigned(Reserved) and (FieldListCheckSum <> NativeInt(Reserved)) then
          Reserved := nil;
  end;
  inherited;
end;

procedure TAbstractObjectDataSet.DoBeforeInsert;
begin
  FInsertIndex := Max(RecNo - 1, 0);
  inherited;
end;

procedure TAbstractObjectDataSet.DoOnNewRecord;
begin
  FModifiedFields.Clear;

  if Pointer(FOldValueBuffer) = nil then
    FOldValueBuffer := AllocRecordBuffer
  else
    Finalize(PVariantList(FOldValueBuffer + SizeOf(TArrayRecInfo))^, Fields.Count);

  InitRecord({$IFDEF DELPHIXE4_UP}NativeInt(FOldValueBuffer){$ELSE}FOldValueBuffer{$ENDIF});
  inherited DoOnNewRecord;
end;

function TAbstractObjectDataSet.FieldListCheckSum: NativeInt;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Fields.Count - 1 do
    Result := Result + (NativeInt(Fields[I]) shr (I mod 16));
end;

function TAbstractObjectDataSet.FindField(const FieldName: string): TField;
begin
  if not FFieldsCache.TryGetValue(FieldName, Result) then
    Result := nil;
end;

procedure TAbstractObjectDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  Finalize(PVariantList(Buffer + SizeOf(TArrayRecInfo))^, Fields.Count);
  FreeMem(Pointer(Buffer));
end;

{$IFDEF NEXTGEN}
procedure TAbstractObjectDataSet.FreeRecBuf(var Buffer: TRecBuf);
begin
  FreeRecordBuffer(Buffer);
end;
{$ENDIF}

function TAbstractObjectDataSet.GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
begin
  Pointer(RecBuf) := nil;
  case State of
    dsBlockRead, dsBrowse:
      if IsEmpty then
        Pointer(RecBuf) := nil
      else
        Pointer(RecBuf) := Pointer(ActiveBuffer);
    dsNewValue, dsInsert, dsEdit:
      Pointer(RecBuf) := Pointer(ActiveBuffer);
    dsCalcFields, dsInternalCalc:
      Pointer(RecBuf) := Pointer(CalcBuffer);
    dsFilter:
      Pointer(RecBuf) := Pointer(FFilterBuffer);
  end;
  Result := Pointer(RecBuf) <> nil;
end;

function TAbstractObjectDataSet.GetBlobFieldData(FieldNo: Integer;
  var Buffer: TBlobByteData): Integer;
begin
  Result := inherited GetBlobFieldData(FieldNo, Buffer);
end;

{$IFDEF DELPHIXE4_UP}
procedure TAbstractObjectDataSet.GetBookmarkData(Buffer: TRecBuf; Data: TBookmark);
begin
  PObject(Data)^ := IndexList.GetModel(PArrayRecInfo(Buffer).Index);
end;
{$ENDIF}

{$IFNDEF NEXTGEN}
{$IFDEF DELPHIXE3_UP}
procedure TAbstractObjectDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark);
begin
  PObject(Data)^ := IndexList.GetModel(PArrayRecInfo(Buffer).Index);
end;
{$ENDIF}

procedure TAbstractObjectDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  PObject(Data)^ := IndexList.GetModel(PArrayRecInfo(Buffer).Index);
end;
{$ENDIF}

function TAbstractObjectDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := PArrayRecInfo(Buffer).BookmarkFlag;
end;

function TAbstractObjectDataSet.GetCanModify: Boolean;
begin
  Result := not FReadOnly;
end;

function TAbstractObjectDataSet.GetFieldClass(FieldDef: TFieldDef): TFieldClass;
begin
  Result := inherited GetFieldClass(FieldDef);
end;

function TAbstractObjectDataSet.GetFieldData(Field: TField;
  {$IFDEF DELPHIXE4_UP}var{$ENDIF} Buffer: TValueBuffer;
  NativeFormat: Boolean): Boolean;
var
  LRecBuf: TRecordBuffer;
  Data: Variant;

  {$IFDEF DELPHIXE3_UP}
  procedure CurrToBuffer(const C: Currency);
  var
    LBuff: TValueBuffer;
  begin
    if NativeFormat then
    begin
      SetLength(LBuff, SizeOf(Currency));
      TDBBitConverter.UnsafeFrom<Currency>(C, LBuff);
      DataConvert(Field, LBuff, Buffer, True)
    end
    else
      TDBBitConverter.UnsafeFrom<Currency>(C, Buffer);
  end;
  {$ELSE}
  procedure CurrToBuffer(const C: Currency);
  begin
    if NativeFormat then
      DataConvert(Field, @C, Buffer, True)
    else
      Currency(Buffer^) := C;
  end;
  {$ENDIF}

  {$IFDEF DELPHIXE3_UP}
  procedure VarToBuffer;
  var
    TempBuff: TValueBuffer;
    PData: Pointer;
  begin
    case Field.DataType of
      ftGuid, ftFixedChar, ftString:
      begin
        PAnsiChar(Buffer)[Field.Size] := #0;
        TempBuff := TEncoding.Default.GetBytes(string(tagVariant(Data).bStrVal));
        Move(TempBuff[0], Buffer[0], Length(TempBuff));
      end;
      ftFixedWideChar, ftWideString:
      begin
        TempBuff := TEncoding.Unicode.GetBytes(tagVariant(Data).bstrVal);
        SetLength(TempBuff, Length(TempBuff) + SizeOf(Char));
        TempBuff[Length(TempBuff) - 2] := 0;
        TempBuff[Length(TempBuff) - 1] := 0;
        Move(TempBuff[0], Buffer[0], Length(TempBuff));
      end;
      ftSmallint:
        if tagVariant(Data).vt = VT_UI1 then
          TDBBitConverter.UnsafeFrom<SmallInt>(Byte(tagVariant(Data).cVal), Buffer)
        else
          TDBBitConverter.UnsafeFrom<SmallInt>(tagVariant(Data).iVal, Buffer);
      ftWord:
        if tagVariant(Data).vt = VT_UI1 then
          TDBBitConverter.UnsafeFrom<Word>(tagVariant(Data).bVal, Buffer)
        else
          TDBBitConverter.UnsafeFrom<Word>(tagVariant(Data).uiVal, Buffer);
      ftAutoInc, ftInteger:
        TDBBitConverter.UnsafeFrom<Integer>(Data, Buffer);
      ftFloat, ftCurrency:
        if tagVariant(Data).vt = VT_R8 then
          TDBBitConverter.UnsafeFrom<Double>(tagVariant(Data).dblVal, Buffer)
        else
          TDBBitConverter.UnsafeFrom<Double>(Data, Buffer);
      ftFMTBCD:
        TDBBitConverter.UnsafeFrom<TBcd>(VarToBcd(Data), Buffer);
      ftBCD:
        if tagVariant(Data).vt = VT_CY then
          CurrToBuffer(tagVariant(Data).cyVal)
        else
          CurrToBuffer(Data);
      ftBoolean:
        TDBBitConverter.UnsafeFrom<WordBool>(tagVariant(Data).vbool, Buffer);
      ftDate, ftTime, ftDateTime:
        if NativeFormat then
        begin
          SetLength(TempBuff, SizeOf(Double));
          TDBBitConverter.UnsafeFrom<Double>(data, TempBuff);
          DataConvert(Field, TempBuff, Buffer, True);
        end
        else
          TDBBitConverter.UnsafeFrom<Double>(tagVariant(Data).date, Buffer);
      ftBytes, ftVarBytes:
        if NativeFormat then
        begin
          PData := VarArrayLock(Data);
          try
            DataConvert(Field, BytesOf(PData, VarArrayHighBound(Data, 1) - VarArrayLowBound(Data, 1) + 1), Buffer, True);
          finally
            VarArrayUnlock(Data);
          end;
        end
        else
          TDBBitConverter.UnsafeFromVariant(Data, Buffer);
      ftInterface:
      begin
        TempBuff := BytesOf(@Data, SizeOf(IUnknown));
        Move(TempBuff[0], Buffer[0], SizeOf(IUnknown));
      end;
      ftIDispatch:
      begin
        TempBuff := BytesOf(@Data, SizeOf(IDispatch));
        Move(TempBuff[0], Buffer[0], SizeOf(IDispatch));
      end;
      ftLargeInt:
      begin
        if PDecimal(@Data).sign > 0 then
          TDBBitConverter.UnsafeFrom<Int64>(-1 * PDecimal(@Data).Lo64, Buffer)
        else
          TDBBitConverter.UnsafeFrom<Int64>(PDecimal(@Data).Lo64, Buffer);
      end;
      ftBlob..ftTypedBinary, ftVariant, ftWideMemo: TDBBitConverter.UnsafeFromVariant(Data, Buffer);
    else
      DatabaseErrorFmt(SUnsupportedFieldType, [FieldTypeNames[Field.DataType],
        Field.DisplayName]);
    end;
  end;
  {$ELSE}
  procedure VarToBuffer;
  var
    TempBuff: TArray<Byte>;
  begin
    case Field.DataType of
      ftGuid, ftFixedChar, ftString:
      begin
        PAnsiChar(Buffer)[Field.Size] := #0;
        TempBuff := TEncoding.Default.GetBytes(string(tagVariant(Data).bStrVal));
        Move(TempBuff[0], PByte(Buffer)[0], Length(TempBuff));
      end;
      ftFixedWideChar, ftWideString:
      begin
        TempBuff := TEncoding.Unicode.GetBytes(tagVariant(Data).bstrVal);
        SetLength(TempBuff, Length(TempBuff) + SizeOf(Char));
        TempBuff[Length(TempBuff) - 2] := 0;
        TempBuff[Length(TempBuff) - 1] := 0;
        Move(TempBuff[0], PByte(Buffer)[0], Length(TempBuff));
      end;
      ftSmallint:
        if tagVariant(Data).vt = VT_UI1 then
          SmallInt(Buffer^) := Byte(tagVariant(Data).cVal)
        else
          SmallInt(Buffer^) := tagVariant(Data).iVal;
      ftWord:
        if tagVariant(Data).vt = VT_UI1 then
          Word(Buffer^) := tagVariant(Data).bVal
        else
          Word(Buffer^) := tagVariant(Data).uiVal;
      ftAutoInc, ftInteger:
        Integer(Buffer^) := Data;
      ftFloat, ftCurrency:
        if tagVariant(Data).vt = VT_R8 then
          Double(Buffer^) := tagVariant(Data).dblVal
        else
          Double(Buffer^) := Data;
      ftFMTBCD:
        TBcd(Buffer^) := VarToBcd(Data);
      ftBCD:
        if tagVariant(Data).vt = VT_CY then
          CurrToBuffer(tagVariant(Data).cyVal)
        else
          CurrToBuffer(Data);
      ftBoolean:
      begin
        VarAsType(Data, VT_BOOL);
        WordBool(Buffer^) := tagVariant(Data).vbool;
      end;
      ftDate, ftTime, ftDateTime:
      begin
        VarAsType(Data, VT_DATE);
        if NativeFormat then
          DataConvert(Field, @date, Buffer, True)
        else
          TOleDate(Buffer^) := Data;
      end;
      ftBytes, ftVarBytes:
        if NativeFormat then
          DataConvert(Field, @Data, Buffer, True)
        else
          OleVariant(Buffer^) := Data;
      ftInterface:
        IUnknown(Buffer^) := Data;
      ftIDispatch:
        IDispatch(Buffer^) := Data;
      ftLargeInt:
        if Decimal(Data).sign > 0 then
          LargeInt(Buffer^) := -1 * Decimal(Data).Lo64
        else
          LargeInt(Buffer^) := Decimal(Data).Lo64;
      ftBlob .. ftTypedBinary, ftVariant, ftWideMemo:
        OleVariant(Buffer^) := Data;
    else
      DatabaseErrorFmt(SUnsupportedFieldType, [FieldTypeNames[Field.DataType],
        Field.DisplayName]);
    end;
  end;
  {$ENDIF}

  procedure RefreshBuffers;
  begin
    Reserved := Pointer(FieldListCheckSum);
    UpdateCursorPos;
    Resync([]);
  end;

  function DataToInt64: Int64;
  begin
    if PDecimal(@Data).sign > 0 then
      Result := -1 * PDecimal(@Data).Lo64
    else
      Result := PDecimal(@Data).Lo64;
  end;

begin
  if not Assigned(Reserved) then
    RefreshBuffers;

  Result := GetActiveRecBuf(LRecBuf);

  if not Result then
    Exit;

  Data := PVariantList(LRecBuf + SizeOf(TArrayRecInfo))[Field.Index];

  if VarIsEmpty(Data) then
  begin
    DoGetFieldValue(Field, PArrayRecInfo(LRecBuf).Index, Data);
    if VarIsEmpty(Data) then
      Data := Null;

    if VarType(Data) = varInt64 then
      PVariantList(LRecBuf + SizeOf(TArrayRecInfo))[Field.Index] := DataToInt64
    else
      PVariantList(LRecBuf + SizeOf(TArrayRecInfo))[Field.Index] := Data;
  end;

  Result := not VarIsNull(Data);
  if Result and (Buffer <> nil) then
    VarToBuffer;
end;

function TAbstractObjectDataSet.GetFieldData(Field: TField;
  {$IFDEF DELPHIXE4_UP}var{$ENDIF} Buffer: TValueBuffer): Boolean;
begin
  Result := GetFieldData(Field, Buffer, True);
end;

function TAbstractObjectDataSet.GetIndex: Integer;
var
  LRecBuf: TRecordBuffer;
begin
  Result := -1;
  CheckActive;
  if GetActiveRecBuf(LRecBuf) and (PArrayRecInfo(LRecBuf).BookmarkFlag = bfCurrent) then
    Result := PArrayRecInfo(LRecBuf).Index;
end;

function TAbstractObjectDataSet.GetRecNo: Longint;
var
  LRecBuf: TRecordBuffer;
begin
  CheckActive;
  Result := -1;
  if GetActiveRecBuf(LRecBuf) and (PArrayRecInfo(LRecBuf).BookmarkFlag = bfCurrent) then
    Result := PArrayRecInfo(LRecBuf).Index + 1;
end;

function TAbstractObjectDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
begin
  if Filtered then
    FFilterBuffer := Buffer;

  Result := InternalGetRecord(Buffer, GetMode, DoCheck);
end;

function TAbstractObjectDataSet.GetRecordCount: Integer;
begin
  Result := -1;
end;

function TAbstractObjectDataSet.GetRecordSize: Word;
begin
  Result := SizeOf(TArrayRecInfo);
end;


procedure TAbstractObjectDataSet.InternalAddRecord(
  Buffer: {$IFDEF DELPHIXE3_UP}TRecordBuffer{$ELSE}Pointer{$ENDIF}; Append: Boolean);
begin
  DoPostRecord(Current, Append);
end;

procedure TAbstractObjectDataSet.InternalClose;
begin
  FInternalOpen := False;
  BindFields(False);
  FieldDefs.Updated := False;
  if Pointer(FOldValueBuffer) <> nil then
  begin
    try
      Finalize(PVariantList(FOldValueBuffer + SizeOf(TArrayRecInfo))^, Fields.Count);
      FreeMem(Pointer(FOldValueBuffer));
    finally
      Pointer(FOldValueBuffer) := nil;
    end;
  end;
end;

procedure TAbstractObjectDataSet.InternalDelete;
var
  LRecBuf: TRecordBuffer;
begin
  if GetActiveRecBuf(LRecBuf) then
    DoDeleteRecord(PArrayRecInfo(LRecBuf).Index);
end;

procedure TAbstractObjectDataSet.InternalEdit;
begin
  FModifiedFields.Clear;

  if Pointer(FOldValueBuffer) = nil then
    FOldValueBuffer := AllocRecordBuffer
  else
    Finalize(PVariantList(FOldValueBuffer + SizeOf(TArrayRecInfo))^, Fields.Count);
end;

procedure TAbstractObjectDataSet.InternalFirst;
begin
  FCurrent := -1;
end;

function TAbstractObjectDataSet.InternalGetRecord(Buffer: TRecordBuffer;
  GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  LRecCount: Integer;
begin
  try
    LRecCount := IndexList.Count;
    Result := grOK;
    case GetMode of
      gmNext:
      begin
        if FCurrent < LRecCount then
          Inc(FCurrent);
        if FCurrent >= LRecCount then
          Result := grEOF;
      end;
      gmPrior:
      begin
        if FCurrent <=0 then
          FCurrent := -1
        else
          FCurrent := Min(FCurrent - 1, LRecCount - 1);

        if FCurrent < 0 then
          Result := grBOF;
      end;
      gmCurrent:
      begin
        if FCurrent < 0 then
          Result := grBOF
        else if FCurrent >= LRecCount then
        begin
          Result := grEOF;
          FCurrent := LRecCount;
        end;
      end;
    end;

    if Result = grOK then
    begin
      PArrayRecInfo(Buffer).Index := FCurrent;
      PArrayRecInfo(Buffer).BookmarkFlag := bfCurrent;

      Finalize(PVariantList(Buffer + SizeOf(TArrayRecInfo))^, Fields.Count);
      GetCalcFields({$IFDEF DELPHIXE4_UP}NativeInt(Buffer){$ELSE}Buffer{$ENDIF});
    end;
  except
    if DoCheck then
      raise ;
    Result := grError;
  end;
end;

procedure TAbstractObjectDataSet.InternalGotoBookmark(Bookmark: {$IFDEF DELPHIXE3_UP}TBookmark{$ELSE}Pointer{$ENDIF});
begin
  FCurrent := IndexList.IndexOfModel(PObject(Bookmark)^);
end;

procedure TAbstractObjectDataSet.InternalHandleException;
begin
  if Assigned(Classes.ApplicationHandleException) then
    Classes.ApplicationHandleException(Self);
end;

procedure TAbstractObjectDataSet.InternalInitFieldDefs;

  procedure InitFieldDefsFromFields(AFields: TFields; AFieldDefs: TFieldDefs);
  var
    I: Integer;
    LField: TField;
    LFieldDef: TFieldDef;
  begin
    for I := 0 to AFields.Count - 1 do
    begin
      LField := AFields[I];
      if AFieldDefs.IndexOf(LField.FieldName) = -1 then
      begin
        LFieldDef := AFieldDefs.AddFieldDef;
        LFieldDef.Name := LField.FieldName;
        LFieldDef.DataType := LField.DataType;
        LFieldDef.Size := LField.Size;
        if LField.Required then
          LFieldDef.Attributes := [faRequired];
        if LField.ReadOnly then
          LFieldDef.Attributes := LFieldDef.Attributes + [DB.faReadonly];
        if (LField.DataType = ftBCD) and (LField is TBCDField) then
          LFieldDef.Precision := TBCDField(LField).Precision;
        if LField is TObjectField then
          InitFieldDefsFromFields(TObjectField(LField).Fields, LFieldDef.ChildDefs);
      end;
    end;
  end;

begin
  FieldDefs.Clear;
  InitFieldDefsFromFields(Fields, FieldDefs);
end;

procedure TAbstractObjectDataSet.InternalInitRecord(Buffer: TRecordBuffer);
var
  I: Integer;
begin
  for I := 0 to Fields.Count - 1 do
    PVariantList(Buffer + SizeOf(TArrayRecInfo))[I] := Null;
end;

procedure TAbstractObjectDataSet.InternalInsert;
begin
  inherited;
end;

procedure TAbstractObjectDataSet.InternalLast;
begin
  FCurrent := RecordCount;
end;

procedure TAbstractObjectDataSet.InternalOpen;
begin
  FInternalOpen := True;
  FCurrent := -1;

  BookmarkSize := SizeOf(Integer);

  FieldDefs.Updated := False;
  FieldDefs.Update;
 { Reserved := Pointer(FieldListCheckSum(Self));
  BindFields(True);
  SetRecBufSize; }
end;

procedure TAbstractObjectDataSet.InternalPost;
var
  LRecBuf: TRecordBuffer;
begin
  inherited InternalPost;
  UpdateCursorPos;
  GetActiveRecBuf(LRecBuf);

  case PArrayRecInfo(LRecBuf).BookmarkFlag of
    bfEOF: DoPostRecord(-1, True);
    bfInserted: DoPostRecord(FInsertIndex, False)
  else
    DoPostRecord(PArrayRecInfo(LRecBuf).Index, False)
  end;
end;

procedure TAbstractObjectDataSet.InternalRefresh;
begin
  FIndexList.Rebuild;
end;

procedure TAbstractObjectDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  if PArrayRecInfo(Buffer).BookmarkFlag in [bfCurrent, bfInserted] then
    FCurrent := PArrayRecInfo(Buffer).Index;
end;

function TAbstractObjectDataSet.IsCursorOpen: Boolean;
begin
  Result := FInternalOpen;
end;

function TAbstractObjectDataSet.IsFiltered: Boolean;
begin
  Result := Filtered;
end;

function TAbstractObjectDataSet.IsFilterEntered: Boolean;
begin
  Result := (Filtered) and (Trim(Filter) <> '');
end;

function TAbstractObjectDataSet.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
  if Result then
  begin
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  end;
end;

function TAbstractObjectDataSet.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: string): Variant;
begin
  Result := Null;
  if DataSetLocateThrough(Self, KeyFields, KeyValues, []) then
  begin
    Result := FieldValues[ResultFields];
  end;
end;

procedure TAbstractObjectDataSet.RebuildFieldCache;
var
  i: Integer;
begin
  FFieldsCache.Clear;
  for i := 0 to Fields.Count - 1 do
  begin
    Fields[i].DisplayLabel := FieldDefs[i].DisplayName;
    FFieldsCache.Add(Fields[i].FieldName, Fields[i]);
  end;
end;

procedure TAbstractObjectDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PArrayRecInfo(Buffer).BookmarkFlag := Value;
end;

procedure TAbstractObjectDataSet.SetCurrent(AValue: Integer);
begin
  FCurrent := AValue;
end;

procedure TAbstractObjectDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin
  SetFieldData(Field, Buffer, True);
end;

procedure TAbstractObjectDataSet.SetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean);

  procedure BcdToOleVariant(const Bcd: TBcd; var Data: OleVariant);
  var
    Temp: OleVariant;
  begin
    VarClear(Data);
    Temp := BcdToStr(Bcd);
    VarResultCheck(VariantChangeTypeEx(TVarData(Data), TVarData(Temp), VAR_LOCALE_USER_DEFAULT,
       0, VT_DECIMAL));
  end;

  {$IFDEF DELPHIXE3_UP}
  procedure BufferToVar(var Data: OleVariant);
  var
    LUnknown: IUnknown;
    LDispatch: IDispatch;
    TempBuff: TValueBuffer;
  begin
    case Field.DataType of
{$IFNDEF NEXTGEN}
      ftString, ftFixedChar, ftGuid:
        Data := AnsiString(PAnsiChar(Buffer));
{$ENDIF}
      ftWideString, ftFixedWideChar:
        Data := WideString(PWideChar(Buffer));
      ftAutoInc, ftInteger:
        Data := TDBBitConverter.UnsafeInto<LongInt>(Buffer);
      ftSmallInt:
        Data := TDBBitConverter.UnsafeInto<SmallInt>(Buffer);
      ftWord:
        Data := TDBBitConverter.UnsafeInto<Word>(Buffer);
      ftBoolean:
        Data := TDBBitConverter.UnsafeInto<WordBool>(Buffer);
      ftFloat, ftCurrency:
        Data := TDBBitConverter.UnsafeInto<Double>(Buffer);
      ftBlob, ftMemo, ftGraphic, ftVariant, ftWideMemo:
        Data := TDBBitConverter.UnsafeIntoVariant(Buffer);
      ftInterface:
      begin
        Move(Buffer[0], LUnknown, SizeOf(IUnknown));
        Data := LUnknown;
      end;
      ftIDispatch:
      begin
        Move(Buffer[0], LDispatch, SizeOf(IDispatch));
        Data := LDispatch;
      end;
      ftDate, ftTime, ftDateTime:
        if NativeFormat then
        begin
          SetLength(TempBuff, SizeOf(TVarData(Data).VDate));
          DataConvert(Field, Buffer, TempBuff, False);
          TVarData(Data).VDate := TDBBitConverter.UnsafeInto<Double>(TempBuff);
        end
        else
          Data := TDBBitConverter.UnsafeInto<Double>(Buffer);
      ftFMTBCD:
        BcdToOleVariant(TDBBitConverter.UnsafeInto<TBcd>(Buffer), Data);
      ftBCD:
        if NativeFormat then
        begin
          SetLength(TempBuff, SizeOf(TVarData(Data).VCurrency));
          DataConvert(Field, Buffer, TempBuff, False);
          TVarData(Data).VCurrency := TDBBitConverter.UnsafeInto<Currency>(TempBuff);
        end
        else
          Data := TDBBitConverter.UnsafeInto<Currency>(Buffer);
      ftBytes, ftVarBytes:
        if NativeFormat then
        begin
          TempBuff := BytesOf(@Data, SizeOf(Variant));
          DataConvert(Field, Buffer, TempBuff, False);
          Data := TDBBitConverter.UnsafeIntoVariant(TempBuff);
        end
        else
          Data := TDBBitConverter.UnsafeIntoVariant(Buffer);
      ftLargeInt:
        Data := TDBBitConverter.UnsafeInto<Int64>(Buffer);
      else
        DatabaseErrorFmt(SUnsupportedFieldType, [FieldTypeNames[Field.DataType],
          Field.DisplayName]);
    end;
  end;
  {$ELSE}
  procedure BufferToVar(var Data: OleVariant);
  begin
    case Field.DataType of
      ftString, ftFixedChar, ftGuid:
        Data := AnsiString(PAnsiChar(Buffer));
      ftWideString, ftFixedWideChar:
        Data := WideString(PWideChar(Buffer));
      ftAutoInc, ftInteger:
        Data := LongInt(Buffer^);
      ftSmallInt:
        Data := SmallInt(Buffer^);
      ftWord:
        Data := Word(Buffer^);
      ftBoolean:
        Data := WordBool(Buffer^);
      ftFloat, ftCurrency:
        Data := Double(Buffer^);
      ftBlob, ftMemo, ftGraphic, ftVariant, ftWideMemo:
        Data := Variant(Buffer^);
      ftInterface:
        Data := IUnknown(Buffer^);
      ftIDispatch:
        Data := IDispatch(Buffer^);
      ftDate, ftTime, ftDateTime:
        if NativeFormat then
          DataConvert(Field, Buffer, @TVarData(Data).VDate, False) else
          Data := TDateTime(Buffer^);
      ftFMTBCD:
        BcdToOleVariant(TBcd(Buffer^), Data);
      ftBCD:
        if NativeFormat then
          DataConvert(Field, Buffer, @TVarData(Data).VCurrency, False) else
          Data := Currency(Buffer^);
      ftBytes, ftVarBytes:
        if NativeFormat then
          DataConvert(Field, Buffer, @Data, False) else
          Data := OleVariant(Buffer^);
      ftLargeInt:
        Data := LargeInt(Buffer^);
      else
        DatabaseErrorFmt(SUnsupportedFieldType, [FieldTypeNames[Field.DataType],
          Field.DisplayName]);
    end;
  end;
  {$ENDIF}

var
  LData: OleVariant;
  LRecBuf: TRecordBuffer;
begin
  if not(State in dsWriteModes) then
    DatabaseError(SNotEditing, Self);

  GetActiveRecBuf(LRecBuf);

  if Buffer = nil then
    LData := Null
  else
    BufferToVar(LData);

  if Field.FieldNo > 0 then
  begin
    if ReadOnly and not(State in [dsSetKey, dsFilter]) then
      DatabaseErrorFmt(SFieldReadOnly, [Field.DisplayName]);

    Field.Validate(Buffer);

    if not FModifiedFields.Contains(Field) then
    begin
      PVariantList(FOldValueBuffer + SizeOf(TArrayRecInfo))[Field.Index] := Field.OldValue;
      FModifiedFields.Add(Field);
    end;
  end;

  PVariantList(LRecBuf + SizeOf(TArrayRecInfo))[Field.Index] := LData;

  if not (State in [dsCalcFields, dsInternalCalc, dsFilter, dsNewValue]) then
    DataEvent(deFieldChange, Longint(Field));
end;

procedure TAbstractObjectDataSet.SetFiltered(Value: Boolean);
begin
  if Filtered <> Value then
  begin
    if Active then
    begin
      CheckBrowseMode;
      inherited SetFiltered(Value);
      if Value then
      begin
        UpdateFilter;
        First;
      end
      else
      begin
        UpdateFilter;
        Resync([]);
        First;
      end;
    end
    else
    begin
      inherited SetFiltered(Value);
    end;
  end;
end;

procedure TAbstractObjectDataSet.SetIndex(const Value: Integer);
begin
  if (Value < 0) or (Value >= RecordCount) then
    raise EAbstractObjectDataSetException.Create(SIndexOutOfRange);

  FCurrent := Value;
end;

procedure TAbstractObjectDataSet.SetRecBufSize;
begin
  FRowBufSize := SizeOf(TArrayRecInfo) + (Fields.Count * SizeOf(Variant));
end;

procedure TAbstractObjectDataSet.SetRecNo(Value: Integer);
begin
  CheckBrowseMode;
  Value :=  Min(max(Value, 1), RecordCount);

  if RecNo <> Value then
  begin
    DoBeforeScroll;
    FCurrent := Value - 1;
    Resync([rmCenter]);
    DoAfterScroll;
  end;
end;

{$ENDREGION}


end.
