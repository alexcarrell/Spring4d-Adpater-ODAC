{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2017 Spring4D Team                           }
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

unit Spring.Persistence.Adapters.Oracle.ODAC;

interface

uses
  Spring.Persistence.Core.Base,
  Spring.Persistence.Adapters.ADO,
  Spring.Persistence.Core.Exceptions,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.SQL.Params,
  Ora,
  System.Variants;

type
  EODACAdapterException = class(EORMAdapterException);
(*
  /// <summary>
  ///   Represents Oracle resultset.
  /// </summary>
  TODACResultsetAdapter = class(TDriverAdapterBase, IDBResultSet)
    function IsEmpty: Boolean;
    function Next: Boolean;
    function FieldExists(const fieldName: string): Boolean;
    function GetFieldValue(index: Integer): Variant; overload;
    function GetFieldValue(const fieldname: string): Variant; overload;
    function GetFieldCount: Integer;
    function GetFieldName(index: Integer): string;
  end;
  /// <summary>
  ///   Represents Oracle statement.
  /// </summary>
  TODACStatementAdapter = class(TDriverStatementAdapter<TOraSQL>)
  public
    destructor Destroy; override;
    procedure SetSQLCommand(const commandText: string); override;
    procedure SetParam(const param: TDBParam); virtual;
    procedure SetParams(const params: IEnumerable<TDBParam>); override;
    function Execute: NativeUInt; override;
    function ExecuteQuery(serverSideCursor: Boolean = True): IDBResultSet; override;
  end;

  /// <summary>
  ///   Represents Oracle connection.
  /// </summary>
  TODACConnectionAdapter = class(TADOConnectionAdapter)
  public
    procedure AfterConstruction; override;
    function BeginTransaction: IDBTransaction; override;
    function CreateStatement: IDBStatement; override;
  end;

  /// <summary>
  ///   Represents Oracle transaction.
  /// </summary>
  TODACTransactionAdapter = class(TADOTransactionAdapter)
  public
    procedure Commit; override;
    procedure Rollback; override;
  end;
*)
implementation

uses

  Spring.Persistence.Core.ConnectionFactory,
  Spring.Persistence.Core.ResourceStrings,
  Spring.Persistence.SQL.Generators.Oracle,
  Spring.Persistence.SQL.Interfaces;
(*

{$REGION 'TODACConnectionAdapter'}

procedure TODACConnectionAdapter.AfterConstruction;
begin
  inherited;
  QueryLanguage := qlOracle;
end;

function TODACConnectionAdapter.BeginTransaction: IDBTransaction;
begin
  if Assigned(Connection) then
  try
    Connection.Connected := True;
    GenerateNewID;
    Connection.Execute(SQL_BEGIN_SAVEPOINT + GetTransactionName);

    Result := TODACTransactionAdapter.Create(Connection, ExceptionHandler);
    Result.TransactionName := GetTransactionName;
  except
    raise HandleException;
  end
  else
    Result := nil;
end;

function TODACConnectionAdapter.CreateStatement: IDBStatement;
var
  statement: TOraSQL;
  adapter: TODACStatementAdapter;
begin
  if Assigned(Connection) then
  begin
    statement := TOraSQL.Create(nil);
    statement.Connection := Connection;

    adapter := TODACStatementAdapter.Create(statement, ExceptionHandler);
    adapter.ExecutionListeners := ExecutionListeners;
    Result := adapter;
  end
  else
    Result := nil;
end;

{$ENDREGION}


{$REGION 'TODACStatementAdapter'}

destructor TODACStatementAdapter.Destroy;
begin

  inherited;
end;

function TODACStatementAdapter.Execute: NativeUInt;
begin

end;

function TODACStatementAdapter.ExecuteQuery(serverSideCursor: Boolean): IDBResultSet;
var
  dataSet: TOraSql;
begin
  inherited;
  dataSet := TOraSql.Create(nil);
//
  dataSet.StatementCache := true;
  dataSet.Connection := Statement.Connection;
  dataSet.Text := Statement.SQL.Text;
  dataSet.Params.AssignValues(Statement.Params);
  try
    dataSet.Execute;
    Result := TADOResultSetAdapter.Create(dataSet, ExceptionHandler);
  except
    on E: Exception do
    begin
      dataSet.Free;
      raise HandleException(Format(SCannotOpenQuery, [E.Message]));
    end;
  end;
end;

{$ENDREGION}


{$REGION 'TODACTransactionAdapter'}

procedure TODACTransactionAdapter.Commit;
begin
  if Assigned(Transaction) then
  try
    Transaction.Execute('COMMIT');
  except
    raise HandleException;
  end;
end;

procedure TODACTransactionAdapter.Rollback;
begin
  if Assigned(Transaction) then
  try
    Transaction.Execute(SQL_ROLLBACK_SAVEPOINT + TransactionName);
  except
    raise HandleException;
  end;
end;

{$ENDREGION}


procedure TODACStatementAdapter.SetParam(const param: TDBParam);
var
  paramName: string;
  parameter: TParameter;
begin
 paramName := param.GetNormalizedParamName;
 parameter := Statement.ParamByName(paramName);
 parameter.Value := param.ToVariant;
 if VarIsNull(parameter.Value) or VarIsEmpty(parameter.Value) then
    parameter.DataType := param.ParamType;
end;

procedure TODACStatementAdapter.SetParams(const params: IEnumerable<TDBParam>);
begin
  inherited;
  params.ForEach(SetParam);
end;

procedure TODACStatementAdapter.SetSQLCommand(const commandText: string);
begin
  inherited;
  Statement.Text := commandText;
end;

{ TODACResultsetAdapter }

function TODACResultsetAdapter.FieldExists(const fieldName: string): Boolean;
begin

end;

function TODACResultsetAdapter.GetFieldCount: Integer;
begin

end;

function TODACResultsetAdapter.GetFieldName(index: Integer): string;
begin

end;

function TODACResultsetAdapter.GetFieldValue(index: Integer): Variant;
begin

end;

function TODACResultsetAdapter.GetFieldValue(const fieldname: string): Variant;
begin

end;

function TODACResultsetAdapter.IsEmpty: Boolean;
begin

end;

function TODACResultsetAdapter.Next: Boolean;
begin

end;

initialization
  TConnectionFactory.RegisterConnection<TODACConnectionAdapter>(dTODAC);
*)
end.
