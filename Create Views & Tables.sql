/*****************************
  Health Insurance Management Module
  Created by Thomas Stockwell
  August 17, 2015

  Tables Created:
  configTSAcademicLevelInsuranceLocation

  Views Created:
  viewCodeTSAcademicLevel
  viewTSHealthInsurance
  
  Custom Tables Configured:
  jbCustomFields4
*/
CREATE TABLE [dbo].[configTSAcademicLevelInsuranceLocation]( [recnum]            [INT] IDENTITY(1, 1)
                                                                                        NOT NULL,
                                                              [levelCode]         [NCHAR](3) NULL,
                                                              [insuranceLocation] [NVARCHAR](50) NULL,
                                                              CONSTRAINT [PK_configTSAcademicLevelInsurance] PRIMARY KEY CLUSTERED( [recnum] ASC )
                                                              WITH( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY] )
ON [PRIMARY];
CREATE VIEW [dbo].[viewCodeTSAcademicLevel]
AS
     SELECT dbo.codeAcademicLevel.code,
            dbo.configTSAcademicLevelInsuranceLocation.insuranceLocation,
            dbo.codeAcademicLevel.description
     FROM dbo.codeAcademicLevel
          LEFT OUTER JOIN dbo.configTSAcademicLevelInsuranceLocation ON dbo.codeAcademicLevel.code = dbo.configTSAcademicLevelInsuranceLocation.levelCode;
CREATE VIEW [dbo].[viewTSHealthInsurance]
AS
     SELECT dbo.jbCustomFields4.idnumber,
            dbo.jbCustomFields4.customField1 AS companyName,
            CONVERT( NVARCHAR(30), CAST(dbo.jbCustomFields4.customField2 AS DATE), 112) AS effectiveDateFormatted,
            dbo.jbCustomFields4.customField2 AS effectiveDate,
            CONVERT( NVARCHAR(30), CAST(dbo.jbCustomFields4.customField3 AS DATE), 112) AS endDateFormatted,
            dbo.jbCustomFields4.customField3 AS endDate,
            CONVERT( NVARCHAR(30), CAST(ext.dob AS DATE), 112) AS dobFormatted,
            ext.dob,
            dbo.jbCustomFields4.customField4 AS termCode,
            dbo.jbCustomFields4.customField5 AS planCode,
            insLoc.insuranceLocation AS location,
            dbo.jbCustomFields4.customField7 AS updatedBy,
            dbo.jbCustomFields4.customField8 AS groupCode,
            dbo.jbCustomFields4.customField9 AS notes,
            dbo.jbCustomFields4.customField10 AS termApplied
     FROM dbo.jbCustomFields4
          INNER JOIN dbo.jbInternationalBioExt AS ext ON ext.idnumber = dbo.jbCustomFields4.idnumber
          LEFT OUTER JOIN dbo.viewCodeTSAcademicLevel AS insLoc ON insLoc.code = dbo.jbCustomFields4.customField6;
						 
						 
INSERT INTO [configCustomTables]([tableName],[label],[description],datestamp)
VALUES('jbCustomFields4','Health Insurance','Handles health insurance on campus',getdate())

INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField1','string','Company Name','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField2','date','Effective Date','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField3','date','End Date','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField4','string','Term Code','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField5','string','Plan Code','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField6','string','Class Code','codeTSInsuranceLocation',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField7','label','Updated By','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField8','string','Group Code','',getdate())
INSERT INTO [configCustomFields]([tableName],[fieldName],[fieldDataType],[fieldLabel],[referencedCodeTable],datestamp)
VALUES('jbCustomFields4','customField9','memo','Policy / Notes','',getdate())

exec spIOfficeRoleUpdate