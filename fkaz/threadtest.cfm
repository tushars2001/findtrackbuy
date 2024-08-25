Entered: <cfdump var="#now()#">
<!--- 
<cfset structdelete(application,"UPDATE_MOVERS")>
 --->
<cfdump var="#application#">
<cfabort>

<cfdump var="#cfthread#">
<cfthread action="terminate" name="#cfthread[application.MOVERS_AZ.RUNTRACKER]#" /> 
<cfdump var="#cgi#">
<cfabort>

<cfset job = createobject("component","job")>
<cfdump var="#job.run('trackmovers')#">
<cfabort>


<cfthread name="t1" action="run">
	T1 Started : <cfdump var="#now()#">
	<cfset thread.msg = 'started'>
	<cfset sleep(1000)>
	<cftry>
		<cfquery name="runjob" datasource="#application.dsn#">
			INSERT INTO `ftb_jobtrackedr`
					(`start`, `status`, `jobtype`, `server`, `groupsk`) 
			VALUES (current_timestamp,'RUNNING','T1','test','123')
		</cfquery>
	<cfcatch><cfset thread.msg = cfcatch></cfcatch></cftry>
	
	T1 Ended : <cfdump var="#now()#">
</cfthread>
<cfthread name="t2" action="run">
	T2 Started : <cfdump var="#now()#">
	<cfquery name="runjob" datasource="#application.dsn#">
		INSERT INTO `ftb_jobtracker`
				(`start`, `status`, `jobtype`, `server`, `groupsk`) 
		VALUES (current_timestamp,'RUNNING','T2','test','123')
	</cfquery>
	T2 Ended : <cfdump var="#now()#">
</cfthread>
<cfdump var="#t1#">
<cfthread
    action="join"
    name="t1"
    />
<cfdump var="#t1#">
Exit: <cfdump var="#now()#">