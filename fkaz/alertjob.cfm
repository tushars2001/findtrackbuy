<cfquery name="getAlretedUsers" datasource="#application.dsn#">
	select distinct a.user_sk,u.email from ftb_alerts a, ftb_users u where a.user_sk = u.user_sk
</cfquery>
	<cfset logarr = arraynew(1)>
	<cfloop from ="1" to="#getAlretedUsers.recordcount#" index="idx">
	<cfset e.email_group_sk = createuuID()>
	<cfsavecontent variable="content">
	<html>
		<head>
			<style>
				 body{
					margin: 0;
					padding: 0;
					font-family:'Verdana', Verdana, sans-serif;
					font-size:small;
					}
					.title{
						font-weight:bold;
					}
			</style>
		</head>
		<body>
			<div style="color:gray;font-size:large;border:20px solid white;">Find.Track.Buy.<span style="font-size:small">alerts</span></div>
			<div style="font-size:small;border:20px solid white;width:800px">
			Dear User,
			<br><br>
			You are tracking products on FindTrackBuy.com and we are excited to send you this alert about the price drops as per you choose your alert settings. 
			Please find below details:
			</div>
	
			<cfquery name="getUserAlerts" datasource="#application.dsn#">
				SELECT a . * , u.email, t.last_price,t.link, t.image,t.title 	
				FROM  `ftb_alerts` a, ftb_users u, ftb_trackers_pid t
				WHERE u.user_sk = a.user_sk and t.pid = a.pid and u.user_sk = '#getAlretedUsers.user_sk[idx]#'
				and t.last_price <= a.rangefrom
				and DATE_ADD( CURDATE() , INTERVAL -7 DAY ) >= IFNULL(a.last_sent,DATE_ADD( CURDATE() , INTERVAL -10 DAY ))
			</cfquery>
			
			<cfset records = valueList(getUserAlerts.record_id)>
			
			<cfloop from="1" to="#getUserAlerts.recordcount#" index="idx2">
				<cfset e.email_sk = createuuID()>
				<cfset e.pid = getUserAlerts.pid[idx2]>
				<cfset e.price_before = getUserAlerts.price[idx2]>
				<cfset e.price_after = getUserAlerts.last_price[idx2]>
				<cfset e.user_sk = getAlretedUsers.user_sk[idx]>
				<cfset arrayappend(logarr,structcopy(e))>
				<div class="wrapper" style="position:relative;border:20px solid white;">
				<cfoutput>
					<div style="float:left; border-right:30px solid white">
						<div>
							<a href="#getUserAlerts.link[idx2]#">#getUserAlerts.title[idx2]#</a>
						</div>
						<div style="text-align:center">
							<a href="#getUserAlerts.link[idx2]#"><img width="100" height="100" src="#getUserAlerts.image[idx2]#"></a>
						</div>
					</div>
					<div style="float:left;">
						<div>
							<p>When you tracked, the price of the product was <span style="color:red;font-weight:bold">Rs. #getUserAlerts.price[idx2]#</span></p>
							<p>Now the price came down to <span style="color:red;font-weight:bold">Rs. #getUserAlerts.last_price[idx2]#</span></p>
						</div>
						<a href="#getUserAlerts.link[idx2]#">Buy Now</a>
					</div>
				</cfoutput>
				</div>
				<div style="clear: both; height:30px"></div>
			</cfloop>
		
		<div style="font-size:small;border:20px solid white;">
			You can visit us, track more products, login and check out your dashboard and update your alerts settings.
			<br><br>
			Best Regards,<br>
			<cfoutput><a href="http://FindTrackBuy.com/"></cfoutput>
			FindTrackBuy.com Team
			</a>
			</div>
		</body>
	</html>
	</cfsavecontent>
	<cfif getUserAlerts.recordcount>
		<cfoutput><br>Sending Mail to #getAlretedUsers.email[idx]# ********************</cfoutput>
		<!------<cfmail from="find.track.buy@quirkycrackers.com" to="#getAlretedUsers.email[idx]#" bcc="tushars2001@gmail.com" type="html" failto="tushars2001@gmail.com" subject="Price Drop Alerts!">
			#content#	
		</cfmail>
		<cfoutput><br>*********************************************</cfoutput>
		<cfquery name="updateAlerts" datasource="#application.dsn#">
			update ftb_alerts set sentcount=sentcount+1, last_sent=curdate() 
			where record_id in (
				<cfqueryPARAM value = "#records#" CFSQLType="cf_sql_integer" list="true">
			)
		</cfquery>------>
		<cfoutput>#content#</cfoutput>
	</cfif>
	</cfloop>
	<!--- <cftry>
		<cfloop from="1" to="#arraylen(logarr)#" index="idx">
			<cftry>
				<cfquery name="logemail" datasource="#application.dsn#">
					INSERT INTO `ftb_emailhistory`
					(`user_sk`, `email_group_sk`, `email_sk`, `price_before`, `price_after`, `pid`) VALUES 
					('#logarr[idx].user_sk#','#logarr[idx].email_group_sk#','#logarr[idx].email_sk#',#logarr[idx].price_before#,#logarr[idx].price_after#,'#logarr[idx].pid#')
				</cfquery>
			<cfcatch>
				<cfdump var="#cfcatch#"><cfabort>
			</cfcatch>
			</cftry>
	</cfloop>
	<cfcatch>
	</cfcatch>
	</cftry> --->
	
	
