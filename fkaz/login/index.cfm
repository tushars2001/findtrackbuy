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
		  
	</style>
	<script language="javascript" type="text/javascript">
	 $(document).ready(function(){
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
		<cfif not isdefined("url.nohead")>
			<cfinclude template="/fkaz/header.cfm">
		</cfif>
		<cfparam name="url.redirect" default="/fkaz/">
		<cfoutput>
			<form name="login" method="post" action="/fkaz/login/do/?redirect=#url.redirect#" onsubmit="return check();">
		</cfoutput>
		<table align="center" class="menuItemSmall">
			<tr>
				<td>Email Address</td>
				<td><cfoutput><input type="text" value="#url.email#" id="email" name="email" size="30" <cfif len(url.email)>disabled</cfif>></cfoutput></td>
			</tr>
			<tr>
				<td>Password</td>
				<td><input type="password" id="password" name="password" size="30"></td>
			</tr>
			<tr>
				<td colspan="2" style="text-align:center"><button type="submit" id="submit" name="submit" style="width:100%" >Login/Register</button></td>
			</tr>
			<tr>
				<td colspan="2" style="text-align:center;color:red;font-size:x-small;font-weight:bold;"><div id="alertmsg"><cfif isdefined("url.msg")><cfoutput>#url.msg#</cfoutput></cfif></div></td>
			</tr>
		</table>
		<div style="display:none;text-align:center;" id="forgot">
			<div><cfoutput><input type="text" value="#url.email#" placeholder="Send Reset info to my email id..." id="email2" name="email2" size="30"></cfoutput></div>
			<div><button type="button" id="submitpwd" name="submitpwd" onclick="sendpassword();">Send Password</button></div>
		</div>
		<div style="cursor: pointer; cursor: hand;text-align:center;" onclick="forgotpassword();">Forgot Password</div>
	</body>
</html>