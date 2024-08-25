function QuicksetupAccount(pid){
		 var user_sk = $("#user_sk").val();
		 var password = $("#password_"+pid).val();
		 
		 if($.trim(password).length<=4){
				
				$("#emailalert_"+pid).empty();
				$("#emailalert_"+pid).append("<br>No complications, but password must be at least 5 characters long.");
				return;
			}
		 
		 $.ajax({
			type: 'GET',
			    url: '/fkaz/cmp.cfc?method=setupAccount&user_sk='+user_sk+'&password='+password,
		    beforeSend : function(a){
		    				$("#passwordbox_"+pid).empty();
		    			 },
		    complete : function(results){
						},
			success : function(results){
						$("#emailalert_"+pid).empty();
						if(results.ERROR == 1){
							$("#passwordbox_"+pid).empty();
							$("#passwordbox_"+pid).append("We apologies! Please try again! :(");
						}
						else{
							$("#passwordbox_"+pid).empty();
							$("#passwordbox_"+pid).append("Thanks for setting up account! An email is sent to your email id. <br>Don't forget to check your SPAM folder and mark email as NO Sapm!");
						}
					  },
			error : function(){
				console.log("ERROR");
				$("#emailalert_"+pid).empty();
				$("#emailalert_"+pid).append("We apologies! Please try again! :(");
			}
		});
}

function sendIssue(user_sk){
	
	$.ajax({
	type: 'GET',
    url: '/fkaz/cmp.cfc?method=addIssue&user_sk='+user_sk+'&issue='+$("#issue").val(),
    beforeSend : function(a){
    	$( "#issuealert" ).empty();
    	$( "#issuealert" ).append("Thanks for reporting issue!")
    			 },
    complete : function(results){
    		$( "#reportissue" ).slideUp( "slow",function(){
    			$( "#issuealert" ).empty();
    		});
    	}
	});
	
}

function dropMenuItems() {
    if($( "#allDropsOptions" ).is(':visible')){
    	$( "#allDropsOptions" ).slideUp( "fast");
    }
    else{
    	 $( "#allDropsOptions" ).slideDown( "fast");
    }
	 
};