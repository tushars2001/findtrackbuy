<cfquery name="getAllJobs" datasource="#application.dsn#">
	select * from ftb_alljobs order by orderjob
</cfquery>
<cfset job = createobject("component","job")>
<html>
	<head>
		<script language="javascript" src="/fkaz/js/jquery-1.11.1.min.js"></script>
		<script type="text/javascript">
			function run(job){
				$.ajax({
						type: 'GET',
					    url: '/fkaz/job.cfc?method=run&jobtype='+job,
					   <!---  cache: false, --->
					    beforeSend : function(a){
					    				$('#b_'+job).prop('disabled', true);
					    				$('#b_'+job).text('Running');
					    				$('.img_'+job).show();
					    				setTimeout(function(){checkstatus(job);}(),5000);
					    			 },
					    complete : function(results,status){
					    	
						},
						
						success:function(results,status){
							console.log(results);
							console.log(status);
						}
					});
			}
			
			function rerun(job,groupsk){
				$.ajax({
						type: 'GET',
					    url: '/fkaz/job.cfc?method=rerun&jobtype='+job+'&groupsk='+groupsk,
					   <!---  cache: false, --->
					    beforeSend : function(a){
					    				$('#rr_'+job).prop('disabled', true);
					    				$('#rr_'+job).text('Running');
					    				$('.img_'+job).show();
					    			 },
					    complete : function(results,status){
					    	
						},
						
						success:function(results,status){
						}
					});
			}
			
			function kill(job){
				$.ajax({
						type: 'GET',
					    url: '/fkaz/job.cfc?method=kill&jobtype='+job,
					   <!---  cache: false, --->
					    beforeSend : function(a){
					    			 },
					    complete : function(results,status){
					    	
						}
						
					});
			}
			
			function checkstatus(job){
				$.ajax({
						type: 'GET',
					    url: '/fkaz/job.cfc?method=checkstatus&jobtype='+job,
					   <!---  cache: false, --->
					    beforeSend : function(a){
					    			 },
					    complete : function(results){
					    	
						},
						success : function(results){
							if(results.ISPROCESSING){
								$('.img_'+job).show();
								$('#b_'+job).text('Running');
								$("#total_"+job).empty();
								$("#proc_"+job).empty();
								$("#ins_"+job).empty();
								$("#failed_"+job).empty();
								$("#total_"+job).append(results.TOTAL);
								$("#proc_"+job).append(results.PROC);
								$("#ins_"+job).append(results.INS);
								$("#failed_"+job).append(results.FAILED);
								//setTimeout(function(){checkstatus(job);}(),5000);
							}
							else{
								$('.img_'+job).hide();
								$('#b_'+job).text('Finished');
							}
						}
					});
			}
		</script>
	</head>
	<body>
		<table cellspacing="5" border="1">
			<tr>
				<td>
					JOBTYPE
				</td>
				<td>
					DESC
				</td>
				<td>
				</td>
				<td>
				</td>
				<td>
				</td>
				<td>
				</td>
				<td>
				</td>
				<td>
					TOTAL	
				</td>
				<td>
					PROCESSED
				</td>
				<td>
					INSERTED
				</td>
				<td>
					FAILED
				</td>
			</tr>
			<cfoutput query="getAllJobs">
			<tr>
				<td>
					#getAllJobs.jobtype#
				</td>
				<td>
					#getAllJobs.job_desc#	
				</td>
				<td>
					<button name="run" id="b_#getAllJobs.jobtype#" onclick="run('#getAllJobs.jobtype#');" <cfif job.isrunning('#getAllJobs.jobtype#')>disabled</cfif>>RUN</button>
				</td>
				<td>
					<button name="kill" id="kill_#getAllJobs.jobtype#" onclick="kill('#getAllJobs.jobtype#');" >KILL</button>
				</td>
				<td>
					<button name="cheskstatus" id="cs_#getAllJobs.jobtype#" onclick="checkstatus('#getAllJobs.jobtype#');" >CheckStatus</button>
				</td>
				<td>
					<button name="rerun" id="rr_#getAllJobs.jobtype#" onclick="rerun('#getAllJobs.jobtype#','');" >Rerun</button>
				</td>
				<td>
					<!--- <button name="checkstatus" id="bs_#getAllJobs.jobtype#" onclick="checkstatus('#getAllJobs.jobtype#');" >Check Status</button> --->
					<span class="img_#getAllJobs.jobtype#" <cfif not job.isrunning('#getAllJobs.jobtype#')>style="display:none;"</cfif>><img src="/fkaz/images/loader_gif.gif" width="80" height="60"></span>
				</td>
				<td>
					<span id="total_#getAllJobs.jobtype#"></span>	
				</td>
				<td>
					<span id="proc_#getAllJobs.jobtype#"></span>
				</td>
				<td>
					<span id="ins_#getAllJobs.jobtype#"></span>
				</td>
				<td>
					<span id="failed_#getAllJobs.jobtype#"></span>
				</td>
			</tr>
				<cfquery name="top3" datasource="#application.dsn#">
					SELECT `jobid`, date_format(ADDTIME( start, '05:30' ),'%d-%M-%y %I:%i %p') as start, `finished`, `status`, `jobtype`, `processed`, `inserted`, `updated`, `failed`, `server`, `groupsk`, `erormessage`, `total` FROM `ftb_jobtracker`
					 where jobtype='#getAllJobs.jobtype#'
					 order by jobid desc
					limit 0,3
				</cfquery>
				<cfif top3.recordcount>
				<tr><td colspan="11">
					<table border="1">
						<cfloop query="top3">
						<tr>
							<td>
								#top3.start#
							</td>
							 <td>
								#top3.status#
							</td>
							 <td>
								#top3.total#
							</td>
							<td>
								#top3.processed#
							</td>
							<td>
								#top3.inserted#
							</td>
							<td>
								#top3.failed#
							</td>
							<td>
								<button name="run" id="subb_#getAllJobs.jobtype#" onclick="rerun('#getAllJobs.jobtype#','#top3.groupsk#');" <cfif job.isrunning('#getAllJobs.jobtype#')></cfif>>RUN</button>
							</td>
							<td>
								<button name="kill" id="kill_#getAllJobs.jobtype#" onclick="kill('#getAllJobs.jobtype#');" >KILL</button>
							</td>
							<td>
								<button name="cheskstatus" id="cs_#getAllJobs.jobtype#" onclick="checkstatus('#getAllJobs.jobtype#');" >CheckStatus</button>
							</td>
							<td>
								<span class="img_#getAllJobs.jobtype#" <cfif not job.isrunning('#getAllJobs.jobtype#')>style="display:none;"</cfif>><img src="/fkaz/images/loader_gif.gif" width="80" height="60"></span>
							</td>
						</tr>
						</cfloop>
					</table>
				</td></tr>
				</cfif>
			</cfoutput>
		</table>
	</body>
</html> 