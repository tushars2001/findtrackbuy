<cfset application.trackerrors = '#GetDirectoryFromPath(GetCurrentTemplatePath())#trackerrors\'>
<cfset request.sk = dateformat(now(),"YYYY-MM-DD")>
<cfset obj = createobject("component","cmp")>
This is tracking job to trac tracker.This is tracking job to trac tracker.This is tracking job to trac tracker.This is tracking job to trac tracker.This is tracking job to trac tracker.This is tracking job to trac tracker.
<cffunction name="snooz" access="public" output="false" returntype="void" hint="Leverages Java's sleep() function">
   <cfargument name="timeToSleep" type="numeric" required="true" />

   <cfscript>
      createObject("java", "java.lang.Thread").sleep(arguments.timeToSleep);    //sleep time in milliseconds
      return;
   </cfscript>
</cffunction>
<cfparam name="url.type" default="1">
<cfparam name="url.frombatches" default="">
<cfparam name="url.groupsk" default="">

<cfset request.errors = arraynew(1)>
<cfset request.insertcnt = 0>
<cfset request.failcnt = 0>
<cfset request.processed = 0>
<cfset request.total = 0>

<cfif isdefined("url.requestsk") and len(url.requestsk)>
	<cfset request.sk = url.requestsk>
</cfif>

<cfquery name="addindb" datasource="#application.dsn#">
		SELECT bp.pid FROM `ftb_browse_pid` bp, ftb_trackers_pid tp where bp.pid = tp.pid
</cfquery>
	
<cfquery name="del" datasource="#application.dsn#" result="res">
		delete from `ftb_browse_pid`
		where pid in (<cfqueryPARAM value = "#valueList(addindb.pid)#" CFSQLType="cf_sql_char" list="true">)
</cfquery>

<cfif len(url.frombatches)>
	<cfquery name="getd" datasource="#application.dsn#">
		select * `ftb_jobtracker`
		where groupsk = '#url.groupsk#'
	</cfquery>
	<cfset request.insertcnt = getd.inserted>
	<cfset request.failcnt = getd.failed>
	<cfset request.processed = getd.processed>
<cfelse>
	<cfset url.frombatches = 1>
</cfif>
<cfset url.frombatches = 1>
<cftry>


<cfif url.type eq 1>
	
	<cfquery name="q_getProductsToTrack" datasource="product">
		SELECT count(*) cnt
		FROM `ftb_browse_pid` where type = 1
	</cfquery>
	<cfset request.total = q_getProductsToTrack.cnt>
	<cfset url.batches = ceiling(q_getProductsToTrack.cnt/100)+1>
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set total = #request.total#
		where groupsk = '#url.groupsk#'
	</cfquery>
	<cfloop from="#url.frombatches#" to="#url.batches#" index="batch">
	<cfquery name="q_getProductsToTrack" datasource="product">
		SELECT t.pid,t.type,0 as last_price
		FROM `ftb_browse_pid` t where type = 1
		order by record_ts desc
		limit #(batch-1)*100#,100
	</cfquery>
		<cfloop from="1" to="#q_getProductsToTrack.recordcount#" index="idx">
			<cftry>
				<cfif  structkeyExists(application,'#url.jobtype#') and application['#url.jobtype#'].abort>
					<cfquery name="runjob" datasource="#application.dsn#">
						update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
						failed = #request.failcnt#,status='ABORTED'
						where groupsk = '#url.groupsk#'
					</cfquery>
					<cfset structdelete(application,"#url.groupsk#")>
					<cfabort>
				</cfif>
			<cfcatch><cfabort></cfcatch></cftry>
			<cfset request.processed++ >
			<cftry>
				<cfset snooz(200)>
				<cfset azdata = obj.ItemLookup(q_getProductsToTrack.pid[idx])>
				<cfset azdata = obj.ConvertXmlToStruct(azdata,structnew())>
				<cfset details = obj.azDetails(azdata.Items.Item)>
				<cfset pid = details.pid>
				<cfset last_price = details.price>
				<cfquery name="addindb" datasource="#application.dsn#">
				 INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`) 
				VALUES ('#details.pid#',
						1,
						'#details.link#',
						'#details.image#',
						#details.price#,
						'#details.title#',
						'#details.description#',
						'BROWSE_TRACKER') 
				</cfquery>
				<cfquery name="addindb" datasource="#application.dsn#">
					INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
					VALUES ('#pid#',#last_price#,'INIT')
				</cfquery>
				<cfset request.insertcnt++ >
			<cfcatch>
				<cfset cfcatch.server = '#cgi.SERVER_NAME#'>
				<cfquery name="faillog" datasource="#application.dsn#">
					INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`,`groupsk`) VALUES
					('#request.sk#','#q_getProductsToTrack.pid[idx]#','browsetrackers',1,'#url.groupsk#')
				</cfquery>
				<cfset request.failcnt++ >
			</cfcatch>
			</cftry>
			<cfif request.processed%10 eq 0>
				<cfquery name="runjob" datasource="#application.dsn#">
					update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
					failed = #request.failcnt#
					where groupsk = '#url.groupsk#'
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop> 
</cfif>

