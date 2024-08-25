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

<cfif len(url.frombatches)>
	<cfquery name="getd" datasource="#application.dsn#">
		select * from `ftb_jobtracker`
		where groupsk = '#url.groupsk#'
	</cfquery>
	<cfset request.insertcnt = getd.inserted>
	<cfset request.failcnt = getd.failed>
	<cfset request.processed = getd.processed>
<cfelse>
	<cfset url.frombatches = 1>
</cfif>

<cftry>


<cfif url.type eq 1>
	
	<cfquery name="q_getProductsToTrack" datasource="product">
		SELECT count(*) cnt
		from ftb_movers m, ftb_trackers_pid t
		where m.pid=t.pid and t.type=1 AND available =0
	</cfquery>
	<cfset request.total = q_getProductsToTrack.cnt>
	<cfset url.batches = ceiling(q_getProductsToTrack.cnt/100)+1>
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set total = #request.total#
		where groupsk = '#url.groupsk#'
	</cfquery>
	
	<cfloop from="#url.frombatches#" to="#url.batches#" index="batch">
	<cfquery name="q_getProductsToTrack" datasource="product">
		SELECT t.pid,t.type,t.link,t.last_price
		<!--- (select price from  ftb_product_tracker where record_id in (SELECT MAX( record_id ) FROM ftb_product_tracker where pid = t.pid)) as last_price   --->
		from ftb_movers m, ftb_trackers_pid t
		where m.pid=t.pid and t.type=1 AND available =0
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
				<cfif len(pid) and last_price gt 0 and (last_price neq q_getProductsToTrack.last_price[idx]) and last_price neq 'NA'>
					<cfquery name="addindb" datasource="#application.dsn#">
						INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
						VALUES ('#pid#',#last_price#,'#request.sk#')
					</cfquery>
					<cfquery name="updateMain" datasource="#application.dsn#">
						update `ftb_trackers_pid` set last_price = #last_price#, last_tracked = CURRENT_TIMESTAMP
						where pid = '#pid#'
					</cfquery>
					<cfset request.insertcnt++ >
				</cfif>
				<cfif structKeyExists(details,"available")>
					<cfquery name="updateMain" datasource="#application.dsn#">
						update `ftb_trackers_pid` set available = #details.available#
						where pid = '#pid#'
					</cfquery>
				</cfif>
			<cfcatch>
				<cfquery name="faillog" datasource="#application.dsn#">
					INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`,`groupsk`) VALUES
					('#request.sk#','#q_getProductsToTrack.pid[idx]#','movers_trackers',1,'#url.groupsk#')
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
		from ftb_movers m, ftb_trackers_pid t
		where m.pid=t.pid and t.type=0 AND available =0
	</cfquery>
	<cfset url.batches = ceiling(q_getProductsToTrack.cnt/100)+1>
	<cfset request.total = q_getProductsToTrack.cnt>
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set total = #request.total#
		where groupsk = '#url.groupsk#'
	</cfquery>
	
	
	<cfloop from="#url.frombatches#" to="#url.batches#" index="batch">
	
		<cfquery name="q_getProductsToTrack" datasource="product"  timeout ="120">
			SELECT t.pid,t.type,t.link,t.last_price
			<!--- (select price from  ftb_product_tracker where record_id in (SELECT MAX( record_id ) FROM ftb_product_tracker where pid = t.pid)) as last_price   --->
			from ftb_movers m, ftb_trackers_pid t
			where m.pid=t.pid and t.type=0 AND available =0
			ORDER BY m.variance
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
				<cfif len(pid) and last_price gt 0 and (last_price neq q_getProductsToTrack.last_price[idx1])>
					<cfquery name="addindb" datasource="#application.dsn#">
						INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
						VALUES ('#pid#',#last_price#,'#request.sk#')
					</cfquery>
					<cfquery name="updateMain" datasource="#application.dsn#">
						update `ftb_trackers_pid` set last_price = #last_price#, last_tracked = CURRENT_TIMESTAMP
						where pid = '#pid#'
					</cfquery>
					<cfset request.insertcnt++ >
				</cfif>
				<cfif structKeyExists(details,"available")>
					<cfquery name="updateMain" datasource="#application.dsn#">
						update `ftb_trackers_pid` set available = #details.available#
						where pid = '#pid#'
					</cfquery>
				</cfif>
			<cfcatch>
				<cfset cfcatch.server = '#cgi.SERVER_NAME#'>
				<cfquery name="faillog" datasource="#application.dsn#">
					INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`,`groupsk`) VALUES
					('#request.sk#','#q_getProductsToTrack.pid[idx1]#','movers_trackers',0,'#url.groupsk#')
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
