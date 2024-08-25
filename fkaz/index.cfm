<cfsetting showdebugoutput="false">
<!--- <script>
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '1684862888425977',
      xfbml      : true,
      version    : 'v2.1'
    });
  };

  (function(d, s, id){
     var js, fjs = d.getElementsByTagName(s)[0];
     if (d.getElementById(id)) {return;}
     js = d.createElement(s); js.id = id;
     js.src = "//connect.facebook.net/en_US/sdk.js";
     fjs.parentNode.insertBefore(js, fjs);
   }(document, 'script', 'facebook-jssdk'));
</script> --->
<script language="javascript">
	<cfoutput>
		meterparams = {
		droprange:{from:'#session.rangeFrom#',to:'#session.rangeto#'},
		pricerange:{from:'#session.prangeFrom#',to:'#session.prangeFrom#'},
		since:'#session.dropsince#',
		saveme:'#session.saveme#'
	};
	</cfoutput>

	(function msite(){
		var sw = screen.width;
		var sh = screen.height;
		var small = sw;
		if(sw > sh) small = sh;
		<cfoutput>
		if(small < 640){
			<cfif not client.mobile and not session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#';
				</cfoutput>
			</cfif>
		}
		else{
			<cfif client.mobile and session.force>
				<cfoutput>
					window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/mobile/?#cgi.QUERY_STRING#';
				</cfoutput>
			</cfif>
		}
		</cfoutput>
	})();

</script>
<cfset application.dsn = 'product'>
<cfset categories.fk = ''>
<cfset categories.az = ''>
<cfparam name="url.type" default="trends">
<cfparam name="session.fluctuate" default="0">
<cfset obj = createObject("component","cmp")>
<cfparam name="url.param" default="">
<cfparam name="url.category" default="All Drops">
<cfparam name="description" default="">
<cfparam name="invalidlink" default="0">
<cfparam name="url.page" default="1">

<cfif url.type eq 'trends'>
	<cfset session.dropsince = -1>
<cfelse>
	<cfif session.dropsince eq -1 or len(session.dropsince) eq 0>
		<cfset session.dropsince = 1>
	</cfif>
</cfif>

<cfset session.usermsg = ''>
<cfset msgcnt = 0>
<cfif session.fluctuate eq 1>
	<cfset msgcnt = msgcnt+1>
	<cfset session.usermsg = "#session.usermsg#These are fluctuaters; products whose prices changes frequently. ">
</cfif>
<cfif len(session.saveme) and  session.saveme neq 0>
	<cfset some = "some">
	<cfif session.saveme eq 100>
		<cfset some = "0 to 100">
	</cfif>
	<cfif session.saveme eq 500>
		<cfset some = "100 to 500">
	</cfif>
	<cfif session.saveme eq 1000>
		<cfset some = "500 to 1000">
	</cfif>
	<cfif session.saveme eq 1001>
		<cfset some = "More then 1000">
	</cfif>
	<cfset in =''>
	<cfif isdefined("url.category") and url.category neq "All Drops">
		<cfset msgcnt = msgcnt+1>
		<cfset in =' in #url.category# segment'>
	</cfif>
	<cfset msgcnt = msgcnt+1>
	<cfset session.usermsg = "#session.usermsg#You are Saving #some# bucks #in#. ">
</cfif>
<cfif len(session.dropsince)>
	<cfset days = "ever">
	<cfif session.dropsince eq 0>
		<cfset days = "ever">
		<cfset msgcnt = msgcnt+1>
	</cfif>
	<cfif session.dropsince eq 1>
		<cfset days = "yesterday">
		<cfset msgcnt = msgcnt+1>
	</cfif>
	<cfif session.dropsince eq 7>
		<cfset days = "last week">
		<cfset msgcnt = msgcnt+1>
	</cfif>
	<cfset by = ''>
	<cfif len(session.rangeFrom) and (session.rangeFrom gt -100 or session.rangeTo lt 100)>
		<cfset by = ' by #session.rangeFrom#% to #session.rangeTo#%'>
		<cfset msgcnt = msgcnt+1>
		<!--- <cfset session.usermsg = "#session.usermsg#Price drop is #session.rangeFrom#% to #session.rangeTo#%. "> --->
	</cfif>
	<cfset session.usermsg = "#session.usermsg#Price dropped since #days##by#. ">
</cfif>

<cfif len(session.prangeFrom) and (session.prangeFrom gt 0 or session.prangeTo lt 25000)>
	<cfset plus = ''>
	<cfif session.prangeTo eq 25000>
		<cfset plus = '+'>
	</cfif>
	<cfset msgcnt = msgcnt+1>
	<cfset session.usermsg = "#session.usermsg#Price range is Rs. #session.prangeFrom#/- to Rs. #session.prangeTo##plus#/-. ">
