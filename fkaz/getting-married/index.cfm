<html>

	<head>
	<meta name="description" 		content="Your Great Wedding can yield in big Savings that you can add on to your Honeymoon! Track All Items that you are planning to buy in next few months from now and we will alert you when their prices are down and when it's best time to buy.">
		<meta property="og:title"   	content="Save Big on Your Wedding" />
	<meta property="og:image"       content="http://findtrackbuy.quirkycrackers.com/fkaz/images/getting-married.png" />		
<style>
			@font-face {
			    font-family: 'wedding'; /*a name to be used later*/
			    src: url('Precious.ttf'); /*URL to font*/
			}
			@font-face {
			    font-family: 'weddingtext'; /*a name to be used later*/
			    src: url('ANGEL___.otf'); /*URL to font*/
			}
			.headingmain{
				font-family: 'wedding';
				font-size:600%;
				text-align:center;
				margin:10px;
				color:red;
			}
			.heading{
				font-size:300%;
				text-align:center;
				margin:10px;
			}
			.starthere{
				font-size:xx-large;
				text-align:center;
				width:100%;
			}
			</style>
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
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#&folder=/getting-married/';
				</cfoutput>
			</cfif>
		}
		else{
			<cfif client.mobile and session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#&folder=/getting-married/';
				</cfoutput>
			</cfif>
		}
		</cfoutput>
	})();

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
		<div class="campaign">
		<div class="headingmain">Wedding Bells on The Cards<br>Congratulations!</div>
		<div class="heading">Big Fat Indian Wedding is Great</div>
		<div class="heading"><img src="bigfat.jpg"></div>
		<div class="heading">But it burns hole in pockets</div>
		<div class="heading"><img src="pocket.jpg"></div>
		<div class="heading">While you cannot just be too miser but you can surely optimize your expanses</div>
		<div class="heading"><img src="miser.jpg"></div>
		<div class="heading">Track Products here that you are supposed to buy in coming months
			<br><img src="shoppinglist.jpg"><br>And we will help you saving money by alerting you when price of the product is at low
			<br><img src="track1.PNG"><img src="track2.PNG">
		</div>
		<div class="heading">Save Bucks for Better things</div>
		<div class="headingmain">Like Honeymoon <3</div>
		<div class="heading"><img src="honeymoon.jpg"></div>
		</div>
		<div class="starthere"><A href="/fkaz/" style="text-decoration:none;" class="starthere">START HERE</a></div>
	</body>
</html>
<!--- <cfinclude template="/fkaz/index.cfm"> --->