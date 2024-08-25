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
<cfparam name="url.frombatches" default="1">
<cfparam name="url.groupsk" default="">
<cfparam name="url.batches" default="">

<cfset request.errors = arraynew(1)>
<cfset request.insertcnt = 0>
<cfset request.failcnt = 0>
<cfset request.processed = 0>
<cfset request.total = 0>

<cfif isdefined("url.requestsk") and len(url.requestsk)>
	<cfset request.sk = url.requestsk>
</cfif>

<cfif len(url.frombatches) and url.frombatches neq 1>
	<cfquery name="getd" datasource="#application.dsn#">
		select * from `ftb_jobtracker`
		where groupsk = '#url.groupsk#'
	</cfquery>
	<cfset request.insertcnt = getd.inserted>
	<cfset request.failcnt = getd.failed>
	<cfset request.processed = getd.processed>
</cfif>

<cftry>


<cfif url.type eq 1>
	
		<cfquery name="q_getProductsToTrack" datasource="product">
			SELECT count(*) cnt
			 from ftb_trackers_pid t left join ftb_movers m on m.pid=t.pid
		where m.pid is null and t.type=1
		</cfquery>
		<cfset request.total = q_getProductsToTrack.cnt>
		<cfset url.batches = ceiling(q_getProductsToTrack.cnt/100)+1>
		<cfquery name="runjob" datasource="#application.dsn#">
			update `ftb_jobtracker` set total = #request.total#
			where groupsk = '#url.groupsk#'
		</cfquery>
	
	<cfloop from="#url.frombatches#" to="#url.batches#" index="batch">
	<cfquery name="q_getProductsToTrack" datasource="product">
		select t.pid,t.type,t.link,t.last_price,t.titletracked, t.brandtracked
					 from ftb_trackers_pid t left join ftb_movers m on m.pid=t.pid
		where m.pid is null and t.type=1
		limit #(batch-1)*100#,100
		<!--- SELECT t.pid,t.type,t.link,t.last_price
		<!--- (select price from  ftb_product_tracker where record_id in (SELECT MAX( record_id ) FROM ftb_product_tracker where pid = t.pid)) as last_price   --->
		from ftb_movers m, ftb_trackers_pid t
		where m.pid=t.pid and t.type=1
		limit #(batch-1)*100#,100 --->
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
				<cfif structKeyExists(details,"available") and not details.available>
					<cfquery name="updateMain" datasource="#application.dsn#">
						update `ftb_trackers_pid` set available = #details.available#
						where pid = '#pid#'
					</cfquery>
				</cfif>
				<cfif not q_getProductsToTrack.titletracked[idx]>
					<cfquery name="updatetitle" datasource="#application.dsn#">
						update `ftb_trackers_pid` set titlelong = '#details.title#', 
						description='#REReplace(details.description,"[^0-9A-Za-z ]","","all")#'
						, available = #details.available#, titletracked=1
						where pid = '#pid#'
					</cfquery>
				</cfif>
				<cfif not q_getProductsToTrack.brandtracked[idx]>
					<cftry>
						<cfset brand ="">
						<cfset product ="">
						<cfset model ="">
						<cftry><cfset brand = azdata.Items.Item.ItemAttributes.Brand><cfcatch></cfcatch></cftry>
						<cftry><cfset product = azdata.Items.Item.ItemAttributes.ProductTypeName><cfcatch></cfcatch></cftry>
						<cftry><cfset model = azdata.Items.Item.ItemAttributes.Model><cfcatch></cfcatch></cftry>
						<cfquery name="updatetitle" datasource="#application.dsn#">
							update `ftb_trackers_pid` set brand = '#brand#', 
							product='#product#', model = '#model#', brandtracked=1
							where pid = '#pid#'
						</cfquery>
					<cfcatch>
					</cfcatch>
					</cftry>
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
			 from ftb_trackers_pid t left join ftb_movers m on m.pid=t.pid
				where m.pid is null and t.type=0
		</cfquery>
		<cfset request.total = q_getProductsToTrack.cnt>
		<cfset url.batches = ceiling(q_getProductsToTrack.cnt/100)+1>
		<cfquery name="runjob" datasource="#application.dsn#">
			update `ftb_jobtracker` set total = #request.total#
			where groupsk = '#url.groupsk#'
		</cfquery>
	
	
	<cfloop from="#url.frombatches#" to="#url.batches#" index="batch">
	
		<cfquery name="q_getProductsToTrack" datasource="product"  timeout ="120">
			select t.pid,t.type,t.link,t.last_price,t.titletracked, t.brandtracked
					 from ftb_trackers_pid t left join ftb_movers m on m.pid=t.pid
				where m.pid is null and t.type=0
				limit #(batch-1)*100#,100
			<!--- SELECT t.pid,t.type,t.link,t.last_price
			<!--- (select price from  ftb_product_tracker where record_id in (SELECT MAX( record_id ) FROM ftb_product_tracker where pid = t.pid)) as last_price   --->
			from ftb_movers m, ftb_trackers_pid t
			where m.pid=t.pid and t.type=0
			ORDER BY m.variance
			limit #(batch-1)*100#,100 --->
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
				<cfset data=obj.flipkartPID(q_getProductsToTrack.pid[idx1],'findtrack','41991286028d42328c43eea3a27ac5c3')>
				<cfset snooz(100)>
				<cfset data=deserializeJSON(data)>
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
				<cfif structKeyExists(details,"available") and not details.available>
					<cfquery name="updateMain" datasource="#application.dsn#">
						update `ftb_trackers_pid` set available = #details.available#
						where pid = '#pid#'
					</cfquery>
				</cfif>
				<cfif not q_getProductsToTrack.titletracked[idx1]>
					<cfquery name="updatetitle" datasource="#application.dsn#">
						update `ftb_trackers_pid` set titlelong = '#details.title#', 
						description='#REReplace(details.description,"[^0-9A-Za-z ]","","all")#'
						, available = #details.available#, titletracked=1
						where pid = '#pid#'
					</cfquery>
				</cfif>
				<cfif not q_getProductsToTrack.brandtracked[idx1]>
					<cftry>
						<cfset brand ="">
						<cfset product ="">
						<cfset model ="">
						<cftry><cfset brand = data.productBaseInfo.productAttributes.productBrand><cfcatch></cfcatch></cftry>
						<cftry><cfset product = ListLast(data.productBaseInfo.productIdentifier.categoryPaths.categoryPath[1][1].title,'>')><cfcatch></cfcatch></cftry>
						<cftry><cfset model = data.productBaseInfo.productAttributes.title><cfcatch></cfcatch></cftry>
						<cfquery name="updatetitle" datasource="#application.dsn#">
							update `ftb_trackers_pid` set brand = '#brand#', 
							product='#product#', model = '#model#', brandtracked=1
							where pid = '#pid#'
						</cfquery>
					<cfcatch>
					</cfcatch>
					</cftry>
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
	<cfdump var="#request#">
	<cfquery name="runjob" datasource="#application.dsn#">
		update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
		failed = #request.failcnt#,status='APPCRASH_ABORT'
		where groupsk = '#url.groupsk#'
	</cfquery>
