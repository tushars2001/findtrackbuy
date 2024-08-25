<cfset application.trackerrors = '#GetDirectoryFromPath(GetCurrentTemplatePath())#trackerrors\'>
<cfset request.sk = dateformat(now(),"YYYY-MM-DD")>
<cfset obj = createobject("component","cmp")>
<!--- <cfhttp url="https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/t06-r3o.json?expiresAt=1436805806740&sig=d21806a4ea2ecc54c6fc1563fed47163" result="res" method="get">
	<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
	<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
</cfhttp>
<cfdump var="#deserializeJSON(res.filecontent)#">ATTE8H527XGMHAFW
 --->
<!--- <cfset data="#deserializeJSON(obj.flipkartPID('ACCD79CFHRYCFZ3V'))#">
<cfset details = obj.fkDetails(data.productBaseInfo.productAttributes)>
<cfdump var="#data#">
<cfabort> --->

<cffunction name="snooz" access="public" output="false" returntype="void" hint="Leverages Java's sleep() function">
   <cfargument name="timeToSleep" type="numeric" required="true" />

   <cfscript>
      createObject("java", "java.lang.Thread").sleep(arguments.timeToSleep);    //sleep time in milliseconds
      return;
   </cfscript>
</cffunction>

<!--- <cfdump var="#now()#">
<cfset snooz(1000)>
<cfdump var="#now()#">
<cfset snooz(2000)>
<cfdump var="#now()#">
<cfset snooz(3000)>
<cfdump var="#now()#">
<cfabort> --->
<!--- <cfloop from ="1" to="10" index="idx">
<cfdump var="#now()#">
<cfset snooz(100)>
</cfloop>
<cfabort> --->

<cfset request.errors = arraynew(1)>
<cfset request.insertcnt = 0>
<cfset request.failcnt = 0>
<cfif isdefined("url.requestsk") and len(url.requestsk)>
	<cfset request.sk = url.requestsk>
</cfif>

<cfquery name="q_getProductsToTrack" datasource="product">
	SELECT fl.pid,fl.type,0 as last_price,fl.record_id FROM `ftb_fail_log` fl where 
	type=1
	and fl.fail_msg = 'QUIRKYCRACKERS'
</cfquery>

<cfdump var="#q_getProductsToTrack.recordcount#">
<cfflush>

<cfloop from="1" to="#q_getProductsToTrack.recordcount#" index="idx">
	
	<cfoutput>@ </cfoutput><CFFLUSH>
	<cftry>
		<cfset snooz(1000)>
		<cfset pid = obj.azurlparse(q_getProductsToTrack.link[idx])>
		<cfset azdata = obj.ItemLookup(pid)>
		<cfset azdata = obj.ConvertXmlToStruct(azdata,structnew())>

		<cfset details = obj.azDetails(azdata.Items.Item)>
		<cfset pid = details.pid>
		<cfset last_price = details.price>
		
		<cfif len(pid) and last_price gt 0 and (last_price neq q_getProductsToTrack.last_price[idx]) and last_price neq 'NA'>
			<cfquery name="addindb" datasource="#application.dsn#">
				INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
				VALUES ('#pid#',#last_price#,'#request.sk#')
			</cfquery>
			<cfquery name="updateMain" datasource="#application.dsn#">
				update `ftb_trackers_pid` set last_price = #last_price#, last_tracked = CURRENT_TIMESTAMP
				where pid = '#pid#'
			</cfquery>
			<cfoutput>(#pid#,#last_price#,#q_getProductsToTrack.last_price[idx]#)</cfoutput>
		</cfif>
		<cfquery name="succesdelete" datasource="#application.dsn#">
			delete from ftb_fail_log where record_id = #q_getProductsToTrack.record_id[idx]#
		</cfquery>
	<cfcatch>
		-<cfdump var="#cfcatch#"><cfabort>

		<!--- <cfset arrayappend(request.errors,structcopy(cfcatch))> --->
	</cfcatch>
	<cfflush>
	</cftry>
</cfloop>
<!--- <cfset dumplog(request.errors)> --->

<cffunction name="dumpLog">
	<cfargument name="data">
	<cfargument name="filename" required="false" default="">
	<cfreturn/>
	<cfset var dir = application.trackerrors & dateformat(now(),"YYYY-MM-DD") & '\'>
	<cfset var t = now()>
	
	<cftry>
	
		<cfif not len(arguments.filename)>
			<cfset arguments.filename = '#dateformat(t,"yyyyddmm")##timeformat(t,"HHmmss")#_#randRange(1,10000)#'>
		</cfif>
		
		<cfif not DirectoryExists(dir)>
			<cfdirectory action = "create" directory = "#dir#" > 
		</cfif>
		
		<cfdump var="#arguments.data#" output="#dir##arguments.filename#_az.html" format="html" >
	
	<cfcatch>
		<cfdump var="#cfcatch#">
		<cfdump var="#serializeJSON(arguments.data)#">
	</cfcatch>
	</cftry>
	<cfflush>
	
</cffunction>