function loadchart(pid,id) {
			var limit = 10000;    //increase number of dataPoints by increasing the limit
			var y = 0;
			var data = [];
			var dataSeries = { type: "line" };
			var dataPoints = [];
			$.ajax({
			type: 'GET',
		    url: '/fkaz/cmp.cfc?method=getPriceHistory&pid='+pid,
		   <!---  cache: false, --->
		    beforeSend : function(a){
		    				$( "#chart"+id ).show();
		    				$( "#chart"+id ).empty();
		    				$( "#chart"+id ).append("Loading...");
		    			 },
		    complete : function(results){
		    	
		    	var jData = $.parseJSON(results.responseText);
				var prev=0;
				var maxval = 0; var minval=10000000;
				var start = 0;
				
				for (var i = 0; i < jData.DATA.length; i += 1) {
					if(jData.DATA[i][1].length == 0){
						jData.DATA[i][1] = prev;
					}
					if(!start && jData.DATA[i][1].toString().length > 0 && jData.DATA[i][1]>0){
						start = 1;
					}
					
					if(!start) continue;
					prev = jData.DATA[i][1];
					x = new Date(jData.DATA[i][3],eval(jData.DATA[i][2]-1),jData.DATA[i][4]);
					y = jData.DATA[i][1];
					
					if(y > maxval ) maxval = y;
					if(y < minval ) minval = y;
					dataPoints.push({
						x: x,
						y: y
					});
				}
				
				maxval = maxval*105/100;
				minval = minval*95/100;
				dataSeries.dataPoints = dataPoints;
				data.push(dataSeries);
				
				//Better to construct options first and then pass it as a parameter
				var options = {
					zoomEnabled: true,
			                animationEnabled: true,
					title: {
						text: ""
					},
					axisX: {
						title: "timeline",
			        	gridThickness: 1,
			        	interval: 1,
			        	titleFontSize:15,
			  			intervalType: "day",
			  			labelAngle: -90,
			  			labelFontSize: 12,
			  			valueFormatString: "DD-MMMM" 
					},
					axisY: {
						title: "Price",
						interval: maxval/10,
						minimum: minval,
						maximum: maxval
					},
					data: data  // random data
				};
				
				chart = new CanvasJS.Chart("chart"+id,options);
				chart.render();
				$("#chart"+id).CanvasJSChart(options);
		    	}
			});
}

scrolling=0;
function moveleft(s,where){
	scrolling=s;
	console.log(scrolling);
	var max = where*($(".canvasjs-chart-container").width()-100);
	var current = (-where)*$(".canvasjs-chart-container").position().left;
	var step = 20;
	if(current < max) scrolling = 0;
	if(scrolling == 0) return;
	$(".canvasjs-chart-container").animate({
	    
	    left: current+(step*where)
	  }, 50,function() {
	    moveleft(scrolling,where);
	  });
}

function moveright(s,where){
	scrolling=s;
	var max = ($(".canvasjs-chart-container").width()-100);
	var current = $(".canvasjs-chart-container").position().left;
	var step = 20;
	if(current >= 0) scrolling = 0;
	if(scrolling == 0) return;
	$(".canvasjs-chart-container").animate({
	    
	    left: current+(step*where)
	  }, 50,function() {
	    moveright(scrolling,where);
	  });
}