</cfif>
<cfif isdefined("url.type")>
	<cfif url.type eq 'link'>
		<cftry>
			<cfif obj.isFKlink(url.param)>
				<cfset pid = obj.fkurlparse(url.param)>
				<cfset data =  obj.flipkartPID(pid)>
				<cfset data = DeserializeJSON(data)>
			<cfelseif obj.isAZlink(url.param)>
				<cfset pid = obj.azurlparse(url.param)>
				<cfset azdata = obj.ItemLookup(pid)>
				<cfset azdata = obj.ConvertXmlToStruct(azdata,structnew())>
			<cfelse>
				<cfset invalidlink = 1>
			</cfif>
		<cfcatch>
			<cfset invalidlink = 1>
		</cfcatch>
		</cftry>
		
		
		<cfset movers = obj.getMovers(1)>
		
		<cfif not invalidlink>
			<cfset moversthis = obj.getMovers(page=1,pid=pid)>
			<cfif obj.isFKlink(url.param)>
				<cfset pdetails = obj.fkDetails(data.productBaseInfo.productAttributes)>
			</cfif>
			<cfif obj.isAZlink(url.param)>
				<cfset pdetails = obj.azDetails(azdata.Items.Item)>
			</cfif>
	
			<cfset pdetails.title = REReplace(pdetails.title, "[^0-9a-zA-Z _]", "", "ALL")>
			<cfif  moversthis.recordcount eq 0 or moversthis.last_price neq pdetails.price>
					<cfset obj.addUsersMovers(pdetails)>
					<cftry>
						<cfset obj.recal(pid)>
					<cfcatch></cfcatch>
					</cftry>
					<cfset moversthis = obj.getMovers(page=1,pid=pid)>
			</cfif>
		</cfif>
		<!--- 
		<cfquery name="joinm" dbtype="query">
			select * from moversthis
			union
			select * from movers
		</cfquery>
		
		<cfset movers = joinm> --->
		
		<cfset obj.searchLog(url.param,2)>
	</cfif>
	<cfif url.type eq 'search'>
	
			<cfset page = 1>
			<cfset fkcat = ''>
			<cfset azcat = ''>
			<cfset categories.fk = ''>
			<cfset categories.az = ''>
			
			<cfif isdefined("url.page") and isnumeric(url.page) and url.page gt 1>
				<cfset page = url.page>
			</cfif>
			
			<cfif isdefined("url.fkcategory")>
				<cfset fkcat = url.fkcategory>
			</cfif>
			<cfif isdefined("url.azcategory")>
				<cfset azcat = url.azcategory>
			</cfif>
			
			<cfset session.dropsince = 0>
			<!--- <cfset movers = obj.getFKAZKeyword(url.param,page,url.category)> --->
			<cfset movers = obj.getFKAZKeyword(url.param,page)>
			<cfif movers.recordcount lt 12>
				<cfset nonmovers = obj.getFKAZKeywordNoMoves(keyw = url.param,page=page,LOT = (12-movers.recordcount))>
				<cfset moversBkp = movers>
				<cfquery name="movers" dbtype="query">
					select * from moversBkp
					union
					select * from nonmovers where pid not in (select pid from moversBkp)
				</cfquery>
			</cfif>

			<cfset obj.searchLog(url.param,1)>
			<!--- <cfset allData =  obj.flipkartKeyword(url.param,page,fkcat)>
			<cfif allData.datatype eq "nonjson">
				<cfset data = DeserializeJSON(allData.data)>
				<cfif page eq 1>
					<cfset categories.fk  = obj.getFKCategories(data)>
				</cfif>
			<cfelse>
				<cfset data = allData.data>
				<cfif page eq 1>
					<cfset categories.fk  = ListRemoveDuplicates(allData.data.category)>
				</cfif>
			</cfif>
			<cfset azdata = obj.azKeyword(url.param,page,azcat)>
			<cfset azdata = obj.ConvertXmlToStruct(azdata,structnew())>
			<cfif page eq 1>
				<cfset categories.az  = obj.getAZCategories(azdata)>
			</cfif> --->
	</cfif>
	<cfif url.type eq 'browse'>
		<cfif not isdefined("url.category")>
			<cfset url.category = 'All Drops'>
		</cfif>
		<cfif not isdefined("url.page")>
			<cfset url.page = 1>
		</cfif>
		<!--- <cfset movers = obj.getMovers(url.page,url.category)> --->
		<!--- <cfset movers = obj.trending()> --->
		<cfset movers = obj.getFKAZKeyword(url.category,page)>
	</cfif>
	<cfif url.type eq 'trends'>
			<cfset url.category = 'All Drops'>
		<cfif not isdefined("url.page")>
			<cfset url.page = 1>
		</cfif>
		<!--- <cfset movers = obj.getMovers(url.page,url.category)> --->
		<cfset movers = obj.trending(url.page)>
		<!--- <cfset movers = obj.getFKAZKeyword(url.category,page)> --->
	</cfif>
</cfif>


