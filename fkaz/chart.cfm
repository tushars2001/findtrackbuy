<cfsetting showdebugoutput="true">

<cfparam name="url.pid" default="">
<cfset minval = 0>
<cfset maxval = 0>

<!--- <cfquery name="itemChardData" datasource="#application.dsn#">
	select pid,IFNULL(price,0) price,
(MONTH((record_ts))-1) month,
YEAR(record_ts) year,
DAY(record_ts) day,
HOUR(record_ts) hour,
minute(record_ts) minute,
second(record_ts) second,

record_ts from ftb_product_tracker
	where pid = 'SLSDXB2Q9P2JJRYY'
	order by record_ts asc
</cfquery> --->
<cfset itemChardData = createobject("component","cmp").getPriceHistory(url.pid)>

<cfquery name="getminmax" dbtype="query">
	select min(price) minp, max(price) maxp from itemChardData
</cfquery>

<cftry>
<cfif itemChardData.recordcount>
	<cfset minval = round(getminmax.minp*95/100)>
	<cfset maxval = round(getminmax.maxp*105/100)>
</cfif>
<cfcatch>
	<div style="">There is no change in price for this product in last one month, so no chart!</div>

</cfcatch></cftry>
<cfset jData = serializeJSON(itemChardData)>
<cfquery name="gettitle" datasource="#application.dsn#">
	select titlelong as title from ftb_trackers_pid where pid = '#url.pid#'
</cfquery>
<cfset title = gettitle.title>
<cfset title = REReplace(title, "[^0-9a-zA-Z _]", "", "ALL")>
<!DOCTYPE HTML>
<html>

<head>
<style>
.textsize{
	font-size:small;
	font-weight:bold;
}
</style>
<cfif isdefined("url.lib")>
	<script type="text/javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
	<script type="text/javascript" src="/fkaz/js/canvasjs-1.7.0/jquery.canvasjs.min.js"></script>
	<script type="text/javascript" src="/fkaz/js/main.js"></script>
</cfif>
<script type="text/javascript">
	var chart ;
	var email;
