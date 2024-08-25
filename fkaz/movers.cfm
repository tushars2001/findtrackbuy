<cfparam name="url.type" default="1">
<cfparam name="url.frombatches" default="">
<cfparam name="url.groupsk" default="">
<cfset request.sk = dateformat(now(),"YYYY-MM-DD")>
<cfset obj = createobject("component","cmp")>
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
		select * `ftb_jobtracker`
		where groupsk = '#url.groupsk#'
	</cfquery>
	<cfset request.insertcnt = getd.inserted>
	<cfset request.failcnt = getd.failed>
	<cfset request.processed = getd.processed>
<cfelse>
	<cfset url.frombatches = 1>
</cfif>

<cfquery name="getMovers" datasource="#application.dsn#">
	select count(*) as cnt from (
		SELECT pid, COUNT( pid ) 
			FROM  `ftb_product_tracker` 
			GROUP BY pid
			HAVING COUNT( pid ) >1
	) o
</cfquery>
<cfset request.total = getMovers.cnt>
<cfquery name="runjob" datasource="#application.dsn#">
	update `ftb_jobtracker` set total = #request.total#
	where groupsk = '#url.groupsk#'
</cfquery>

<cfset toProcess = getMovers.cnt>
<cfset lot = 100>
<cfset batches = ceiling(toProcess/lot)>

<cfloop from="#url.frombatches#" to="#batches#" index="batch">
	<cftry>
		<cfoutput>batch : #batch#</cfoutput>
		<cfquery name="getBatchIds" datasource="#application.dsn#">
				SELECT pid 
					FROM  `ftb_product_tracker`
					GROUP BY pid
					HAVING COUNT( pid ) >1
					limit #(batch-1)*lot#,#lot#
		</cfquery>
		
		<cfquery name="getBatchData" datasource="#application.dsn#">
				SELECT * FROM  `ftb_product_tracker` 
				where pid in (
					<cfqueryPARAM value = "#valueList(getBatchIds.pid)#" CFSQLType="cf_sql_char" list="true">
				)
							AND record_ts
			BETWEEN DATE_ADD( current_date, INTERVAL -1
			MONTH ) 
			AND DATE_ADD( CURRENT_DATE, INTERVAL 1 DAY ) 
		</cfquery>
		<cfloop from="1" to="#getBatchIds.recordcount#" index="record">
			<cftry>
				<cfset request.processed ++>
				<cfquery name="getRecord" dbtype="query">
					select * from getBatchData
					where pid = '#getBatchIds.pid[record]#'
					order by record_ts desc
				</cfquery>
				<cfset base = getRecord.price[1]>
				<cfset was_at_on = dateAdd('d',-1,getRecord.record_ts[1])>
				<cfset minval = base>
				<cfloop query="getRecord">
					<cfif getRecord.price neq base>
						<cfset minval = getRecord.price>
						<cfbreak>
					</cfif>
				</cfloop>
				
				<!--- <cfset l = ListSort(ListRest(ListRemoveDuplicates(valueList(getRecord.price))),"numeric")>
				<cfset basedup = listfind(l,base)>
				l0: <cfdump var="#l#">
				<cfif basedup>
					<cfset l = ListDeleteAt(l,basedup)>
				</cfif>
				l: <cfdump var="#l#">
				<cfset minval = ListFirst(l)>
				<cfif not len(minval)>
					<cfset minval = base>
				</cfif> --->
				<cfset difference = base-minval>
				<cfset track_count = getRecord.recordcount>
				<cfset variance = DecimalFormat(((difference)/minval)*100)>
				<cfset variance = replace(variance,',','','all')>

				<cfset minval = DecimalFormat(minval)>
				<cfset minval = replace(minval,',','','all')>

				<cfset pid = getBatchIds.pid[record]>
					<cftransaction>
					<cfquery name="getBatchData" datasource="#application.dsn#">
						delete from `ftb_movers` where `pid` ='#pid#'
					</cfquery>
					<cfquery name="getBatchData" datasource="#application.dsn#">
						INSERT INTO `ftb_movers`(`pid`, `variance`, `track_count`, `difference`,`was_at`,was_at_on) 
						values ('#pid#',#variance#,#track_count#,#difference#,#minval#,'#dateFormat(was_at_on,"yyyy-mm-dd")#')
					</cfquery>
					+
					<cfset request.insertcnt ++>
					</cftransaction>
			<cfcatch>
			</cfcatch>
			</cftry>
			<cfif request.processed%10 eq 0>
				<cfquery name="runjob" datasource="#application.dsn#">
					update `ftb_jobtracker` set processed = #request.processed#, inserted = #request.insertcnt#,
					failed = #request.failcnt#
					where groupsk = '#url.groupsk#'
				</cfquery>
			</cfif>
			<cfflush>
		</cfloop>
	<cfcatch>
		<cfdump var="OUTER">
		<cfdump var="#cfcatch#">
	</cfcatch>
	</cftry>
	
</cfloop>
<cfquery name="runjob" datasource="#application.dsn#">
	update `ftb_jobtracker` set status='FINISHED'
	where groupsk = '#url.groupsk#'
</cfquery>