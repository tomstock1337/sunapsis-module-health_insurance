<cfcomponent extends="AbstractAlertService">

	<cffunction name="isF1Student" access="public" returntype="boolean">
		<cfreturn false>
	</cffunction>
	
	<cffunction name="isJ1Student" access="public" returntype="boolean">
		<cfreturn false>
	</cffunction>
	
	<cffunction name="isJ1Scholar" access="public" returntype="boolean">
		<cfreturn false>
	</cffunction>
	
	<cffunction name="isH1BEmployee" access="public" returntype="boolean">
		<cfreturn false>
	</cffunction>
	
	<cffunction name="isPREmployee" access="public" returntype="boolean">
		<cfreturn false>
	</cffunction>

	<cffunction name="getAlertType" access="public" returntype="AlertType">
		<cfscript>
			var alertType = createObject("component", "AlertType");
			alertType.setServiceID(getImplementedServiceID());
			alertType.alertName = getServiceLabelType() & "Expiring Health Insurance";
			alertType.alertDescription = "Health Insurance is nearing expiration";
			alertType.levelDescription = "Severe: <20 days<br/>High: <= 45 days; > 30 days; <br/>Elevated: <=45 days; > 30 days; <br/>Guarded: <=60 days; > 45 days";	
			alertType.override = false;
		</cfscript>
		<cfreturn alertType>
	</cffunction>

	<cffunction name="getQueryData" access="private" returntype="query">
		<cfargument name="threatLevel" type="numeric" required="true">
		<cfargument name="idnumber" type="numeric" required="true">
		<cfquery name="dataset">
			SELECT
			  jbInternational.idnumber,
			  dbo.jbInternationalBioExt.gender,
			  jbInternational.lastname,
			  jbInternational.firstname,
			  jbInternational.midname,
			  jbInternational.campus,
			  jbInternational.universityid,
			  jbCommunication.universityEmail,
			  MAX( CAST( jbcustomfields4.customfield3 AS DATE )) AS customfield3
			FROM jbInternational
				 INNER JOIN dbo.jbInternationalBioExt
				   ON dbo.jbInternationalBioExt.idnumber = dbo.jbInternational.idnumber
				 INNER JOIN dbo.jbCommunication
				   ON dbo.jbCommunication.idnumber = jbInternational.idnumber
				 INNER JOIN jbcustomfields4
				   ON jbcustomfields4.idnumber = jbInternational.idnumber
			WHERE  (jbinternational.idnumber IN( 
							   SELECT
								idnumber
							   FROM iuieTerm
							   WHERE STU_DRVD_TOT_TERM_UNT_NBR > 0 )
					OR jbinternational.idnumber IN( 
													  SELECT idnumber
													  FROM sevisI20CPT
													  WHERE status = 'Approved'
														AND endDate > GETDATE())
					  OR jbinternational.idnumber IN( 
													  SELECT idnumber
													  FROM sevisI20OPT
													  WHERE status = 'Approved'
														AND endDate > GETDATE())	 )
						AND jbInternational.idnumber NOT IN (SELECT idnumber
															 FROM jbAlertsOverride WITH (nolock)
															 WHERE serviceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getImplementedServiceID()#" />
															 AND (forever = 1 OR endDate > CURRENT_TIMESTAMP) )
			<cfif idnumber gt 0>AND jbInternational.idnumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#idnumber#"></cfif>
			GROUP BY
			  jbInternational.idnumber,
			  dbo.jbInternationalBioExt.gender,
			  jbInternational.lastname,
			  jbInternational.firstname,
			  jbInternational.midname,
			  jbInternational.campus,
			  jbInternational.universityid,
			  jbCommunication.universityEmail
			  
			<cfif idnumber eq 0>
				<cfif threatLevel eq 1>
				HAVING MAX( CAST( jbcustomfields4.customfield3 AS DATE )) <= GETDATE() + 21
				<cfelseif threatLevel eq 2>
				HAVING MAX( CAST( jbcustomfields4.customfield3 AS DATE )) <= GETDATE() + 30
				  AND MAX( CAST( jbcustomfields4.customfield3 AS DATE )) > GETDATE() + 21
				<cfelseif threatLevel eq 3>
				HAVING MAX( CAST( jbcustomfields4.customfield3 AS DATE )) <= GETDATE() + 45
				  AND MAX( CAST( jbcustomfields4.customfield3 AS DATE )) > GETDATE() + 30
				<cfelseif threatLevel eq 4>
				HAVING MAX( CAST( jbcustomfields4.customfield3 AS DATE )) <= GETDATE() + 60
				  AND MAX( CAST( jbcustomfields4.customfield3 AS DATE )) > GETDATE() + 45
				<cfelse> HAVING jbinternational.idnumber = 0
				</cfif>
			</cfif>

		</cfquery>
		<cfreturn dataset>
	</cffunction>

	<!--- STEP (5) --->	
	<!--- Returns a threat level based on a given row of the dataset (i.e. state of the rowset 
	at moment query is given to the method) the function will determine the threat level. This 
	is most useful on identifying differing threat levels for alerts queried by idnumber. --->	
	<cffunction name="getAlertDataThreatLevel" access="private" returntype="numeric">
		<cfargument name="dataset" type="query" required="true">
		<cfscript>
			var threatLevel = 4;
			if( DateDiff("d",Now(),dataset.customfield3 ) GT 45)  
			threatLevel = 4;
			else 
			if( DateDiff("d",Now(),dataset.customfield3 ) GT 30) 
			threatLevel = 3;
			else 
			if( DateDiff("d",Now(),dataset.customfield3 ) GT 20) 
			threatLevel = 2;
			else 
			if( DateDiff("d",Now(),dataset.customfield3 ) LTE 20) 
			threatLevel = 1;
			else threatLevel = 4;
		</cfscript>
		<cfreturn threatLevel>
	</cffunction>

	<!--- STEP (6) --->	
	<!--- Returns a message string based on a given row of the dataset (i.e. state of the rowset 
	at moment query is given to the method) the function will build an individualized alert message.  
	This provides a greater detail on the alert issue. --->		
	<cffunction name="getAlertDataMessage" access="private" returntype="string">
		<cfargument name="dataset" type="query" required="true">
		<cfscript>
			var alertMessage = "Health Insurance expiring " & DateFormat(dataset.customfield3,"mm/dd/yyyy")&".";
		</cfscript>
		<cfreturn alertMessage>
	</cffunction>

</cfcomponent>
