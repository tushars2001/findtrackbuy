<cfparam default="" name="url.email">
<html>
	<head>
		<cfif client.mobile>
			<meta name="viewport" content="width=device-width, initial-scale = 1.0, maximum-scale=1.0, user-scalable=no" />
		</cfif>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<script language="javascript" src="/fkaz/js/common.js"></script>
	<script language="javascript" src="/fkaz/js/utils.js"></script>
		<cfoutput><link rel="stylesheet" href="/fkaz/js/#request.files#.css"></cfoutput>
	<script type="text/javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
	<script language="javascript" src="/fkaz/js/isotope.pkgd.min.js"></script>
	<cfoutput><script language="javascript" src="/fkaz/js/#request.files#.js"></script></cfoutput>
	<style>
		body{
		margin: 0;
		padding: 0;
		font-family:'Verdana', Verdana, sans-serif;
		}
		
		.mainHead{
		  	font-size:xx-large; 
		  	font-family:'Verdana', Verdana, sans-serif;
		  	text-align:center;
		  	color:gray;
		  }
		  .question{
		  	cursor: pointer; cursor: hand;
		  }
		  .answer{
		  	display:none;
		  }
	</style>
	<script language="javascript" type="text/javascript">
	 $(document).ready(function(){
	 	init();
	 	$(".question").click(
	 		function(o,p){
	 			$(".answer").slideUp( "slow");
	 			var classname = '';
	 			var elem = this;
	 			var track = 0;
	 			while(classname != 'answer'){
	 				track++;
	 				if(track > 50) break;
	 				elem = $(elem).next();
	 				classname = elem.attr("class");
	 				if(classname == "answer"){
	 					if($( elem ).is(':visible')){
	 						$(elem).slideUp( "slow");
	 					}
	 					else{
	 						$(elem).slideDown("slow");
	 					}
	 					break;
	 				}
	 			}
	 		}
	 	);
	 	$(".showhide").click(function(){
	 		$(".answer").slideToggle();
	 	});
	 });
	 
	
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
		<div class="FAQ" style="position:absolute;width:90%;margin:1%">
			<div class="showhide" style="cursor: pointer; cursor: hand;text-align:center;">Show/Hide All</div>
			<cfinclude template="./FAQ.htm">
		</div>
		<!--- <div>Frequently Asked Questions</div>
		
		<div class="question">What is FindTrackBuy.com?</div>
		<div class="answer">
			FindTrackBuy.com is free analytical tool that helps you save money by keeping track of products you wish to buy and alert you via email when price drops.
			How FindTrackBuy saves me money?
			There are various way this tool can help you save money, below are two examples:
			1.	You track the product that you want to buy and we will inform you when price drops to certain levels as per you.
			2.	Before buying product online, just check its history. May be the product that you are buying is high at cost and might come down. So track it and save bucks.

		</div>
		
		<div class="question">How to Track Product?</div>
		<div class="answer">
		
		</div>
		
		<div class="question"></div>
		<div class="answer">
		
		</div>
		
		<div class="question"></div>
		<div class="answer">
		
		</div>
		
		<div class="question"></div>
		<div class="answer">
		
		</div>
		
		<div class="question"></div>
		<div class="answer">
		
		</div> --->
		
	</body>
</html>