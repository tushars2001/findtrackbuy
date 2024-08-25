<cfparam default="" name="url.email">
<html>
	<head>
		<cfif client.mobile>
			<meta name="viewport" content="width=device-width, initial-scale = 1.0, maximum-scale=1.0, user-scalable=no" />
		</cfif>
		<script language="javascript" src="/fkaz/js/common.js"></script>
	<script language="javascript" src="/fkaz/js/utils.js"></script>
		<cfoutput><link rel="stylesheet" href="/fkaz/js/#request.files#.css"></cfoutput>
	<script type="text/javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
	<script language="javascript" src="/fkaz/js/isotope.pkgd.min.js"></script>
	<cfoutput><script language="javascript" src="/fkaz/js/#request.files#.js"></script></cfoutput>
	<link rel="stylesheet" type="text/css" href="/fkaz//js/slick-master/slick/slick.css"/>
	<script language="javascript" src="/fkaz/js/slick-master/slick/slick.min.js"></script>
	

	<script language="javascript" type="text/javascript">
	<!---  $(document).ready(function(){
	 	init();
	 });
	 
	function check(){
		if(isValidEmailAddress($("#email").val()) && $.trim($("#password").val()).length>3){
			document.getElementById("email").disabled = "";
			return true;
		}
		else{
			$("#alertmsg").empty();
			if(! isValidEmailAddress($("#email").val())){
				$("#alertmsg").append("Email doesn't look ok!");
			}
			if($.trim($("#password").val()).length<=4){
				$("#alertmsg").append("<br>No complications, but password must be at least 4 characters long.");
			}
			return false;
		}
		
	}
	
	function isValidEmailAddress(emailAddress) {
	    var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
	    return pattern.test(emailAddress);
	}; //isValidEmailAddress ends
	
	function forgotpassword() {
    	
	    if($( "#forgot" ).is(':visible')){
	    	$( "#forgot" ).slideUp( "slow");
	    }
	    else{
	    	 $( "#forgot" ).slideDown( "slow");
	    }
	 
	}
	
	function sendpassword(){
		var email = $("#email2").val();
		if(isValidEmailAddress(email)){
			$.ajax({
				type: 'GET',
			    url: '/fkaz/cmp.cfc?method=sendPassword&email='+email,
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    				$("#alertmsg").empty();
			    			 },
			    complete : function(results){
			    				$("#alertmsg").append("Password reset link sent to "+email);
			    			}
			});
		}
		else{
			$("#alertmsg").empty();
			$("#alertmsg").append("Email doesn't look ok!");
		}
		
	} --->
	
	</script>
	<style>
		body{
			//background-color:black;
		}
	</style>
	<script>
	$(document).ready(function(){
		init();
		var car_height = 550;
		<cfif client.mobile>
			car_height = 200;
		</cfif>
	 	$('.scenario').slick({
				  lazyLoad: 'ondemand',
				  autoplay: true,
				  autoplaySpeed: 5000,
				  arrows: true,
				  dots:true
				  //,centerMode: true
  				  //,centerPadding: '60px'
				});
		$(".scenario").css("width",screen.width*.8);
		$(".scenario").css("height",car_height);
		$(".scenario").css("left",(screen.width-$(".scenario").width())/2)
		//$(".images").css("left",(screen.width-$(".scenario").width())/2)
		$('.scenario').on('swipe', function(event, slick, direction){
		  console.log($('.scenario').slick('slickCurrentSlide'));
		});
		//$(".mainHead a").css("color","white");	
	 });
	
	function show(which){
		$(".scenario").hide();
		$("#s"+which+"content").show();
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
		<div style="width:100%;background-color:rgb(23, 51, 6);">
			<div style="color:gray;text-align:center;width:100%;height:100px;border-top:10px solid rgb(23, 51, 6);font-size:<cfif client.mobile>x-</cfif>small;">
			We claim that using our tool you can save money.<br>With individual product price history in your hand, you can make smart decisions.<br>It can give a sense if it is best time to buy the product.<br>Our hassel free email alert service ensure you don't miss out to save bucks when product price is droped.<br>Here are three of many scenario where you can save money. 
			</div>
			<a name="anch"></a>
				<div style="text-align:center;color:orange;">How this Tool Saves You Bucks</div>
				<div style="text-align:center;color:orange;">
					<span id="scenario1"  style="cursor: pointer; cursor: hand;margin:10px">Scenario 1</span>
				</div>
				<cfoutput>
				<div class="scenario" id="s1content" style="display:block;"> 
					<div class="step">
						<div class="data">I want to buy a pair of Shoes</div>
						<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_1.jpg"/></div>
					</div>
					<div class="step">
						<div class="data">I searched Shoes and checked price history of my fav shoes.</div>
						<div class="images"><img  src="/fkaz//images/hiw/#request.files#/1_2.jpg"/></div>
					</div>
					<div class="step">
						<div class="data">I want to wait untill it drops by 10% atleast.<br>I track it.</div>
						<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_3.jpg"/></div>
					</div>
					<div class="step">
						<div class="data">We will send you alert when price drops<br>You buy it. You save bucks!</div>
						<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_4.jpg"/></div>
					</div>
					
				</div>
				
				<div style="text-align:center;color:orange;">
					<span id="scenario1"  style="cursor: pointer; cursor: hand;margin:10px">Scenario 2</span>
				</div>
				
			<div class="scenario" id="s2content" style="display:block;">
				<div class="step">
					<div class="data">I didn't find my Fav one in search. But I know it's on Amazon/Flipkart.</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/2_1.jpg"/></div>
				</div>
				<div class="step">
					<div class="data">I copy-pasted link. Found it. It looks costly.</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/2_2.jpg"/></div>
				</div>
				<div class="step">
					<div class="data">I want to wait untill it drops by 10% atleast.<br>I track it.</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_3.jpg"/></div>
				</div>
				<div class="step">
					<div class="data">We will send you alert when price drops<br>You buy it. You save bucks!</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_4.jpg"/></div>
				</div>
			</div>
			
			<div style="text-align:center;color:orange;">
					<span id="scenario1"  style="cursor: pointer; cursor: hand;margin:10px">Scenario 3</span>
				</div>
				
			<div class="scenario" id="s3content"  style="display:block;">
				<div class="step">
					<div class="data">I'm going to buy this awesome shoe on Flipkart/Amazon.</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_1.jpg"/></div>
				</div>
				<div class="step">
					<div class="data">Wait! Let me check it's price history here first!<br>Oh! It looks like price of this shoe is at high.</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/2_2.jpg"/></div>
				</div>
				<div class="step">
					<div class="data">I want to wait untill price drops by 10% atleast</div>
					<div class="data">I track it.</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_3.jpg"/></div>
				</div>
				<div class="step">
					<div class="data">We will send you alert when price drops<br>You buy it. You save bucks!</div>
					<div class="images"><img src="/fkaz/images/hiw/#request.files#/1_4.jpg"/></div>
				</div>
			</div>
			</cfoutput>
		</div>
	</body>
</html>