<cfif not isdefined("client.user_sk")>
	<cflocation url="/fkaz/login/?msg=You are not logged in. Login to continue">
</cfif>


<cfquery name="getuseralerts" datasource="#application.dsn#">
	SELECT a.pid, t.link, t.type, t.image, t.title, a.rule, t.last_price, a.price, a.active,a.record_id
	FROM  `ftb_alerts` a, ftb_trackers_pid t
	WHERE t.pid = a.pid and a.user_sk = '#client.user_sk#' and a.rule is not null
	order by a.active desc, a.record_id desc
</cfquery>

<cfquery name="savings" dbtype="query">
	select sum(price-last_price) as savings from getuseralerts
	where price > last_price
</cfquery>


<html>
	<head>
		<cfif client.mobile>
			<meta name="viewport" content="width=device-width, initial-scale = 1.0, maximum-scale=1.0, user-scalable=no" />
		</cfif>
		<script language="javascript" src="/fkaz/js/common.js"></script>
		<script language="javascript" src="/fkaz/js/utils.js"></script>
		<link rel="stylesheet" href="/fkaz/js/jquery-ui.theme.min.css">
		<script type="text/javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
		<script language="javascript" src="/fkaz/js/isotope.pkgd.min.js"></script>
		<script type="text/javascript" src="/fkaz/js/canvasjs-1.7.0/jquery.canvasjs.min.js"></script>
		<script language="javascript" src="/fkaz/js/jquery-ui.min.js"></script>
		<script language="javascript" src="/fkaz/js/jquery.resizecrop-1.0.3.min.js"></script>
		<script language="javascript" src="/fkaz/js/chart.js"></script>
		<cfoutput><link rel="stylesheet" href="/fkaz/js/#request.files#.css"></cfoutput>
		<cfoutput><script language="javascript" src="/fkaz/js/#request.files#.js"></script></cfoutput>
		<script language="javascript">
		 $(document).ready(function(){
			$('.prodimg').resizecrop({
			    width: '200',
			    height: '200'
			});
			 init();
			 $('.grid').isotope('layout');
			<cfloop from="1" to="#getuseralerts.recordcount#" index="idx">
				<cfoutput>
					//loadchart('#getuseralerts.pid[idx]#',#idx#);
				</cfoutput>
			</cfloop>
			<cfif not client.mobile>
				//$(".wrapper").css("left",($(window).width()-$(".wrapper").width())/2);
			</cfif>
			
		});
		
		
		
		
		
		function updatealert(pid,id,record_id){
			<cfoutput>
				var email = '#client.email#';
				var active =0;
				if(document.getElementById("alert"+id).checked){
					active=1;
				}
			</cfoutput>
			$.ajax({
				type: 'GET',
			    url: '/fkaz/cmp.cfc?method=updateAlert&email='+email+'&pid='+pid+'&rule='+$("#pricedrop"+id).val()+'&active='+active+'&record_id='+record_id,
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    				$("#update"+id).text("Updating...");
			    			 },
			    complete : function(results){
			    				$("#update"+id).text("Update");
			    			}
			});
			
		}
		
		</script>
	</head>
	<body>
		<script>
		  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
		  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
		  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
		  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
		
		  <cfoutput>ga('create', '#application.goog#', 'auto');</cfoutput>
		  ga('require', 'displayfeatures');
		  ga('send', 'pageview');
		
		</script>
		<cfinclude template="/fkaz/header.cfm">
		<div class="mainHead" style="color:black;font-size:medium;">My Dashboard</div>
		
		<cfif savings.savings gt 0>
			<cfoutput><div class="mainHead" style="color:red;font-size:medium;font-weight:bold;">You can save approx. Rs. #numberFormat(savings.savings,',')# if you buy products that you are tracking and prices are dropped.</div></cfoutput>
		</cfif>
		<div style="height:20px"></div>
		<cfif not getuseralerts.recordcount>
			<div class="mainHead" style="color:red;font-size:small;">You are not tracking any item yet!</div>
		</cfif>
		<div class="grid" id="mainGrid">
		<cfloop from="1" to="#getuseralerts.recordcount#" index="idx">
			<div class="wrapper grid-item" style="height:330;text-align:center;border-bottom:1px solid gray;border-top:15px solid white">
				<cfoutput>
						<div style="font-weight:bold<cfif client.mobile>;font-size:x-small;</cfif>">
							#getuseralerts.title[idx]#
						</div>
						<div>
							<a href="#getuseralerts.link[idx]#">
								<img class="prodimg" src="#getuseralerts.image[idx]#">
							</a>
						</div>
						<div style="border:5px solid white;width:100%">
						Drop Alert settings:
						</div>
						<div id="rule#idx#" <cfif client.mobile>style="font-size:x-small;"</cfif>>
							<select name="pricedrop#idx#" id="pricedrop#idx#" style="font-size:small">
								<option value="1" style="font-size:small" <cfif getuseralerts.rule[idx] eq 1>selected</cfif>>Less then 5%</option>
								<option value="2" style="font-size:small" <cfif getuseralerts.rule[idx] eq 2>selected</cfif>>5% to 10%</option>
								<option value="3" style="font-size:small" <cfif getuseralerts.rule[idx] eq 3>selected</cfif>>10% to 20%</option>
								<option value="4" style="font-size:small" <cfif getuseralerts.rule[idx] eq 4>selected</cfif>>20% to 50%</option>
								<option value="5" style="font-size:small" <cfif getuseralerts.rule[idx] eq 5>selected</cfif>>50+%</option>
							</select>
							Alert me:<input type="checkbox" name="alert#idx#" id="alert#idx#"  <cfif getuseralerts.active[idx] eq 1> checked </cfif>>
							<button name="update#idx#" id="update#idx#" onclick="updatealert('#getuseralerts.pid[idx]#','#idx#','#getuseralerts.record_id[idx]#')">Update</button>
						</div>
						<div style="border:1px solid white;width:100%;font-size:x-small;text-align:left;">
							When you tracked, price was: <span style="font-weight:bold">Rs. #getuseralerts.price[idx]#</span><br>
							Current price : <span style="font-weight:bold">Rs. #getuseralerts.last_price[idx]#</span><br>
							<cfif getuseralerts.price[idx] eq getuseralerts.last_price[idx]>
								<span style="text-align:center">No Change :-|</span>
							<cfelseif getuseralerts.price[idx] gt getuseralerts.last_price[idx]>
								<span style="font-weight:bold;color:red;text-align:center">Price Dropped! :)</span>
							<cfelseif getuseralerts.price[idx] lt getuseralerts.last_price[idx]>
								<span style="color:green;text-align:center">It gained :(</span>
							</cfif>
						</div>
						<div style="border:5px solid white;width:100%">
							<span style="text-align:left">
								<a href="#getuseralerts.link[idx]#" style="text-decoration:none;color:black;font-weight:bold;">Buy Now </a>
							</span>
							<span>&nbsp;&nbsp;&nbsp;</span>
							<span style="text-align:right;cursor: hand;" onclick="getchart('#getuseralerts.pid[idx]#','')">
								Price History
							</span>
						</div>
					</div>
					<!--- <div style="display:none;position:absolute;overflow-x: scroll;width:400;height:200;text-align:center;" id="chartparent#idx#">
						<div id="chart#idx#" style="width:600;height:300;float: left;">
						
						</div>
					</div> --->
				</cfoutput>
		</cfloop>
		</div>
		<div id="dialog" class="dialogcss" title="Price History"></div>
		<div style="height:20px"></div>
		<div class="footer">
			Copyrights 2015. A <a href="http://www.QuirkyCrackers.com" target="_blank">QuirkyCrackers.com</a> Productions
		</div>
	</body>
</html>
