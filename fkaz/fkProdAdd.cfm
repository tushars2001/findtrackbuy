<cfparam default="1" name="url.from">
<cfparam default="20" name="url.to">
<cfparam default="false" name="url.updateApi">
<cfset request.sk = '78153A32-E5D7-41EE-A9CFB0FE5632EE2E'>
<cfif url.updateApi>
	<cfhttp url="https://affiliate-api.flipkart.net/affiliate/api/tnhpindia.json" result="res" method="get">
		<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
		<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
	</cfhttp>
	
	<cfset data = DeserializeJSON(res.filecontent)>
	<cfset apinames = structKeyList(data.apiGroups.affiliate.apiListings)>
	<cfset apiDetails = arraynew(1)>
	<cfquery name="insertapi" datasource="#application.dsn#" result="res">
			DELETE from `ftb_fkapi`
		</cfquery>
	<cfloop list ="#apinames#" index="idx">
		<cfset s.apiname = idx>
		<cfset s.apiurl = evaluate("data.apiGroups.affiliate.apiListings.#s.apiname#.availableVariants['v0.1.0'].get")><!--- .availableVariants.v0.1.0.get --->
		
		
		
		<cfdump var="#res#">
		
		<cfquery name="insertapi" datasource="#application.dsn#" result="res">
			INSERT INTO `ftb_fkapi`(`apiname`, `apiurl`) 
			VALUES ('#s.apiname#','#s.apiurl#')
		</cfquery>
		
		
	</cfloop>
</cfif>

<cfquery name="getApis" datasource="#application.dsn#" cachedwithin="#createtimespan(1,0,0,0)#">
	select apiname, apiurl from ftb_fkapi		
	<!--- 
where 
	<!--- apiname not in (		SELECT DISTINCT category FROM  `ftb_trackers_pid` 	) --->
	apiname in ('bags_wallets_belts','fragrances','home_and_kitchen_needs','home_decor_and_festive_needs',
	'home_improvement_tools','laptop_accessories','luggage_travel','mobile_accessories','womens_footwear','sunglasses','toys')
 --->
</cfquery>
<!--- <cfset getApis.apiurl = arraynew(1)>
<cfset getApis.apiname = arraynew(1)>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/reh/500.json?expiresAt=1436463032881&sig=914eea30a3b1264ef86e9d34e16db993')>
<cfset arrayappend(getApis.apiname,'bags_wallets_belts')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/t06-r3o/500.json?expiresAt=1436463039736&sig=49686426dd4743b3d6658df96bb7707c')>
<cfset arrayappend(getApis.apiname,'fragrances')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/tyy-4mr/500.json?expiresAt=1436463044362&sig=81abf8007f9cf2bb9b532f9483d508f4')>
<cfset arrayappend(getApis.apiname,'mobile_accessories')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/r4l/500.json?expiresAt=1436463051913&sig=76266b67bd15fb40f70013a64856a761')>
<cfset arrayappend(getApis.apiname,'home_and_kitchen_needs')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/1m7/500.json?expiresAt=1436463059384&sig=25e5eaa277000e71346a8845b0c49428')>
<cfset arrayappend(getApis.apiname,'home_decor_and_festive_needs')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/26x/500.json?expiresAt=1436463065051&sig=66336c8650834b28e9f1c1f839ab1fa9')>
<cfset arrayappend(getApis.apiname,'sunglasses')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/osp-iko/500.json?expiresAt=1436463070515&sig=e21bee9a9469e9d59e2e6358b9acf387')>
<cfset arrayappend(getApis.apiname,'womens_footwear')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/6bo-ai3/500.json?expiresAt=1436463076268&sig=c93109c2e7c5ff2b390c14f022293c52')>
<cfset arrayappend(getApis.apiname,'laptop_accessories')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/amz/500.json?expiresAt=1436463081376&sig=f57d8aa2abc122451a540ec4a33e0cd1')>
<cfset arrayappend(getApis.apiname,'home_improvement_tools')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/reh-plk/500.json?expiresAt=1436463085915&sig=12f8fe56e91b44777031554073c71a9a')>
<cfset arrayappend(getApis.apiname,'luggage_travel')>
<cfset arrayappend(getApis.apiurl,
	'https://affiliate-api.flipkart.net/affiliate/feeds/tnhpindia/category/mgl/500.json?expiresAt=1436463088180&sig=eadbacf3b6c7fe9469f04bfb33b90705')>
<cfset arrayappend(getApis.apiname,'toys')> --->

<cfset errors = arraynew(1)>
<cfset url.to = getApis.recordcount>
<cfset insertcnt = 0>

<cfloop from="#url.from#" to="#url.to#" index="idx">	
	<cftry>
		<cfoutput>HTTPing #getApis.apiurl[idx]#<br> #getApis.apiname[idx]#<br></cfoutput>
		<cfhttp url="#getApis.apiurl[idx]#" result="res" method="get">
			<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
			<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
		</cfhttp>
		<cfset data = deserializeJSON(res.filecontent)>	

		<cfloop from="1" to="#arraylen(data.productInfoList)#" index="idx2">
				<cfset details = createObject("component","cmp").fkDetails(data.productInfoList[idx2].productBaseInfo.productAttributes)>
				<cfset pid = details.pid>
				<cfset link = details.link>
				<cfset image = details.image>
				<cfset last_price = details.price>
				<cfset title = details.title>
				<cfset description = details.description>
				<cftry>
					<cfquery name="addindb" datasource="#application.dsn#">
				<!--- INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`) 
				VALUES ('#pid#',
						0,
						'#link#',
						'#image#',
						#last_price#,
						'#title#',
						'#description#',
						'#getApis.apiname[idx]#') --->
					INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
					VALUES ('#pid#',#last_price#,'#request.sk#')
				</cfquery>
				<cfset insertcnt = insertcnt+1>	
				<cfcatch>
					<cfset arrayappend(errors,structcopy(cfcatch.additional))>
				</cfcatch>
				</cftry>		
				<cfoutput>(#idx#,#idx2#) </cfoutput>	
				<cfflush>	
		</cfloop>
		<cfoutput><br> Inserted so far : #insertcnt#</cfoutput>
		<cfflush>	
	<cfcatch>
		<cfset arrayappend(errors,structcopy(cfcatch.additional))>	
	</cfcatch>
	</cftry>
</cfloop>
<cfdump var="#errors#">