<cfif url.type eq 0>
	
	<cfquery name="q_getProductsToTrack" datasource="product">
		SELECT count(*) cnt
		FROM `ftb_browse_pid` where type = 0
	</cfquery>
	<cfset request.total = q_getProductsToTrack.cnt>
	<cfset url.batches = ceiling(q_getProductsToTrack.cnt/100)+1>
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set total = #request.total#
		where groupsk = '#url.groupsk#'
	</cfquery>
	
	<cfloop from="#url.frombatches#" to="#url.batches#" index="batch">
		<cfquery name="q_getProductsToTrack" datasource="product">
			SELECT t.pid,t.type,0 as last_price
			FROM `ftb_browse_pid` t where type = 0
			order by record_ts desc
			limit #(batch-1)*100#,100
		</cfquery>
	
		<cfloop from="1" to="#q_getProductsToTrack.recordcount#" index="idx1">
			<cftry>
				<cfif  structkeyExists(application,'#url.jobtype#') and application['#url.jobtype#'].abort>
					<cfquery name="runjob" datasource="#application.dsn#">
						update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
						failed = #request.failcnt#,status='ABORTED'
						where groupsk = '#url.groupsk#'
					</cfquery>
					<cfset structdelete(application,"#url.groupsk#")>
					<cfabort>
				</cfif>
			<cfcatch><cfabort></cfcatch></cftry>
			<cfset request.processed++ >
			<cftry>
				<cfset data="#obj.flipkartPID(q_getProductsToTrack.pid[idx1])#">
				<cfset snooz(100)>
				<cfset data="#deserializeJSON(data)#">
				<cfset details = obj.fkDetails(data.productBaseInfo.productAttributes)>
				<cfset pid = details.pid>
				<cfset last_price = details.price>
				<cfquery name="addindb" datasource="#application.dsn#">
				 INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`) 
				VALUES ('#details.pid#',
						0,
						'#details.link#',
						'#details.image#',
						#details.price#,
						'#details.title#',
						'#details.description#',
						'BROWSE_TRACKER') 
				</cfquery>
				<cfquery name="addindb" datasource="#application.dsn#">
					INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
					VALUES ('#pid#',#last_price#,'INIT')
				</cfquery>
				<cfset request.insertcnt++ >
			<cfcatch>
				<cfset cfcatch.server = '#cgi.SERVER_NAME#'>
				<cfquery name="faillog" datasource="#application.dsn#">
					INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`,`groupsk`) VALUES
					('#request.sk#','#q_getProductsToTrack.pid[idx1]#','browsetrackers',0,'#url.groupsk#')
				</cfquery>
				<cfset request.failcnt++ >
			</cfcatch>
			</cftry>
			<cfif request.processed%10 eq 0>
				<cfquery name="runjob" datasource="#application.dsn#">
					update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
					failed = #request.failcnt#
					where groupsk = '#url.groupsk#'
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
		failed = #request.failcnt#,status='FINISHED'
		where groupsk = '#url.groupsk#'
	</cfquery>
<cfcatch>
	<cfdump var="#cfcatch#">
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
		failed = #request.failcnt#,status='APPCRASH_ABORT'
		where groupsk = '#url.groupsk#'
	</cfquery>
</cfcatch>
</cftry>

<!--- 
<cfabort>


<cfset application.trackerrors = '#GetDirectoryFromPath(GetCurrentTemplatePath())#trackerrors\'>
<cfset request.sk = dateformat(now(),"YYYY-MM-DD")>
<cfset obj = createobject("component","cmp")>