<html>
<head>
	<cfif client.mobile>
	<meta name="viewport" content="width=device-width, initial-scale = 1.0, maximum-scale=1.0, user-scalable=no" />
	</cfif>
	<meta name="keywords" 			content="Amazon, Flipkart, Amazon Price Tracker, Flipkart Price Tracker, price tracker, India">
	
	<meta name="description" 		content="Best Amazon and Flipkart Price tracker and price management website">
	<cfoutput>
		<meta property="og:title"   	content="FindTrackBuy.com : Best Amazon and Flipkart Price Tracker" />
		<meta property="og:image"       content="http://dev.quirkycrackers.com/fkaz/images/ftb.png" /> 
		<meta property="og:description" content="Best Amazon and Flipkart Price tracker and price management website." /> 
	</cfoutput>
	<title>Get Alerts When Price Drops: Best Price Tracker</title>
	<script language="javascript" src="/fkaz/js/cssua.min.js"></script>
	<script language="javascript" src="/fkaz/js/common.js"></script>
	<script language="javascript" src="/fkaz/js/utils.js"></script>
	<link rel="shortcut icon" href="/fkaz/images/favicon.ico">
	<!--- <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css"> --->
	<link rel="stylesheet" href="/fkaz/js/jquery-ui.theme.min.css">
	<cfoutput><link rel="stylesheet" href="/fkaz/js/#request.files#.css"></cfoutput>
	<!--- <link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css"> --->
	<script language="javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
	<script language="javascript" src="/fkaz/js/jquery-ui.min.js"></script>
	<script language="javascript" src="/fkaz/js/jquery.resizecrop-1.0.3.min.js"></script>
	<!--- <script language="javascript" src="/fkaz/js/masonry.pkgd.min.js"></script> --->
	<script language="javascript" src="/fkaz/js/isotope.pkgd.min.js"></script>
	<script type="text/javascript" src="/fkaz/js/canvasjs-1.7.0/jquery.canvasjs.min.js"></script>
	<cfoutput><script language="javascript" src="/fkaz/js/#request.files#.js"></script></cfoutput>
	<link rel="stylesheet"  href="/fkaz/js/ion.rangeSlider-1.9.3/css/normalize.min.css"></link>
	<link rel="stylesheet"  href="/fkaz/js/ion.rangeSlider-1.9.3/css/ion.rangeSlider.css"></link>
	<link rel="stylesheet"  href="/fkaz/js/ion.rangeSlider-1.9.3/css/ion.rangeSlider.skinFlat.css"></link>
	<script src="/fkaz/js/ion.rangeSlider-1.9.3/js/ion-rangeSlider/ion.rangeSlider.min.js"></script>
	
	<script language="javascript">
		
		function submitform(val,type){
			<cfoutput>
				window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#?type='+type+'&param='+val;
			</cfoutput>
		}
	</script>
	
	<script type="text/javascript" language="javascript">
  
		  $(document).ready(function(){
		    $('.resize').resizecrop({
		      width:175,
		      height:175,
		      vertical:"top"
		    });  
		    psort=true;
		  
			$('#maintable').css("text-align","center");
			$('#maintable').css("position","relative");
			$('#maintable').css("left",$(window).width()*0.1);
			
			<!--- $('.grid').isotope({ sortBy: 'title' }); --->
		   <!---    $('.grid').masonry({
			  // options
			  itemSelector: '.grid-item',
			  columnWidth: 300
			}); --->
		    
			init();
			<cftry>
				<cfoutput>
					<cfif isdefined("session.sort")>
					var sortby = '';
					sortby = '#StructKeyArray(session.sort)[1]#';
					try {
						$(".sortby_"+sortby).empty();
						$(".sortby_"+sortby).append("<img src='/fkaz/images/#session.sort[StructKeyArray(session.sort)[1]]#.png'>");
					}
					catch(e){}
					</cfif>
				</cfoutput>
			<cfcatch>
			</cfcatch>
			</cftry>
			$("#range_1").ionRangeSlider(
				{
				    min: -100,
				    max: 100,
				    <cfif (isdefined('session.rangeFrom') and session.rangeFrom gte -100) and (isdefined('session.rangeTo') and session.rangeTo lte 100)>
						<cfoutput>
							from: #session.rangeFrom#,
				   	 		to: #session.rangeTo#,
						</cfoutput>
					<cfelse>
						from: -100,
				    	to: 100,
					</cfif>
				    type: 'double',
				    step: 1,
				    postfix: " % drop",
				    <!--- maxPostfix : "+", --->
				    //,hasGrid: true,
				    //gridMargin: 15,
				    onLoad: function (obj) {        // callback is called after slider load and update
				       /// console.log(obj);
				    },
				    onChange: function (obj) {      // callback is called on every slider change
				       //console.log(obj);
				    },
				    onFinish: function (obj) {      // callback is called on slider action is finished
				      <!---  console.log(obj); --->
				      meterparams.droprange.from = obj.from;
				      meterparams.droprange.to = obj.to;
				      <cfif client.mobile>
				      	return;
				      </cfif>
				       $.ajax({
							type: 'get',
						    url: '/fkaz/cmp.cfc?method=setRange&from='+obj.from+'&vto='+obj.to,
						   <!---  cache: false, --->
						    beforeSend : function(a){
						    			 },
						    complete : function(results){
						    				location.reload();
						    			}
						});
				       //loadByRange(obj.from,obj.to,'C');
				    }
				}
			);  
			
			$("#range_2").ionRangeSlider(
				{
				    min: 0,
				    max: 25000,
				    <cfif (isdefined('session.prangeFrom') and session.prangeFrom gte 0) and (isdefined('session.prangeTo') and session.prangeTo lte 25000)>
						<cfoutput>
							from: #session.prangeFrom#,
				   	 		to: #session.prangeTo#,
						</cfoutput>
					<cfelse>
						from: 0,
				    	to: 25000,
					</cfif>
				    type: 'double',
				    step: 10,
				    prefix: "Rs. ",
				     maxPostfix : "+",
				    <!--- maxPostfix : "+", --->
				    //,hasGrid: true,
				    //gridMargin: 15,
				    onLoad: function (obj) {        // callback is called after slider load and update
				       /// console.log(obj);
				    },
				    onChange: function (obj) {      // callback is called on every slider change
				       //console.log(obj);
				    },
				    onFinish: function (obj) {      // callback is called on slider action is finished
				      <!---  console.log(obj); --->
				      
				      meterparams.pricerange.from = obj.from;
				      meterparams.pricerange.to = obj.to;
				      <cfif client.mobile>
				      	return;
				      </cfif>
				       $.ajax({
							type: 'get',
						    url: '/fkaz/cmp.cfc?method=setPriceRange&from='+obj.from+'&vto='+obj.to,
						   <!---  cache: false, --->
						    beforeSend : function(a){
						    			 },
						    complete : function(results){
						    				location.reload();
						    			}
						});
				       //loadByRange(obj.from,obj.to,'C');
				    }
				}
			);  
						
			$("#rangecontent").css("left",($(window).width()- $("#rangecontent").width())/2);
			//setInterval(function(){$(".footerpopup").slideDown( "slow")}(),5000);
			<cfif not client.mobile>
				$("#rangecontent").css("left",($(".content").width()- $("#rangecontent").width())/2);
			</cfif>
			
			setTimeout(function () {
					$(".footerpopup").slideDown( "slow");
                    //showLoginPopup();
            }, 2000);
            
            
			$(".sideadgoog").css("top",($(".sidead").height()-$(".sideadgoog").height())/2);
		    
		  }); 
		  
		 function login(){
		  	FB.login(function(response) {
		  		//console.log(response);
			   if (response.authResponse) {
			     FB.api('/me', function(response) {
			     	//console.log("Inner response");
			     	//console.log(response);
			     	register(response);
			     });
			   } else {
			     //console.log('User cancelled login or did not fully authorize.');
			   }
			 },{scope: 'email',return_scopes: true});
		  }
		  
		function showLoginPopup(){
			
			 $.ajax({
						type: 'get',
					    url: '/fkaz/showLoginPopup.cfm',
					   <!---  cache: false, --->
					    beforeSend : function(a){
					    			 },
					    complete : function(results){
					    				//location.reload();
					    			},
					    success : function(results){
					    	
					    	$( "#loginPopup" ).empty();
				    		$( "#loginPopup" ).append(results);
				    		$( "#loginPopup" ).dialog({ 
								autoOpen: false,
								modal:true,
									      buttons: {
								        Close: function() {
								          	$( this ).dialog( "close" );
								          	closeFooter();
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
				    		$( "#loginPopup" ).dialog( "open" );
					    
					    }
					});
		
		}

		
		function ValidUrl(str) {
		  var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
		  '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
		  '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
		  '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
		  '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
		  '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
		  if(!pattern.test(str)) {
		    return false;
		  } else {
		    return true;
		  }
		}
		
		function dropSince(days){
			
			$.ajax({
				type: 'get',
			    url: '/fkaz/cmp.cfc?method=setSince&days='+days,
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    				location.reload();
			    			}
			});
			
		}
		
		function fluctuate(){
			$.ajax({
				type: 'get',
			    url: '/fkaz/cmp.cfc?method=setfluctuate',
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    				location.reload();
			    			}
			});
		}
		
		function reset(){
			$.ajax({
				type: 'get',
			    url: '/fkaz/cmp.cfc?method=setReset',
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    				location.reload();
			    			}
			});
		}
		
		function isUrl(s) {
			var regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
			return regexp.test(s);
			}
		
		function go(){
			if(isUrl(document.getElementById('search').value)){
				submitform((function(){return document.getElementById('search').value})(),'link');
			}
			else{
				submitform((function(){return document.getElementById('search').value})(),'search');
			}
			
		}
		
		function saveme(rs){
			
			$.ajax({
				type: 'get',
			    url: '/fkaz/cmp.cfc?method=setSaveme&rs='+rs,
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    				location.reload();
			    			}
			});
		}
		
		function sortby(what,order){
			
			$.ajax({
				type: 'get',
			    url: '/fkaz/cmp.cfc?method=setSortby&what='+what+'&order='+order,
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    				location.reload();
			    			}
			});
		}
		
		function closeFooter(){
			$.ajax({
				type: 'get',
			    url: '/fkaz/cmp.cfc?method=setSessionVar&what=showsub&value=0',
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    			 },
			    complete : function(results){
			    				//location.reload();
			    			}
			});
			$(".footerpopup").slideUp( "slow");
		}
		
		function gosubscribe(){
		var email = $("#email").val();
		if(isValidEmailAddress(email)){
			$.ajax({
				type: 'GET',
			    url: '/fkaz/cmp.cfc?method=subscribe&email='+email,
			   <!---  cache: false, --->
			    beforeSend : function(a){
			    				$(".alertmsg").empty();
			    			 },
			    complete : function(results){
			    				$(".alertmsg").append("Thanks!");
			    				$(".footerpopup").slideUp( 3000);
			    			}
			});
		}
		else{
			$(".alertmsg").empty();
			$(".alertmsg").append("Email doesn't look ok!");
		}
		
	}
	
	function login(){
		  	FB.login(function(response) {
		  		//console.log(response);
			   if (response.authResponse) {
			     FB.api('/me', function(response) {
			     	//console.log("Inner response");
			     	//console.log(response);
			     	register(response);
			     });
			   } else {
			     //console.log('User cancelled login or did not fully authorize.');
			   }
			 },{scope: 'email',return_scopes: true});
		  }
	
	function register(fbRes){
	
	var email = '';
	var password = '';
	var isEmailOk = '';
	var isPasswordOk = '' ;
	var fb_id = '' ;
	var fb_resObj = '' ;
	
	if(typeof fbRes == 'object'){
		fb_resObj = JSON.stringify(fbRes);
		fb_id = fbRes.id;
	}
	
	<!--- $.ajax({
		    type: 'POST',
		    url: '/fkaz/cmp.cfc?method=registerfb',
		    data: { 
		        'email': '', 
		        'password': 'fbpass',
		        'fb_id':fb_id,
		        'fb_resObj':fb_resObj,
		        'source':'FTB'
		    },
		    success: function(res){
		    	res = $.parseJSON(res);
		    	if(res.LOGUSER == true){
		    		window.location="/fkaz/";
		    	}
		    }
		}); --->
	 }
	 
	 function doLogin(){
			<cfoutput>
				window.location.href = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/fkaz/login/?email='+email;
			</cfoutput>
		}

		function trackit(pid){
				email = $("#quickemail_"+pid).val();
				dropto = $("#pricedrop_"+pid).val();
				if(isValidEmailAddress(email)){
				 $.ajax({
					type: 'GET',
					    url: '/fkaz/cmp.cfc?method=adduser&email='+email+'&dropto='+dropto+'&pid='+pid,
				    beforeSend : function(a){
				    				$("#emailalert_"+pid).empty();
				    				$("#trackitbutton_"+pid).empty()
				    				$("#trackitbutton_"+pid).append("Tracking...");
				    			 },
				    complete : function(results){
								},
					success : function(results){
								var ret = results;	
								if(ret.ERROR == 1){
									$("#emailalert_"+pid).empty();
									$("#emailalert_"+pid).append("We apologies! Please try again! :(");
									$("#trackitbutton_"+pid).empty()
				    				$("#trackitbutton_"+pid).append("Quick track!");
									return;
								}
								
								$("#user_sk").val(ret.USER_SK);
								$("input[name='email']").val(email);
								if(ret.ISACCOUNTSETUP == 0){
									$("#quicktrackbox_"+pid).hide();
									$("#passwordbox_"+pid).show();
								}
								else{
									$("#quicktrackbox_"+pid).empty();
									$("#quicktrackbox_"+pid).css({
										"border":"0px sold rgba(255,255,255,0)",
										"text-align":"center",
										"font-size":"medium"
									});
									
									$.ajax({
										type: 'POST',
									    url: '/fkaz/cmp.cfc?method=setClientvar&what=email&value='+email,
									   <!---  cache: false, --->
									    beforeSend : function(a){
									    				//$("#update"+id).text("Updating...");
									    			 },
									    complete : function(results){
									    				//$("#update"+id).text("Update");
									    			}
									});
			
									<cfif isdefined("client.user_sk")>
										$("#quicktrackbox_"+pid).append("Tracking successful!");
									<cfelse>
										$("#quicktrackbox_"+pid).append("Tracking successful! <br>You are already with us. Why not <span style='cursor: pointer; cursor: hand;' onclick='doLogin();'>Login</span> and checkout your dashboard.");
									</cfif>
									
								}
							  },
					error : function(){
						$("#emailalert_"+pid).empty();
						$("#emailalert_"+pid).append("We apologies! Please try again! :(");
					}
				});
			}
			else{
				$("#emailalert_"+pid).empty();
				$("#emailalert_"+pid).append("Email doesn't look good!");
			}
		}
		
	</script>
	
	<!--- <style>
		.thatsall {
			display:none;
		}
		.ui-dialog .ui-dialog-buttonpane .ui-dialog-buttonset {
		   float: none;
		}
		
		.ui-dialog .ui-dialog-buttonpane {
		     text-align: center; /* left/center/right */
		}
	</style> --->
