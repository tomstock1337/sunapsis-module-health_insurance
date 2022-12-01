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
			alertType.alertName = getServiceLabelType() & "Missing Health Insurance";
			alertType.alertDescription = "Health insurance record is missing";
			alertType.levelDescription = "High Alert Only";	
			alertType.override = true;
		</cfscript>
		<cfreturn alertType>
	</cffunction>
	
	<cffunction name="getQueryData" access="private" returntype="query">
		<cfargument name="threatLevel" type="numeric" required="true">
		<cfargument name="idnumber" type="numeric" required="true">
		<cfquery name="dataset">
			SELECT
				jbInternational.idnumber,
				jbInternationalBioExt.gender,
				jbInternational.lastname,
				jbInternational.firstname,
				jbInternational.midname,
				jbInternational.campus,
				jbInternational.universityid,
				jbCommunication.universityEmail
			FROM
			jbInternational
			INNER JOIN dbo.jbInternationalBioExt
				ON dbo.jbInternationalBioExt.idnumber = dbo.jbInternational.idnumber
			INNER JOIN dbo.jbCommunication
				ON dbo.jbCommunication.idnumber = jbInternational.idnumber
			WHERE jbinternational.idnumber NOT IN ( 
																			SELECT
																				idnumber
																			FROM jbcustomfields4
																			) 
			AND ( jbinternational.idnumber IN ( 
																			SELECT
																				idnumber
																			FROM iuieterm AS term
																			WHERE term.STU_DRVD_TOT_TERM_UNT_NBR > 0
																		) 
			OR jbinternational.idnumber IN ( 
																			SELECT
																				idnumber
																			FROM sevisI20OPT
																			WHERE status = 'Approved'
																		) 
			OR jbinternational.idnumber IN ( 
																			SELECT
																				idnumber
																			FROM sevisI20CPT
																			WHERE status = 'Approved'
																		) 
			)
			AND jbInternational.idnumber NOT IN (SELECT idnumber
            									 FROM jbAlertsOverride WITH (nolock)
												 WHERE serviceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getImplementedServiceID()#" />
                                                 AND (forever = 1 OR endDate > CURRENT_TIMESTAMP) )
			<cfif idnumber gt 0>AND jbInternational.idnumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#idnumber#"></cfif>  
			<cfif idnumber eq 0>
				<cfif threatLevel neq 2>
					AND jbinternational.idnumber = 0
				</cfif>
			</cfif>
		</cfquery>
		<cfreturn dataset>
	</cffunction>

	<cffunction name="getAlertDataThreatLevel" access="private" returntype="numeric">
		<cfargument name="dataset" type="query" required="true">
		<cfscript>
			var threatLevel = 2;
		</cfscript>
		<cfreturn threatLevel>
	</cffunction>

	<cffunction name="getAlertDataMessage" access="private" returntype="string">
		<cfargument name="dataset" type="query" required="true">
		<cfscript>
			var alertMessage = "Health insurance record missing based on either enrollment or OPT/CPT status.";
		</cfscript>
		<cfreturn alertMessage>
	</cffunction>

</cfcomponent>
