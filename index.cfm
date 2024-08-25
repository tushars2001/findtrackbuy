<html>

	<head>
		
	<meta name="description" 		content="Your Great Wedding can yield in big Savings that you can add on to your Honeymoon! Track All Items that you are planning to buy in next few months from now and we will alert you when their prices are down and when it's best time to buy.">
		<meta property="og:title"   	content="Save Big on Your Wedding" />
	<meta property="og:image"       content="http://findtrackbuy.quirkycrackers.com/fkaz/images/getting-married.png" />		
<style>
			@font-face {
			    font-family: 'wedding'; /*a name to be used later*/
			    src: url('artill_luco_sans_923.ttf'); /*URL to font*/
			}
			body{
				margin:0;
				
			}
			
			<!--- .group{
				border-bottom:100px solid rgb(255, 212, 150);
				border-top:10px solid white;
				background-color:rgb(255, 212, 150);
			} --->
			
			.head{
				font-family: 'wedding';
				font-size:600%;
				text-align:center;
				color:black;
			}
			.subhead{
				font-family: 'wedding';
				font-size:300%;
				text-align:center;
			}
			.detail{
				text-align:center;
				font-size:200%;
			}
			.img{
				text-align:center;
				opacity: 0.6;
				overflow:auto;
			}
			
			.starthere{
				font-size:xx-large;
				//text-align:center;
				font-family: 'wedding';
				border-top:10px solid white;
				width:100%;
				background-color:yellow;
				position:fixed;
				bottom:0;
			}
			.bgimg{
				background-image:url('bgimg2.jpg');
				position:fixed;
				height:100%;
				width:100%;
				opacity: 0.2;
			}
			</style>
			<!--- <script language="javascript">
	(function msite(){
		var sw = screen.width;
		var sh = screen.height;
		var small = sw;
		if(sw > sh) small = sh;
		<cfoutput>
		if(small < 640){
			<cfif not session.mobile and not session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#';
				</cfoutput>
			</cfif>
		}
		else{
			<cfif session.mobile and session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#';
				</cfoutput>
			</cfif>
		}
		</cfoutput>
	})();

</script> --->
	<script>
		var t = 60;
		var skip = 1;
		setInterval(function(){ 
			if(skip){
				t--; 
				if(t >= 0){
					document.getElementById('timer').innerHTML = ''; 
					document.getElementById('timer').innerHTML = t; 
				}
				if(t == 0){
					window.location = '/fkaz/';
				}
				if(t == 10){
					//document.getElementById('skipblock').style.fontSize = 'xx-large';
					document.getElementById('timer').style.fontSize = 'xx-large';
					document.getElementById('timer').style.color = 'red';
				}
			}
			}, 1000);
	</script>
	</head>
	<body>
		<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	
	  <cfoutput>ga('create', 'UA-54318348-1', 'auto');</cfoutput>
	  ga('require', 'displayfeatures');
	  ga('send', 'pageview');
	
	</script>
		<div class="bgimg">
		
		</div>
		<div class="group">
			<div class="head">FindTrackBuy</div>
			<div class="subhead">Your Favorite Analytical Tool that Saves you Bucks!</div>
			<div class="detail" style="z-index:10;position:relative;">How- <a href="/fkaz/faq/" style="color:black;">FAQ Here</a></div>
		</div>
		<div class="img"><img src="./fkaz/images/bg/1.jpg"></div>
		<div class="group">
			<div class="head">Data is Power</div>
			<div class="subhead">They Say : Data is New Oil</div>
			<div class="detail">The key to good decision making is evaluating the available information - the data - and combining it with your own estimates of pluses and minuses.</div>
		</div>
		<div class="img"><img src="./fkaz/images/bg/2.jpg"></div>
		<div class="group">
			<div class="head">Time Changes. So do Prices.</div>
			<div class="subhead">But when, how much, how frequent?</div>
			<div class="detail">The price of everything rises and falls from time to time and place to place; and with every such change the purchasing power of money changes so far as that thing goes.</div>
		</div>
		<div class="img"><img src="./fkaz/images/bg/3.jpg"></div>
		<div class="group">
			<div class="head">Data is Power. Analytics Makes it Great</div>
			<div class="subhead">Optimize your online shopping expenses!</div>
			<div class="detail">Analysis is not a new Trend. It is a tool that successful people have been using for centuries. Information is the oil of 21st Century and analytics is the combustion engine.</div>
		</div>
		<div style="height:100px"></div>
		<div class="starthere" style="text-decoration:none;text-align:center;"><A href="/fkaz/" style="text-decoration:none;text-align:center;">Start Tracking. Start Savings. START HERE</a> <div id="skipblock" style="text-align:center;font-family:abc;">Skip To Main Site in <span id="timer" >60</span> Seconds. <span onclick="skip=0;" style="cursor: pointer; cursor: hand;text-decoration:underline;">Don't Skip</span> </div></div>
	</body>
</html>
<!--- <cfinclude template="/fkaz/index.cfm"> --->