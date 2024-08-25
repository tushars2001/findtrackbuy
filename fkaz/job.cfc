<cfcomponent output="true">
	
	<cffunction name="isrunning" access="remote">
		<cfargument name="jobtype">

		<cfset var running = false>
		<cfif structkeyexists(application,'#jobtype#')>
			<cfif structkeyexists(application['#jobtype#'],"running")>
				<cfif application['#jobtype#'].running eq true>
					<cfset running = true>
				</cfif>
			</cfif>
		</cfif>
		
		<cfreturn running>
		
	</cffunction>
	
	<cffunction name="run" access="remote">
		<cfargument name="jobtype">
		<cfargument name="groupsk" default="" required="false">
		<cfargument name="batch" default="" required="false">

		<cftry>
			<cfquery name="geturl" datasource="#application.dsn#">
				select url from ftb_alljobs where jobtype='#arguments.jobtype#'
			</cfquery>
			<cfif not len(arguments.groupsk)>
				<cfset groupsk = createuUID()>
			<cfelse>
				<cfset groupsk = arguments.groupsk>
			</cfif>
			<cfset v=structnew()>
			<!--- <cfif isdefined("application['#arguments.jobtype#'].running") and application['#arguments.jobtype#'].running eq true>
				<cfdump var="Already Running">
				<cfabort>
			</cfif> --->
			
				<cfset application['#arguments.jobtype#'].running = true>
				<cfset application['#arguments.jobtype#'].abort = false>
				<cfset application['#arguments.jobtype#'].groupsk = groupsk>
				<cfif find("?",geturl.url)>
					<cfset geturl.url = "#geturl.url#&groupsk=#groupsk#&jobtype=#arguments.jobtype#">
				<cfelse>
					<cfset geturl.url = "#geturl.url#?groupsk=#groupsk#&jobtype=#arguments.jobtype#">
				</cfif>
				<cfif len(arguments.batch)>
					<cfset geturl.url = "#geturl.url#&frombatches=#arguments.batch#">
				</cfif>
				<cfset application['#arguments.jobtype#'].url = geturl.url>
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>
			</cftry>
			<cfthread action="run" name="runtracker" groupsk="#groupsk#" jobtype = "#arguments.jobtype#" joburl = "#geturl.url#">
				<cftry>
					<cfif not find("frombatches=",arguments.joburl)>
						<cfquery name="runjob" datasource="#application.dsn#">
							INSERT INTO `ftb_jobtracker`
									(`start`, `status`, `jobtype`, `server`, `groupsk`) 
							VALUES (current_timestamp,'RUNNING','#arguments.jobtype#','#CGI.server_name#','#groupsk#')
						</cfquery>
					<cfelse>
						<cfquery name="runjob" datasource="#application.dsn#">
							update `ftb_jobtracker` set status = 'RERUNNING'
							where groupsk = '#groupsk#'
						</cfquery>
					</cfif>
					<cfhttp url="http://#CGI.server_name#:#CGI.server_port##arguments.joburl#" result="res">
				<cfcatch>
					<cfdump var="#cfcatch#">
					<!--- <cfquery name="runjob" datasource="#application.dsn#">
						update `ftb_jobtracker` set finished = current_timestamp, status = 'NOT_STARTED'
						where groupsk = '#groupsk#'
					</cfquery> --->
				</cfcatch>
				</cftry>
			</cfthread>
			<cfset application['#arguments.jobtype#'].runtracker = runtracker>
			<cfthread action="join" name="runtracker" />
			<cfset application['#arguments.jobtype#'].running = false>
			<!--- <cfquery name="runjob" datasource="#application.dsn#">
				update `ftb_jobtracker` set finished = current_timestamp, status = 'FINISHED'
				where groupsk = '#groupsk#'
			</cfquery> --->
		<cfreturn application['#arguments.jobtype#']> 
	</cffunction>
	
	<cffunction name="rerun" access="remote">
		<cfargument name="jobtype">
		<cfargument name="groupsk" required="false" default="">
			
			<cfif len(arguments.groupsk)>
				<cfquery name="getsk" datasource="#application.dsn#">
						select groupsk, processed from ftb_jobtracker where groupsk='#arguments.groupsk#'
						order by jobid desc
						limit 0,1
				</cfquery>
			<cfelse>
				<cfquery name="getsk" datasource="#application.dsn#">
						select groupsk, processed from ftb_jobtracker where jobtype='#arguments.jobtype#'
						and status != 'FINISHED'
						order by jobid desc
						limit 0,1
				</cfquery>
			</cfif>
			<cfset argurments.groupsk = getsk.groupsk>
			<cfif isnumeric(getsk.processed)>
				<cfset batch = ceiling(getsk.processed/100)>
				<cfset run(arguments.jobtype,argurments.groupsk,batch)>
			<cfelse>
				<cfreturn 'Cannot rerun'/>
			</cfif>
		
		<cfreturn application['#arguments.jobtype#']> 
	</cffunction>
	
	<cffunction name="checkstatus" access="remote">
		<cfargument name="jobtype">
		
		<cfset response = {
			    isProcessing = false,
			    total = 0,
			    proc = 0,
			    ins = 0,
			    failed=0
			    } />
			    
		<cfif not structkeyExists(application,"#arguments.jobtype#")>
			<cfset response = {
			    isProcessing = false,
			    total = 0,
			    proc = 0,
			    ins = 0,
			    failed=0
			    } />
		<cfelse>
			
			<cfquery name="getdetail" datasource="#application.dsn#">
				select total,processed,inserted,failed from ftb_jobtracker where 
				groupsk='#application[arguments.jobtype].groupsk#'
			</cfquery>
			<cfset porc =false>
			<cftry>
				<cfset porc =application['#arguments.jobtype#'].running>
			<cfcatch>
			</cfcatch>
			</cftry>
			
			<cfset response = {
			    isProcessing = porc,
			    total = getdetail.total,
			    proc = getdetail.processed,
			    ins = getdetail.inserted,
			    failed=getdetail.failed
			    } />
		</cfif>
		
		
			    
		<cfset binaryResponse = toBinary(
		    toBase64(
		        serializeJSON( response )
		        )
		    ) />
		    
		 <cfcontent
		    type="text/json"
		    variable="#binaryResponse#"
		    />
		    
		  <cfabort>
	</cffunction>
	
	<cffunction name="kill" access="remote">
		<cfargument name="jobtype">
		
		<cftry>
			<cfset application['#arguments.jobtype#'].abort = true>
		<cfcatch>
		</cfcatch>
		</cftry>
		
	</cffunction>
	
</cfcomponent>