</head>
<body>
	<!--- <cfset trending = obj.trending()> --->
	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
	
	  <cfoutput>ga('create', '#application.goog#', 'auto');</cfoutput>
	  ga('require', 'displayfeatures');
	  ga('send', 'pageview');
	
	</script>
	<cfinclude template="header.cfm">
	<input name="user_sk" id="user_sk" type="hidden">
	<div class="inputFields">
		<div class="inputSet" style="overflow: auto;white-space: nowrap;">
			<span><input type="text" name="search" id="search" placeholder=" Search Product or Paste any Amazon/Flipkart Link..." size="80" onkeydown="if (event.keyCode == 13) { go(); }"></span>
		    <span><button type="submit" onclick="go();">Go!</i></button></span>
		    <!--- submitform((function(){return document.getElementById('search').value})(),'search') --->
			<!--- <input type="button" onclick="submitform((function(){return document.getElementById('search').value})(),'search')" value="Find Products"> --->
		</div>
		<!--- <div style="height:20px"></div>
		<div class="inputSet" style="overflow: auto;white-space: nowrap;">
			<input type="text" name="search" id="searchlink" placeholder=" OR Paste any Amazon or Flipkart Link..." size="80" onkeydown="if (event.keyCode == 13) { submitform((function(){return document.getElementById('searchlink').value})(),'link'); }">
			<button type="submit" onclick="submitform((function(){return document.getElementById('searchlink').value})(),'link')">Go!</i></button>
			<!--- <input type="button" onclick="submitform((function(){return document.getElementById('searchlink').value})(),'link')" value="Find by Link"> --->
		</div> --->
	</div>
	<div style="height:10px"></div>
	<cfif url.type eq 'search' and isdefined("url.param")>
		<cfoutput><div style="color:green;font-size:large;text-align:center;font-family:'Verdana', Verdana, sans-serif;">
			Search Result: #url.param#
			<span style="cursor: pointer; cursor: hand;" onclick="window.location = 'http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#application.cgi_SCRIPT_NAME#';"> X </span></div>
			</cfoutput>
	</cfif>
	<cfset bcategories = obj.getCategories()>
	
	<cfif (url.type eq 'link')>
			<cfif invalidlink>
				<div class="title sanss" style="color:red;text-align:center">You seemed to entered invalid link. As of now, we support links from Amazon & Flipkart<br>
				If you think, you entered valid Flipkart/Amazon Product Link, we apologise. We'll check the issue and correct it ASAP.
				</div>
			<cfelse>
					<cftry>
						<cfoutput>
							<div id="#pdetails.pid#" class="fkProduct wrapper" style="height:325;text-align:center;border-bottom:1px solid gray;border-top:15px solid white">
								<div class="title sanss" style="color:red">The link you searched returned this product</div>
								<div class="title sanss" title="#pdetails.title#">#left(pdetails.title,28)#..</div>
								<div><a href="#pdetails.link#" target="_blank"><img src="#pdetails.image#" class="resize"></a></div>
								<div style="height: 30px;vertical-align: middle;display: inline-block;" >
									<cfif moversthis.recordcount>
										<cfset idx = 1>
										<cfif moversthis.type[idx] eq 0>
											<cfset wrapClass = "fkProduct">
											<cfset logo = "/fkaz/images/fklogo.jpg">
										<cfelse>
											<cfset wrapClass = "azProduct">
											<cfset logo = "/fkaz/images/azlogo.jpg">
										</cfif>
										<cfset color = 'Black'>
										<cfif movers.variance[idx] lt 0>
											<cfset color = 'Red'>
										<cfelseif movers.variance[idx] eq 0>
											<cfset color = 'Black'>
										<cfelseif movers.variance[idx] gt 0>
											<cfset color = 'Green'>
										</cfif>
										<span class="sanss" style="display: inline-block;vertical-align: middle;color:#color#">
											#moversthis.variance[idx]#%
										</span>
										<span class="sanss" style="display: inline-block;vertical-align: middle;">
											<cfif moversthis.variance lt 0>
												<img src="/fkaz/images/down.png">
											<cfelseif moversthis.variance[idx] eq 0>
											<cfelseif moversthis.variance[idx] gt 0>
												<img src="/fkaz/images/up.png">
											</cfif>
										</span>
										<span class="sanss" style="display: inline-block;vertical-align: middle;">Rs. #numberformat(moversthis.last_price[idx])#</span>
										<span style="display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></span>
								<cfelse>
									<span class="sanss" style="display: inline-block;vertical-align: middle;">Rs. #numberformat(pdetails.price)#</span>
								</cfif>
								</div>
								<div>
									<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;cursor: pointer; cursor: hand;" onclick="getchart('#pdetails.pid#','#pdetails.title#','#pdetails.image#')">Track It</span>
									<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;"><a href="#pdetails.link#" target="_blank" style="text-decoration:none;color:black;">Check Out</a></span>
								</div>
							</div>
						</cfoutput>
					<cfcatch>
						<!--- <cfdump var="#data.productInfoList[idx].productBaseInfo.productAttributes.imageUrls#"> --->
					</cfcatch>
					</cftry>
			</cfif>
			<!--- <cfset url.type = 'browse'> --->
			<cfset url.type = 'trends'>
		</cfif>
	
	<cfinclude template="#request.files#_meter.cfm">	
	<cfset wrapArray = arraynew(1)>

	<!--- <cfif isdefined("url.type")>
		<cfif (url.type eq 'search')>
			<div class="grid" id="mainGrid">
			<cfloop from="1" to="#movers.recordcount#" index="idx">
				<cfif movers.type[idx] eq 0>
					<cfset wrapClass = "fkProduct">
					<cfset logo = "/fkaz/images/fklogo.jpg">
				<cfelse>
					<cfset wrapClass = "azProduct">
					<cfset logo = "/fkaz/images/azlogo.jpg">
				</cfif>
				
				<cfoutput>
					<div id="#movers.pid[idx]#" class="grid-item #wrapClass#" data-category="#wrapClass#" style="height:285;text-align:center;border-bottom:1px solid gray;border-top:15px solid white">
						<div class="title sanss" title="#movers.title[idx]#">#left(movers.title[idx],28)#..</div>
						<div style="font-size:x-small;color:gray;">Product ID: #movers.pid[idx]#</div>
						<div><a href="#movers.link[idx]#" target="_blank"><img src="#movers.image[idx]#" class="resize"></a></div>
						<div style="height:2px"></div>
						<div style="height: 30px;vertical-align: middle;display: inline-block;" >
							<cfset color = 'Black'>
							<cfif movers.variance[idx] lt 0>
								<cfset color = 'Red'>
							<cfelseif movers.variance[idx] eq 0>
								<cfset color = 'Black'>
							<cfelseif movers.variance[idx] gt 0>
								<cfset color = 'Green'>
							</cfif>
							<cfif len(movers.variance[idx])>
								<span class="sanss" style="display: inline-block;vertical-align: middle;color:#color#">
									#movers.variance[idx]#%
								</span>
								<span class="sanss" style="display: inline-block;vertical-align: middle;">
									<cfif movers.variance[idx] lt 0>
										<img src="/fkaz/images/down.png">
									<cfelseif movers.variance[idx] eq 0>
									<cfelseif movers.variance[idx] gt 0>
										<img src="/fkaz/images/up.png">
									</cfif>
								</span>
							</cfif>
							<span class="sanss" style="display: inline-block;vertical-align: middle;">Rs. <!--- <span class="price sanss" style="display:none;vertical-align: middle;">#movers.last_price[idx]#</span> --->#numberformat(movers.last_price[idx])#</span>
							<span style="display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></span>
						</div>
						
						<div>
							<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;cursor: pointer; cursor: hand;" onclick="getchart('#movers.pid[idx]#')">Track It</span>
							<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;"><a target="_blank" href="#movers.link[idx]#" style="text-decoration:none;color:black;">Check Out</a></span>
						</div>
					</div>
				</cfoutput>
			</cfloop>
			</div>
			<cfif movers.recordcount lt 12>
				<div style="color:gray;font-weight:bold;text-align:center;border-top:20px solid white">
				<script type="text/javascript">
					$.ajax({
							type: 'GET',
						    <cfoutput>
							    url: '/fkaz/livedata.cfm?keyword=#url.param#',
							</cfoutput>
						   <!---  cache: false, --->
						    beforeSend : function(a){
						    			 },
						    complete : function(results){
						    		$(".thatsall").show();
						    	},
						    success : function(results){
						    		$("#mainGridLive").empty();
						    		$("#mainGridLive").append(results);
						    	}
							});
							
				</script>
				</div>
				
				<div class="gridlive" id="mainGridLive" style="color:gray;font-weight:bold;text-align:center;">
					<div>Trying to find more products directly from Amazon/Flipkart</div>
					<img alt="" width="160" height="120" src="/fkaz/images/loader_gif.gif"/>
				</div>
			<cfelse>
				<script type="text/javascript">
					 $(document).ready(function(){
					 	$(".thatsall").show();
					 });
				</script>
			</cfif>
		
		</cfif>
		
	</cfif> --->
		
		