$(function () {
	var limit = 10000;    //increase number of dataPoints by increasing the limit
	var y = 0;
	var data = [];
	var dataSeries = { type: "line" };
	var dataPoints = [];
	<cfoutput>var jData = #jData#</cfoutput>
	var prev=0;
	var start = 0;
	for (var i = 0; i < jData.DATA.length; i += 1) {
		if(jData.DATA[i][1].toString().length == 0){
			jData.DATA[i][1] = prev;
		}
		if(!start && jData.DATA[i][1].toString().length > 0 && jData.DATA[i][1]>0){
			start = 1;
		}
		
		if(!start) continue;
		prev = jData.DATA[i][1];
		x = new Date(jData.DATA[i][3],eval(jData.DATA[i][2]-1),jData.DATA[i][4]);
		y = jData.DATA[i][1];
		dataPoints.push({
			x: x,
			y: y
		});
	}
	dataSeries.dataPoints = dataPoints;
	data.push(dataSeries);
	if(dataPoints.length < 6){
		$("#whysoless").show();
	}
	<cfif client.mobile>
		if(screen.width < screen.height){
			$("#chartContainer").css({"width":"200%",height:"100%"});
		}
		else{
			$("#chartContainer").css({"width":"100%",height:"200%"});
		}
	<cfelse>
		$("#chartContainer").css({"width":"100%",height:"100%"});
	</cfif>
	
	//Better to construct options first and then pass it as a parameter
	var options = {
		zoomEnabled: true,
                animationEnabled: true,
		title: {
			<cfoutput>text: "#left(title,100)#"</cfoutput>,
			fontSize: 12
		},
		axisX: {
			title: "Timeline",
        	gridThickness: 1,
        	interval: 1,
        	titleFontSize:15,
  			intervalType: "day",
  			labelAngle: -90,
  			labelFontSize: 12,
  			valueFormatString: "DD-MMMM" 
		},
		axisY: {
			title: "Price",
			titleFontSize:15,
			<cfoutput>
			interval: #maxval/10#,
			minimum: #minval#,
			maximum: #maxval#,
			labelFontSize: 12
			</cfoutput>
		},
		data: data  // random data
	};
	
	chart = new CanvasJS.Chart("chartContainer",options);
	chart.render();
	$("#chartContainer").CanvasJSChart(options);
	
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

});
<!----
function trackit(pid){
	if(validEmail()){
		email = $("#email").val();
		 $.ajax({
			type: 'GET',
		    <cfoutput>
			    url: '/fkaz/cmp.cfc?method=adduser&email='+$("##email").val()+'&dropto='+$("##pricedrop").val()+'&pid=#url.pid#',
			</cfoutput>
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
---->
function doLogin(){
	<cfoutput>
		window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/login/?email='+email;
	</cfoutput>
}

function setupAccount(){
		 var user_sk = $("#user_sk").val();
		 var password = $("#password").val();
		 
		 $.ajax({
			type: 'GET',
		    <cfoutput>
			    url: '/fkaz/cmp.cfc?method=setupAccount&user_sk='+user_sk+'&password='+password,
			</cfoutput>
		    beforeSend : function(a){
		    				$("#passwordalert").empty();
		    			 },
		    complete : function(results){
						},
			success : function(results){
						if(results.ERROR == 1){
							$("#passwordalert").empty();
							$("#passwordalert").append("We apologies! Please try again! :(");
						}
						else{
							$("#passwordbox").empty();
							$("#passwordbox").append("Thanks for setting up account! An email is sent to your email id. Please activate your account.<br>Don't forget to check your SPAM folder and mark email as NO Sapm!");
						}
					  },
			error : function(){
				console.log("ERROR");
				$("#emailalert").empty();
				$("#emailalert").append("We apologies! Please try again! :(");
			}
		});
}


	
//$( "#email" ).blur(validEmail);
scrolling=0;
function moveleft(s,where){
	scrolling=s;
	console.log(scrolling);
	var max = where*($(".canvasjs-chart-container").width()-100);
	var current = (-where)*$(".canvasjs-chart-container").position().left;
	var step = 20;
	if(current < max) scrolling = 0;
	if(scrolling == 0) return;
	$(".canvasjs-chart-container").animate({
	    
	    left: current+(step*where)
	  }, 50,function() {
	    moveleft(scrolling,where);
	  });
}

function moveright(s,where){
	scrolling=s;
	var max = ($(".canvasjs-chart-container").width()-100);
	var current = $(".canvasjs-chart-container").position().left;
	var step = 20;
	if(current >= 0) scrolling = 0;
	if(scrolling == 0) return;
	$(".canvasjs-chart-container").animate({
	    
	    left: current+(step*where)
	  }, 50,function() {
	    moveright(scrolling,where);
	  });
}

function showrange(o){
	console.log(o);
}
</script>
</head>
<body>
<div id="contentbox" style="z-index:100;">
	<!--- <cfif not isdefined("client.user_sk")>
	<div style="border:3px solid white;background-color:white;"><span class="textsize" style="width:100px">Send me alert at:</span></div>
		<div style="border:3px solid white;background-color:white;">
			<input name="email" id="email" size="30" placeholder="Please enter Email" style="font-size:small">
			<span class="textsize" style="width:100px;color:red;" id="emailalert"></span> 
		</div>
	<cfelse>
		<cfoutput><input name="email" id="email" type="hidden" value="#client.email#"></cfoutput>
	</cfif>
	<div style="border:1px solid white;background-color:white;"><span class="textsize"><br>When price drops to Rs.</span></div>
	<div style="border:1px solid white;background-color:white;"><span>
		<!--- <input name="pricedrop" id="pricedrop" size="10"> --->
		<select name="pricedrop" id="pricedrop" style="font-size:small" onchange="showrange(this);">
			<option value="1" style="font-size:small">Less then 5%</option>
			<option value="2" style="font-size:small">5% to 10%</option>
			<option value="3" style="font-size:small">10% to 20%</option>
			<option value="4" style="font-size:small">20% to 50%</option>
			<option value="5" style="font-size:small">50+%</option>
		</select>
	</span><span class="pricerange"></span></div>
	<cfoutput>
		<div style="border:3px solid white;background-color:white;"><button value="Track it!" onclick="trackit('#url.pid#')" type="submit" id="trackitbutton">Track it!</button></div>
	</cfoutput> --->
</div>
<div id="passwordbox" style="display:none;font-size:small;">
	<div style="border:5px solid rgba(0,0,0,0)">
		Your alert is setup! Setup a password & manage alerts. See a dashboard with all products that you are tracking.
	</div>
	<div style="border:5px solid rgba(0,0,0,0);text-align:center;">
	<input name="password" id="password" type="password" size="30" placeholder="Please enter password" style="font-size:small"> 
	<button value="Track it!" onclick="setupAccount();" type="submit">Setup Account</button>
	<input name="user_sk" id="user_sk" type="hidden"> 
	<span class="textsize" style="width:100px;color:red;" id="passwordalert"></span> 
	</div>
</div>
<div id="whysoless" style="display:none;text-align:center;width:100%">
	<span style="font-size:x-small;color:blue;text-align:center;width:100%">Why I'm seeing less data</span>
	<div id="whysolessdata" style="display:none;font-size:x-small;left:10;text-align:left;">
		<p>Amazon/Flipkart has millions of products. We put many products daily in our system to track their price history. Or whatever our users search/track, it becomes part of tracking system. So if the product you are looking for was put in our system a few days before, there will be lesser history which will keep on growing everyday. So if you search for a product with less or no data, no worries, track it and we will alert you when price drops.</p>	
	</div>
</div>
<cfif itemChardData.recordcount gt 1>
	<div style="overflow-x: scroll;float: left;width:100%;text-align:center;" id="chartparent">
		<cfif client.mobile>
			<span id="charright" 
					<!--- onkeydown='moveleft(1,-1)' onkeyup='moveleft(0,-1)' onmouseover='moveleft(1,-1)' onmouseout='moveleft(0,-1)' --->
					><img src="/fkaz/images/left.jpg">
					<!---  ---></span><span style="width:30px">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span id="charleft" <!--- onkeydown='moveright(1,1)' onkeyup='moveright(0,1)' onmouseover='moveright(1,1)' onmouseout='moveright(0,1)' --->><img src="/fkaz/images/right.jpg"></span>
		</cfif>
		<div id="chartContainer"></div>
	</div>
<cfelse>
	<div id="nochartContainer" style="text-align:center;border:15px solid rgba(255, 255, 255, 0);">
	We are not yet tracking this item so price history is not available!<br>But don't worry, its in our tracking system now!<br>
	You can still get alerts when price drops in future:<br>
	</div>
</cfif>
</body>

</html>
