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
<cfparam name="url.batches" default="1">
<cfparam name="url.parts" default="0">
<cfparam name="url.pagefrom" default="1">
<cfparam name="url.pageto" default="10">
<cfset batches = url.batches>
<cfloop from="#batches#" to="#batches#" index="batch">
	<cftry>
			<cfset batchPagesto = url.pageto>
			<cfset batchPagesfrom = url.pagefrom>
				<cfquery name="q_getProductsToTrack" datasource="product">
					SELECT fl.pid, fl.type, t.link, t.last_price, fl.record_id
					FROM  `ftb_fail_log` fl, ftb_trackers_pid t
					WHERE fl.pid = t.pid
					AND t.type =0
					AND track_group_sk like  '#request.sk#%'
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
						<cfquery name="succesdelete" datasource="#application.dsn#">
							delete from ftb_fail_log where record_id = #q_getProductsToTrack.record_id[idx1]#
						</cfquery>
					<cfcatch>
						-
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
