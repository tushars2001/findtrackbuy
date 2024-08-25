<cfif isdefined("form.trends") and len(form.trends)>
	<cfset ins = 0>
	<cfloop list="#form.trends#" index="trend">
		<cftry>
			<cfif form.type eq 'LINKS'>
				<cfset o = createobject("component","cmp")>
				<cfset pid = ''>
				<cftry>
					<cfset pid = o.fkurlparse(trend)>
				<cfcatch>
				</cfcatch>
				</cftry>
				<cfif len(pid) neq 16>
					<cftry>
						<cfset pid = o.azurlparse(trend)>
					<cfcatch>
					</cfcatch>
					</cftry>
				</cfif>
				<cfset trend = pid>
			</cfif>
			<cfif len(trend)>
				<cfquery name="addindb" datasource="#application.dsn#">
					INSERT INTO `ftb_trends`(`trend`, `type`) 
					VALUES ('#uCase(trend)#','#form.type#')
				</cfquery>
				<cfset ins = ins+1>
			</cfif>
		<cfcatch><cfdump var="cannot add #trend#. #cfcatch.Message#"></cfcatch></cftry>
	</cfloop>
	
	ADDED: <cfdump var="#ins#">
	
	
</cfif>
<html>
	<head>
	
	</head>
	<body>
		<h2>BRANDS</h2>
		<form name="f" method="post" action="./addtrends.cfm">
		<textarea name="trends" id="brands" cols="50" rows="10"></textarea><br>
		<input type="hidden" name="type" value="BRAND">
		<input type="submit">
		</form>
		<h2>PRODUCT IDS</h2>
		<form name="f" method="post" action="./addtrends.cfm">
		<textarea name="trends" id="products" cols="50" rows="10"></textarea><br>
		<input type="hidden" name="type" value="PRODUCT">
		<input type="submit">
		</form>
		<h2>PRODUCT LINKS</h2>
		<form name="f" method="post" action="./addtrends.cfm">
		<textarea name="trends" id="links" cols="50" rows="10"></textarea><br>
		<input type="hidden" name="type" value="LINKS">
		<input type="submit">
		</form>
		</form>
		<h2>KEYWORDS</h2>
		<form name="f" method="post" action="./addtrends.cfm">
		<textarea name="trends" id="keywords" cols="50" rows="10"></textarea><br>
		<input type="hidden" name="type" value="KEYWORDS">
		<input type="submit">
		</form>
	</body>
</html>