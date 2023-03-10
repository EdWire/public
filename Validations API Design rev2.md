# Validations API Design rev2

Rev1 can be found at https://techdocs.ed-fi.org/display/ESIG/Ed-Fi+Validation+API+Design+Rev1.

- [Schemas](#schemas)
  - [Rule](#rule)
  - [Run](#run)
  - [Result](#result)
- [Endpoints](#endpoints)
  - [/runs](#runs)
  - [/runs/:runId](#runsrunid)
  - [/runs/:runId/rules](#runsrunidrules)
  - [/runs/:runId/results](#runsrunidresults)
  - [/rules](#rules)
  - [/rules/:ruleId](#rulesruleid)
  - [/results](#results)
- [Order By](#order-by)
- [Filter](#filter)

# Schemas

> Data Types marked with `"?"` are optional

## Run

| Property         | Data Type  | Description                                                                                                              |
| ---------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------ |
| Id               | Guid       | The unique ID of this resource.                                                                                          |
| StartDateTime    | DateTime?  | The UTC time when the Run started.                                                                                       |
| EndDateTime      | DateTime?  | The UTC time when the Run ended.                                                                                         |
| Status           | StringEnum | The status of the Run. Examples are: "Queued", "Running", "Completed", "Cancelled", "Error" or other standardized value. |
| Host             | String?    | The name of the host or ODS that was evaluated in this Run.                                                              |
| ValidationEngine | String?    | A reference to the validation engine that was responsible for this Run.                                                  |

## Rule

| Property            | Data Type  | Description                                                                                                                                                                                    |
| ------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Id                  | Guid       | The unique ID of this resource.                                                                                                                                                                |
| RunId               | Guid       | The ID of the Run that created this Rule snapshot.                                                                                                                                             |
| Source              | String     | The source or origin of the Rule. This value would be set by the application or server.                                                                                                        |
| Name                | String     | The display name of the Rule.                                                                                                                                                                  |
| Description         | String?    | Non-structured text about the details used in the evaluation of the Rule.                                                                                                                      |
| ShortDescription    | String?    | A more brief version of the "Description" property.                                                                                                                                            |
| Resolution          | String?    | Information about how to resolve an issue related to the Rule. It could be a detailed explanation or a link to an external resource.                                                           |
| Status              | StringEnum | The current status of the Rule. Examples: "UnderAnalysis", "Active", "Inactive", "Deprecated", or other standardized value.                                                                    |
| Category            | String     | The category for the type of Rule. The value is a "/" separated list indicating the path to the Rule. Examples: "Students/Demographics", "Students/Attendance", "Education/Special Education". |
| Severity            | StringEnum | The level of severity of the Rule. Examples: "Warning", "MinorError", "MajorError" or other standardized value.                                                                                |
| ExternalRuleId      | String?    | Refers back to a unique identifier for this Rule in another system (such as a state-maintained repository of validation rules).                                                                |
| ValidationLogicType | StringEnum | Specifies the language that the validation logic is represented in. Examples are: "SQL", "Pseudo-code" or other standardized value.                                                            |
| ValidationLogic     | String     | The actual code that is used to find validation errors.                                                                                                                                        |
| Version             | String     | The version of this Rule.                                                                                                                                                                      |

## Result

| Property          | Data Type       | Description                                                                                                                                                                                                                                                                                                                                          |
| ----------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Id                | Guid            | The unique ID of this resource.                                                                                                                                                                                                                                                                                                                      |
| RunId             | Guid            | The ID of the Run that generated this result.                                                                                                                                                                                                                                                                                                        |
| RuleId            | Guid            | The ID of the Rule used by the validation Run. If a validation Rule caused multiple results (e.g. multiple students with the same condition) they would share this ID. This is part of the validation result signature.                                                                                                                              |
| ResourceId        | String          | The unique identifier in the ODS that is used to reference a specific resource. Examples are EducationOrganizationId, StudentUniqueId or StaffUniqueId . This is part of the validation result signature.                                                                                                                                            |
| ResourceType      | StringEnum      | The resource associated with the Rule. This is de-normalized from the Rule, every instance of a given RuleID will have the same Ed-Fi resource. Examples are "EducationOrganization", "Student" or "Staff".                                                                                                                                          |
| ResourceUrl       | String          | The URL where the resource can be located.                                                                                                                                                                                                                                                                                                           |
| Namespace         | String?         | Along with EducationOrganization, this can be used for limiting what systems can consume the validation results and routing the validation results within the consuming system. `IMPORTANT: Should this be in the response? Since it will most likely only be used by the server for security purposes (e.g. comparison with claims in auth token)`. |
| AdditionalContext | KeyValuePair[]? | Includes the details that were used in the evaluation of the validation Rule..                                                                                                                                                                                                                                                                       |

# Endpoints

> All of the endpoints are readonly, this is, only GET requests are supported.

## /runs

This resource will track the runs of the validation rules. The expectation is that this table would be populated before any validation results are produced with a status of "Running".

### Query Parameters:

| Parameter | Data Type | Description                                                                                  |
| --------- | --------- | -------------------------------------------------------------------------------------------- |
| pageIndex | Integer   | The index of the pagination. The value must be greater than or equal to 0. It defaults to 0. |
| pageSize  | Integer   | The size of the pagination. The value must be between 10 and 1000. It defaults to 100.       |
| orderBy   | String    | The sorting to apply to the query. More information in the [OrderBy](#order-by) section.     |
| filter    | String    | A filter to apply to the query. More information in the [Filter](#filter) section.           |

### Response Schema:

| Property  | Data Type     | Description                              |
| --------- | ------------- | ---------------------------------------- |
| pageIndex | Integer       | The page index of the paginated results. |
| pageSize  | Integer       | The page size of the paginated results.  |
| count     | Long          | The total count of the resources.        |
| data      | [Run[]](#run) | The results of the query.                |

### Example Response:

```json
{
  "pageIndex": 0,
  "pageSize": 100,
  "count": 1,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "startDateTime": "2023-03-29T14:05:00.000+00:00",
      "endDateTime": "2023-03-29T14:06:42.000+00:00",
      "status": "Completed",
      "host": "EdFi_Ods_Populated_Template_Test",
      "validationEngine": "Application Name"
    }
  ]
}
```

## /runs/:runId

The details of a Run.

### Response Schema:

More information in the [Run Schema](#run) section.

### Example Response:

```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "startDateTime": "2023-03-29T14:05:00.000+00:00",
  "endDateTime": "2023-03-29T14:06:42.000+00:00",
  "status": "Completed",
  "host": "EdFi_Ods_Populated_Template_Test",
  "validationEngine": "Application Name"
}
```

## runs/:runId/rules

The Rules that were ran by the specified Run.

### Query Parameters:

| Parameter | Data Type | Description                                                                                  |
| --------- | --------- | -------------------------------------------------------------------------------------------- |
| pageIndex | Integer   | The index of the pagination. The value must be greater than or equal to 0. It defaults to 0. |
| pageSize  | Integer   | The size of the pagination. The value must be between 10 and 1000. It defaults to 100.       |
| orderBy   | String    | The sorting to apply to the query. More information in the [OrderBy](#order-by) section.     |
| filter    | String    | A filter to apply to the query. More information in the [Filter](#filter) section.           |

### Response Schema:

| Property  | Data Type       | Description                              |
| --------- | --------------- | ---------------------------------------- |
| pageIndex | Integer         | The page index of the paginated results. |
| pageSize  | Integer         | The page size of the paginated results.  |
| count     | Long            | The total count of the resources.        |
| data      | [Rule[]](#rule) | The results of the query.                |

### Example Response:

```json
{
  "pageIndex": 0,
  "pageSize": 100,
  "count": 1,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "runId": "00000000-0000-0000-0000-000000000000",
      "source": "Application Name",
      "name": "name",
      "description": "A long detailed explanation of the Rule.",
      "shortDescription": "A brief explanation of the Rule.",
      "resolution": "A long detailed explanation or an external resource url on how to resolve the errors produced by this Rule.",
      "status": "Active",
      "category": "My Collection/My Container",
      "severity": "MinorError",
      "externalRuleId": "00000000-0000-0000-0000-000000000000",
      "validationLogicType": "SQL",
      "validationLogic": "SELECT * FROM [myschema].[TableName]"
    }
  ]
}
```

## runs/:runId/results

The Results generated by the Rules that were ran by the specified Run.

### Query Parameters:

| Parameter | Data Type | Description                                                                                  |
| --------- | --------- | -------------------------------------------------------------------------------------------- |
| pageIndex | Integer   | The index of the pagination. The value must be greater than or equal to 0. It defaults to 0. |
| pageSize  | Integer   | The size of the pagination. The value must be between 10 and 1000. It defaults to 100.       |
| orderBy   | String    | The sorting to apply to the query. More information in the [OrderBy](#order-by) section.     |
| filter    | String    | A filter to apply to the query. More information in the [Filter](#filter) section.           |

### Response Schema:

| Property  | Data Type           | Description                              |
| --------- | ------------------- | ---------------------------------------- |
| pageIndex | Integer             | The page index of the paginated results. |
| pageSize  | Integer             | The page size of the paginated results.  |
| count     | Long                | The total count of the resources.        |
| data      | [Result[]](#result) | The results of the query.                |

### Example Response:

```json
{
  "pageIndex": 0,
  "pageSize": 100,
  "count": 1,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "runId": "00000000-0000-0000-0000-000000000000",
      "ruleId": "00000000-0000-0000-0000-000000000000",
      "resourceId": "00000000-0000-0000-0000-000000000000",
      "resourceUrl": "educationOrganizations/00000000-0000-0000-0000-000000000000",
      "namespace": "uri://namespace",
      "additionalContext": [
        {
          "key": "key",
          "value": "value"
        }
      ]
    }
  ]
}
```

## /rules

The validation Rules.

### Query Parameters:

| Parameter | Data Type | Description                                                                                  |
| --------- | --------- | -------------------------------------------------------------------------------------------- |
| pageIndex | Integer   | The index of the pagination. The value must be greater than or equal to 0. It defaults to 0. |
| pageSize  | Integer   | The size of the pagination. The value must be between 10 and 1000. It defaults to 100.       |
| orderBy   | String    | The sorting to apply to the query. More information in the [OrderBy](#order-by) section.     |
| filter    | String    | A filter to apply to the query. More information in the [Filter](#filter) section.           |

### Response Schema:

| Property  | Data Type       | Description                              |
| --------- | --------------- | ---------------------------------------- |
| pageIndex | Integer         | The page index of the paginated results. |
| pageSize  | Integer         | The page size of the paginated results.  |
| count     | Long            | The total count of the resources.        |
| data      | [Rule[]](#rule) | The results of the query.                |

### Example Response:

```json
{
  "pageIndex": 0,
  "pageSize": 100,
  "count": 1,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "runId": "00000000-0000-0000-0000-000000000000",
      "source": "Application Name",
      "name": "name",
      "description": "A long detailed explanation of the Rule.",
      "shortDescription": "A brief explanation of the Rule.",
      "resolution": "A long detailed explanation or an external resource url on how to resolve the errors produced by this Rule.",
      "status": "Active",
      "category": "My Collection/My Container",
      "severity": "MinorError",
      "externalRuleId": "00000000-0000-0000-0000-000000000000",
      "validationLogicType": "SQL",
      "validationLogic": "SELECT * FROM [myschema].[TableName]"
    }
  ]
}
```

## /rules/:ruleId

The details of a validation Rule.

### Response Schema:

More information in the [Rule Schema](#rule) section.

### Example Response:

```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "runId": "00000000-0000-0000-0000-000000000000",
  "source": "Application Name",
  "name": "name",
  "description": "A long detailed explanation of the Rule.",
  "shortDescription": "A brief explanation of the Rule.",
  "resolution": "A long detailed explanation or an external resource url on how to resolve the errors produced by this Rule.",
  "status": "Active",
  "category": "My Collection/My Container",
  "severity": "MinorError",
  "externalRuleId": "00000000-0000-0000-0000-000000000000",
  "validationLogicType": "SQL",
  "validationLogic": "SELECT * FROM [myschema].[TableName]"
}
```

## /results

The Results generated by the Rules that were ran by the specified Run.

### Query Parameters:

| Parameter | Data Type | Description                                                                                  |
| --------- | --------- | -------------------------------------------------------------------------------------------- |
| pageIndex | Integer   | The index of the pagination. The value must be greater than or equal to 0. It defaults to 0. |
| pageSize  | Integer   | The size of the pagination. The value must be between 10 and 1000. It defaults to 100.       |
| orderBy   | String    | The sorting to apply to the query. More information in the [OrderBy](#order-by) section.     |
| filter    | String    | A filter to apply to the query. More information in the [Filter](#filter) section.           |

### Response Schema:

| Property  | Data Type           | Description                              |
| --------- | ------------------- | ---------------------------------------- |
| pageIndex | Integer             | The page index of the paginated results. |
| pageSize  | Integer             | The page size of the paginated results.  |
| count     | Long                | The total count of the resources.        |
| data      | [Result[]](#result) | The results of the query.                |

### Example Response:

```json
{
  "pageIndex": 0,
  "pageSize": 100,
  "count": 1,
  "data": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "runId": "00000000-0000-0000-0000-000000000000",
      "ruleId": "00000000-0000-0000-0000-000000000000",
      "resourceId": "123456",
      "resourceType": "EducationOrganization",
      "resourceUrl": "educationOrganizations/00000000-0000-0000-0000-000000000000",
      "namespace": "uri://namespace",
      "additionalContext": [
        {
          "key": "key",
          "value": "value"
        }
      ]
    }
  ]
}
```

# Order By

The properties used by an orderBy depend on the type of resource that is being queried.

Consider the following schema:

```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "name": "name",
  "resultsCount": 2,
  "results": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "value": "value"
    },
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "value": "value"
    }
  ]
}
```

Some valid orderBy for this resource would be the following:

```
name

name asc

name desc

resultsCount

resultsCount asc

resultsCount desc
```

# Filter

The properties used by a filter depend on the type of resource that is being queried.

Consider the following schema:

```json
{
  "id": "00000000-0000-0000-0000-000000000000",
  "name": "name",
  "resultsCount": 2,
  "results": [
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "value": "value"
    },
    {
      "id": "00000000-0000-0000-0000-000000000000",
      "value": "value"
    }
  ]
}
```

Some valid filters for this resource would be the following:

```
id == "00000000-0000-0000-0000-000000000000"

name == "name" && resultsCount >= 1

results.any(value == "Some Value")

resultsCount >= 1 && results.any(value == "Some Value")
```

A complete list of examples can be found below.

## Examples

```
numberProp == 10

numberProp >= 10

numberProp <= 10

numberProp != 10

numberPropA >= 10 && numberPropB <= 10

stringProp == "Value"

stringPropA == "ValueA" && stringPropB == "ValueB"

stringPropA == "ValueA" || stringPropB == "ValueB"

stringProp.contains("Value")

stringProp.trim().toLower().contains("Value".trim().toLower())

stringPropA.trim().toLower().contains("ValueA".trim().toLower()) || stringPropB.trim().toLower().contains("ValueB".trim().toLower())

arrayProp.any(numberProp == 10)

arrayProp.any(stringProp.contains("value"))

arrayProp.any(numberProp == 10 && stringProp.contains("value"))

numberProp == 10 && stringProp.contains("value") && arrayProp.any(numberProp == 10 && stringProp.contains("value"))
```