</cfcatch>
</cftry>


<cfabort>




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


<cfset request.errors = arraynew(1)>
<cfset request.insertcnt = 0>
<cfset request.failcnt = 0>
<cfif isdefined("url.requestsk") and len(url.requestsk)>
	<cfset request.sk = url.requestsk>
</cfif>

<cfset fkTrackAPI()>
<!--- <cfset fkTrackRest()> --->



<cffunction name="fkTrackAPI">

	<!--- <cfquery name="getApis" datasource="#application.dsn#">
		select apiname, apiurl from ftb_fkapi		
	</cfquery> --->
	<!--- <cfquery name="q_getProductsToTrack" datasource="product">
		select count(*) as cnt from ftb_trackers_pid
		where active = 1
		and type = 0
	</cfquery>	
	
	<cfset pages = ceiling(q_getProductsToTrack.cnt/100)>
	<cfset batches = ceiling(pages/10)>
	<cfoutput>pages #pages# TO TRACK. #batches# batches TO TRACK<br></cfoutput><cfflush> --->
<cfparam name="url.batches" default="0">
<cfparam name="url.parts" default="0">
<cfparam name="url.pagefrom" default="1">
<cfparam name="url.pageto" default="10">
<cfset batches = url.batches>
<cfset request.sk = "#request.sk#_#batches#">
<cfloop from="#batches#" to="#batches#" index="batch">
	<cfoutput>Batch: #batch#<br></cfoutput><cfflush>
	<cftry>
			<cfset batchPagesto = url.pageto>
			<cfset batchPagesfrom = url.pagefrom>
			<cfloop from="#batchPagesfrom#" to="#batchPagesto#" index="batchpage">
				<cfquery name="q_getProductsToTrack" datasource="product">
					select t.pid,t.type,t.link,
					(select price from  ftb_product_tracker where record_id in (SELECT MAX( record_id ) FROM ftb_product_tracker where pid = t.pid)) as last_price 
					 from ftb_trackers_pid t
					where  batch=#batch#
					limit #(batchpage-1)*100#,100
				</cfquery>
				<cfoutput>Quired: batch#batch# Page:#batchpage# count:#q_getProductsToTrack.recordcount#<br></cfoutput><cfflush>
				<cfloop from="1" to="#q_getProductsToTrack.recordcount#" index="idx1">
					<cftry>
						<!--- <cfoutput>Getting Data for: #q_getProductsToTrack.pid[idx1]#<BR></cfoutput>
						<CFFLUSH> --->
						<cfset data="#obj.flipkartPID(q_getProductsToTrack.pid[idx1])#">
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
							+
						</cfif>
					<cfcatch>
						<cfset cfcatch.server = '#cgi.SERVER_NAME#'>
						<cfquery name="faillog" datasource="#application.dsn#">
							INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`,`type`) VALUES
							('#request.sk#','#q_getProductsToTrack.pid[idx1]#','#serializeJSON(cfcatch)#',0)
						</cfquery>
						<!--- <cfif structkeyExists(cfcatch,'Detail') and findnoCase('Duplicate entry',cfcatch.Detail) and isdefined("pid")>
							<cfquery name="updateMain" datasource="#application.dsn#">
								update `ftb_trackers_pid` set last_tracked = CURRENT_TIMESTAMP
								where pid = '#pid#'
							</cfquery>
						</cfif> --->
					</cfcatch>
					<cfoutput><cfflush></cfoutput>
					</cftry>
				</cfloop>
				<cfoutput>#batchpage# page done: Batch: #batch# <br></cfoutput>
			</cfloop>
	<cfcatch>
		<!--- <cfset st.batch = batch>
		<cfset st.cfcatch = cfcatch> --->
		<!--- <cfset dumplog(st)> --->
	</cfcatch>
	</cftry>

</cfloop>
	<!--- 
<cfflush>
	

<cfloop from="0" to="#pages#" index="pageidx">
	<cfquery name="q_getProductsToTrack" datasource="product">
		select pid,type,link from ftb_trackers_pid
		where active = 1
		and type = 0
		limit #pageidx*100#,100
	</cfquery>	
	
	
	
	<cfoutput>#pageidx+1# DONE <br>Inserted: #request.insertcnt# -- Failed: #request.failcnt#<br></cfoutput>
	<cfset dumplog(request.errors)>
	<cfset arrayclear(request.errors)>
	<cfflush>
	
</cfloop>
 --->

	
	<!--- <cfloop from="1" to="#getApis.recordcount#" index="out1">
		
		<cftry>
			
			<cfhttp url="#getApis.apiurl[out1]#" result="res" method="get">
				<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
				<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
			</cfhttp>

			<cfset data = deserializeJSON(res.filecontent)>	

			<cfloop from="1" to="#arraylen(data.productInfoList)#" index="out2">
				<cftry>
					<cfset details = obj.fkDetails(data.productInfoList[out2].productBaseInfo.productAttributes)>
					<cfset pid = details.pid>
					<cfset last_price = details.price>

					<cfquery name="addindb" datasource="#application.dsn#">
						INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
						VALUES ('#pid#',#last_price#,'#request.sk#')
					</cfquery>
					<cfset request.insertcnt = request.insertcnt+1>
					<cfif request.insertcnt mod 10 eq 0>
						<cfoutput>inserted: #request.insertcnt# <br></cfoutput>
						<cfflush>
					</cfif>
					
				<cfcatch type="database">
					<cftry>
						<cfif isdefined("pid")>
							<cfquery name="faillog" datasource="#application.dsn#">
								INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`) VALUES
								('#request.sk#','#pid#','#cfcatch.Message#')
							</cfquery>
						<cfelse>
							<cfthrow type="Custom" message="Unable to fail log" detail="PID was not there" />
						</cfif>
					<cfcatch>
						<cfset st.errorlvl = 3>
						<cfset st.cfcatch = structcopy(cfcatch)>
						<cfset arrayappend(request.errors,structcopy(st))>
					</cfcatch>
					</cftry>
					<cfset st.errorlvl = 2>
					<cfset st.cfcatch = structcopy(cfcatch)>
					<cfset arrayappend(request.errors,structcopy(st))>
				</cfcatch>
				<cfcatch>
					<cfset st.errorlvl = 2>
					<cfset st.cfcatch = structcopy(cfcatch)>
					<cfset arrayappend(request.errors,structcopy(st))>
					<cfset dumplog(st)>
				</cfcatch>
				</cftry>		
		</cfloop>
		
		<cfcatch>
			<cfset st.errorlvl = 1>
			<cfset st.cfcatch = structcopy(cfcatch)>
			<cfset arrayappend(request.errors,structcopy(st))>
			<cfset dumplog(st)>
		</cfcatch>
		</cftry>
	
	</cfloop>
	
	<cfset dumplog(request.errors,"final")> --->
	
