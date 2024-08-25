<cfparam name="form.user_sk" default="">
<cfparam name="form.password1" default="">
<cfparam name="msg" default="Trouble in password reset. Please retry.">


<cftry>

	<cfif len(form.user_sk) and len(form.password1)>
		<cfquery name="resetpassword" datasource="#application.dsn#">
			update ftb_users set password='#form.password1#', passhash = '#hash(form.password1)#', active=1
			where user_sk = '#form.user_sk#'
		</cfquery>
		<cfset msg = 'Password reset successful.'>
	</cfif>

<cfcatch>
	<cfdump var="#cfcatch#">
	<cfabort>
</cfcatch>
</cftry>


<cflocation url="/fkaz/login/?msg=#msg#">

