function init(){
	
	$('#mainGrid').css("width",$(window).width()*0.8);
	//$('#mainGridLive').css("width",$(window).width()*0.8);
			$('#mainGrid').css("text-align","center");
			//$('#mainGridLive').css("text-align","center");
			<!--- $('#mainGrid').css("position","relative"); --->
			$('#mainGrid').css("left",$(window).width()*0.1);
			//$('#mainGridLive').css("left",$(window).width()*0.1);
			$('.grid-item').css("width",$('#mainGrid').width()-20);
			
			$('.grid').isotope({
			  // options
			  itemSelector: '.grid-item',
			  layoutMode: 'fitRows',
				fitRows: {
				  gutter: 10
				},
				 getSortData: {
			      title: '.title',	
			      price: '.price parseInt',
			      category: '[data-category]'
			    }
			  
			});
			$('.grid').isotope('layout');
			
			$(".options").css({
				"height":$(".wrapper").height()
			});
			$(".options").css({
				"width":$(".wrapper").width()
			});
			$(".options").css({
				"max-height":$(".wrapper").height()
			});
			$(".options").css({
				"max-width":$(".wrapper").width()
			});
			$(".options").css({
				"overflow":"auto"
			});
			$(".hist_input").css("width",$(".wrapper").width()*.9);
			$(".hist_button").css("width",$(".wrapper").width()*.9);
			$(".hist_button").css("left",$(".wrapper").width()*.05);
			$(".hist_button").css("cursor","pointer");
			$(".hist_button").css("cursor","hand");
			
			
	$( "#helpusgrow" ).slideUp( "slow");
	$( "#clickme" ).click(function() {
    	$( "#reportissue" ).slideUp( "slow");
    	$( "#helpusgrow" ).slideUp( "slow");
    	
	    if($( "#howitworks" ).is(':visible')){
	    	$( "#howitworks" ).slideUp( "slow");
	    }
	    else{
	    	 $( "#howitworks" ).slideDown( "slow");
	    }
	 
	});
	
	$( "#reportissueitem" ).click(function() {
		$( "#howitworks" ).slideUp( "slow");
		$( "#helpusgrow" ).slideUp( "slow");
		
	    if($( "#reportissue" ).is(':visible')){
	    	$( "#reportissue" ).slideUp( "slow");
	    }
	    else{
	    	 $( "#reportissue" ).slideDown( "slow");
	    }
	 
	});
	
	$( "#helpusgrowitem" ).click(function() {
		$( "#howitworks" ).slideUp( "slow");
		$( "#reportissue" ).slideUp( "slow");
		
	    if($( "#helpusgrow" ).is(':visible')){
	    	$( "#helpusgrow" ).slideUp( "slow");
	    }
	    else{
	    	 $( "#helpusgrow" ).slideDown( "slow");
	    }
	 
	});
	
	$(window).on("orientationchange",function(){
		//alert('w:'+screen.width+' h:'+screen.height);
	 $( "#dialog" ).dialog( "close" );
	 $( "#dialog" ).dialog( "open" );
	 
	});
}

function selectsince(days,o){
	meterparams.since = days;
	$(".sinceclass").css({"text-decoration":"none","color":"gray"});
	$(o).css({color:"black","text-decoration":"underline"});
	console.log(o);
}

function getsetgo(){
	 $.ajax({
				type: 'post',
			    url: '/fkaz/cmp.cfc?method=setMeter',
			    data: {arg:JSON.stringify(meterparams)},
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    //console.log(results);
			    location.reload();
			    			}
			});
}


function getchart(pid,title,img) {
		  $.ajax({
			type: 'GET',
		    url: '/fkaz/chart.cfm?pid='+pid,
		   <!---  cache: false, --->
		    beforeSend : function(a){
		    				$( "#dialog" ).show();
		    				$( "#dialog" ).empty();
		    				$( "#dialog" ).append("Loading...");
		    				$( "#dialog" ).dialog({ 
							modal:true,
							      buttons: {
						        Close: function() {
						          $( this ).dialog( "Close" );
						        }
						      },
							autoOpen: false,
							position: { 
								my: "top", 
								at: "top", 
								of: window
								 },
								height:screen.height*.7,
								width:screen.width*.95
							
							
						});
						
			    		$( "#dialog" ).dialog( "open" );
		    			 },
		    complete : function(results){
		    		$( "#dialog" ).empty();
		    		$(".ui-dialog").css("z-index","25");
		    		if(typeof title != "undefined"){
		    			//$( "#dialog" ).append("<div style='text-align:center'><div>"+title+"</div>"+"<div><img width='100' height='100' src='"+img+"'></div></div>");
		    		}
		    		$( "#dialog" ).append(results.responseText);
		    		$( "#dialog" ).dialog({ 
			
						autoOpen: false,
						modal:true,
							      buttons: {
						        Close: function() {
						          $( this ).dialog( "close" );
						        }
						      },
						position: { 
							my: "top", 
							at: "top", 
							of: window
							 },
								height:screen.height*.7,
								width:screen.width*.95
						
					});
		    		$( "#dialog" ).dialog( "open" );
		    		
		    		chart.render();
		    		
		    		$( "#dialog" ).resize(function() {
					  chart.render();
					});
		    	}
			});
}