<div id="dialog" class="dialogcss" title="Price History"></div>
<div id="loginPopup" class="dialogcss" title="Login"></div>

<cfif url.type eq 'browse' or url.type eq 'trends' or url.type eq 'search'>
	
	<div class="grid" id="mainGrid">
	<cfloop from="1" to="#movers.recordcount#" index="idx">
		<cfif movers.type[idx] eq 0>
			<cfset wrapClass = "fkProduct">
			<cfset logo = "/fkaz/images/fklogo.jpg">
		<cfelse>
			<cfset wrapClass = "azProduct">
			<cfset logo = "/fkaz/images/azlogo.jpg">
		</cfif>
		<cfoutput>
		<cfif client.mobile><cfif idx eq 5>

				<div class="grid-item wrapper">
<cfif client.mobile>
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- QC_MO_SLIDE -->
<ins class="adsbygoogle"
     style="display:inline-block;width:300px;height:200px"
     data-ad-client="ca-pub-9042848322034372"
     data-ad-slot="7811368043"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
<cfelse>
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- FTB_PROD -->
<ins class="adsbygoogle"
     style="display:inline-block;width:336px;height:280px"
     data-ad-client="ca-pub-9042848322034372"
     data-ad-slot="8399209643"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
</cfif>
				
				</div>
			</cfif> </cfif>
			<div id="#movers.pid[idx]#" <cfif not client.mobile>onmouseenter="$('###movers.pid[idx]#_options').slideDown(75);" onmouseleave="$('###movers.pid[idx]#_options').slideUp(75);"</cfif> class="grid-item #wrapClass# wrapper" data-category="#wrapClass#" style="height:285;text-align:center;border-bottom:1px solid gray;border-top:15px solid white">
				<cfset movers.title[idx] = REReplace(movers.title[idx], "[^0-9a-zA-Z _]", "", "ALL")>
				<!--- <cfif len(session.saveme) and session.saveme neq 0 and not client.mobile>
					<div id="#movers.pid[idx]#_options" class="savestamp" style="position:absolute;top:0;left:0;z-index:2;display:none;">
						<a href="#movers.link[idx]#" target="_blank">
							<img src="/fkaz/images/save.png">
							<div style="position:absolute;top:65;z-index:2;font-weight:bold;width:100%;"><div style="text-align:center;width:100%;font-size:large;" ><cfoutput>&##8377; #abs(movers.difference[idx])#</cfoutput></div></div>
						</a>
					</div>
				</cfif> --->
				<cfset op_top = 30>
				<cfif client.mobile>
					<cfset op_top = 60>
				</cfif>
				<div id="#movers.pid[idx]#_options" class="options" style="position:absolute;top:0;left:0;z-index:2;display:none;background-color:rgba(0,0,0,0.7);">
						<div style="position:absolute;left:2;top:28;display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></div>
						<cfif client.mobile>
							<div onclick="$('###movers.pid[idx]#_options').slideToggle(75);" style="position:absolute;right:5;top:28;display: inline-block;vertical-align: middle;color:white;font-size:large">X</div>
						</cfif>
						<div style="height:#op_top#px;"></div>
						<div style="border:0px solid black;color:white" class="quicktrackbox" id="quicktrackbox_#movers.pid[idx]#">
							<cfif not isdefined("client.email")>
								<span class="textsize" style="border:0px solid black;" <!--- onblur="$('.emailalert').hide();" --->> <input name="email" id="quickemail_#movers.pid[idx]#" size="30" placeholder="Send me@mymail.com Alert" class="hist_input" <!--- style="font-size:small;width:250" --->></span>
							<cfelse>
								<span class="textsize" style="border:0px solid black;" <!--- onblur="$('.emailalert').hide();" --->> <input name="email" id="quickemail_#movers.pid[idx]#" size="30" placeholder="Send me@mymail.com Alert" value="#client.email#" class="hist_input" <!--- style="font-size:small;width:250" --->></span>
							</cfif>
							
							<span>
							<select name="pricedrop" id="pricedrop_#movers.pid[idx]#" class="hist_input" <!--- style="font-size:small;width:250" --->>
								<option value="1" style="font-size:small">When price drops to Less then 5%</option>
								<option value="2" style="font-size:small">When price drops to 5% to 10%</option>
								<option value="3" style="font-size:small">When price drops to 10% to 20%</option>
								<option value="4" style="font-size:small">When price drops to 20% to 50%</option>
								<option value="5" style="font-size:small">When price drops to 50+%</option>
							</select>
							</span>
							<span>
								<!--- <br>
							<button value="Track it!" onclick="trackit('#movers.pid[idx]#')" type="submit" id="trackitbutton">Quick Track!</button></span> --->
							<div style="height:5px;"></div>
							<div id="trackitbutton_#movers.pid[idx]#" onclick="trackit('#movers.pid[idx]#')" class="hist_button hist_button_small" <!--- style="position:absolute;width:250;height:20px;line-height: 20px;background-color:rgb(131, 220, 14);border-radius: 5px;color:white;" --->>
								Quick Track
								
							</div>

							
						</div>
						
						<div id="passwordbox_#movers.pid[idx]#" class="passwordbox" style="display:none;font-size:small;color:white;">
							<div style="border:50x solid rgba(0,0,0,0);color:white;">
								Your alert is setup! Setup a password & manage alerts. See a dashboard with all products that you are tracking.
							</div>
							<div style="border:5px solid rgba(0,0,0,0);text-align:center;">
							<input name="password" id="password_#movers.pid[idx]#" type="password" size="30" placeholder="Please enter password" style="font-size:small"> 
							<button value="Track it!" onclick="QuicksetupAccount('#movers.pid[idx]#');" type="submit">Setup Account</button>
							<span class="textsize" style="width:100px;color:red;" id="passwordalert"></span> 
							</div>
						</div>

						<div class="hist_gap" <!--- style="height:55px;" --->></div>