<cffunction name="snooz" access="public" output="false" returntype="void" hint="Leverages Java's sleep() function">
   <cfargument name="timeToSleep" type="numeric" required="true" />

   <cfscript>
      createObject("java", "java.lang.Thread").sleep(arguments.timeToSleep);    //sleep time in milliseconds
      return;
   </cfscript>
</cffunction>

<cfset request.errors = arraynew(1)>
<cfset request.insertcnt = 0>
<cfset request.failcnt = 0>
<cfif isdefined("url.requestsk") and len(url.requestsk)>
	<cfset request.sk = url.requestsk>
</cfif>
<cfquery name="addindb" datasource="#application.dsn#">
		SELECT bp.pid FROM `ftb_browse_pid` bp, ftb_trackers_pid tp where bp.pid = tp.pid
</cfquery>
	
<cfquery name="del" datasource="#application.dsn#" result="res">
		delete from `ftb_browse_pid`
		where pid in (<cfqueryPARAM value = "#valueList(addindb.pid)#" CFSQLType="cf_sql_char" list="true">)
</cfquery>

<cfquery name="q_getProductsToTrack" datasource="product">
	SELECT pid,type FROM `ftb_browse_pid` where type = 1
</cfquery>

<cfdump var="#q_getProductsToTrack.recordcount#">
<cfflush>

<cfloop from="1" to="#q_getProductsToTrack.recordcount#" index="idx">
	
	<cfoutput>@ </cfoutput><CFFLUSH>
	<cftry>
		<cfset snooz(250)>
		<cfset azdata = obj.ItemLookup(q_getProductsToTrack.pid[idx])>
		<cfset azdata = obj.ConvertXmlToStruct(azdata,structnew())>
		<cfset details = obj.azDetails(azdata.Items.Item)>
		<cfset pid = details.pid>
		<cfset last_price = details.price>
		<cfquery name="addindb" datasource="#application.dsn#">
				 INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`) 
				VALUES ('#details.pid#',
						1,
						'#details.link#',
						'#details.image#',
						#details.price#,
						'#details.title#',
						'#details.description#',
						'BROWSE_TRACKER') 
				</cfquery>
			<cfquery name="addindb" datasource="#application.dsn#">
				INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
				VALUES ('#details.pid#',#details.price#,'INIT')
			</cfquery>
			+
	<cfcatch>
		-
		<cfquery name="faillog" datasource="#application.dsn#">
			INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`) VALUES
			('#request.sk#','#q_getProductsToTrack.pid[idx]#','browsetracker',1)
		</cfquery>
		<cfquery name="del" datasource="#application.dsn#" result="res">
			delete from `ftb_browse_pid`
			where pid = '#q_getProductsToTrack.pid[idx]#'
		</cfquery>
	</cfcatch>
	<cfflush>
	</cftry>
</cfloop>

<cfquery name="q_getProductsToTrack" datasource="product">
	SELECT pid,type FROM `ftb_browse_pid` where type = 0
</cfquery>

<cfdump var="#q_getProductsToTrack.recordcount#">
<cfflush>

<cfloop from="1" to="#q_getProductsToTrack.recordcount#" index="idx1">
	<cftry>
		<!--- <cfoutput>Getting Data for: #q_getProductsToTrack.pid[idx1]#<BR></cfoutput>
		<CFFLUSH> --->
		<cfset data="#obj.flipkartPID(q_getProductsToTrack.pid[idx1])#">
		<cfset data="#deserializeJSON(data)#">
		<cfset details = obj.fkDetails(data.productBaseInfo.productAttributes)>
		<cfset pid = details.pid>
		<cfset last_price = details.price>
		<cfquery name="addindb" datasource="#application.dsn#">
				 INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`) 
				VALUES ('#details.pid#',
						0,
						'#details.link#',
						'#details.image#',
						#details.price#,
						'#details.title#',
						'#details.description#',
						'BROWSE_TRACKER') 
				</cfquery>
			<cfquery name="addindb" datasource="#application.dsn#">
				INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
				VALUES ('#details.pid#',#details.price#,'INIT')
			</cfquery>
			+
	<cfcatch>
		-
		<cfquery name="faillog" datasource="#application.dsn#">
			INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`) VALUES
			('#request.sk#','#details.pid#','browsetracker',0)
		</cfquery>
		<cfquery name="del" datasource="#application.dsn#" result="res">
			delete from `ftb_browse_pid`
			where pid = '#details.pid#'
		</cfquery>
	</cfcatch>
	<cfoutput><cfflush></cfoutput>
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
	
</cffunction> --->