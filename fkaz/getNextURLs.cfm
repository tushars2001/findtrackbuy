<cfquery name="getApis" datasource="#application.dsn#" cachedwithin="#createtimespan(1,0,0,0)#">
	select apiname, apiurl from ftb_fkapi		
	where 
	apiname in ('bags_wallets_belts','fragrances','home_and_kitchen_needs','home_decor_and_festive_needs',
	'home_improvement_tools','laptop_accessories','luggage_travel','mobile_accessories','womens_footwear','sunglasses','toys')
</cfquery>

<cfset errors = arraynew(1)>
<cfset nexturls = arraynew(1)>

<cfloop from="1" to="#getApis.recordcount#" index="idx">	
<cfoutput>HTTPing<br>#getApis.apiname[idx]#<br>#getApis.apiurl[idx]#</cfoutput>

	<cfhttp url="#getApis.apiurl[idx]#" result="res" method="get">
		<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
		<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
	</cfhttp>
		<cftry>		
			<cfset data = deserializeJSON(res.filecontent)>	
			<cfset arrayappend(nexturls,data.nextUrl)>
			<cfcatch>		
				<cfset arrayappend(errors,getApis.apiname[idx])>
			</cfcatch>	
		</cftry>
</cfloop>
<cfdump var="#errors#">
<cfdump var="#nexturls#">
