<div class="browse">
		<!--- <span class="browseItem" >
			Top Drops
		</span>
		<span class="browseItem" >
			Trending Drops
		</span> --->
		<span class="browseItem">
				<cfoutput><a style="text-decoration:none;color:gray<cfif isdefined("url.type") and url.type eq 'trends'>;font-weight:bold;color:green</cfif>" href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=trends">Trending</a></cfoutput>
		</span>
		<span class="browseItem" <cfif isdefined("url.type") and url.type eq 'browse'>style="font-weight:bold;color:green"</cfif>>
			<cfif isdefined("url.type") and url.type eq 'browse'>
				<cfoutput>#url.category#</cfoutput>
			<cfelse>
				<cfoutput><a style="text-decoration:none;color:gray" href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=browse&category=All Drops">All Drops</a></cfoutput>
			</cfif>
			<img src="/fkaz/images/more.png" width="15" onclick="dropMenuItems();">
		</span>
		<cfif  url.type neq 'trends'>
			<span class="browseItem menuItemSmall" style="<cfif isdefined('session.dropsince') and session.dropsince eq 1>color:black;text-decoration: underline;</cfif>"  onclick="dropSince(1);" >Drops Since Yesterday</span>
			<span class="browseItem menuItemSmall" style="<cfif isdefined('session.dropsince') and session.dropsince eq 7>color:black;text-decoration: underline;</cfif>"  onclick="dropSince(7);" >Drops Last Week</span>
			<span class="browseItem menuItemSmall" style="<cfif (not isdefined('session.dropsince')) or ( isdefined('session.dropsince')  and session.dropsince eq 0)>color:black;text-decoration: underline;</cfif>"  onclick="dropSince(0);" >Ever</span>
		</cfif>
<cfif session.fluctuate>
			<cfset color = 'black'>
		<cfelse>
			<cfset color = 'white'>
		</cfif>
		<cfoutput>
			<span class="browseItem" style="font-size:small;background-color:#color#;border-radius: 25px;border:5px solid #color#"  onclick="fluctuate(0);" title="Fluctuaters are products whose prices vary more with time">&nbsp;Fluctuaters&nbsp;<cfif session.fluctuate><sup>X</sup></cfif></span>
		</cfoutput>
		<cfoutput>
			<span class="browseItem" style="font-size:small;"  onclick="reset(0);" title="Reset">&nbsp;Reset&nbsp;</span>
		</cfoutput> 
			<span class="browseItem hspace" style="font-size:small;"  onclick="$('#meter').slideToggle(1000)" title="Filters">&nbsp;Filters&nbsp;</span>
	</div>
	<!--- <cfif isdefined("movers") and structkeyExists(movers,"recordcount") and movers.recordcount > --->
	<div class="browse browsemenu" id="allDropsOptions" style="display:none;font-size:small">
		<cfloop from="1" to="#bcategories.recordcount#" index="idx">
		<cfif isdefined("url.type") and (url.type eq 'browse') and url.category eq bcategories.category[idx] >
		<cfelse>
			<span class="browsemenuItem">
				<cfoutput><a href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=browse&category=#bcategories.category[idx]#">#bcategories.category[idx]#</a></cfoutput>
			</span>
		</cfif>
		</cfloop>
		<cfif isdefined("url.type") and (url.type eq 'browse')>
			<span class="browsemenuItem">
				<cfoutput><a href="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type=browse">All Drops</a></cfoutput>
			</span>
		</cfif>
	</div>
	<!--- </cfif> --->
	<div style="height:20px"></div>
	<div id="meter" style="background-color:white;border:0px solid black;">
		<div style="width:50%;text-align:center;position:relative;" id="rangecontent">
		<input type="text" id="range_1" />
		<input type="text" id="range_2" />
		</div>
		<div style="height:10px"></div>
		<div style="text-align:center;position:relative;" >
			<span style="color:red;font-weight:bold" style="font-size:small;"  >Save me </span>
			<span class="browseItem" style="font-size:small;"  >
				<cfset saveme = 0>
				<cfif isdefined("session.saveme")>
					<cfset saveme = session.saveme>
				</cfif>
				<select name="savemers" onchange="saveme(this.value);">
					<option value="0" <cfif saveme eq 0>selected</cfif>>------</option>
					<option value="100" <cfif saveme eq 100>selected</cfif>>Upto 100</option>
					<option value="500" <cfif saveme eq 500>selected</cfif>>100 to 500</option>
					<option value="1000" <cfif saveme eq 1000>selected</cfif>>500 to 1000</option>
					<option value="1001" <cfif saveme eq 1001>selected</cfif>>1000+</option>
				</select>
			</span>
			<span style="color:red;font-weight:bold" style="font-size:small;"  > Bucks</span>
		</div>
		<div class="browse">
			<span class="menuItemSmall">Sort</span>
			<span class="browseItem menuItemSmall"   onclick="sortby('last_price','desc');" >Price <span class="sortby_last_price"></span></span>
			<span class="browseItem menuItemSmall"   onclick="sortby('variance','asc');" >Drop % <span class="sortby_variance"></span></span>
			<span class="browseItem menuItemSmall"  onclick="sortby('difference','asc');" >Savings <span class="sortby_difference"></span></span>
		</div>
	</div>
	<cfif len(session.usermsg) and msgcnt gt 2>
		<div style="text-align:center;position:relative;background-color:YELLOW;border:5px solid white" >
			<cfoutput>#session.usermsg#</cfoutput>
		</div>
	</cfif>