<div style="border:0px solid black;background-color:black;">
									<span class="textsize" style="width:100px;color:red;" id="emailalert_#movers.pid[idx]#" class="emailalert"></span> 
								</div>
						<div class="hist_gap "<!--- style="height:70px;" --->></div>
						<div class="hist_button hist_button_big" onclick="getchart('#movers.pid[idx]#')" <!--- style="position:absolute;width:250;height:50px;line-height: 50px;background-color:rgb(131, 220, 14);border-radius: 10px;color:white;font-size:large;" --->>
						Price History
						</div>
						<div class="hist_gap "<!--- style="height:70px;" --->></div>
						<div class="hist_gap "<!--- style="height:70px;" --->></div>
						<a target="_blank" href="#movers.link[idx]#" style="text-decoration:none;color:white;">
						<div class="hist_button hist_button_big" <!--- style="position:absolute;width:250;height:50px;line-height: 50px;background-color:rgb(131, 220, 14);border-radius: 10px;color:white;font-size:large;" --->>
						Buy / Details
						</div>
						</a>
						<!--- <div style="position:absolute;top:65;z-index:2;font-weight:bold;width:100%;">
							<div style="text-align:center;width:100%;font-size:large;" >
							</div>
						</div> --->
				</div>
				<div>
					<div class="title sanss" style="z-index:20;position:relative;background-color:white;" title="#movers.title[idx]#">#left(movers.title[idx],28)#..</div>
					<div style="font-size:x-small;color:gray;z-index:20;position:relative;background-color:white;">Product ID: #movers.pid[idx]#</div>
				</div>
				<div style="height:2px"></div>
				<div><a href="#movers.link[idx]#" target="_blank"><img src="#movers.image[idx]#" class="resize"></a></div>
				<div style="height:2px"></div>
				<div style="height: 30px;vertical-align: middle;display: inline-block;" >
					<cfset color = 'Black'>
					<cfif not len(movers.variance[idx])>
						<cfset movers.variance[idx] = 0>
					</cfif>
					<cfif movers.variance[idx] lt 0>
						<cfset color = 'Red'>
					<cfelseif movers.variance[idx] eq 0>
						<cfset color = 'Black'>
					<cfelseif movers.variance[idx] gt 0>
						<cfset color = 'Green'>
					</cfif>
					<span class="sanss" style="display: inline-block;vertical-align: middle;color:#color#;font-size:large;">
						#movers.variance[idx]#%
					</span>
					<span class="sanss" style="display: inline-block;vertical-align: middle;">
						<cfif movers.variance[idx] lt 0>
							<img src="/fkaz/images/down.png">
						<cfelseif movers.variance[idx] eq 0>
						<cfelseif movers.variance[idx] gt 0>
							<img src="/fkaz/images/up.png">
						</cfif>
					</span>
					<span class="sanss" style="display: inline-block;vertical-align: middle;">Rs. <!--- <span class="price sanss" style="display:none;vertical-align: middle;">#movers.last_price[idx]#</span> --->#numberformat(movers.last_price[idx])#</span>
					<cfif client.mobile>
						<span class="sanss" style="border:0px solid black;display: inline-block;vertical-align: middle;color:red" onclick="$('.options').hide();$('###movers.pid[idx]#_options').slideToggle(75);"><img alt="" width="25" height="25" src="/fkaz/images/ftb-small.png"/>Track</span>
					</cfif>
					<!--- <span style="display: inline-block;vertical-align: middle;"><img src="#logo#" width="25" height="25"></span> --->
				</div>
				
				<!--- <div>
					<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;cursor: pointer; cursor: hand;" onclick="getchart('#movers.pid[idx]#')">Track It</span>
					<span class="sanss" style="border-left:5px solid white;border-right:5px solid white;"><a target="_blank" href="#movers.link[idx]#" style="text-decoration:none;color:black;">Check Out</a></span>
				</div> --->
				
			</div>
		</cfoutput>
	</cfloop>
	</div>
	<cfif movers.recordcount lt 12 and url.type eq 'search'>
		<div style="color:gray;font-weight:bold;text-align:center;border-top:20px solid white">
		<script type="text/javascript">
			$.ajax({
					type: 'GET',
				    <cfoutput>
					    url: '/fkaz/livedata.cfm?keyword=#url.param#',
					</cfoutput>
				   <!---  cache: false, --->
				    beforeSend : function(a){
				    			 },
				    complete : function(results){
				    		$(".thatsall").show();
				    	},
				    success : function(results){
				    		$("#mainGridLive").empty();
				    		$("#mainGridLive").append(results);
				    	}
					});
					
		</script>
		</div>
		
		<div class="gridlive" id="mainGridLive" style="color:gray;font-weight:bold;text-align:center;">
			<div>Trying to find more products directly from Amazon/Flipkart</div>
			<img alt="" width="160" height="120" src="/fkaz/images/loader_gif.gif"/>
		</div>
	<cfelse>
		<script type="text/javascript">
			 $(document).ready(function(){
			 	$(".thatsall").show();
			 });
		</script>
	</cfif>
