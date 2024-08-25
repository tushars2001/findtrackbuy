<cfsetting showdebugoutput="false">
<cfparam name="url.keyword" default="">
<cfset obj = createobject("component","cmp")>
<cfset movers = obj.azKeyword(url.keyword)>

<cftry>
	<cfset moversaz = obj.ConvertXmlToStruct(movers,structnew())>
<cfcatch>
</cfcatch>
</cftry>

<cfset movers = obj.flipkartKeyword(url.keyword)>
<cftry>
	<cfset moversfk = DeserializeJSON(movers.DATA)>
<cfcatch>
</cfcatch>
</cftry>

<cfset wrapArray = arraynew(1)>

<cftry>
	<cfloop from="1" to="#arraylen(moversfk.productInfoList)#" index="idx">
		<cfset pdetails = obj.fkDetails(moversfk.productInfoList[idx].productBaseInfo.productAttributes)>
		<cfset pdetails.wrapClass = "fkProduct">
		<cfset pdetails.logo = "/fkaz/images/fklogo.jpg">
		<cfset pdetails.brand ="">
		<cfset pdetails.product ="">
		<cfset pdetails.model ="">
		<cftry>
			<cftry><cfset pdetails.brand = moversfk.productInfoList[idx].productBaseInfo.productAttributes.productBrand><cfcatch></cfcatch></cftry>
			<cftry><cfset pdetails.product = ListLast(moversfk.productInfoList[idx].productBaseInfo.productIdentifier.categoryPaths.categoryPath[1][1].title,'>')><cfcatch></cfcatch></cftry>
			<cftry><cfset pdetails.model = moversfk.productInfoList[idx].productBaseInfo.productAttributes.title><cfcatch></cfcatch></cftry>
		<cfcatch>
		</cfcatch>
		</cftry>
		<cfif pdetails.price neq 'NA'>
			<cfset arrayappend(wrapArray,structcopy(pdetails))>
		</cfif>
	</cfloop>
<cfcatch>
</cfcatch>
</cftry>

<cftry>
	<cfloop from="1" to="#arraylen(moversaz.Items.Item)#" index="idx">
		<cfset pdetails = obj.azDetails(moversaz.Items.Item[idx])>
		<cfset pdetails.wrapClass = "azProduct">
		<cfset pdetails.logo = "/fkaz/images/azlogo.jpg">
		<cfset pdetails.brand ="">
		<cfset pdetails.product ="">
		<cfset pdetails.model ="">
		<cftry>
			<cftry><cfset pdetails.brand = moversaz.Items.Item[idx].ItemAttributes.Brand><cfcatch></cfcatch></cftry>
			<cftry><cfset pdetails.product = moversaz.Items.Item[idx].ItemAttributes.ProductTypeName><cfcatch></cfcatch></cftry>
			<cftry><cfset pdetails.model = moversaz.Items.Item[idx].ItemAttributes.Model><cfcatch></cfcatch></cftry>
		<cfcatch>
		</cfcatch>
		</cftry>
		<cfif pdetails.price neq 'NA'>
			<cfset arrayappend(wrapArray,structcopy(pdetails))>
		</cfif>
	</cfloop>
<cfcatch>
</cfcatch>
</cftry>


