<div class="browse">
		<span class="browseItem hspace">
				<cfoutput><a style="text-decoration:none;color:gray<cfif isdefined('url.type') and url.type eq 'trends'>;font-weight:bold;color:green</cfif>" href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=trends">Trending</a></cfoutput>
		</span>
			<span class="browseItem hspace"  <cfif isdefined("url.type") and url.type eq 'browse'>style="font-weight:bold;color:green"</cfif>>
				<cfif isdefined("url.type") and url.type eq 'browse'>
					<cfoutput>#url.category#</cfoutput>
				<cfelse>
					<cfoutput><a style="text-decoration:none;color:gray" href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=browse&category=All Drops">All Drops</a></cfoutput>
				</cfif>
				<img src="/fkaz/images/more.png" width="15" onclick="dropMenuItems();">
			</span>
			<!--- <cfif session.fluctuate>
				<cfset color = 'black'>
			<cfelse>
				<cfset color = 'white'>
			</cfif>
			<cfoutput>
				<span class="browseItem" style="font-size:small;background-color:#color#;border-radius: 25px;border:5px solid #color#"  onclick="fluctuate(0);" title="Fluctuaters are products whose prices vary more with time">&nbsp;Fluctuaters&nbsp;<cfif session.fluctuate><sup>X</sup></cfif></span>
			</cfoutput>---->
			<cfoutput>
				<span class="browseItem hspace" style="font-size:small;"  onclick="reset(0);" title="Reset">&nbsp;Reset&nbsp;</span>
			</cfoutput> 
			<span class="browseItem hspace" style="font-size:small;"  onclick="$('#meter').slideToggle(1000)" title="Filters">&nbsp;Filters&nbsp;</span>
	</div>
		<!--- <cfif isdefined("movers") and structkeyExists(movers,"recordcount") and movers.recordcount > --->
	<div class="browse" id="allDropsOptions" style="display:none;font-size:x-small;background-color:white;font-weight:bold;">
		<cfloop from="1" to="#bcategories.recordcount#" index="idx">
		<cfif isdefined("url.type") and (url.type eq 'browse') and url.category eq bcategories.category[idx] >
		<cfelse>
			<div class="browsemenuItem" >
				<cfoutput><a href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=browse&category=#bcategories.category[idx]#">#bcategories.category[idx]#</a></cfoutput>
			</div>
		</cfif>
		</cfloop>
		<cfif isdefined("url.type") and (url.type eq 'browse')>
			<div class="browsemenuItem" >
				<cfoutput><a href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=browse">All Drops</a></cfoutput>
			</div>
		</cfif>
	</div>
	<div class="gap"></div><div class="gap"></div><div class="gap"></div>
<div id="meter" style="background-color:white;border:1px solid black;">
	<div class="browse">
			<!--- <span class="browseItem" >
				Top Drops
			</span>
			<span class="browseItem" >
				Trending Drops
			</span> --->
			<span class="browseItem menuItemSmall sinceclass" style="<cfif isdefined('session.dropsince') and session.dropsince eq 1>color:black;text-decoration: underline;</cfif>"  onclick="selectsince(1,this);return false;dropSince(1);" >Drops Since Yesterday</span> -
			<span class="browseItem menuItemSmall sinceclass" style="<cfif isdefined('session.dropsince') and session.dropsince eq 7>color:black;text-decoration: underline;</cfif>"  onclick="selectsince(7,this);return false;dropSince(7);" >Drops Last Week</span> -
			<span class="browseItem menuItemSmall sinceclass" style="<cfif (not isdefined('session.dropsince')) or ( isdefined('session.dropsince')  and session.dropsince eq 0)>color:black;text-decoration: underline;</cfif>"  onclick="selectsince(0,this);return false;dropSince(0);" >Ever</span>
	</div>
	<div class="gap"></div><div class="gap"></div><div class="gap"></div>
	<div class="gap"></div><div class="gap"></div><div class="gap"></div>
	
	<!--- </cfif> --->
	<div style="width:90%;text-align:center;position:relative;" id="rangecontent">
	<input type="text" id="range_1" />
	<input type="text" id="range_2" />
	</div>
	<div class="gap"></div><div class="gap"></div><div class="gap"></div>
	<div style="text-align:center;position:relative;" >
		<span style="color:black;font-weight:bold" style="font-size:small;"  >Save me </span>
		<span class="browseItem" style="font-size:small;"  >
			<cfset saveme = 0>
			<cfif isdefined("session.saveme")>
				<cfset saveme = session.saveme>
			</cfif>
			<select name="savemers" onchange="meterparams.saveme = this.value;return false;saveme(this.value);" style="background-color:white;border:1px solid black">
				<option value="0" <cfif saveme eq 0>selected</cfif>>------</option>
				<option value="100" <cfif saveme eq 100>selected</cfif>>Upto 100</option>
				<option value="500" <cfif saveme eq 500>selected</cfif>>100 to 500</option>
				<option value="1000" <cfif saveme eq 1000>selected</cfif>>500 to 1000</option>
				<option value="1001" <cfif saveme eq 1001>selected</cfif>>1000+</option>
			</select>
		</span>
		<span style="color:black;font-weight:bold" style="font-size:small;"  > Bucks</span>
	</div>
	<div class="gap"></div><div class="gap"></div><div class="gap"></div>
	<div style="text-align:center;border-top:3px solid white">
	<button name="but" value="Get.Set.Go." style="width:90%;;background-color:rgb(186, 2, 16);border:1px solid black;color:white;" onclick="getsetgo();">Get.Set.Go.</button>
	</div>
	<div class="gap"></div><div class="gap"></div><div class="gap"></div>
	<cfif len(session.usermsg) and msgcnt gt 2>
		<div style="text-align:center;position:relative;background-color:white;border:5px solid white;font-size:x-small;" >
			<cfoutput>#session.usermsg#</cfoutput>
		</div>
	</cfif>
	<div class="browse">
		<span class="menuItemSmall hspace">Sort</span>
		<span class="browseItem menuItemSmall hspace"   onclick="sortby('last_price','desc');" >Price <span class="sortby_last_price"></span></span>
		<span class="browseItem menuItemSmall hspace"   onclick="sortby('variance','asc');" >Drop % <span class="sortby_variance"></span></span>
		<span class="browseItem menuItemSmall hspace"  onclick="sortby('difference','asc');" >Savings <span class="sortby_difference"></span></span>
	</div>
</div>