</cfif>
	
<cfset prev=0>
<cfset next=0>
<cfif isdefined("url.page") and isnumeric(url.page) and url.page gt 0>
	<cfset prev = url.page-1>
	<cfset next = url.page+1>
<cfelse>
	<cfset url.page = 1>
	<cfset prev = url.page-1>
	<cfset next = url.page+1>
</cfif>
<cfset catparam = ''>
<cfparam name="url.fkcategory" default="">
<cfparam name="url.azcategory" default="">
<cfparam name="url.category" default="">
<cfif not len(url.fkcategory)>
	<cfset url.fkcategory = listappend(url.fkcategory,categories.fk)>
	<cfset url.fkcategory = ListRemoveDuplicates(url.fkcategory)>
</cfif>
<cfif not len(url.azcategory)>
	<cfset url.azcategory = listappend(url.azcategory,categories.az)>
	<cfset url.azcategory = ListRemoveDuplicates(url.azcategory)>
</cfif>
<cfif not len(url.category)>
	<cfset url.category = ''>
</cfif>
<cfset catparam = '&fkcategory=#url.fkcategory#&azcategory=#url.azcategory#&category=#url.category#'>

<cfif movers.recordcount lt 12>
	<div class="thatsall" style="font-size:large;color:gray;text-align:center;border-top:10px solid white;display:block">
	That's All Folks
	</div>
	<div class="thatsall" style="color:gray;text-align:center;display:block">
	Our system is on path of self growth. You'll be finding more products in future. Though you have your last weapon. If you know what you are looking for on Amazon/Flipkart, just copy-paste the product link in search box and that's it!
	</div>
