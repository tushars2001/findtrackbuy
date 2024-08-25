<cfparam name="url.m" default="1">
<cfparam name="url.force" default="0">
<cfparam name="url.folder" default="">
<cfset session.force = url.force>
<cfset client.mobile = url.m>

<cfif len(cgi.http_referer)>
	<cflocation url="/fkaz/#url.folder#?#cgi.QUERY_STRING#" addtoken="false">
<cfelse>
	<cflocation url="/" addtoken="false">
</cfif>