<html>
	<head>
		<!--- <link rel="stylesheet" href="/fkaz/js/jquery-ui.min.css">
		<link rel="stylesheet" href="/fkaz/js/main.css"> --->
		<!--- <script language="javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
		<script language="javascript" src="/fkaz/js/jquery-ui.min.js"></script>
		<script language="javascript" src="/fkaz/js/jquery.resizecrop-1.0.3.min.js"></script>
		<script language="javascript" src="/fkaz/js/isotope.pkgd.min.js"></script> --->
		<!--- <script type="text/javascript" src="/fkaz/js/canvasjs-1.7.0/jquery.canvasjs.min.js"></script>
		<script language="javascript" src="/fkaz/js/main.js"></script> --->
		<script type="text/javascript">
			 $(document).ready(function(){
				    $('.resizelive').resizecrop({
				      width:200,
				      height:200,
				      vertical:"top"
				    });  
				    psort=true;
				  
					$('#maintable').css("text-align","center");
					$('#maintable').css("position","relative");
					$('#maintable').css("left",$(window).width()*0.1);
					
					$('#mainGridLive').css("width",$(window).width()*0.8);
					$('#mainGridLive').css("text-align","center");
					<!--- $('#mainGrid').css("position","relative"); --->
					$('#mainGridLive').css("left",$(window).width()*0.1);
					<cfif client.mobile>
						$('.grid-item').css("width",$('#mainGridLive').width()-20);
					<cfelse>
						$('.grid-item').css("width",$('#mainGridLive').width()/3-20);
					</cfif>
					
					
					$('.gridLive').isotope({
					  // options
					  itemSelector: '.grid-item',
					  layoutMode: 'fitRows',
						fitRows: {
						  gutter: 10
						},
						 getSortData: {
					      title: '.title',	
					      price: '.price parseInt',
					      category: '[data-category]'
					    }
					  
					});
					
					$(".options").css({
						"height":$(".wrapper").height()
					});
					$(".options").css({
						"width":$(".wrapper").width()
					});
					$(".hist_button").css("left",($(".wrapper").width()-250)/2);
					$(".hist_button").css("cursor","pointer");
					$(".hist_button").css("cursor","hand");
					<!--- $('.grid').isotope({ sortBy: 'title' }); --->
				   <!---    $('.grid').masonry({
					  // options
					  itemSelector: '.grid-item',
					  columnWidth: 300
					}); --->
				    
				  }); 
		</script>
	</head>
	<body>
		<cfset op_top = 30>
		<cfif client.mobile>
			<cfset op_top = 60>
		</cfif>
		<cfloop from="1" to="#arraylen(wrapArray)#" index="idx">
			<cfoutput>
				<cfif wrapArray[idx].type eq 0>
							<cfset wrapClass = "fkProduct">
							<cfset logo = "/fkaz/images/fklogo.jpg">
						<cfelse>
							<cfset wrapClass = "azProduct">
							<cfset logo = "/fkaz/images/azlogo.jpg">
						</cfif>
				<div id="#wrapArray[idx].pid#" class="grid-item #wrapArray[idx].wrapClass# wrapper" <cfif not client.mobile>onmouseenter="$('###wrapArray[idx].pid#_options').slideDown(75);" onmouseleave="$('###wrapArray[idx].pid#_options').slideUp(75);"</cfif> data-category="#wrapArray[idx].wrapClass#" style="height:300;width:300;text-align:center;border-bottom:1px solid gray;border-top:15px solid white">
					<div id="#wrapArray[idx].pid#_options" class="options" style="position:absolute;top:0;left:0;z-index:2;display:none;background-color:rgba(0,0,0,0.7);">
						<div style="position:absolute;left:2;top:28;display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></div>
						<cfif client.mobile>
							<div onclick="$('###wrapArray[idx].pid#_options').slideToggle(75);" style="position:absolute;right:5;top:28;display: inline-block;vertical-align: middle;color:white;font-size:large">X</div>
						</cfif>
						<div style="height:#op_top#px;"></div>
						<div style="border:0px solid black;color:white" class="quicktrackbox" id="quicktrackbox_#wrapArray[idx].pid#">
							<cfif not isdefined("client.email")>
								<span class="textsize" style="border:0px solid black;" <!--- onblur="$('.emailalert').hide();" --->> <input name="email" id="quickemail_#wrapArray[idx].pid#" size="30" placeholder="Send me@mymail.com Alert" class="hist_input" <!--- style="font-size:small;width:250" --->></span>
							<cfelse>
								<span class="textsize" style="border:0px solid black;" <!--- onblur="$('.emailalert').hide();" --->> <input name="email" id="quickemail_#wrapArray[idx].pid#" size="30" placeholder="Send me@mymail.com Alert" value="#client.email#" class="hist_input" <!--- style="font-size:small;width:250" --->></span>
							</cfif>
							
							<span>
							<select name="pricedrop" id="pricedrop_#wrapArray[idx].pid#" class="hist_input" <!--- style="font-size:small;width:250" --->>
								<option value="1" style="font-size:small">When price drops to Less then 5%</option>
								<option value="2" style="font-size:small">When price drops to 5% to 10%</option>
								<option value="3" style="font-size:small">When price drops to 10% to 20%</option>
								<option value="4" style="font-size:small">When price drops to 20% to 50%</option>
								<option value="5" style="font-size:small">When price drops to 50+%</option>
							</select>
							</span>
							<span>
								<!--- <br>
							<button value="Track it!" onclick="trackit('#wrapArray[idx].pid#')" type="submit" id="trackitbutton">Quick Track!</button></span> --->
							<div style="height:5px;"></div>
							<div id="trackitbutton_#wrapArray[idx].pid#" onclick="trackit('#wrapArray[idx].pid#')" class="hist_button hist_button_small" <!--- style="position:absolute;width:250;height:20px;line-height: 20px;background-color:rgb(131, 220, 14);border-radius: 5px;color:white;" --->>
								Quick Track
								<div style="border:0px solid black;background-color:black;">
									<span class="textsize" style="width:100px;color:red;" id="emailalert_#wrapArray[idx].pid#" class="emailalert"></span> 
								</div>
							</div>
							
						</div>
						
						<div id="passwordbox_#wrapArray[idx].pid#" class="passwordbox" style="display:none;font-size:small;color:white;">
							<div style="border:50x solid rgba(0,0,0,0);color:white;">
								Your alert is setup! Setup a password & manage alerts. See a dashboard with all products that you are tracking.
							</div>
							<div style="border:5px solid rgba(0,0,0,0);text-align:center;">
							<input name="password" id="password_#wrapArray[idx].pid#" type="password" size="30" placeholder="Please enter password" style="font-size:small"> 
							<button value="Track it!" onclick="QuicksetupAccount('#wrapArray[idx].pid#');" type="submit">Setup Account</button>
							<span class="textsize" style="width:100px;color:red;" id="passwordalert"></span> 
							</div>
						</div>
						<div class="hist_gap" <!--- style="height:55px;" --->></div>
						<div class="hist_gap "<!--- style="height:70px;" --->></div>
						<div class="hist_button hist_button_big" onclick="getchart('#wrapArray[idx].pid#')" <!--- style="position:absolute;width:250;height:50px;line-height: 50px;background-color:rgb(131, 220, 14);border-radius: 10px;color:white;font-size:large;" --->>
						Price History
						</div>
						<div class="hist_gap "<!--- style="height:70px;" --->></div>
						<div class="hist_gap "<!--- style="height:70px;" --->></div>
						<a target="_blank" href="#wrapArray[idx].link#" style="text-decoration:none;color:white;">
						<div class="hist_button hist_button_big" <!--- style="position:absolute;width:250;height:50px;line-height: 50px;background-color:rgb(131, 220, 14);border-radius: 10px;color:white;font-size:large;" --->>
						Buy / Details
						</div>
						</a>
						<!--- <div style="position:absolute;top:65;z-index:2;font-weight:bold;width:100%;">
							<div style="text-align:center;width:100%;font-size:large;" >
							</div>
						</div> --->
				</div>
					<!--- 	<div class="title">#wrapArray[idx].title#</div>
					<a href="#wrapArray[idx].link#">
						<div><img src="#wrapArray[idx].image#" class="resize"></div>
					</a>
					<div>
					<table><tr>
						<td><div>Rs. <span class="price" style="display:none;">#wrapArray[idx].price#</span>#numberformat(wrapArray[idx].price)#</div></td>
						<td><div><img src="#wrapArray[idx].logo#"></div></td>
					</tr></table>
					</div>
					<div>
					<table><tr>
						<td><div>Track It</div></td><td><div>Check Out</div></td>
					</tr></table>
					</div> --->
					<div class="title sanss" style="color:black" title="#wrapArray[idx].title#">#left(wrapArray[idx].title,28)#..</div>
					<div style="font-size:x-small;color:gray;">Product ID: #wrapArray[idx].pid#</div>
					<div><a href="#wrapArray[idx].link#" target="_blank"><img src="#wrapArray[idx].image#" class="resizelive"></a></div>
					<div style="height:2px"></div>
					<div style="height: 30px;vertical-align: middle;display: inline-block;" >
						<!--- <cfset color = 'Black'>
						<cfif movers.variance lt 0>
							<cfset color = 'Red'>
						<cfelseif movers.variance eq 0>
							<cfset color = 'Black'>
						<cfelseif movers.variance gt 0>
							<cfset color = 'Green'>
						</cfif>
						<span class="sanss" style="display: inline-block;vertical-align: middle;color:#color#">
							#movers.variance[idx]#%
						</span>
						<span class="sanss" style="display: inline-block;vertical-align: middle;">
							<cfif movers.variance lt 0>
								<img src="/fkaz/images/down.png">
							<cfelseif movers.variance[idx] eq 0>
							<cfelseif movers.variance[idx] gt 0>
								<img src="/fkaz/images/up.png">
							</cfif>
						</span> --->
						<cfset movers = obj.getMovers(page=1,pid=wrapArray[idx].pid)>
							<cfif movers.recordcount>
								<cfset color = 'Black'>
							<cfif movers.variance lt 0>
								<cfset color = 'Red'>
							<cfelseif movers.variance eq 0>
								<cfset color = 'Black'>
							<cfelseif movers.variance gt 0>
								<cfset color = 'Green'>
							</cfif>
							<span class="sanss" style="display: inline-block;vertical-align: middle;color:#color#">
								#movers.variance#%
							</span>
							<span class="sanss" style="display: inline-block;vertical-align: middle;">
								<cfif movers.variance lt 0>
									<img src="/fkaz/images/down.png">
								<cfelseif movers.variance eq 0>
								<cfelseif movers.variance gt 0>
									<img src="/fkaz/images/up.png">
								</cfif>
							</span>
						</cfif>
					
						<span class="sanss" style="display: inline-block;vertical-align: middle;color:black;font-weight:normal">Rs. #numberformat(wrapArray[idx].price)#</span>
						<!--- <span style="display: inline-block;vertical-align: middle;"><img src="#wrapArray[idx].logo#" width="25" height="25"></span> --->
					</div>
					<cfif client.mobile>
						<span class="sanss" style="border:0px solid black;display: inline-block;vertical-align: middle;color:red" onclick="$('.options').hide();$('###wrapArray[idx].pid#_options').slideToggle(75);"><img alt="" width="25" height="25" src="/fkaz/images/ftb-small.png"/>Track</span>
					</cfif>
					<!--- <div>
						<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;cursor: pointer; cursor: hand;color:black;font-weight:normal" onclick="getchart('#wrapArray[idx].pid#')">Track It</span>
						<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;color:black;font-weight:normal"><a href="#wrapArray[idx].link#" style="text-decoration:none;color:black;">Check Out</a></span>
					</div> --->
				</div>
				<cftry>
				<cfif isnumeric(wrapArray[idx].price) and wrapArray[idx].price gt 0>
					<cfquery name="addindb" datasource="#application.dsn#" result="res">
					INSERT INTO `ftb_trackers_pid`(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`,`titlelong`,`pagelink`,`titletracked`,`brand`,`model`,`product`,`brandtracked`) 
					VALUES ('#wrapArray[idx].pid#',
							#wrapArray[idx].type#,
							'#wrapArray[idx].link#',
							'#wrapArray[idx].image#',
							#wrapArray[idx].price#,
							'#wrapArray[idx].title#',
							'#wrapArray[idx].description#',
							'#left(url.keyword,100)#',
							'#wrapArray[idx].title#',
							CONCAT( REPLACE( stripSpeciaChars('#wrapArray[idx].title#', 1, 0, 1, 0),  ' ',  '-' ) COLLATE utf8_general_ci,  '-', pid,  '/' ),
							1,
							'#wrapArray[idx].brand#',
							'#wrapArray[idx].model#',
							'#wrapArray[idx].product#',
							1
							)
					</cfquery>	
					<cfquery name="addindb" datasource="#application.dsn#">
						INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
						VALUES ('#wrapArray[idx].pid#',#wrapArray[idx].price#,'USER_SEARCHED')
					</cfquery>
				</cfif>	
				<cfcatch>
				</cfcatch>
				</cftry>
				
			</cfoutput>
		</cfloop>
	</body>
</html>

