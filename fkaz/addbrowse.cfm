<cfif isdefined("form.pids") and len(form.pids)>
	<cfdump var="#listlen(form.pids)#">
	<cfif len(listFirst(form.pids)) eq 10>
		<cfset type = 1>
	<cfelse>
		<cfset type = 0>
	</cfif>
	<cfset ins = 0>
	<cfloop list="#form.pids#" index="pid">
		<cftry>
			<cfquery name="addindb" datasource="#application.dsn#">
				INSERT INTO `ftb_browse_pid`(`pid`, `type`) 
				VALUES ('#pid#',#type#)
			</cfquery>
			<cfset ins = ins+1>
		<cfcatch></cfcatch></cftry>
	</cfloop>
	
	
	<cfquery name="addindb" datasource="#application.dsn#">
			SELECT bp.pid FROM `ftb_browse_pid` bp, ftb_trackers_pid tp where bp.pid = tp.pid
	</cfquery>
	
	<cfquery name="del" datasource="#application.dsn#" result="res">
			delete from `ftb_browse_pid`
			where pid in (<cfqueryPARAM value = "#valueList(addindb.pid)#" CFSQLType="cf_sql_char" list="true">)
	</cfquery>
	ADDED: <cfdump var="#ins#">
	DELTED: <cfdump var="#res.recordcount#">
	
	
</cfif>
<html>
	<head>
	
	</head>
	<body>
		<form name="f" method="post" action="./addbrowse.cfm">
		<textarea name="pids" id="pids" cols="50" rows="10"></textarea><br>
		<input type="submit">
		</form>
	</body>
</html>
<script>
javascript:(
	function(){
		var pids = '';
		$('[data-pid]').each(function(idx,rec){
			var value = $(rec).attr('data-pid');
			pids = pids + value + ',';
		});
		var pidarr = pids.split(',');
		pidarr = $.unique(pidarr)
		var cntr = pidarr.length % 50;
		for(var i =0; i<=cntr;i++){
			var batch = pidarr.splice(i,50);
			if(batch.length > 0){
				pids = batch.join(',');
				 $.ajax({
	                url: 'http://localhost:8888/fkaz/cmp.cfc?method=addbrowse',
	                method : 'post',
	                crossDomain: true,
	                data:{pids:pids},
	                dataType: 'jsonp',
	                jsonp: false
	            });
	            console.log("sending req " + (i+1));
			}
		}
		
		}
	)();
</script>
<script>
javascript:(
	function(){
			var as = document.getElementsByTagName('a');
			var pids = '';
			for(var i=0; i<as.length;i++){
				var url = as[i].href;
				var regex = RegExp("([\\w-]+/)?(dp|gp/product)/(\\w+/)?(\\w{10})");
				m = url.match(regex);
				if (m) { 
					pids = pids + m[4] + ',';
				}				
			}
			var script = document.createElement("script");
			script.type = "text/javascript";
			script.src = "http://localhost:8888/fkaz/cmp.cfc?method=addbrowse&pids="+pids;
			 script.onload = script.onreadystatechange = function(){
			 	console.log(script);
			 };
			  document.getElementsByTagName('head')[0].appendChild(script);
			//window.prompt("Copy it",pids);
		}
	)();
</script>
<script>
/*jshint quotmark: false */
/*jslint latedef:false*/
'use strict';
(function(){
    // the minimum version of jQuery we want
    var v = '1.11.1';
    function isCurrentjQueryOlderThan(required) {
        var current = window.jQuery.fn.jquery;
        var currentSplit = current.split('.').map(function(ele) {return parseInt(ele);});
        var requiredSplit = required.split('.').map(function(ele) {return parseInt(ele);});
        if (currentSplit[0] === requiredSplit[0]) {
            //1.1.11 1.7.4
            if (currentSplit[1] === requiredSplit[1]) {
                //1.11.1 1.11.0
                if (currentSplit[2] === requiredSplit[2]) {
                    //1.11.1 1.11.1
                    return true;
                } else {
                    return currentSplit[2] < requiredSplit[2];
                }
            } else {
                return currentSplit[1] < requiredSplit[1];
            }
        } else {
            return currentSplit[0] < requiredSplit[0];
        }
    }

    // check prior inclusion and version
    if (window.cheapass === undefined && (window.jQuery === undefined || isCurrentjQueryOlderThan(v))) {
        var done = false;
        var script = document.createElement('script');
        script.src = 'https://ajax.googleapis.com/ajax/libs/jquery/' + v + '/jquery.min.js';
        script.onload = script.onreadystatechange = function(){
            if (!done && (!this.readyState || this.readyState === 'loaded' || this.readyState === 'complete')) {
                done = true;
                initCheapass();
            }
        };
        document.getElementsByTagName('head')[0].appendChild(script);
    } else {
        initCheapass();
    }

    function initCheapass() {
        function cssIsFetched(cssRes) {
            if (cssRes) {
                //Check if the user theme element is in place - if not, create it.
                if (!$('#cheapassCSS').length) {
                    $('head').append('<style id="cheapassCSS"></style>');
                }

                //populate the theme element with the new style (replace the old one if necessary)
                $('#cheapassCSS').text(cssRes);
            }

            window.cheapass = function() {
                var caPopup = '#caPopup';
                var domTop =
                '<div id="caPopup">' +
                '<a id="caClose" class="caClose" title="Close" style="position: absolute; left: -10px; top: -10px;"><div class="circle" style="font-size: 17px; border: 2px solid #444546; padding: 0 0 0 0; width: 26px; height: 26px; background-color:#444546; color: #fff; border-radius: 50px; text-align: center;"> x </div></a>' +
                '<a target="_blank" href="https://cheapass.in"><img class="caPopupLogo" src="https://cheapass.in/cdn/cheapass.png" /></a>';
                var domLoader =
                '<div class="caPopupLoader">'+
                '<img src="https://cheapass.in/cdn/loader.gif" height="45px" width="45px">'+
                '</div>';
                var domFinePrintSeller =
                '<p class="caFinePrint">Track changes in price. Got notified by email.</p>';
                var domFinePrintSite =
                '<p class="caFinePrint">A Cheapass doesn\'t pay for stuff.</p>';
                var domBottom =
                '</div>';

                var url = document.location.href;
                //remove the popup if exists
                removePopup();

                preRequestHandler();

                $.ajax({
                    url: 'https://cheapass.in/inputurl',
                    data: {url: url, jsonp: 1},
                    dataType: 'jsonp',
                    success: inputURLResponseHandler
                });

                function caClose() {
                    $(caPopup).remove();
                }

                function removePopup() {
                    if ($(caPopup).length) {
                        $(caPopup).remove();
                    }
                }

                function preRequestHandler() {
                    var dom = domTop + domFinePrintSeller + domLoader + domBottom;
                    $('body').append(dom);
                }

                function inputURLResponseHandler(response) {
                    removePopup();
                    if (response.downloadURLs || response.downloadURL) {
                        inputURLVideoDownloader(response.downloadURLs || response.downloadURL);
                    } else {
                        if (response.productPrice && response.productName) {
                            inputURLSuccessHandler(response);
                        } else {
                            inputURLErrorHandler();
                        }
                    }
                }

                function inputURLVideoDownloader(urls) {
                    var domBody = '<p class="caProductName">Click below to download</p>'+
                    '<div class="caDownloadListWrapper"><ul class="caDownloadList">';
                    if ($.isArray(urls)) {
                        if (urls.length) {
                            $.each(urls, function(index, url) {
                                domBody += '<li><a target="_blank" download="'+ url.name +'" href="' + url.downloadURL + '">' + url.name + '</a></li>';
                            });
                        } else {
                            domBody += '<li>Nope. Sorry I could not find any download links for this page.</li>';
                        }
                    } else {
                        domBody += '<li><a target="_blank" href="' + urls + '">Download link</a></li>';
                    }
                    domBody += '</ul></div>';

                    var dom = domTop + domFinePrintSite + domBody + domBottom;
                    $('body').append(dom);
                    $('#caClose').on('click', caClose);
                }

                function inputURLErrorHandler() {
                    var dom = domTop + domFinePrintSeller +
                    '<div id="caResponseNotification" class="caResponseNotification">'+
                    '<p class="caTextError" style="margin-bottom: 15px;">Duh! I couldn\'t process this page. Hit the button to try again, maybe?</p>'+
                    '<p>BTW, Is that a product page? <a href="mailto:aakash@cheapass.in">Let me know</a>, please?</p>'+
                    '</div>'+
                    domBottom;

                    $('body').append(dom);
                    $('#caClose').on('click', caClose);
                }

                function inputURLSuccessHandler(response) {
                    var name = response.productName,
                    price = response.productPrice,
                    image = response.productImage;

                    var dom = domTop + domFinePrintSeller +
                    '<h1 class="caProductName">'+ name +'</h1>' +
                    '<p class="caProductPrice">Price: Rs. '+ price +'/-</p>' +
                    '<form id="caQueueForm" class="caQueueForm">' +
                    '<input type="hidden" name="productName" value="' + name + '" />' +
                    '<input type="hidden" name="productURL" value="' + url + '" />' +
                    '<input type="hidden" name="currentPrice" value="' + price + '" />' +
                    '<input type="hidden" name="productImage" value="' + image + '" />' +
                    '<input type="hidden" name="source" value="bookmarklet" />' +
                    '<input type="hidden" name="jsonp" value="1" />' +
                    '<div class="caFormGroup">' +
                    '<label for="caFormUserEmail">Email</label>' +
                    '<input required autofocus type="email" class="email" name="email" placeholder="Email" />' +
                    '</div>' +
                    '<div class="caFormGroup">' +
                    '<input type="submit" value="Keep me notified" />' +
                    '</div>' +
                    '</form>'+
                    '<div id="caResponseNotification" class="caResponseNotification" style="display:none">'+
                    '<p></p>'+
                    '</div>' +
                    domBottom;

                    $('body').append(dom);

                    if ('localStorage' in window) {
                        var userEmail = localStorage.getItem('cheapassUserEmail');
                        if (userEmail) {
                            $('#caQueueForm').find('.email').val(userEmail).focus();
                        }
                    }

                    $('#caQueueForm').on('submit', handleQueueFormSubmit);
                    $('#caClose').on('click', caClose);
                }

                function handleQueueFormSubmit(e) {
                    e.preventDefault();
                    var payload = $(this).serialize();
                    $.ajax({
                        url: 'https://cheapass.in/queue?' + payload,
                        dataType: 'jsonp',
                        success: queueSuccessHandler
                    });

                    if ('localStorage' in window) {
                        var email = $('#caQueueForm').find('.email').val();
                        localStorage.setItem('cheapassUserEmail', email);
                    }

                    $('#caQueueForm input').attr('disabled', 'disabled');
                }

                function queueSuccessHandler(res) {
                    var message = res.status;
                    $('#caResponseNotification').find('p').addClass('caTextSuccess').text(message).end().fadeIn();
                }
            };

            window.cheapass();

        }

        if (window.cheapass) {
            cssIsFetched();
        } else {
            $.ajax({
                url: 'https://cheapass.in/cdn/cheapass.css?ts=' + new Date().getTime(),
                type: 'get',
                crossDomain: true,
                success: cssIsFetched
            });
        }
    }
})();

</script>
