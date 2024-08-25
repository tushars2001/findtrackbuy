<div id="fb-root"></div>
	<script>(function(d, s, id) {
	  var js, fjs = d.getElementsByTagName(s)[0];
	  if (d.getElementById(id)) return;
	  js = d.createElement(s); js.id = id;
	  js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.4&appId=438255596343870";
	  fjs.parentNode.insertBefore(js, fjs);
	}(document, 'script', 'facebook-jssdk'));</script>
	<script>
		 user_sk = '';
		<cfif isdefined("client.user_sk")>
			<cfoutput>
				user_sk = '#client.user_sk#';
			</cfoutput>
		</cfif>
	</script>
	
	<div class="mainMenu">
		<!--- <span class="menuItem">
			About
		</span> --->
		<div style="height:5px"></div>
		<div class="menuContainer">
		<span class="menuItem" id="clickme">
			<a href="/fkaz/how_it_works/" onclick="" style="text-decoration:none;color:white">How It Works</a>
		</span>
		<span class="menuItem menuItemSmall"  id="reportissueitem">
			<a href="/fkaz/faq/" onclick="" style="text-decoration:none;color:white">FAQ</a>
		</span>
		<span class="menuItem menuItemSmall"  id="helpusgrowitem">
			Help us Grow!
		</span>
		
		<cfif not client.mobile>
			<span class="menuItem menuItemSmall"  id="mobilesite" style="display:none">
				<a href="/fkaz/mobile/?m=1&force=1" style="text-decoration:none;color:white">Mobile Site</a>
			</span>
			</cfif>
		</div>
		<div style="height:15px"></div>
		<div class="loginCSS">
		<cfif isdefined("client.user_sk")>
				<span  class="menuItem"  onclick="window.location.href='/fkaz/dashboard/';" >
					Dashboard
				</span>
				<span  class="menuItem"  onclick="window.location.href='/fkaz/logout/';">
					Logout
				</span>
		<cfelse>
			<span  class="menuItem desktop1" onclick="window.location.href='/fkaz/login/';" >
				Login/Register
			</span>
		</cfif>
		<cfif client.mobile>
				<span id="mobilesite"  class="menuItem desktop1" >
						<a href="/fkaz/mobile/?m=0&force=1" style="text-decoration:none;color:white;font-size:x-small;">Desktop Site</a>
				</span>
			</cfif>
		
		</div>
		
	</div>
	<!--- <div id="howitworks" class="menudItemetails" >
		<div class="gap"></div>
		<div style="font-size:large;color:gray">Find.</div>
		<div class="itemlist">Browse products</div>
		<div class="itemlist">Search Products by Keywords</div>
		<div class="itemlist">If you didn't find what you are looking for yet, just copy-paste product link from Amazon/Flipkart</div>
		<div style="font-size:large;color:gray">Track.</div>
		<div class="itemlist">Click on Track Link and enter your email/phone</div>
		<div class="itemlist">Enter your expected price of purchase.</div>
		<div class="itemlist">We will track your product and notify you about price drops.</div>
		<div class="itemlist">In the meantime, you can always come back and check how your products are doing. Check products price history</div>
		<div style="font-size:large;color:gray">Buy.</div>
		<div class="itemlist">Once the price drops, we notify you about it and you buy it!</div>
		<div class="gap"></div>
	</div> --->
	<!--- <div id="reportissue" class="menudItemetails">
		<div class="gap"></div>
		<div class="itemlist">We are new. We are human. We do mistakes!</div>
		<div class="itemlist">Please report if you come up with any issue.</div>
		<div class="itemlist">Please let us know what issue you face, please quote product id if you see any product related issues.</div>
		<div class="itemlist"><textarea name="issue" cols="100" rows="5" id="issue" placeholder="Please provide issue description. Like: Product B0012879 has a major price mismatch.."></textarea></div>
		<div class="itemlist"><button type="submit" onclick="sendIssue(user_sk);">Send</button></div>
		<div class="itemlist" id="issuealert" style="color:red"></div>
		<div class="itemlist">*We use data provided by Flipkart and Amazon.</div>
		<div class="gap"></div>
	</div> --->
	<div id="helpusgrow" class="menudetails" >
		<div class="gap"></div>
			<div class="fb-share-button" data-href="http://www.findtrackbuy.com" data-layout="button"></div>
			<div class="fb-like" data-href="https://www.facebook.com/FindTrackBuy" data-layout="button" data-action="like" data-show-faces="false" data-share="false"></div> 
			
		<div class="gap"></div>
	</div>
	<cfif not client.mobile>
		<div class="content" style="width:80%;">
	</cfif>
	
	<div class="mainHead">
	<div><a href="https://www.amazon.in/gp/windowshop/ua_redirect.html/?ie=UTF8&android=%2Fgp%2Faw%2Fgb&bb=%2Fgp%2Faw%2Fgb&camp=3626&creative=24790&default=%2Fb%2F%3Fie%3DUTF8%26node%3D3419926031&iphone=%2Fgp%2Faw%2Fgb&linkCode=ur2&tag=t00fd-21&wp=%2Fgp%2Faw%2Fgb"><img src="azbbd.jpg"></a></div>
	<a href="/fkaz/" style="text-decoration: none;color:gray">Find.Track.Buy.</a><span style="font-size:xx-small">Beta</span></div>
	<div class="gap"></div>
