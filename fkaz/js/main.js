function init(){
	
	try{
		if (cssua.ua.mobile) {
			$("#mobilesite").show();
		}
	}catch(e){}
	
	$('#mainGrid').css("width",$(window).width()*0.8);
	                $(".content").css("width",$(window).width()-300);
                        $(".sidead").css("width",300);
	
			$('#mainGrid').css("text-align","center");
			<!--- $('#mainGrid').css("position","relative"); --->
			//$('#mainGrid').css("left",$(window).width()*0.1);
			$('.grid-item').css("width",$('#mainGrid').width()/3-20);
			
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
			$(".hist_button").css("left",($(".wrapper").width()-250)/2);
			$(".hist_button").css("cursor","pointer");
			$(".hist_button").css("cursor","hand");
			
			$(".savestamp").each(function(idx,rec){
			$(rec).css({
				left:($($(rec).parent()).width()-143)/2,
				top:($($(rec).parent()).height()-147)/2
			});
			$($(".savebucks")[idx]).css({
				"top":(147-$($(".savebucks")[idx]).height())/2,
				"left":(143-$($(".savebucks")[idx]).width())/2
			}
			);
			
			
		});

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

        $(".sidead").css({
		"position":"fixed",
		"top":$(".content").position().top,
		"width":"20%",
		"left":$(".content").width(),
		"height":"90%"
		
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
					          $( this ).dialog( "close" );
					        }
					      },
						autoOpen: false,
						position: { 
							my: "top", 
							at: "top", 
							of: window
							 },
							height:screen.height/2,
							width:screen.width/2
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
							height:screen.height/2,
							width:screen.width/2
				});
	    		$( "#dialog" ).dialog( "open" );
	    		
	    		chart.render();
	    		
	    		$( "#dialog" ).resize(function() {
				  chart.render();
				});
	    	}
		});
}