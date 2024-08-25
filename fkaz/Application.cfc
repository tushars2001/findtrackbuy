<cfcomponent
	displayname="Application"
	output="true"
	hint="Handle the application.">


	<!--- Set up the application. --->
	<cfset THIS.Name = "FTB" />
	<cfset THIS.ApplicationTimeout = CreateTimeSpan(  0, 5, 1, 0 ) />
	<cfset THIS.SessionManagement = true />
	<cfset THIS.SetClientCookies = true />
	<cfset THIS.clientManagement = true />
	<cfset THIS.clientStorage = "product" />


	<!--- Define the page request properties. --->
	<!--- <cfsetting
		requesttimeout="20"
		showdebugoutput="false"
		enablecfoutputonly="false"
		/> --->


	<cffunction
		name="OnApplicationStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="Fires when the application is first created.">
		<cfset application.dsn = 'product'>
		<cfset application.goog = 'UA-54318348-1'>
		<!--- Return out. --->
		<cfreturn true />
	</cffunction>

	<cffunction
		name="OnRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="Fires at first part of page processing.">

		<!--- Define arguments. --->
		<cfargument
			name="TargetPage"
			type="string"
			required="true"
			/>
		<cfset application.goog = 'UA-54318348-1'>
		<cfset application.cgi_SCRIPT_NAME = replace(cgi.SCRIPT_NAME,"index.cfm","")>
		<cfparam name="session.fluctuate" default="0">
		<cfparam name="session.prangeFrom" default="">
		<cfparam name="session.prangeTo" default="">
		<cfparam name="session.rangeTo" default="">
		<cfparam name="session.rangeFrom" default="">
		<cfparam name="session.dropsince" default="1">
		<cfparam name="session.saveme" default="">
		<cfparam name="session.usermsg" default="">
		<cfparam name="client.mobile" default="0">
		<cfparam name="session.force" default="0">
		<cfparam name="request.files" default="main">
		<cfparam name="session.showsub" default="1">
		<cfif client.mobile>
			<cfset request.files = "m">
		</cfif>
		<cfif isdefined("client.user_sk") and len(client.user_sk)>
			<cfset session.showsub = "0">
		</cfif>
		<cfset obj = createObject("component","cmp")>
                 <cfif isdefined("url.sortby") and isdefined("url.sortOrder")>
			<cfset obj.setSortby(url.sortby,url.sortOrder)>
		</cfif> 
		<!--- Return out. --->
		<cfreturn true />
	</cffunction>

	<!--- <cffunction
		name="OnSessionStart"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the session is first created.">

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction
		name="OnRequest"
		access="public"
		returntype="void"
		output="true"
		hint="Fires after pre page processing is complete.">

		<!--- Define arguments. --->
		<cfargument
			name="TargetPage"
			type="string"
			required="true"
			/>

		<!--- Include the requested page. --->
		<cfinclude template="#ARGUMENTS.TargetPage#" />

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction
		name="OnRequestEnd"
		access="public"
		returntype="void"
		output="true"
		hint="Fires after the page processing is complete.">

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction
		name="OnSessionEnd"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the session is terminated.">

		<!--- Define arguments. --->
		<cfargument
			name="SessionScope"
			type="struct"
			required="true"
			/>

		<cfargument
			name="ApplicationScope"
			type="struct"
			required="false"
			default="#StructNew()#"
			/>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction
		name="OnApplicationEnd"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the application is terminated.">

		<!--- Define arguments. --->
		<cfargument
			name="ApplicationScope"
			type="struct"
			required="false"
			default="#StructNew()#"
			/>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	--->

	 
<cffunction
		name="OnError"
		access="public"
		returntype="void"
		output="true"
		hint="Fires when an exception occures that is not caught by a try/catch.">

		<!--- Define arguments. --->
		<cfargument
			name="Exception"
			type="any"
			required="true"
			/>

		<cfargument
			name="EventName"
			type="string"
			required="false"
			default=""
			/>
			<cfoutput>
			<html>
				<head>
					<link rel="stylesheet" href="/fkaz/js/main.css">
					<script language="javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
					<script language="javascript" src="/fkaz/js/jquery-ui.min.js"></script>
					<script language="javascript" src="/fkaz/js/main.js"></script>
				</head>
				<body>
					<cfinclude template="header.cfm">
					<div style="text-align:center;width:100%">
						<img src="/fkaz/images/error.jpg">
					</div>
					<div style="text-align:center;width:100%">
						<a href="/fkaz/">Please visit Home</a>
					</div>
				</body>
			</html>
			<cftry>
				<cfmail from="hello@quirkycrackers.com" to="tushars2001@gmail.com" type="html" failto="tushars2001@gmail.com" subject="Error Page">
					<cfdump var="#arguments#">
				</cfmail>
			<cfcatch>
				<div style="text-align:center;width:100%">
					Mail wasn't sent
				</div>
			</cfcatch>
			</cftry>
			</cfoutput>
		<!--- Return out. --->
		<cfreturn />
	</cffunction> 
 

</cfcomponent>