</cffunction>

<cffunction name="fkTrackRest">
	<cfset var errors = arraynew(1)>
	<cfset var dataArray = arrayNew(1)>
	<cfset var getRest = arraynew(1)>
	
	<cftry>
		<cfquery name="getRest" datasource="#application.dsn#">
			select pid, type from ftb_trackers_pid
			where pid not in (
				select pid from ftb_product_tracker
				where track_group_sk = '#request.sk#'
			)
		</cfquery>
	<cfcatch>
		<cfset st.errorlvl = 1>
		<cfset st.cfcatch = structcopy(cfcatch)>
		<cfset arrayappend(errors,structcopy(st))>
		<cfset dumplog(st)>
	</cfcatch>
	</cftry>
	
	
	<cfloop from="1" to="#getRest.recordcount#" index="idx">
		<cftry>
			<cfset trackdata = obj.flipkartPID(getRest.pid[idx])>
			<cfset trackdata = DeserializeJSON(trackdata)>
			<cfset dbdata.price = trackdata.productBaseInfo.productAttributes.sellingPrice.amount>
			<cfset dbdata.pid = getRest.pid[idx]>
			<cfset arrayAppend(dataArray,structcopy(dbdata))>
			<cfset ret = obj.insertTrackData(dataArray)>
		<cfcatch>
			<cfquery name="faillog" datasource="#application.dsn#">
				INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`) VALUES
				('#request.sk#','#arguments.productsToTrack.pid[idx]#','#cfcatch.Message#')
			</cfquery>
			<cfset st.errorlvl = 2>
			<cfset st.cfcatch = structcopy(cfcatch)>
			<cfset arrayappend(errors,structcopy(st))>
			<cfset dumplog(st)>
		</cfcatch>
		</cftry>	
		
	</cfloop>

</cffunction>

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
		
	
	<cfcatch>
	</cfcatch>
	</cftry>
	<cfflush>
	
</cffunction>