<cfelse>
	<cfoutput>
	<table width="100%" align="center">
	<tr>
		<td width="45%" align="right">
			<cfif prev gt 0>
				<cfif prev eq 1>
					<a href="/fkaz/?type=#url.type#&param=#url.param#">
				<cfelse>
					<a href="/fkaz/?type=#url.type#&param=#url.param#&page=#prev##catparam#">
				</cfif>
				PREVIOUS</a>
			<cfelse>
				PREVIOUS
			</cfif>
		</td>
		<td width="10%"></td>
		<td width="45%" align="left"><a href="/fkaz/?type=#url.type#&param=#url.param#&page=#next##catparam#">NEXT</a></td></tr>
	</table>
	</cfoutput>
</cfif>

<div style="height:20px"></div>
<div style="width:100%;text-align:center;">
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- FTB_ADAP -->
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-9042848322034372"
     data-ad-slot="2771478442"
     data-ad-format="auto"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
</div>
<cfif session.showsub>
	<div class="footerpopup">
		<div class="xclose" onclick="closeFooter()">X</div>
		<div class="poptitle">START TRACKING. START SAVING</div>
		<div class="popemail"><input style="width:70%;text-align:center;" type="text" name="email" id="email" placeholder="myemail@something.com" size="80" onkeydown="if (event.keyCode == 13) { gosubscribe(); }"><button type="submit" onclick="gosubscribe();">Go!</i></button></div>
		<div class=" popsmall alertmsg" style="color:red;text-decoration:underline;"></div>
		<div class="popsmall"><span style="color:red">NO SPAM Guarantee</span> | Once in a week Price Drop update | Dashoard Availability | Please check your SPAM folder after entering email</div>
	</div>
</cfif>
<div class="footer">
	Copyrights 2015. A <a href="http://www.QuirkyCrackers.com" target="_blank">QuirkyCrackers.com</a> Productions
</div>
<div style="width:100%;height:25%;">
</div>
<cfif not client.mobile>
</div> <!--- content class end --->
	<div class="sidead">
		<div class="sideadgoog">
			<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
			<!-- FTB_SIDE_large -->
			<ins class="adsbygoogle"
			     style="display:inline-block;width:300px;height:600px"
			     data-ad-client="ca-pub-9042848322034372"
			     data-ad-slot="2568695244"></ins>
			<script>
			(adsbygoogle = window.adsbygoogle || []).push({});
			</script>
		</div>
	</div>
</cfif>
</body>
</html>