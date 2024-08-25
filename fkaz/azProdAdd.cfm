<cfset productGroupsArr =
	[ 'Beauty','Grocery','PetSupplies','OfficeProducts','Electronics','Watches','Jewelry',
	'Luggage','Shoes','KindleStore','Automotive','MusicalInstruments','GiftCards','Toys',
	'SportingGoods','PCHardware','Books','Baby','HomeGarden','VideoGames','Apparel','Marketplace','DVD',
	'Music','HealthPersonalCare','Software' ]
	>
<cfset insertcnt = 0>
<cffunction name="snooz" access="public" output="false" returntype="void" hint="Leverages Java's sleep() function">
   <cfargument name="timeToSleep" type="numeric" required="true" />

   <cfscript>
      createObject("java", "java.lang.Thread").sleep(arguments.timeToSleep);    //sleep time in milliseconds
      return;
   </cfscript>
</cffunction>
<cfset cmp = createobject("component","cmp")>
<cfset errors = arraynew(1)>
<!--- <cfset keywords = ['usb','smasung','apple','home decore','gift for man','gift for kids','bestseller','mugs','poster']> --->
<cfset keywords = ['New and Popular Mobiles','Cases & Covers','Screen Guards','Kitchen & Dining','Cookware','Pots & Pans','Pressure Cookers',
		'Speakers','Personal Care Appliances','stationary','t shirts','sports shoes','decoration','teddy bear','wall clocks','school bags',
		'Coffee Mugs','Dinnerware','Crockery','Casseroles','Bedsheets','Blankets','Curtains','Towels','Showpieces','Wall Decor','Wall Shelves',	
		'Wall Lamps','Table Lamps','Umbrellas','Puja Mandir Temples'	]>

<cftry>

<cfloop from="1" to="#arraylen(keywords)#" index="outer">
	<cfoutput>KEYWORD: #keywords[outer]#<br></cfoutput><cfflush>
	<cfloop from="1" to="#arraylen(productGroupsArr)#" index="idx">
		<cfoutput>Querying #productGroupsArr[idx]#<br></cfoutput>
		
		<cfloop from="1" to="10" index="idx2">
			
			<cftry>	
			<cfset data = cmp.azKeyword(keywords[outer],idx2,productGroupsArr[idx])>
			<cfset snooz(100)>
			<cfset data = cmp.ConvertXmlToStruct(data,structnew())>
			<cfoutput>PAGE: #idx2#.. ITEMS: #arraylen(data.items.item)#<br></cfoutput>
			<cfflush>
			<cfloop from="1" to="#arraylen(data.items.item)#" index="inner">
				<cfset details = cmp.azDetails(data.Items.Item[inner])>
				<cfset pid = details.pid>
				<cfset link = details.link>
				<cfset image = details.image>
				<cfset last_price = details.price>
				<cfset title = details.title>
				<cfset description = details.description>	
				
								
				<cfif isnumeric(last_price) and last_price gt 0>
					<cfquery name="addindb" datasource="#application.dsn#" result="res">
					INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`) 
					VALUES ('#pid#',
							1,
							'#link#',
							'#image#',
							#last_price#,
							'#title#',
							'#description#',
							'#productGroupsArr[idx]#')
					</cfquery>	
					<cfset insertcnt = insertcnt+1>
				<cfelse>
						<cfoutput>LAST PROCE: #last_price# <br> </cfoutput>	
				</cfif>	
				<cfoutput>(#idx#,#idx2#) </cfoutput>			
				<cfflush>
			</cfloop>
			<cfcatch>
				<cfset arrayappend(errors,structcopy(cfcatch.additional))>	
				<cfflush>	
			</cfcatch>
			</cftry>
		
		</cfloop>
		<cfoutput>***** INSERTED = #insertcnt# ***********</cfoutput>
		<cfflush>
	</cfloop>
</cfloop>
<cfoutput>***** TOTAL INSERTED = #insertcnt# ***********</cfoutput>
<cfcatch>
	<cfdump var="#cfcatch#">
	<cfabort>
</cfcatch>
</cftry>