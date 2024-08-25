<cfparam name="url.pid" default="">
<cfparam name="url.type" default="">
<cfparam name="data" default="">
<cfif len(url.pid) eq 10>
	<cfset url.type = 1>
<cfelse>
	<cfset url.type = 0>
</cfif>
<cfset o = createobject("component","cmp")>

<cftry>
	<cfif url.type eq 0>
		<cfset data = o.flipkartPID(url.pid,'findtrack','41991286028d42328c43eea3a27ac5c3')>
		<cfdump var="#data#">
		<cfset data = DeserializeJSON(data)>
	</cfif>
	
	<cfif url.type eq 1>
		<cfset data = o.ItemLookup(url.pid)>
		<cfset data = o.ConvertXmlToStruct(data,structnew())>
	</cfif>
<cfcatch>
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>


<cfdump var="#data#">