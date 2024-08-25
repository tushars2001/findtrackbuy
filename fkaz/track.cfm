<html>
<head>
<script language="javascript">
		function submitform(val,type){
			window.location.href = 'http://127.0.0.1:8888/fkaz/track.cfm?param='+val;
		}
	</script>
</head>
<body>

</body>
</html>
<input type="text"  name="search" id="searchlink" size="100">
<input type="button" onclick="submitform((function(){return document.getElementById('searchlink').value})(),'link')" value="Track">

<cfif isdefined("url.param")>
	<cfset obj = createObject("component","cmp")>	<cfset db = structnew()>
	<cfif obj.isFKlink(url.param)>					<cfset db.link = url.param & '&affid=tnhpindia'>
			<cfset db.pid = obj.fkurlparse(url.param)>			<cfset data =  obj.flipkartPID(db.pid)>			<cfset data = DeserializeJSON(data)>			<cfset db.img = obj.fkImage(data.productBaseInfo.productAttributes)>				<cfset db.img = db.img.small.url>			<cfset db.price = obj.fkMinPrice(data.productBaseInfo.productAttributes)>			<cfset db.title = obj.fkTitle(data.productBaseInfo.productAttributes)>
			<cfset db.type = 0>
		</cfif>
	<cfif obj.isAZlink(url.param)>				<cfset db.link = url.param & '?&tag=t00fd-21'>
		<cfset db.pid = obj.azurlparse(url.param)>		<cfset data = obj.ItemLookup(db.pid)>		<cfset data = obj.ConvertXmlToStruct(data,structnew())>		<cfset db.img = obj.azImage(data.Items.Item)>		<cfset db.img = db.img.small.url>		<cfset db.price = obj.azMinPrice(data.Items.Item)>		<cfset db.title = obj.azTitle(data.Items.Item)>
		<cfset db.type = 1>
	</cfif>
	<cfset obj.addToTrack(db)>
	<h2><cfoutput>#db.pid# is now tracked!</cfoutput></h2>
</cfif>
