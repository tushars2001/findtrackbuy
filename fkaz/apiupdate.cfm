<cfhttp url="https://affiliate-api.flipkart.net/affiliate/api/tnhpindia.json" result="res" method="get">
	<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
	<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
</cfhttp>

<cfset data = DeserializeJSON(res.filecontent)>
<cfset apinames = structKeyList(data.apiGroups.affiliate.apiListings)>
<cfset apiDetails = arraynew(1)>
<cfquery name="insertapi" datasource="#application.dsn#" result="res">
		DELETE from `ftb_fkapi`
	</cfquery>
<cfloop list ="#apinames#" index="idx">
	<cfset s.apiname = idx>
	<cfset s.apiurl = evaluate("data.apiGroups.affiliate.apiListings.#s.apiname#.availableVariants['v0.1.0'].get")><!--- .availableVariants.v0.1.0.get --->
	
	
	
	
	<cfquery name="insertapi" datasource="#application.dsn#" result="res">
		INSERT INTO `ftb_fkapi`(`apiname`, `apiurl`) 
		VALUES ('#s.apiname#','#s.apiurl#')
	</cfquery>
	
	
</cfloop>
<cfabort>

