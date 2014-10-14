{***************************************************************************}
{                                                                           }
{           Spring Framework for Delphi                                     }
{                                                                           }
{           Copyright (c) 2009-2014 Spring4D Team                           }
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

unit Spring.Persistence.Core.Exceptions;

interface

uses
  SysUtils;

type
  EBaseORMException = class(Exception)
  protected
    function EntityToString(const entity: TObject): string; virtual;
  public
    constructor Create(const entity: TObject); reintroduce; overload;
  end;

  EEntityAlreadyPersisted = class(EBaseORMException);

  ECannotPersististEntityWithId = class(EBaseORMException);

  ETableNotSpecified = class(EBaseORMException);

  EORMMethodNotImplemented = class(Exception);

  EUnknownMember = class(Exception);

  EORMEnumException = class(Exception);

  EEntityManagerNotSet = class(Exception);

  EUnknownJoinType = class(Exception);

  EORMRecordNotFoundException = class(Exception);

  EORMUpdateNotSuccessfulException = class(EBaseORMException);

  EORMColumnCannotBeNull = class(EBaseORMException);

  EORMColumnNotFound = class(EBaseORMException);

  EORMContainerDoesNotHaveAddMethod = class(Exception);

  EORMContainerDoesNotHaveClearMethod = class(Exception);

  EORMContainerDoesNotHaveCountMethod = class(Exception);

  EORMContainerAddMustHaveOneParameter = class(Exception);

  EORMContainerItemTypeNotSupported = class(Exception);

  EORMUnsupportedType = class(Exception);

  EORMConnectionAlreadyRegistered = class(Exception);
  EORMConnectionNotRegistered = class(Exception);

  EORMManyToOneMappedByColumnNotFound = class(Exception);

  EORMTransactionNotStarted = class(Exception);

  EORMListInSession = class(Exception);

  EORMCannotConvertValue = class(Exception);

  EORMInvalidArguments = class(Exception);

  EORMOptimisticLockException = class(EBaseORMException);

  EORMCannotGenerateQueryStatement = class(EBaseORMException);

implementation

uses
  Spring,
  Spring.Collections,
  Spring.Persistence.Mapping.Attributes,
  Spring.Persistence.Mapping.RttiExplorer;


{$REGION 'EBaseORMException'}

constructor EBaseORMException.Create(const entity: TObject);
begin
  inherited Create(EntityToString(entity));
end;

function EBaseORMException.EntityToString(const entity: TObject): string;
var
  builder: TStringBuilder;
  columns: IList<ColumnAttribute>;
  column: ColumnAttribute;
  value: TValue;
begin
  if not Assigned(entity) then
    Exit('null');
  builder := TStringBuilder.Create;
  try
    builder.AppendFormat('ClassName: %s', [entity.ClassName]).AppendLine;
    columns := TRttiExplorer.GetColumns(entity.ClassType);
    for column in columns do
    begin
      value := TRttiExplorer.GetMemberValue(entity, column.ClassMemberName);
      builder.AppendFormat('[%s] : %s', [column.Name, value.ToString]).AppendLine;
    end;
    Result := builder.ToString;
  finally
    builder.Free;
  end;
end;

{$ENDREGION}


end.
