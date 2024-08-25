<cfsetting showdebugoutput="false">
<!--- <script>
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '1684862888425977',
      xfbml      : true,
      version    : 'v2.1'
    });
  };

  (function(d, s, id){
     var js, fjs = d.getElementsByTagName(s)[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement(s); js.id = id;
     js.src = "//connect.facebook.net/en_US/sdk.js";
     fjs.parentNode.insertBefore(js, fjs);
   }(document, 'script', 'facebook-jssdk'));
</script> --->
<script language="javascript">
	(function msite(){
		var sw = screen.width;
		var sh = screen.height;
		var small = sw;
		if(sw > sh) small = sh;
		<cfoutput>
		if(small < 640){
			<cfif not client.mobile and not session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#';
				</cfoutput>
			</cfif>
		}
		else{
			<cfif client.mobile and session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#';
				</cfoutput>
			</cfif>
		}
		</cfoutput>
	})();

</script>


<html>
<head>
	<cfif client.mobile>
	<meta name="viewport" content="width=device-width, initial-scale = 1.0, maximum-scale=1.0, user-scalable=no" />
	</cfif>
	<meta name="keywords" 			content="Amazon, Flipkart, Amazon Price Tracker, Flipkart Price Tracker, price tracker, India">
	
	<meta name="description" 		content="Best Amazon and Flipkart Price tracker and price management website">
	<cfoutput>
		<meta property="og:title"   	content="FindTrackBuy.com : Best Amazon and Flipkart Price Tracker" />
		<meta property="og:image"       content="http://dev.quirkycrackers.com/fkaz/images/ftb.png" /> 
		<meta property="og:description" content="Best Amazon and Flipkart Price tracker and price management website." /> 
	</cfoutput>
	<title>Get Alerts When Price Drops: Best Price Tracker</title>
	<script language="javascript" src="/fkaz/js/cssua.min.js"></script>
	<link rel="shortcut icon" href="/fkaz/images/favicon.ico">
	<!--- <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css"> --->
	<link rel="stylesheet" href="/fkaz/js/jquery-ui.theme.min.css">
	<cfoutput><link rel="stylesheet" href="/fkaz/js/#request.files#.css"></cfoutput>
	<!--- <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css"> --->
	<script language="javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
	<script language="javascript" src="/fkaz/js/jquery-ui.min.js"></script>
	<script language="javascript" src="/fkaz/js/jquery.resizecrop-1.0.3.min.js"></script>
	<!--- <script language="javascript" src="/fkaz/js/masonry.pkgd.min.js"></script> --->
	<script language="javascript" src="/fkaz/js/isotope.pkgd.min.js"></script>
	<script type="text/javascript" src="/fkaz/js/canvasjs-1.7.0/jquery.canvasjs.min.js"></script>
	<cfoutput><script language="javascript" src="/fkaz/js/#request.files#.js"></script></cfoutput>
	<link rel="stylesheet"  href="/fkaz/js/ion.rangeSlider-1.9.3/css/normalize.min.css"></link>
	<link rel="stylesheet"  href="/fkaz/js/ion.rangeSlider-1.9.3/css/ion.rangeSlider.css"></link>
	<link rel="stylesheet"  href="/fkaz/js/ion.rangeSlider-1.9.3/css/ion.rangeSlider.skinFlat.css"></link>
	<script src="/fkaz/js/ion.rangeSlider-1.9.3/js/ion-rangeSlider/ion.rangeSlider.min.js"></script>
	<script language="javascript" src="/fkaz/js/chart.js"></script>
	<cfset movers = obj.getProductById(url.pid)>
	<script type="text/javascript">
		$(document).ready(function(){
			init();
			var size = 400;
			<cfif client.mobile>
				size = 200;
			</cfif>
			$('.resize').resizecrop({
		      width:size,
		      height:size,
		      vertical:"top"
		    });  
		    
		    $("#charleft").on("touchstart", function(ev) {
				ev.preventDefault();
				scrolling=1;
				moveleft(1,-1);
			});
			
			$("#charleft").on("touchend", function(ev) {
				ev.preventDefault();
				scrolling=0;
				moveleft(0,-1);
			});
			
			
			$("#charright").on("touchstart", function(ev) {
				ev.preventDefault();
				scrolling=1;
				moveright(1,1)
			});
			
			
			$("#charright").on("touchend", function(ev) {
				ev.preventDefault();
				scrolling=0;
				moveright(0,1);
				
			});
			
			$( "#whysoless" ).click(function() {
			    if($( "#whysolessdata" ).is(':visible')){
			    	$( "#whysolessdata" ).slideUp( "slow");
			    }
			    else{
			    	 $( "#whysolessdata" ).slideDown( "slow");
			    }
			 
			});
			<cfloop from="1" to="#movers.recordcount#" index="idx">
				<cfoutput>
					loadchart('#movers.pid[idx]#',#idx#);
				</cfoutput>
			</cfloop>
		});
		
		function doLogin(){
			<cfoutput>
				window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/login/?email='+email;
			</cfoutput>
		}

		function trackit(pid){
			if(validEmail()){
				email = $("#email").val();
				 $.ajax({
					type: 'GET',
					    url: '/fkaz/cmp.cfc?method=adduser&email='+$("#email").val()+'&dropto='+$("#pricedrop").val()+'&pid='+pid,
				    beforeSend : function(a){
				    				$("#emailalert").empty();
				    				$("#trackitbutton").text("Tracking...");
				    			 },
				    complete : function(results){
								},
					success : function(results){
								var ret = results;	
								if(ret.ERROR == 1){
									$("#emailalert").empty();
									$("#emailalert").append("We apologies! Please try again! :(");
									$("#trackitbutton").text("Track it!");
									return;
								}
								
								$("#user_sk").val(ret.USER_SK);
								
								if(ret.ISACCOUNTSETUP == 0){
									$("#contentbox").hide();
									$("#passwordbox").show();
								}
								else{
									$("#contentbox").empty();
									$("#contentbox").css({
										"border":"5px sold rgba(255,255,255,0)",
										"text-align":"center",
										"font-size":"medium"
									});
									<cfif isdefined("client.user_sk")>
										$("#contentbox").append("Tracking successful!");
									<cfelse>
										$("#contentbox").append("Tracking successful! <br>You are already with us. Why not <span style='cursor: pointer; cursor: hand;' onclick='doLogin();'>Login</span> and checkout your dashboard.");
									</cfif>
									
								}
							  },
					error : function(){
						$("#emailalert").empty();
						$("#emailalert").append("We apologies! Please try again! :(");
					}
				});
			}
			
		}
	</script>
	<style>
		.title{
			text-align:center;
		}
		.details{
			text-align:center;
		}
		.image{
			text-align:center;
		}
	</style>
</head>
<body>
	<div id="fb-root"></div>
	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.4";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>
	<!--- <cfset trending = obj.trending()> --->
	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	
	  <cfoutput>ga('create', '#application.goog#', 'auto');</cfoutput>
	  ga('require', 'displayfeatures');
	  ga('send', 'pageview');
	
	</script>
	<cfinclude template="header.cfm">
	<!--- <cfdump var="#movers#"> --->
	<cfset color = 'white'>
	<cfif movers.variance lt 0>
		<cfset color = 'Red'>
	<cfelseif movers.variance eq 0>
		<cfset color = 'white'>
	<cfelseif movers.variance gt 0>
		<cfset color = 'Green'>
	</cfif>
	<cfif movers.type eq 0>
		<cfset logo = "/fkaz/images/fklogo.jpg">
	<cfelse>
		<cfset logo = "/fkaz/images/azlogo.jpg">
	</cfif>
	<cfoutput>
		<div class="title">#movers.title#</div>
		<div class="image" style="border:0px solid white"><a href="#movers.link#"><img class="resize" src="#movers.image#"></a></div>
		<div class="details" style="margin:5px; border:2px solid white">
			<span class="sanss" style="margin:2px;display: inline-block;vertical-align: middle;color:#color#">
			#movers.variance# 
			</span>
			<span class="sanss" style="margin:2px;display: inline-block;vertical-align: middle;">
				<cfif movers.variance lt 0>
					<img src="/fkaz/images/down.png">
				<cfelseif movers.variance eq 0>
				<cfelseif movers.variance gt 0>
					<img src="/fkaz/images/up.png">
				</cfif>
			</span>
			<span class="sanss" style="margin:2px;display: inline-block;vertical-align: middle;">
				Rs. #movers.last_price#
			</span>
			<span style="margin:2px;display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></span>
		</div>
		<div style="overflow-x: scroll;float: left;width:100%;text-align:center;" id="chartparent">
			<cfif client.mobile>
				<span id="charright" 
						<!--- onkeydown='moveleft(1,-1)' onkeyup='moveleft(0,-1)' onmouseover='moveleft(1,-1)' onmouseout='moveleft(0,-1)' --->
						><img src="/fkaz/images/left.jpg">
						<!---  ---></span><span style="width:30px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span id="charleft" <!--- onkeydown='moveright(1,1)' onkeyup='moveright(0,1)' onmouseover='moveright(1,1)' onmouseout='moveright(0,1)' --->><img src="/fkaz/images/right.jpg"></span>
			</cfif>
			<div id="chart1" style="width:600;height:300;"></div>
		</div>
		<div id="contentbox" style="z-index:100;background-color:white;color:black;">
			<div style="border:3px solid white;">
			 
				<span class="textsize" style="width:100px">Send me alert</span>
				<cfif not isdefined("client.user_sk")>
				<span class="textsize" style="border:3px solid white;"> at:<input name="email" id="email" size="30" placeholder="Please enter Email" style="font-size:small"></span>
				<cfelse>
					<cfoutput><input name="email" id="email" type="hidden" value="#client.email#"></cfoutput>
				</cfif>
				<cfif client.mobile>
					<br>
				</cfif>
				<span class="textsize">When price drops to Rs.</span>
				<span>
				<select name="pricedrop" id="pricedrop" style="font-size:small">
					<option value="1" style="font-size:small">Less then 5%</option>
					<option value="2" style="font-size:small">5% to 10%</option>
					<option value="3" style="font-size:small">10% to 20%</option>
					<option value="4" style="font-size:small">20% to 50%</option>
					<option value="5" style="font-size:small">50+%</option>
				</select>
				</span>
				<cfif client.mobile>
					<br>
				</cfif>
				<span><cfoutput><button value="Track it!" onclick="trackit('#url.pid#')" type="submit" id="trackitbutton">Track it!</button></cfoutput></span>
			</div>
			<div style="border:1px solid white;background-color:white;">
				<span class="textsize" style="width:100px;color:red;" id="emailalert"></span> 
			</div>
		</div>
		<div class="fb-comments" data-href="http://developers.facebook.com/docs/plugins/comments/" data-numposts="5"></div>
		<!--- <table border="1" width="90%;" style="text-align:center" align="center">
		<tr>
			<td colspan="2" style="font-weight:bold;">#movers.title#</td>
		</tr>
		<tr>
			<td width="50%">
				<table align="center" border="0" style="text-align:center">
					<tr>
						<td><div style="border:0px solid white"><a href="#movers.link#"><img class="resize" src="#movers.image#"></a></div></td>
					</tr>
					<tr>
						<td>
							<div style="margin:5px; border:2px solid white">
								<span class="sanss" style="margin:2px;display: inline-block;vertical-align: middle;color:#color#">
								#movers.variance# 
								</span>
								<span class="sanss" style="margin:2px;display: inline-block;vertical-align: middle;">
									<cfif movers.variance lt 0>
										<img src="/fkaz/images/down.png">
									<cfelseif movers.variance eq 0>
									<cfelseif movers.variance gt 0>
										<img src="/fkaz/images/up.png">
									</cfif>
								</span>
								<span class="sanss" style="margin:2px;display: inline-block;vertical-align: middle;">
									Rs. #movers.last_price#
								</span>
								<span style="margin:2px;display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></span>
							</div>
						</td>
					</tr>
				</table>
				
			</td>
			<td width="50%"><div id="chart1" style="width:600;height:300;"></div></td>
		</tr>
		
		<tr>
			<td colspan="2">
				<div id="contentbox" style="z-index:100;background-color:white;color:white;">
					
					<div style="border:3px solid white;">
					 
						<span class="textsize" style="width:100px">Send me alert</span>
						<cfif not isdefined("client.user_sk")>
						<span class="textsize" style="border:3px solid white;"> at:<input name="email" id="email" size="30" placeholder="Please enter Email" style="font-size:small"></span>
						<cfelse>
							<cfoutput><input name="email" id="email" type="hidden" value="#client.email#"></cfoutput>
						</cfif>
						<span class="textsize">When price drops to Rs.</span>
						<span>
						<select name="pricedrop" id="pricedrop" style="font-size:small">
							<option value="1" style="font-size:small">Less then 5%</option>
							<option value="2" style="font-size:small">5% to 10%</option>
							<option value="3" style="font-size:small">10% to 20%</option>
							<option value="4" style="font-size:small">20% to 50%</option>
							<option value="5" style="font-size:small">50+%</option>
						</select>
						</span>
						<span><cfoutput><button value="Track it!" onclick="trackit('#url.pid#')" type="submit" id="trackitbutton">Track it!</button></cfoutput></span>
					</div>
					<div style="border:1px solid white;background-color:white;">
						<span class="textsize" style="width:100px;color:red;" id="emailalert"></span> 
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<td colspan="2"><div class="fb-comments" data-href="http://developers.facebook.com/docs/plugins/comments/" data-numposts="5"></div></td>
		</tr>
		</table> --->
	</cfoutput>
	
	<div class="footer">
		Copyrights 2015. A <a href="http://www.QuirkyCrackers.com" target="_blank">QuirkyCrackers.com</a> Productions
	</div>
	<div style="width:100%;height:25%;">
	</div>
</body>
</html>