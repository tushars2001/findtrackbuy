<cfparam default="" name="url.user_sk">
<cfset obj = createobject("component","fkaz.cmp")>
<cfset getUserData = obj.getUserBySk(url.user_sk)>
<cfif (not len(url.user_sk)) or (getUserData.recordcount eq 0)>
	<cflocation url="/fkaz/login/?msg=Problem in Password Reset Link.">
</cfif>


<html>
	<head>
		<link rel="stylesheet" href="/fkaz/js/main.css">
	<script type="text/javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
	<script language="javascript" src="/fkaz/js/main.js"></script>
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
		if($.trim($("#password1").val()).length>3 && $.trim($("#password1").val()) == $.trim($("#password2").val())){
			return true;
		}
		else{
			$("#alertmsg").empty();
			if($.trim($("#password1").val()).length<=4){
				$("#alertmsg").append("<br>No complications, but password must be at least 4 characters long.");
			}
			else if($.trim($("#password1").val()) != $.trim($("#password2").val())){
				$("#alertmsg").append("Passwords don't match");
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
		<cfinclude template="/fkaz/header.cfm">
		<form name="resetpassword" method="post" action="/fkaz/login/reset/do/" onsubmit="return check();">
		<cfoutput><input type="hidden" id="user_sk" name="user_sk" value="#url.user_sk#"></cfoutput>
		<table align="center">
			<tr>
				<td colspan="2"><h2>Reset Password</h2></td>
			</tr>
			<tr>
				<td>Please enter password</td>
				<td><cfoutput><input type="password" value="" id="password1" name="password1" size="30"></cfoutput></td>
			</tr>
			<tr>
				<td>Re-enter password</td>
				<td><input type="password" id="password2" name="password2" size="30"></td>
			</tr>
			<tr>
				<td colspan="2" style="text-align:center"><button type="submit" id="submit" name="submit" style="width:100%" >Reset</button></td>
			</tr>
			<tr>
				<td colspan="2" style="text-align:center;color:red;font-size:x-small;font-weight:bold;"><div id="alertmsg"><cfif isdefined("url.msg")><cfoutput>#url.msg#</cfoutput></cfif></div></td>
			</tr>
		</table>
	</body>
</html>