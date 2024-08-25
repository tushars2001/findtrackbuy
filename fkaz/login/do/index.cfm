<cfquery name="getUser" datasource="#application.dsn#">
	select user_sk,active,passhash,email from ftb_users
	where upper(email) = upper('#form.email#')
</cfquery>
<cfparam name="url.redirect" default="/fkaz/">
<cfif not len(url.redirect)>
	<cfset url.redirect = "/fkaz/login/">
</cfif>
<cfset user_sk = createuUID()>
<cfset newuser = 0>
<cfset active = 0>
<cfset msg = ''>

<cfif getUser.recordcount>
	<cfif getUser.passhash neq hash(form.password)>
		<cfset msg = 'Your email/password combination is not correct.'>
		<cfset url.redirect = "/fkaz/login/">
	<cfelse>
		<cfset client.user_sk = getUser.user_sk>
		<cfset client.email = getUser.email>
	</cfif>
<cfelse>
	<cfquery name="q_adduser" datasource="#application.dsn#">
		INSERT INTO `ftb_users`(`email`, `user_sk`,`password`,`passhash` ) 
		VALUES ('#form.email#','#user_sk#','#form.password#','#hash(form.password)#')
	</cfquery>
	<cfset newuser = 1>
	<cfset client.user_sk = user_sk>
	<cfset client.email = form.email>
	<!--- <cfmail from="hello@quirkycrackers.com" to="#form.email#" type="html" failto="tushars2001@gmail.com" subject="Welcome to FindTrackBuy.com!">
		<cfoutput>
			<html>
				<head>
				</head>
				<body>
				
				</body>
			</html>
		<div>Dear User,</div>
		<br><br>
		<div>Thanks for Registering at FindTrackBuy.com.</div>
		<div>Please activate your account to see your dashboard.</div>
		<br><br>
		<div><a href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/acticate/?user_sk=#user_sk#">Activate</a></div>
		<div>or copy paste below link:</div>
		<div>http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/acticate/?user_sk=#user_sk#</div>
		<br><br>
		<div>You can track and control Alerts and Price Drops from Dashboard.</div>
		<br><br>
		<div>Best Regards,</div>
		<div>FindTrackBuy Team</div>
		</cfoutput>
	</cfmail> --->
	<cfmail from="hello@quirkycrackers.com" to="#form.email#" type="html" failto="tushars2001@gmail.com" subject="Welcome to FindTrackBuy.com!">
		<cfoutput>
			<html>
				<head>
				</head>
				<body>
				
				</body>
			</html>
		<div>Dear User,</div>
		<br><br>
		<div>Thanks for Registering at FindTrackBuy.com.</div>
		<br><br>
		<div>You can track and control Alerts and Price Drops from Dashboard.</div>
		<br><br>
		<div>Best Regards,</div>
		<div>FindTrackBuy Team</div>
		</cfoutput>
	</cfmail>
	<cfset msg = 'Your ID is not in our system.<br>We created your account and sent email at #form.email#.'>
</cfif>
<cflocation addtoken="false" url="#url.redirect#?msg=#msg#">
