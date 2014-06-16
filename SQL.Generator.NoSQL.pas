(*
* Copyright (c) 2012, Linas Naginionis
* Contacts: lnaginionis@gmail.com or support@soundvibe.net
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
unit SQL.Generator.NoSQL;

interface

uses
  SQL.AbstractSQLGenerator, SQL.Commands, SQL.Types, Generics.Collections, Mapping.Attributes
  , SQL.Interfaces, SvSerializer;

type
  {$REGION 'Documentation'}
  ///	<summary>
  ///	  Represents base <b>NoSQL</b> database statements generator.
  ///	</summary>
  {$ENDREGION}
  TNoSQLGenerator = class(TAbstractSQLGenerator)
  private
    class var FSerializerFormat: TSvSerializeFormat;
  protected
    class constructor Create;

    function GetExpressionFromWhereField(AField: TSQLWhereField): string; virtual;
    function ResolveFieldAndExpression(const AFieldname: string; out AField: string; out AExpression: string; const ADelta: Integer = 1): Boolean;
    function GetPrefix(ATable: TSQLTable): string; virtual;
    function GetOrderType(AOrderType: TOrderType): string; virtual;
    function WrapResult(const AResult: string): string; virtual;
  public
    function GetQueryLanguage(): TQueryLanguage; override;
    function GenerateSelect(ASelectCommand: TSelectCommand): string; override;
    function GenerateInsert(AInsertCommand: TInsertCommand): string; override;
    function GenerateUpdate(AUpdateCommand: TUpdateCommand): string; override;
    function GenerateDelete(ADeleteCommand: TDeleteCommand): string; override;
    function GenerateCreateTable(ACreateTableCommand: TCreateTableCommand): TList<string>; override;
    function GenerateCreateFK(ACreateFKCommand: TCreateFKCommand): TList<string>; override;
    function GenerateCreateSequence(ASequence: TCreateSequenceCommand): string; override;
    function GenerateGetNextSequenceValue(ASequence: SequenceAttribute): string; override;
    function GenerateGetLastInsertId(AIdentityColumn: ColumnAttribute): string; override;
    function GeneratePagedQuery(const ASql: string; const ALimit, AOffset: Integer): string; override;
    function GenerateGetQueryCount(const ASql: string): string; override;
    function GetSQLTableCount(const ATablename: string): string; override;
    function GetSQLSequenceCount(const ASequenceName: string): string; override;
    function GetTableColumns(const ATableName: string): string; override;
    function GetSQLDataTypeName(AField: TSQLCreateField): string; override;
    function GetSQLTableExists(const ATablename: string): string; override;
    function GetEscapeFieldnameChar(): Char; override;

    class property SerializerFormat: TSvSerializeFormat read FSerializerFormat write FSerializerFormat;
  end;

implementation

uses
  Core.Exceptions
  ,Core.Utils
  ,SvSerializerSuperJson
  ,SysUtils
  ,StrUtils
  ,Math
  ;

const
  PARAM_ID = '#$';


{ TNoSQLGenerator }

class constructor TNoSQLGenerator.Create;
begin
  FSerializerFormat := sstSuperJson;
end;

function TNoSQLGenerator.GenerateCreateFK(ACreateFKCommand: TCreateFKCommand): TList<string>;
begin
  Result := TList<string>.Create;
end;

function TNoSQLGenerator.GenerateCreateSequence(ASequence: TCreateSequenceCommand): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GenerateCreateTable(ACreateTableCommand: TCreateTableCommand): TList<string>;
begin
  Result := TList<string>.Create;
end;

function TNoSQLGenerator.GenerateDelete(ADeleteCommand: TDeleteCommand): string;
begin
  Result := 'D' + GetPrefix(ADeleteCommand.Table) +'{"_id": '+ PARAM_ID + '}';
end;

function TNoSQLGenerator.GenerateGetLastInsertId(AIdentityColumn: ColumnAttribute): string;
begin
  Result := ' ';
end;

function TNoSQLGenerator.GenerateGetNextSequenceValue(ASequence: SequenceAttribute): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GenerateGetQueryCount(const ASql: string): string;
begin
  Result := 'count' + Copy(ASql, 2, Length(ASql));
end;

function TNoSQLGenerator.GenerateInsert(AInsertCommand: TInsertCommand): string;
begin
  if (AInsertCommand.Entity = nil) then
    Exit('');
  TSvSerializer.SerializeObject(AInsertCommand.Entity, Result, FSerializerFormat);
  Result := 'I' + GetPrefix(AInsertCommand.Table) + Result;
end;

function TNoSQLGenerator.GeneratePagedQuery(const ASql: string; const ALimit, AOffset: Integer): string;
begin
  Result := Format('page%d_%d_%s', [ALimit, AOffset, Copy(ASql, 2, Length(ASql))]);
end;

function TNoSQLGenerator.GenerateSelect(ASelectCommand: TSelectCommand): string;
var
  LField, LPrevField: TSQLWhereField;
  i: Integer;
  LStmtType: string;
begin
  Result := '';
  LStmtType := 'S';
  for i := 0 to ASelectCommand.WhereFields.Count - 1 do
  begin
    LField := ASelectCommand.WhereFields[i];
    LPrevField := ASelectCommand.WhereFields[Max(0, i - 1)];

    if not (LPrevField.WhereOperator in StartOperators) and not (LField.WhereOperator in EndOperators)  then
    begin
      if i <> 0 then
        Result := Result + ',';
    end;

    Result := Result + GetExpressionFromWhereField(LField);
  end;

  for i := 0 to ASelectCommand.OrderByFields.Count - 1 do
  begin
    if i<>0 then
      LStmtType := LStmtType + ','
    else
    begin
      LStmtType := 'SO';
    end;

    LStmtType := LStmtType + '{' + AnsiQuotedStr(ASelectCommand.OrderByFields[i].Fieldname, '"') + ': ' +
      GetOrderType(ASelectCommand.OrderByFields[i].OrderType) + '}';
  end;
  if Length(LStmtType) > 1 then
  begin
    Insert(IntToStr(Length(LStmtType)-2) + '_', LStmtType, 3); //insert length
  end;

  Result := WrapResult(Result);
  Result := LStmtType + GetPrefix(ASelectCommand.Table) + Result;
end;

function TNoSQLGenerator.GenerateUpdate(AUpdateCommand: TUpdateCommand): string;
begin
  if (AUpdateCommand.Entity = nil) then
    Exit('');
  TSvSerializer.SerializeObject(AUpdateCommand.Entity, Result, FSerializerFormat);
  Result := 'U' + GetPrefix(AUpdateCommand.Table) + Result;
end;

function TNoSQLGenerator.GetEscapeFieldnameChar: Char;
begin
  Result := '"';
end;

const
  WhereOpNames: array[TWhereOperator] of string = (
    {woEqual =} '=', {woNotEqual =} '$ne', {woMore = }'$gt', {woLess = }'$lt', {woLike = }'$regex', {woNotLike = }'NOT LIKE',
    {woMoreOrEqual = }'$gte', {woLessOrEqual = }'$lte', {woIn = }'$in', {woNotIn = }'$nin', {woIsNull} '', {woIsNotNull} ''
    ,{woOr}'$or', {woOrEnd}'', {woAnd} '$and', {woAndEnd}'', {woNot}'$not', {woNotEnd}'',{woBetween}'BETWEEN', {woJunction} ''
    );

function TNoSQLGenerator.GetExpressionFromWhereField(AField: TSQLWhereField): string;
var
  LField, LExpression: string;
begin
  case AField.WhereOperator of
    woEqual: Result := '{' + AnsiQuotedStr(AField.Fieldname, '"') + ' : ' + PARAM_ID + '}';
    woNotEqual, woMoreOrEqual, woMore, woLess, woLessOrEqual :
      Result := Format('{%S: { %S: %S}}', [AnsiQuotedStr(AField.Fieldname, '"'), WhereOpNames[AField.WhereOperator], PARAM_ID]);
    woIsNotNull: Result := Format('{%S: { $ne: null }}', [AnsiQuotedStr(AField.Fieldname, '"')]);
    woIsNull: Result := Format('{%S: null}', [AnsiQuotedStr(AField.Fieldname, '"')]);
    woBetween: Result := Format('{$and: [ { %0:S: { $gte: %1:S} }, { %0:S: { $lte: %1:S} } ] }'
      , [AnsiQuotedStr(AField.Fieldname, '"'), PARAM_ID]);
    woOr, woAnd:
    begin
        Result := Format('{%S: [', [WhereOpNames[AField.WhereOperator]]);
    end;
    woOrEnd, woAndEnd: Result := ']}';
    woIn, woNotIn:
    begin
      Result := AField.Fieldname;
       if ResolveFieldAndExpression(AField.Fieldname, LField, LExpression) then
         Result := Format('{%S: { %S: [%S] } }', [AnsiQuotedStr(LField, '"'), WhereOpNames[AField.WhereOperator], LExpression]);
    end;
  end;
end;

function TNoSQLGenerator.GetOrderType(AOrderType: TOrderType): string;
begin
  Result := '1';
  case AOrderType of
    otAscending: Result := '1';
    otDescending: Result := '-1';
  end;
end;

function TNoSQLGenerator.GetPrefix(ATable: TSQLTable): string;
begin
  Result := '[' + ATable.Name + ']';
end;

function TNoSQLGenerator.GetQueryLanguage: TQueryLanguage;
begin
  Result := qlNoSQL;
end;

function TNoSQLGenerator.GetSQLDataTypeName(AField: TSQLCreateField): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetSQLSequenceCount(const ASequenceName: string): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetSQLTableCount(const ATablename: string): string;
begin
  Result := 'count' + '[' + ATablename + ']';
end;

function TNoSQLGenerator.GetSQLTableExists(const ATablename: string): string;
begin
  Result := '';
end;

function TNoSQLGenerator.GetTableColumns(const ATableName: string): string;
begin
  Result := '';
end;

function TNoSQLGenerator.ResolveFieldAndExpression(const AFieldname: string;
  out AField, AExpression: string; const ADelta: Integer): Boolean;
var
  LPos, LPos2: Integer;
begin
  //Field NOT IN (1,2,3)
  LPos := PosEx(' ', AFieldname);
  AField := Copy(AFieldname, 1, LPos - 1);
  LPos := PosEx(' ', AFieldname, LPos + 1);
  LPos2 := PosEx(' ', AFieldname, LPos + 1);
  if LPos2 > 0 then
    LPos := LPos2;

  AExpression := Copy(AFieldname, LPos + 1 + ADelta, Length(AFieldname) - LPos - 1 - ADelta);
  Result := True;
end;

function TNoSQLGenerator.WrapResult(const AResult: string): string;
begin
  Result := AResult;
  if Length(Result) = 0 then
    Result := '{}'
  else
  begin
    if not StartsStr('{', Result) then
    begin
      Result := '{' + Result + '}';
    end;
  end;
end;

end.
