
<cfquery name="q_getProductsToTrack" datasource="product">
		select count(*) as cnt from ftb_trackers_pid
		where active = 1
		and type = 0
</cfquery>	
	
<cfset pages = ceiling(q_getProductsToTrack.cnt/100)>
<cfset batches = ceiling(pages/10)>
<cfloop from="1" to="#batches#" index="batch">
	<cfoutput>Batch : #Batch# Started<br></cfoutput><cfflush>
	<cfquery name="getrec" datasource="#application.dsn#">
			select max(record_id) mx, min(record_id) m from (
			select record_id from ftb_trackers_pid
					where active = 1
					and type = 0
					order by record_id asc
					limit #(batch-1)*1000#,1000
			    ) b
	</cfquery>
	<cfquery name="updateBatch" datasource="#application.dsn#" result="res">
			update ftb_trackers_pid set batch = #batch#
			where active = 1 and type = 0
			and (record_id between #getrec.m# and #getrec.mx#)
	</cfquery>
	<cfoutput>Batch : #Batch# completed<br></cfoutput><cfdump var="#res#"><cfflush>
</cfloop>
