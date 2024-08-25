<cfcomponent>
<cfset application.dsn = 'product'>
<cffunction name="HMAC_SHA256" returntype="binary" access="public" output="no" hint="Sign for AZ request">
 <cfargument name="signMessage" type="string" required="true" />
 <cfargument name="signKey" type="string" required="true" />
 <cfset local.jMsg = JavaCast("string",arguments.signMessage).getBytes("iso-8859-1") />
 <cfset local.jKey = JavaCast("string",arguments.signKey).getBytes("iso-8859-1") />
 <cfset local.key = createObject("java","javax.crypto.spec.SecretKeySpec") />
 <cfset local.mac = createObject("java","javax.crypto.Mac") />
 <cfset local.key = local.key.init(local.jKey,"HmacSHA256") />
 <cfset local.mac = local.mac.getInstance(local.key.getAlgorithm()) />
 <cfset local.mac.init(local.key) />
 <cfset local.mac.update(local.jMsg) />
 <cfreturn local.mac.doFinal() />
</cffunction>

<cffunction name="xmlToJson" output="false" returntype="any" hint="convert xml to JSON">
		<cfargument name="xml" default="" required="false" hint="raw xml"/>
		<cfargument name="includeFormatting" type="boolean" default="false" required="false" hint="whether or not to maintain and encode tabs, linefeeds and carriage returns"/>
		<cfset var result ="">
		<cfset var xsl ="">
		<cfsavecontent variable="xsl">
			<?xml version="1.0" encoding="UTF-8"?>
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="application/json"/>
				<xsl:strip-space elements="*"/>
			
				<!-- used to identify unique children in Muenchian grouping, credit Martynas Jusevicius http://www.xml.lt -->
				<xsl:key name="elements-by-name" match="@* | *" use="concat(generate-id(..), '@', name(.))"/>
			
				<!-- string -->
				<xsl:template match="text()">
					<xsl:call-template name="processValues">
						 <xsl:with-param name="s" select="."/>
					</xsl:call-template>
				</xsl:template>
			
				<!-- text values (from text nodes and attributes) -->
				<xsl:template name="processValues">
					<xsl:param name="s"/>
					<xsl:choose>
						<!-- number -->
						<xsl:when test="not(string(number($s))='NaN')">
							<xsl:value-of select="$s"/>
						</xsl:when>			
						<!-- boolean -->
						<xsl:when test="translate($s,'TRUE','true')='true'">true</xsl:when>
						<xsl:when test="translate($s,'FALSE','false')='false'">false</xsl:when>			
						<!-- string -->
						<xsl:otherwise>
							<xsl:call-template name="escapeArtist">
								<xsl:with-param name="s" select="$s"/>
							</xsl:call-template>
						</xsl:otherwise>			
					</xsl:choose>
				</xsl:template>
			
				<!-- begin filter chain -->
				<xsl:template name="escapeArtist">
					<xsl:param name="s"/>
					"
					<xsl:call-template name="escapeBackslash">
						<xsl:with-param name="s" select="$s"/>
					</xsl:call-template>
					"
				</xsl:template>
			
				<!-- escape the backslash (\) before everything else. -->
				<xsl:template name="escapeBackslash">
					<xsl:param name="s"/>
					<xsl:choose>
						<xsl:when test="contains($s,'\')">
							<xsl:call-template name="escapeQuotes">
								<xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
							</xsl:call-template>
							<xsl:call-template name="escapeBackslash">
								<xsl:with-param name="s" select="substring-after($s,'\')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="escapeQuotes">
								<xsl:with-param name="s" select="$s"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			
				<!-- escape the double quote ("). -->
				<xsl:template name="escapeQuotes">
					<xsl:param name="s"/>
					<xsl:choose>
						<xsl:when test="contains($s,'&quot;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
							</xsl:call-template>
							<xsl:call-template name="escapeQuotes">
								<xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="$s"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			
				<!-- encode tab, line feed and/or carriage return-->
				<xsl:template name="encoder">
					<xsl:param name="s"/>
					<xsl:choose>
						<!-- tab -->
						<xsl:when test="contains($s,'&#x9;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'<cfoutput>#iif(arguments.includeFormatting,DE("\t"),DE(" "))#</cfoutput>',substring-after($s,'&#x9;'))"/>
							</xsl:call-template>
						</xsl:when>			
						<!-- line feed -->
						<xsl:when test="contains($s,'&#xA;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'<cfoutput>#iif(arguments.includeFormatting,DE("\n"),DE(" "))#</cfoutput>',substring-after($s,'&#xA;'))"/>
							</xsl:call-template>
						</xsl:when>			
						<!-- carriage return -->
						<xsl:when test="contains($s,'&#xD;')">
							<xsl:call-template name="encoder">
								<xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'<cfoutput>#iif(arguments.includeFormatting,DE("\r"),DE(" "))#</cfoutput>',substring-after($s,'&#xD;'))"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
					</xsl:choose>
				</xsl:template>
				
				<!-- main handler template
					creates a struct containing: the node text(); struct of attributes; and set a struct key for any node children. 
					this template then drills into the children, repeating itself until complete
				-->
				<xsl:template name="processNode">
					{
						"text":	
						<xsl:call-template name="escapeArtist">
							<xsl:with-param name="s" select="key('elements-by-name', concat(generate-id(..), '@', name(.)))/text()"/>
						</xsl:call-template>
						,"attributes":{				
							<xsl:for-each select="@*">
								<xsl:call-template name="escapeArtist">
									<xsl:with-param name="s" select="name()"/>
								</xsl:call-template>
								:						
								<xsl:call-template name="processValues">
									<xsl:with-param name="s" select="."/>
								</xsl:call-template>
								<xsl:if test="position() &lt; count(parent::node()/attribute::*)">
									,
								</xsl:if>
							</xsl:for-each>
						}
						<!-- drill down the tree -->
						<xsl:for-each select="*[generate-id(.) = generate-id(key('elements-by-name', concat(generate-id(..), '@', name(.))))]">
							,
							<xsl:call-template name="escapeArtist">
								<xsl:with-param name="s" select="name()"/>
							</xsl:call-template>
							:						
							<xsl:apply-templates select="."/>				
						</xsl:for-each>
					}
				</xsl:template>
				
				<!-- main parser
					basically a node 'loop' - performed once for all matches of *, so once for each node including the root.
					note: this loop has no knowledge of other iterations it may have performed.
				-->
				<xsl:template match="*">
					<!-- determine whether any peers share the node name, so we can spool off into 'array mode' -->
					<xsl:variable name="isArray" select="count(key('elements-by-name', concat(generate-id(..), '@', name(.)))) &gt; 1"/>
					
					<xsl:if test="count(ancestor::node()) = 1"><!-- begin the root node-->
						{ 
						<xsl:call-template name="escapeArtist">
							<xsl:with-param name="s" select="name()"/>
						</xsl:call-template>
						:		
					</xsl:if>				
					
					<xsl:if test="not($isArray)">
						<xsl:call-template name="processNode">
							<xsl:with-param name="s" select="."/>
						</xsl:call-template>
					</xsl:if>				
					<xsl:if test="$isArray">
						[
							<xsl:apply-templates select="key('elements-by-name', concat(generate-id(..), '@', name(.)))" mode="array"/>
						]
					</xsl:if>		
					<xsl:if test="count(ancestor::node()) = 1">}</xsl:if><!-- close the root node -->		
				</xsl:template>
				
				<!-- array template called from main parser -->
				<xsl:template match="*" mode="array">	
					<xsl:call-template name="processNode">
						<xsl:with-param name="s" select="."/>
					</xsl:call-template>
					<xsl:if test="position() != last()">,</xsl:if>				
				</xsl:template>
				
			</xsl:stylesheet>
		</cfsavecontent>
		<cfset xsl = xmlParse(reReplace(xsl,'([\s\S\w\W]*)(<\?xml)','\2','all'))>
		<cfscript>		
			result = arguments.xml;
			result = reReplace(result,'([\s\S\w\W]*)(<\?xml)','\2','all');
			result = xmlTransform(trim(result),xsl);
			return result;
		</cfscript>
	</cffunction>

<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="false"
				hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
	<cfargument name="xmlNode" type="string" required="true" />
	<cfargument name="str" type="struct" required="true" />
	<!---Setup local variables for recurse: --->
	<cfset var i = 0 />
	<cfset var axml = arguments.xmlNode />
	<cfset var astr = arguments.str />
	<cfset var n = "" />
	<cfset var tmpContainer = "" />
	
	<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
	<cfset axml = axml[1] />
	<!--- For each children of context node: --->
	<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
		<!--- Read XML node name without namespace: --->
		<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
		<!--- If key with that name exists within output struct ... --->
		<cfif structKeyExists(astr, n)>
			<!--- ... and is not an array... --->
			<cfif not isArray(astr[n])>
				<!--- ... get this item into temp variable, ... --->
				<cfset tmpContainer = astr[n] />
				<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
				<cfset astr[n] = arrayNew(1) />
				<!--- ... and reassing temp item as a first element of new array: --->
				<cfset astr[n][1] = tmpContainer />
			<cfelse>
				<!--- Item is already an array: --->
				
			</cfif>
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
			</cfif>
		<cfelse>
			<!---
				This is not a struct. This may be first tag with some name.
				This may also be one and only tag with this name.
			--->
			<!---
					If context child node has child nodes (which means it will be complex type): --->
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
				<!--- recurse call: get complex item: --->
				<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
			<cfelse>
				<!--- else: assign node value as last element of array: --->
				<!--- if there are any attributes on this element--->
				<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
					<!--- assign the text --->
					<cfset astr[n] = axml.XmlChildren[i].XmlText />
						<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
					 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
					 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
						 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
							 <!--- remove any namespace attributes--->
							<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
						 </cfif>
					 </cfloop>
					 <!--- if there are any atributes left, append them to the response--->
					 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
						 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
					</cfif>
				<cfelse>
					 <cfset astr[n] = axml.XmlChildren[i].XmlText />
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<!--- return struct: --->
	<cfreturn astr />
</cffunction>

<cffunction name="ItemLookup" hint="AZ lookup by PID">
	<cfargument name="ItemId">
	<cfset ts = '#DateFormat(now(), "YYYY-MM-DD")#T'>
	<cfset tt = '#TimeFormat(now(), "HH:mm:ss")#Z'>
	<cfset encts = '#ts#' & urlencodedFormat('#tt#')>
	<cfset p = arraynew(1)>
	<cfset p[4] = 'Service=AWSECommerceService'>
	<cfset p[8] = 'AWSAccessKeyId=AKIAIYWVIWGRZ6GQ5ZZA'>
	<cfset p[3] = 'Operation=ItemLookup'>
	<cfset p[2] = 'ItemId=#arguments.ItemId#'>
	<cfset p[5] = 'Timestamp=#encts#'>
	<cfset p[6] = 'AssociateTag=t00fd-21'>
	<cfset p[7] = 'Version=2011-08-01'>
	<cfset p[1] = 'ResponseGroup=Medium'>
	 <cfset ArraySort(p,"text","asc")>
	<cfset req_params = '#p[1]#&#p[2]#&#p[3]#&#p[4]#&#p[5]#&#p[6]#&#p[7]#&#p[8]#'>
	<cfset lineBreak = Chr(10)>
	<cfset tosign = 'GET#lineBreak#webservices.amazon.in#lineBreak#/onca/xml#lineBreak##req_params#'>
	<cfset signed = URLEncodedFormat(ToBase64(HMAC_SHA256(tosign,"2GAqGMMvYPsjJfkVZlShNNdprFzvpCElSvJkKj8x")))>
	<cfset req = 'http://webservices.amazon.in/onca/xml?#req_params#&Signature=#signed#'>
	<cfhttp url='#req#' method="get" result="res"/>
	<cfreturn res.filecontent>
	
</cffunction>

<cffunction name="azKeyword" hint="AZ lookup by Keyword">
	<cfargument name="keyw">
	<cfargument name="page" required="false" default="1">
	<cfargument name="searchindex" required="false" default="All">
	<cfargument name="AWSAccessKeyId" required="false" default="AKIAIYWVIWGRZ6GQ5ZZA">
	<cfargument name="AssociateTag" required="false" default="t00fd-21">
	<cfset ts = '#DateFormat(now(), "YYYY-MM-DD")#T'>
	<cfset tt = '#TimeFormat(now(), "HH:mm:ss")#Z'>
	<cfset encts = '#ts#' & urlencodedFormat('#tt#')>
	<cfset arguments.keyw = replace(arguments.keyw,'-','')>
	<cfset p = arraynew(1)>
	
	<cfif arguments.page gt 5>
		<cfset arguments.page = 5>
	</cfif>
	
	<cfif not len(arguments.searchindex)>
		<cfset arguments.searchindex = 'All'>
	</cfif>
	
	<cfset productGroupsArr =
	[ 'All','Beauty','Grocery','PetSupplies','OfficeProducts','Electronics','Watches','Jewelry','Luggage','Shoes','KindleStore','Automotive','MusicalInstruments','GiftCards','Toys','SportingGoods','PCHardware','Books','Baby','HomeGarden','VideoGames','Apparel','Marketplace','DVD','Music','HealthPersonalCare','Software' ]
	>
	
	<cfset arguments.searchindex = replace(arguments.searchindex,' ','')>
	<cfset pg = arraytolist(productGroupsArr)>
	<cfset productGroups = ''>
	<cfloop list="#arguments.searchindex#" index="litem">
		<cfif ListFindNoCase(pg,litem) gt 1>
			<cfset productGroups = listappend(productGroups,litem)>
		</cfif>
	</cfloop>
	
	<cfif not len(productGroups)>
		<cfset productGroups = 'All'>
	</cfif>
	
	<cfset p[4] = 'Service=AWSECommerceService'>
	<cfset p[8] = 'AWSAccessKeyId=#arguments.AWSAccessKeyId#'>
	<cfset p[3] = 'Operation=ItemSearch'>
	<cfif len(arguments.keyw)>
		<cfset p[2] = 'Keywords=#urlencodedFormat(replace(arguments.keyw,".","XXZZ","all"))#'>
		<cfset p[2] = replace(p[2],"XXZZ",".","all")>
	</cfif>
	
	<cfset p[5] = 'Timestamp=#encts#'>
	<cfset p[6] = 'AssociateTag=#arguments.AssociateTag#'>
	<cfset p[7] = 'Version=2011-08-01'>
	<cfset p[1] = 'ResponseGroup=Medium'>
	<cfset p[9]='Condition=New'>
	<cfset p[10] ='SearchIndex=#urlencodedFormat(productGroups)#'>
	<cfset p[11] ='ItemPage=#arguments.page#'>
	<cfset p_correct = arraynew(1)>
	<cfloop from ="1" to="#arraylen(p)#" index="idx">
		<cfif arrayIsDefined(p,idx)>
			<cfset arrayappend(p_correct,p[idx])>
		</cfif>
	</cfloop>

	 <cfset ArraySort(p_correct,"text","asc")>
	<!--- <cfset req_params = '#p[1]#&#p[2]#&#p[3]#&#p[4]#&#p[5]#&#p[6]#&#p[7]#&#p[8]#&#p[9]#&#p[10]#&#p[11]#'> --->
	<cfset req_params = arraytoList(p_correct,'&')>
	<cfset lineBreak = Chr(10)>
	<cfset tosign = 'GET#lineBreak#webservices.amazon.in#lineBreak#/onca/xml#lineBreak##req_params#'>
	<cfset signed = URLEncodedFormat(ToBase64(HMAC_SHA256(tosign,"2GAqGMMvYPsjJfkVZlShNNdprFzvpCElSvJkKj8x")))>
	<cfset req = 'http://webservices.amazon.in/onca/xml?#req_params#&Signature=#signed#'>
	
	<cfhttp url='#req#' method="get" result="res"/>

	<cfreturn res.filecontent>
	
</cffunction>

<cffunction name="flipkartKeyword" hint="FK lookup by Keyword">
	<cfargument name="keyw">
	<cfargument name="page" default="1">
	<cfargument name="fkcat" default="">
	
	<cfset keywords = listtoarray(arguments.keyw,' ')>
	<cfset arguments.keyw = arraytolist(keywords)>
	
	<cfif arguments.page gt 1 and len(arguments.fkcat)>
		
		<cfset from = (arguments.page-1)*10>
		<cfset howmany = 10>
	
		<cfquery name="q_kwcat" datasource="#application.dsn#">
			select * from (
			SELECT `pid`, `last_tracked`, `link`, `image`, `last_price`, `title`, `description`, `category` 
			FROM `ftb_trackers_pid`
			where 
			category in ( <cfqueryPARAM value = "#arguments.fkcat#" CFSQLType="cf_sql_char" list="true"> )
			and (
			<cfprocessingdirective suppressWhiteSpace = "true">
			(
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(title) like upper('%#litem#%') and
				</cfif>
			</cfloop>
			1=1
			) or (
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(description) like upper('%#litem#%') and 
				</cfif>
			</cfloop>
			 1=1)
			 )
			 </cfprocessingdirective>
			and active = 1 
			and type = 0 <!--- FK only --->
			
			union
			
			SELECT `pid`, `last_tracked`, `link`, `image`, `last_price`, `title`, `description`, `category` 
			FROM `ftb_trackers_pid`
			where 
			category in ( <cfqueryPARAM value = "#arguments.fkcat#" CFSQLType="cf_sql_char" list="true"> )
			and (
			<cfprocessingdirective suppressWhiteSpace = "true">
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(title) like upper('%#litem#%') or  upper(description) like upper('%#litem#%') or
				</cfif>
			</cfloop>
			 1=0)
			 </cfprocessingdirective>
			and active = 1 
			and type = 0 <!--- FK only --->
			
			union
			
			SELECT `pid`, `last_tracked`, `link`, `image`, `last_price`, `title`, `description`, `category` 
			FROM `ftb_trackers_pid`
			where 
			1=1
			and (
			<cfprocessingdirective suppressWhiteSpace = "true">
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gt 3 and not isgeneric(litem)>
					 upper(title) like upper('%#litem#%') or  upper(description) like upper('%#litem#%') or
				</cfif>
			</cfloop>
			</cfprocessingdirective>
			 1=0)
			and active = 1 
			and type = 0 <!--- FK only --->
			
			union
			
			SELECT `pid`, `last_tracked`, `link`, `image`, `last_price`, `title`, `description`, `category`
			FROM `ftb_trackers_pid`
			where 
			category in ( <cfqueryPARAM value = "#arguments.fkcat#" CFSQLType="cf_sql_char" list="true"> )
			and active = 1 
			and type = 0 <!--- FK only --->
			) fnl
			where image != '/fkaz/images/noimage.png'
			LIMIT #from#,#howmany# 
		</cfquery>
		
		<cfset ret.data = q_kwcat>
		<cfset ret.datatype = 'query'>
		
	<cfelse>
		<!--- <cfhttp url="https://affiliate-api.flipkart.net/affiliate/api/tnhpindia.json" result="res" method="get">
			<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
			<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
		</cfhttp> --->
		<cfhttp url="https://affiliate-api.flipkart.net/affiliate/search/json?query=#arguments.keyw#&resultCount=200" result="res" method="get">
			<cfhttpparam name="Fk-Affiliate-Id" value="tnhpindia" type="header">
			<cfhttpparam name="Fk-Affiliate-Token" value="f40996af11994496b1ffd196a75e89fb" type="header">
		</cfhttp>
		<cfset ret.data = res.filecontent>
		<cfset ret.datatype = 'nonjson'>
	</cfif>
	
	<cfreturn ret>

</cffunction>

<cffunction name="flipkartPID" hint="FK lookup by PID">
	<cfargument name="pid">
	<cfargument name="affid" required="false" default="tnhpindia">
	<cfargument name="token" required="false" default="f40996af11994496b1ffd196a75e89fb">

	<cfhttp url="https://affiliate-api.flipkart.net/affiliate/product/json?id=#arguments.pid#" result="res" method="get">
		<cfhttpparam name="Fk-Affiliate-Id" value="#arguments.affid#" type="header">
		<cfhttpparam name="Fk-Affiliate-Token" value="#arguments.token#" type="header">
	</cfhttp>

	<cfreturn res.filecontent>

</cffunction>

<cffunction name="fkurlparse" hint="FK get PID from URL">
	<cfargument name="link">
	
	<cfset var pid = ''>
	<cfset pid = mid(link,findNoCase('pid=',arguments.link),len(link)) >
	<cfset pid = mid(pid,1,findNoCase('&',pid)-1) >
	<cfset pid = replaceNoCase(pid,'pid=','') >

	<cfreturn pid>

</cffunction>

<cffunction name="azurlparse" hint="AZ get PID from URL">
	<cfargument name="link">
	
	<cfset var pid = ''>
	<cfset findterm = findNoCase('dp/',arguments.link)>
	<cfset found = 'dp/'>
	<cfif not findterm>
		<cfset findterm = findNoCase('product/',arguments.link)>
		<cfset found = 'product/'>
	</cfif>
	<cfset pid = mid(link,findterm,len(link)) >
	<cfset pid = mid(pid,1,10+len(found)) >
	<cfset pid = replaceNoCase(pid,found,'') >
	<cfreturn pid>

</cffunction>

<cffunction name="isAZlink" hint="Check if URL is AZ">
	<cfargument name="link">
	
	<cfset var ret = false>
	<cfset ret = findnocase('amazon.in/',arguments.link) >
	
	<cfif ret lte 0>
		<cfset ret = 0>
	</cfif>	
	
	<cfreturn ret>

</cffunction>

<cffunction name="isFKlink" hint="Check if URL is FK">
	<cfargument name="link">
	
	<cfset var ret = false>
	<cfset ret = findnocase('flipkart.com/',arguments.link) >
	
	<cfif ret lte 0>
		<cfset ret = 0>
	</cfif>	
	
	<cfreturn ret>
</cffunction>

<cffunction name="fkImage" hint="Return FK image struct">
	<cfargument name="imgList">
	<cfset var img = structNew()>
	<cfset imgList = imgList.imageUrls>
	<cfset imgSizes = structKeyArray(imgList)>
	<cfset mini = 200*200>
	<cfset maxi = 400*400>
	<cfset big = 0>
	<cfset small = 1000000000>
	<cfloop from="1" to="#arraylen(imgSizes)#" index="idx">
		<cfif imgSizes[idx] neq 'unknown'>
			<cfset temp = evaluate(replace(imgSizes[idx],'x','*'))>
			<cfif temp gte 200*200 and temp lte 400*400>
				<cfif temp gt big>
					<cfset big = temp>
					<cfset img.big.size=big>
					<cfset img.big.url = evaluate('imgList.'&imgSizes[idx])>
				</cfif>
				<cfif temp lt small>
					<cfset small = temp>
					<cfset img.small.size=temp>
					<cfset img.small.url = evaluate('imgList.'&imgSizes[idx])>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfreturn img>
</cffunction>

<cffunction name="azImage" hint="Return AZ image struct">
	<cfargument name="imgList">
	<cfset var img = structNew()>

	<cftry>
	
	<cfif structKeyExists(imgList,"MediumImage")>
		<cfset img.small.height = imgList.LargeImage.Height>
		<cfset img.small.width = imgList.LargeImage.Width>
		<cfset img.small.size = img.small.height*img.small.width>
		<cfset img.small.url = imgList.LargeImage.URL>
		
		<cfset img.big.height = imgList.LargeImage.Height>
		<cfset img.big.width = imgList.LargeImage.Width>
		<cfset img.big.size = img.big.height*img.big.width>
		<cfset img.big.url = imgList.LargeImage.URL>
	<cfelse>
		<cfset img.small.height = imgList.ImageSets.ImageSet[1].LargeImage.Height>
		<cfset img.small.width = imgList.ImageSets.ImageSet[1].LargeImage.Width>
		<cfset img.small.size = img.small.height*img.small.width>
		<cfset img.small.url = imgList.ImageSets.ImageSet[1].LargeImage.URL>
		
		<cfset img.big.height = imgList.ImageSets.ImageSet[1].LargeImage.Height>
		<cfset img.big.width = imgList.ImageSets.ImageSet[1].LargeImage.Width>
		<cfset img.big.size = img.big.height*img.big.width>
		<cfset img.big.url = imgList.ImageSets.ImageSet[1].LargeImage.URL>
	</cfif>
	
	<cfcatch>
	</cfcatch>
	</cftry>

	<cfreturn img>
</cffunction>

<cffunction name="getProductsToTrack" hint="get Products To Track">
	<cfargument name="pid" required="false">
	<cfset var q_getProductsToTrack = queryNew('')>
	
	<cfquery name="q_getProductsToTrack" datasource="product" cachedwithin="#createtimespan(1,0,0,0)#">
		select pid, type from ftb_trackers_pid
		where active = 1
		and pid not in (
		SELECT pid 
			FROM  `ftb_product_tracker`
			where track_group_sk = '#request.sk#' 
		union
		SELECT pid 
		FROM  `ftb_fail_log`
		where track_group_sk = '#request.sk#' 
		)
	</cfquery>	
	
	<cfoutput>#q_getProductsToTrack.recordcount# PRODUCTS TO GO<br></cfoutput>
	<cfflush>

	<cfreturn q_getProductsToTrack>
</cffunction>

<cffunction name="trackingJob" hint="run tracking job and return all trackData">
	<cfargument name="productsToTrack" required="true" type="query">
	<cfset dataArray = arraynew(1)>

	<cfloop from="1" to="#arguments.productsToTrack.recordcount#" index="idx">
		<cftry>
			<cfif arguments.productsToTrack.type[idx] eq 0><!--- Flipkart --->
				<cfset trackdata = flipkartPID(arguments.productsToTrack.pid[idx])>
				<cfset trackdata = DeserializeJSON(trackdata)>
				<cfset dbdata.price = trackdata.productBaseInfo.productAttributes.sellingPrice.amount>
				<cfset dbdata.pid = arguments.productsToTrack.pid[idx]>
				<cfset arrayAppend(dataArray,structcopy(dbdata))>
				<cfset ret = insertTrackData(dataArray)>
				<cfset arrayclear(dataArray)>
			</cfif>
			<cfif arguments.productsToTrack.type[idx] eq 1><!--- Amazon --->
				<cfset trackdata = ItemLookup(arguments.productsToTrack.pid[idx])>
				<cfset trackdata = ConvertXmlToStruct(trackdata,structnew())>
				<cfset dbdata.price = trackdata.Items.item.OfferSummary.LowestNewPrice.Amount/100>
				<cfset dbdata.pid = arguments.productsToTrack.pid[idx]>
				<cfset arrayAppend(dataArray,structcopy(dbdata))>
				<cfset ret = insertTrackData(dataArray)>
				<cfset arrayclear(dataArray)>
			</cfif>
			. 
		<cfcatch>
			<cfquery name="faillog" datasource="#application.dsn#">
				INSERT INTO `ftb_fail_log`(`track_group_sk`, `pid`, `fail_msg`) VALUES
				('#request.sk#','#arguments.productsToTrack.pid[idx]#','#cfcatch.Message#')
			</cfquery>
		</cfcatch>
		</cftry>
		<cfflush>
	</cfloop>
	
	<cfreturn dataArray>
	
</cffunction>

<cffunction name="insertTrackData" hint="Insert trackData in DB">
	<cfargument name="trackData" required="true" type="array">
	<cfset var ret = arraynew(1)>
	
	<cfloop from="1" index="idx" to="#arraylen(arguments.trackData)#">
			<cfquery name="q_insertTrackData" datasource="#application.dsn#">
				INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
				VALUES ('#arguments.trackData[idx].pid#',#arguments.trackData[idx].price#,'#request.sk#')
			</cfquery>
			<cfset arrayAppend(ret,{
				pid:arguments.trackData[idx].pid,
				price: arguments.trackData[idx].price
			})>
	</cfloop>
	
	<cfreturn ret>
</cffunction>


<cffunction name="addToTrack" hint="Insert query to add in tracking table">
	<cfargument name="data" required="true" type="struct">
	
	<cftry>
		<cfquery name="q_insertTrackData" datasource="#application.dsn#">
			INSERT INTO `ftb_trackers_pid`
			(`pid`, `type`, `link`, `image`, `last_price`,`title`) 
			VALUES 
			('#arguments.data.pid#',#arguments.data.TYPE#,'#arguments.data.LINK#','#arguments.data.IMG#',#arguments.data.PRICE#,'#arguments.data.TITLE#')
		</cfquery>
	<cfcatch>
	</cfcatch>
	</cftry>

</cffunction>

<cffunction name="fkMinPrice" hint="return price of FK">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var price = 0>
	<cfif structkeyexists(arguments.pJson,'sellingPrice') and isnumeric(arguments.pJson.sellingPrice.amount)>
		<cfset price = arguments.pJson.sellingPrice.amount>
	</cfif>
	
	<cfreturn price>
</cffunction>

<cffunction name="azMinPrice" hint="return price of AZ">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var price = ''>
	<cftry>
		<cfset price = arguments.pJson.OfferSummary.LowestNewPrice.Amount/100>
	<cfcatch>
		<cfset price = 'NA'>
	</cfcatch>
	</cftry>
	
	
	<cfreturn price>
</cffunction>

<cffunction name="fkTitle" hint="return title of FK">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var title = ''>

	<cfset title = left(arguments.pJson.title,300)>
	
	<cfreturn title>
</cffunction>

<cffunction name="azTitle" hint="return price of AZ">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var title = ''>

	<cfset title = left(arguments.pJson.ItemAttributes.Title,300)>
	
	<cfreturn title>
</cffunction>

<cffunction name="fkDetails" hint="return details of FK">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var data = {
		pid:'',
		title:'',
		link:'',
		image:'',
		price:'',
		description:'',
		type:'0',
		available:'1'
	}>

	<cfset data.title = left(fkTitle(arguments.pJson),300)>
	<cfset image = fkImage(arguments.pJson)>
	<cfif structkeyExists(image,'big')>
		<cfset data.image = fkImage(arguments.pJson).big.url>
	<cfelse>		
		<cfset data.image = '/fkaz/images/noimage.png'>
	</cfif>
	
	<cfset data.price = fkMinPrice(arguments.pJson)>
	<cfset data.link = pJson.productUrl>
	<cfset data.pid = fkurlparse(data.link)>
	<cfif structkeyExists(arguments.pJson,"productDescription")>
		<cfset data.description = left(arguments.pJson.productDescription,20000)>
	</cfif>	
	<cfif structkeyExists(arguments.pJson,"inStock")>
		<cfif arguments.pJson.inStock eq 'false'>
			<cfset data.available = '0'>
		</cfif>
	</cfif>	

	
	<cfreturn data>
</cffunction>

<cffunction name="azDetails" hint="return details of AZ">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var data = {
		pid:'',
		title:'',
		link:'',
		image:'',
		price:'',
		description:'',
		type:'1',
		available:'1'
	}>

	<cfset data.title = left(azTitle(arguments.pJson),300)>
	<cfset image = azImage(arguments.pJson)>
	<cfif structkeyExists(image,'big')>
		<cfset data.image = azImage(arguments.pJson).big.url>
	<cfelse>		
		<cfset data.image = '/fkaz/images/noimage.png'>
	</cfif>
	<cfset data.price = azMinPrice(arguments.pJson)>
	<cfset data.link = urlDecode(pJson.DetailPageURL)>
	<cfset data.pid = azurlparse(data.link)>
	<cfif isdefined("arguments.pJson.EditorialReviews.EditorialReview.Content")>
		<cfset data.description = left(arguments.pJson.EditorialReviews.EditorialReview.Content,20000)>
	</cfif>

	
	<cfreturn data>
</cffunction>

<cffunction name="getFKCategories" hint="return category info for FK">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var categories = ''>
	<cfset var maxlen = 30>
	
	<cfquery name="qcatList" datasource="#application.dsn#" cachedwithin="#createTimespan(1,0,0,0)#">
		SELECT MAX( LENGTH( apiname ) ) as maxlen FROM  `ftb_fkapi`
	</cfquery>	
	
	<cfif qcatList.maxlen gt maxlen>
		<cfset maxlen = qcatList.maxlen>
	</cfif>
	
	<cfloop from="1" to="#arraylen(pJson.productInfoList)#" index="idx">
		<cfset cattemp = pJson.productInfoList[idx].productBaseInfo.productIdentifier.categoryPaths.categoryPath[1][1].title>
		
		<cfif len(cattemp) lte maxlen>
			<cfset categories = listappend(categories,cattemp)>
		</cfif>
		<!--- <cfset listappend(categories,pJson.productInfoList[idx].productBaseInfo.productIdentifier.categoryPaths.categoryPath[1][1].title)> --->
	</cfloop>	
	<cfset categories = ListRemoveDuplicates(categories)>
	
	<cfquery name="qgetCat" datasource="#application.dsn#">
		SELECT apiname,apiurl FROM  `ftb_fkapi`
		where apiname in (<cfqueryPARAM value = "#categories#" 
    CFSQLType="cf_sql_char" list="true">)
	</cfquery>

	
	<cfreturn valueList(qgetCat.apiname)>
</cffunction>

<cffunction name="getAZCategories" hint="return category info for AZ">
	<cfargument name="pJson" required="true" type="struct">
	<cfset var categories = ''>

	<cfloop from="1" to="#arraylen(pJson.Items.Item)#" index="idx">
		<cfset group = pJson.Items.Item[idx].ItemAttributes.ProductGroup>
		<cfset categories = listappend(categories,group)>
	</cfloop>	
	
	<cfset categories = ListRemoveDuplicates(categories)>
	
	<cfreturn categories>
</cffunction>

<cffunction name="getFKAPILinks" hint="return API URLs for FK by APINAME">
	<cfargument name="apinames" required="true" type="string">
	<cfset var apilinks = arraynew(1)>
	
	<!--- <cf_apiupdate> --->
	
	<cfquery name="qcatList" datasource="#application.dsn#">
		SELECT apiurl,apiname FROM  `ftb_fkapi`
		where apiname in (<cfqueryPARAM value = "#arguments.apinames#" CFSQLType="cf_sql_char" list="true">)
	</cfquery>	

	<cfset apiurllist = valuelist(qcatList.apiurl)>
	
	<cfset apilinks = listtoArray(apiurllist)>
	
	<cfreturn apilinks>
</cffunction>

<cffunction name="isgeneric" hint="return if the word passed is generic word">
	<cfargument name="item" required="true" type="string">
	<cfset var isgen = false>
	<cfset var genericwords = ["a", "about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also","although","always","am","among", "amongst", "amoungst", "amount",  "an", "and", "another", "any","anyhow","anyone","anything","anyway", "anywhere", "are", "around", "as",  "at", "back","be","became", "because","become","becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom","but", "by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each", "eg", "eight", "either", "eleven","else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own","part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves", "the"]>
	
	<cfloop from ="1" to="#arraylen(genericwords)#" index="idx">
		
		<cfif ucase(genericwords[idx]) eq ucase(arguments.item)>
			<cfset isgen = true >
			<cfbreak>
		</cfif>
	
	</cfloop>
	
	<cfreturn isgen>
</cffunction>

<cffunction name="getMovers" hint="return top trends">
	<cfargument name="page" required="true">
	<cfargument name="category" required="FAlse" Default="">
	<cfargument name="LOT" required="FAlse" Default="12">
	<cfargument name="pid" required="FAlse" Default="">
	<cfset var q_getMovers = QUERYNew('')>
	<cfset var q_getCats = QUERYNew('')>
	
	<cfif len(arguments.category)>
		<cfquery name="q_getCats" datasource="#application.dsn#">
			select distinct sub_category from ftp_category
			where category = '#arguments.category#'
		</cfquery>
	</cfif>
	
	<cfquery name="q_getMovers" datasource="#application.dsn#">
		select * from (
		SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.titlelong as title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			<cfif isdefined('session.dropsince') and session.dropsince gt 0>
			, (SELECT distinct pid FROM `ftb_product_tracker` where record_ts > date_add(curdate(), interval -#session.dropsince# day)) b
			</cfif>
			WHERE m.pid = t.pid
			<cfif isdefined('session.dropsince') and session.dropsince gt 0>
			and m.pid = b.pid
			</cfif>
			and m.`variance` >= -75
			<cfif (isdefined('session.rangeFrom') and session.rangeFrom gte -100) and (isdefined('session.rangeTo') and session.rangeTo lte 100)>
				and m.`variance` >= #session.rangeFrom# and m.`variance` <= #session.rangeTo# 
			</cfif>
			
			<cfif (isdefined('session.prangeFrom') and session.prangeFrom gte 0) and (isdefined('session.prangeTo') and session.prangeTo lte 25000)>
				and t.last_price >= #session.prangeFrom# <cfif session.prangeTo neq 25000>and t.last_price <= #session.prangeTo# </cfif>
			</cfif>
			
			<cfif isdefined('session.fluctuate') and session.fluctuate>
				and m.track_count > 5
			</cfif>
			
			
			<cfif isdefined('session.saveme') and session.saveme gt 0>
				<cfif session.saveme eq 100>
					and m.difference >= -100 and m.difference < 0
				</cfif>
				<cfif session.saveme eq 500>
					and m.difference >= -500 and m.difference < -100
				</cfif>
				<cfif session.saveme eq 1000>
					and m.difference >= -1000 and m.difference < -500
				</cfif>
				<cfif session.saveme eq 1001>
					and m.difference < -1000
				</cfif>
			</cfif>
			
			<cfif len(arguments.category) and q_getCats.recordcount>
			and t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">)
			</cfif>
			<cfif len(arguments.pid)>
			and m.`pid`='#arguments.pid#'
			</cfif>
			
			ORDER BY variance ASC 
		) o
		limit #(arguments.page-1)*arguments.lot#,#arguments.lot#
	</cfquery>

	<cfreturn q_getMovers>
</cffunction>

<cffunction name="getMoversKW" hint="return top trends">
	<cfargument name="page" required="true">
	<cfargument name="category" required="FAlse" Default="">
	<cfargument name="LOT" required="FAlse" Default="12">
	<cfargument name="pid" required="FAlse" Default="">
	<cfset var q_getMovers = QUERYNew('')>
	<cfset var q_getCats = QUERYNew('')>
	
	<cfif len(arguments.category)>
		<cfquery name="q_getCats" datasource="#application.dsn#">
			select distinct sub_category from ftp_category
			where category = '#arguments.category#'
		</cfquery>
	</cfif>
	
	<cfquery name="q_getMovers" datasource="#application.dsn#">
		select * from (
		SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
				,t.category 
			FROM  `ftb_movers` m, ftb_trackers_pid t, ftb_keywords k
			<cfif isdefined('session.dropsince') and session.dropsince gt 0>
			, (SELECT distinct pid FROM `ftb_product_tracker` where record_ts > date_add(curdate(), interval -#session.dropsince# day)) b
			</cfif>
			WHERE m.pid = t.pid
			and m.pid = k.pid
			and length(k.keywords) = 0
			<cfif isdefined('session.dropsince') and session.dropsince gt 0>
			and m.pid = b.pid
			</cfif>
			and m.`variance` >= -75
			<cfif (isdefined('session.rangeFrom') and session.rangeFrom gte -100) and (isdefined('session.rangeTo') and session.rangeTo lte 100)>
				and m.`variance` >= #session.rangeFrom# and m.`variance` <= #session.rangeTo# 
			</cfif>
			
			<cfif (isdefined('session.prangeFrom') and session.prangeFrom gte 0) and (isdefined('session.prangeTo') and session.prangeTo lte 25000)>
				and t.last_price >= #session.prangeFrom# <cfif session.prangeTo neq 25000>and t.last_price <= #session.prangeTo# </cfif>
			</cfif>
			
			<cfif isdefined('session.fluctuate') and session.fluctuate>
				and m.track_count > 5
			</cfif>
			
			<cfif isdefined('session.saveme') and session.saveme gt 0>
				<cfif session.saveme eq 100>
					and m.difference >= -100 and m.difference < 0
				</cfif>
				<cfif session.saveme eq 500>
					and m.difference >= -500 and m.difference < -100
				</cfif>
				<cfif session.saveme eq 1000>
					and m.difference >= -1000 and m.difference < -500
				</cfif>
				<cfif session.saveme eq 1001>
					and m.difference < -1000
				</cfif>
			</cfif>
			
			<cfif len(arguments.category) and q_getCats.recordcount>
			and t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">)
			</cfif>
			<cfif len(arguments.pid)>
			and m.`pid`='#arguments.pid#'
			</cfif>
			
			ORDER BY category desc 
		) o
		limit #(arguments.page-1)*arguments.lot#,#arguments.lot#
	</cfquery>

	<cfreturn q_getMovers>
</cffunction>

<cffunction name="getFKAZKeyword" hint="return top trends">
	<cfargument name="keyw" required="true">
	<cfargument name="page" required="true">
	<cfargument name="category" required="false" default="">
	<cfargument name="LOT" required="FAlse" Default="12">
	<cfset var q_kwcat = QUERYNew('')>
	
	<cfset arguments.category = arguments.keyw>
	<cfset keywords = replace(arguments.keyw,' ','%','all')>
	<cfset arguments.keyw = keywords>
	
	<cfif len(arguments.category)>
		<cfquery name="q_getCats" datasource="#application.dsn#">
			select distinct sub_category from ftp_category
			where category = '#arguments.category#'
		</cfquery>
		<cfif q_getCats.recordcount>
			<cfset arguments.category = valueList(q_getCats.sub_category)>
		</cfif>
	</cfif>
	
	<cfquery name="q_kwcat" datasource="#application.dsn#">
		select * from (
			SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.titlelong as title, t.type,
			CASE
			    WHEN REPLACE(upper(t.titlelong),'''','') like upper('%#left(arguments.keyw,30)#%')  THEN 1
			    <!--- else 2 --->
			  END as titlefound,
		   CASE
			    WHEN upper(t.description) like upper('%#arguments.keyw#%')  THEN 1
			   <!---  else 2 --->
			  END as descfound,
		    CASE
			    WHEN (t.category) in (
						 <cfqueryPARAM value = "#arguments.category#" CFSQLType="cf_sql_char" list="true">
						 )  THEN 1
			    <!--- else 2 --->
			  END as catfound
			FROM  `ftb_movers` m, ftb_trackers_pid t
			<cfif isdefined('session.dropsince') and session.dropsince gt 0>
							, (select distinct pid from ftb_drop_since where since = #session.dropsince#) b
			</cfif>
			WHERE m.pid = t.pid
			<cfif isdefined('session.dropsince') and session.dropsince gt 0>
			and m.pid = b.pid
			</cfif>
			<!--- and t.available = 1 --->
			and m.`variance` < 350 
			and m.`variance` > -80 and
			(
						 REPLACE(upper(t.titlelong),'''','') like upper('%#left(arguments.keyw,30)#%') 
						 or
						 upper(t.description) like upper('%#arguments.keyw#%')
						  or
						 upper(t.category) like upper('%#arguments.category#%')
						 or
						 (t.category) in (
						 <cfqueryPARAM value = "#arguments.category#" CFSQLType="cf_sql_char" list="true">
						 )
						 or
						 upper(t.pid) like upper('%#arguments.keyw#%') 
						 <cfif arguments.keyw eq 'All%Drops'>
							or 1=1
						</cfif>
			 )
			 <cfif (isdefined('session.rangeFrom') and session.rangeFrom gte -100) and (isdefined('session.rangeTo') and session.rangeTo lte 100)>
				and m.`variance` >= #session.rangeFrom# and m.`variance` <= #session.rangeTo# 
			</cfif>
			
			<cfif isdefined('session.saveme') and session.saveme gt 0>
				<cfif session.saveme eq 100>
					and m.difference >= -100 and m.difference < 0
				</cfif>
				<cfif session.saveme eq 500>
					and m.difference >= -500 and m.difference < -100
				</cfif>
				<cfif session.saveme eq 1000>
					and m.difference >= -1000 and m.difference < -500
				</cfif>
				<cfif session.saveme eq 1001>
					and m.difference < -1000
				</cfif>
			</cfif>
			
			
			<cfif (isdefined('session.prangeFrom') and session.prangeFrom gte 0) and (isdefined('session.prangeTo') and session.prangeTo lte 25000)>
				and t.last_price >= #session.prangeFrom# <cfif session.prangeTo neq 25000>and t.last_price <= #session.prangeTo# </cfif>
			</cfif>
			and t.active = 1 
			) fnl
			where image != '/fkaz/images/noimage.png'
			<cfif isdefined('session.fluctuate') and session.fluctuate>
				and track_count > 5
			</cfif>
			<cfif structkeyexists(session,"sort") and isstruct(session.sort)>
				order by  #StructKeyArray(session.sort)[1]# #session.sort[StructKeyArray(session.sort)[1]]#
			<cfelse>
				<cfif arguments.keyw eq 'All%Drops'>
					order by variance
				<cfelse>
					order by catfound,titlefound,catfound, descfound
				</cfif>
			</cfif>
			limit #(arguments.page-1)*arguments.lot#,#arguments.lot#
			<!--- select * from (
			SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			WHERE m.pid = t.pid
			and m.`variance` > -70 and
			<cfif len(arguments.category) and q_getCats.recordcount>
			t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">)
			and
			</cfif>
			(
			<cfprocessingdirective suppressWhiteSpace = "true">
			(
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(t.title) like upper('%#litem#%') and
				</cfif>
			</cfloop>
			1=1
			) or (
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(t.description) like upper('%#litem#%') and 
				</cfif>
			</cfloop>
			 1=1)
			 </cfprocessingdirective>
			 )
			and t.active = 1 
			
			union
			
			SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			where
			m.pid = t.pid
			and m.`variance` > -50 and
			<cfif len(arguments.category) and q_getCats.recordcount>
			t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">)
			and
			</cfif>
			 (
			<cfprocessingdirective suppressWhiteSpace = "true">
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(t.title) like upper('%#litem#%') or  upper(t.description) like upper('%#litem#%') or
				</cfif>
			</cfloop>
			 </cfprocessingdirective>
			  1=0)
			and t.active = 1 
			
			union
			
			SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			where 
			m.pid = t.pid
			and m.`variance` > -50 and
			<cfif len(arguments.category) and q_getCats.recordcount>
			t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">) and
			</cfif>
			 (
			<cfprocessingdirective suppressWhiteSpace = "true">
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gt 3 and not isgeneric(litem)>
					 upper(t.title) like upper('%#litem#%') or  upper(t.description) like upper('%#litem#%') or
				</cfif>
			</cfloop>
			</cfprocessingdirective>
			 1=0)
			and active = 1 
			
			) fnl
			where image != '/fkaz/images/noimage.png'
			order by variance asc
			limit #(arguments.page-1)*arguments.lot#,#arguments.lot# --->
		</cfquery>
	<cfreturn q_kwcat>
</cffunction>

<cffunction name="getFKAZKeywordNoMoves" hint="return not movers">
	<cfargument name="keyw" required="true">
	<cfargument name="page" required="true">
	<cfargument name="category" required="false" default="">
	<cfargument name="LOT" required="FAlse" Default="12">
	<cfset var q_kwcat = QUERYNew('')>
	
	<cfset keywords = replace(arguments.keyw,' ','%','all')>
	<cfset arguments.keyw = keywords>
	
	<cfif len(arguments.category)>
		<cfquery name="q_getCats" datasource="#application.dsn#">
			select distinct sub_category from ftp_category
			where category = '#arguments.category#'
		</cfquery>
	</cfif>
	
	<cfquery name="q_kwcat" datasource="#application.dsn#">
			select * from (
			SELECT t.`record_id` , t.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.titlelong as title, t.type,
			CASE
			    WHEN REPLACE(upper(t.titlelong),'''','') like upper('%#left(arguments.keyw,30)#%')  THEN 1
			    else 2
			  END as titlefound,
		   CASE
			    WHEN upper(t.description) like upper('%#arguments.keyw#%')  THEN 1
			    else 2
			  END as descfound,
		    CASE
			    WHEN upper(t.category) like upper('%#arguments.keyw#%')  THEN 1
			    else 2
			  END as catfound
			FROM ftb_trackers_pid t left join `ftb_movers` m on t.pid = m.pid
			WHERE (m.pid is null or (m.track_count) = 1) and
			(
						 REPLACE(upper(t.titlelong),'''','') like upper('%#left(arguments.keyw,30)#%') 
						 or
						 upper(t.description) like upper('%#arguments.keyw#%')
						  or
						 upper(t.category) like upper('%#arguments.keyw#%')
						 or
						 upper(t.category) like upper('%#arguments.keyw#%') 
						 or
						 upper(t.pid) like upper('%#arguments.keyw#%') 
						 <cfif arguments.keyw eq 'All%Drops'>
							or 1=1
						</cfif>
			 )
			and t.active = 1 
			and t.available = 1
			<cfif (isdefined('session.rangeFrom') and session.rangeFrom gte -100) and (isdefined('session.rangeTo') and session.rangeTo lte 100)>
				and m.`variance` >= #session.rangeFrom# and m.`variance` <= #session.rangeTo# 
			</cfif>
			
			<cfif isdefined('session.saveme') and session.saveme gt 0>
				<cfif session.saveme eq 100>
					and m.difference >= -100 and m.difference < 0
				</cfif>
				<cfif session.saveme eq 500>
					and m.difference >= -500 and m.difference < -100
				</cfif>
				<cfif session.saveme eq 1000>
					and m.difference >= -1000 and m.difference < -500
				</cfif>
				<cfif session.saveme eq 1001>
					and m.difference < -1000
				</cfif>
			</cfif>
			
			<cfif (isdefined('session.prangeFrom') and session.prangeFrom gte 0) and (isdefined('session.prangeTo') and session.prangeTo lte 25000)>
				and t.last_price >= #session.prangeFrom# <cfif session.prangeTo neq 25000>and t.last_price <= #session.prangeTo# </cfif>
			</cfif>
			) fnl
			where image != '/fkaz/images/noimage.png'
			<cfif structkeyexists(session,"sort") and isstruct(session.sort)>
				order by  #StructKeyArray(session.sort)[1]# #session.sort[StructKeyArray(session.sort)[1]]#
			<cfelse>
				<cfif arguments.keyw eq 'All%Drops'>
					order by variance
				<cfelse>
					order by catfound,titlefound,catfound, descfound
				</cfif>
			</cfif>
			limit #(arguments.page-1)*arguments.lot#,#arguments.lot#
			<!--- select * from (
			SELECT t.`record_id` , t.`pid` , 0 as variance ,0 as track_count , 0 as difference, t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			WHERE m.pid != t.pid
			and
			<cfif len(arguments.category) and q_getCats.recordcount>
			t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">)
			and
			</cfif>
			(
			<cfprocessingdirective suppressWhiteSpace = "true">
			(
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(t.title) like upper('%#litem#%') and
				</cfif>
			</cfloop>
			1=1
			) or (
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(t.description) like upper('%#litem#%') and 
				</cfif>
			</cfloop>
			 1=1)
			 </cfprocessingdirective>
			 )
			and t.active = 1 
			
			union
			
			SELECT t.`record_id` , t.`pid` , 0 as variance ,0 as track_count , 0 as difference, t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			WHERE m.pid != t.pid
			and m.`variance` > -50 and
			<cfif len(arguments.category) and q_getCats.recordcount>
			t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">)
			and
			</cfif>
			 (
			<cfprocessingdirective suppressWhiteSpace = "true">
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gte 3 and not isgeneric(litem)>
					 upper(t.title) like upper('%#litem#%') or  upper(t.description) like upper('%#litem#%') or
				</cfif>
			</cfloop>
			 </cfprocessingdirective>
			  1=0)
			and t.active = 1 
			
			union
			
			SELECT t.`record_id` , t.`pid` , 0 as variance ,0 as track_count , 0 as difference, t.last_price, t.image, t.last_tracked, t.link, t.title, t.type
			FROM  `ftb_movers` m, ftb_trackers_pid t
			WHERE m.pid != t.pid
			and m.`variance` > -50 and
			<cfif len(arguments.category) and q_getCats.recordcount>
			t.category in (<cfqueryPARAM value = "#valueList(q_getCats.sub_category)#" CFSQLType="cf_sql_char" list="true">) and
			</cfif>
			 (
			<cfprocessingdirective suppressWhiteSpace = "true">
			<cfloop list="#arguments.keyw#" index="litem">
				<cfif len(litem) gt 3 and not isgeneric(litem)>
					 upper(t.title) like upper('%#litem#%') or  upper(t.description) like upper('%#litem#%') or
				</cfif>
			</cfloop>
			</cfprocessingdirective>
			 1=0)
			and active = 1 
			
			) fnl
			where image != '/fkaz/images/noimage.png'
			order by variance asc
			limit #(arguments.page-1)*arguments.lot#,#arguments.lot# --->
		</cfquery>
	<cfreturn q_kwcat>
</cffunction>

<cffunction name="getCategories" hint="return top trends">
	<cfset var q_getMovers = QUERYNew('')>
	
	<cfquery name="q_getMovers" datasource="#application.dsn#">
		SELECT distinct category FROM `ftp_category`
	</cfquery>
	
	<cfreturn q_getMovers>
</cffunction>

<cffunction name="getPriceHistory" hint="return price info for pid" access="remote" returnformat="JSON">
	<cfargument name="pid" required="true" type="string">
	<cfset var qgetPriceHistory = querynew('')>
	
	<cfquery name="getMinDate" datasource="#application.dsn#">
		SELECT YEAR(min(record_ts)) as min_yr, MONTH(min(record_ts)) as min_mth, DAY(min(record_ts)) as min_dt FROM `ftb_product_tracker` where pid = '#arguments.pid#'
		and record_ts > date_add(curdate(),INTERVAL -1 MONTH)
	</cfquery>
	
	<cfquery name="getData" datasource="#application.dsn#">
		select pid, price,  MONTH((record_ts)) month,
		YEAR(record_ts) year,
		DAY(record_ts) day,
		HOUR(record_ts) hour,
		minute(record_ts) minute,
		second(record_ts) second,DATE_FORMAT(record_ts,'%c/%e/%y') as record_ts,record_id FROM `ftb_product_tracker` where pid = '#arguments.pid#'
		and record_ts > date_add(curdate(),INTERVAL -1 MONTH)
		order by record_ts desc
	</cfquery>
	
	<cfquery name="getLatestMax" dbtype="query">
		select max(record_id) as record_id from getData
	</cfquery>
	<cfquery name="getLatest" dbtype="query">
		select price from getData where record_id = #getLatestMax.record_id#
	</cfquery>
	
	<cfset latest_price = getLatest.price>
	
	<cfset alldays = arraynew(1)>
	<cfloop from="1" to="30" index="idx">
		<cfset alldays[idx] = dateAdd("d",idx*-1+1,now())>
		<cfquery name="getdatedata" dbtype="query">
			select price from getData where record_ts = '#dateformat(alldays[idx],"short")#'
			order by record_id desc
		</cfquery>
		<cfif getdatedata.recordcount eq 0>
			
			<cfset d.mth=dateformat(alldays[idx],"m")>
			<cfset d.yr=dateformat(alldays[idx],"yyyy")>
			<cfset d.dt=dateformat(alldays[idx],"dd")>
			
			<cfif "#d.yr##d.mth##d.dt#" gte "#getMinDate.min_yr##getMinDate.min_mth##getMinDate.min_dt#">
				<cfset temp = queryAddRow(getData,1)>
				<cfset querysetCell(getdata,"price",latest_price,temp)>
				<cfset querysetCell(getdata,"pid",arguments.pid,temp)>
				<cfset querysetCell(getdata,"month",d.mth,temp)>
				<cfset querysetCell(getdata,"year",d.yr,temp)>
				<cfset querysetCell(getdata,"day",d.dt,temp)>
				<cfset querysetCell(getdata,"hour",0,temp)>
				<cfset querysetCell(getdata,"minute",0,temp)>
				<cfset querysetCell(getdata,"second",0,temp)>
			</cfif>
			
		<cfelse>
			<cfset latest_price = getdatedata.price>
		</cfif>
	</cfloop>
	
	<cfquery name="qgetPriceHistory" dbtype="query">
		select * from getdata order by year desc, month desc, day desc
	</cfquery>
	
	<!--- <cfquery name="qgetPriceHistory" datasource="#application.dsn#">
		SELECT '#arguments.pid#' as pid,
		(
				select price from ftb_product_tracker where date_format(date(record_ts),'%d-%m-%Y') = date_format(date(selected_date),'%d-%m-%Y')
				and pid = '#arguments.pid#'
				order by record_ts desc
				limit 0,1
		) as price,
		MONTH((selected_date)) month,
		YEAR(selected_date) year,
		DAY(selected_date) day,
		HOUR(selected_date) hour,
		minute(selected_date) minute,
		second(selected_date) second
		FROM (
		
		SELECT ADDDATE(  '1970-01-01', t4.i *10000 + t3.i *1000 + t2.i *100 + t1.i *10 + t0.i ) selected_date
		FROM (
		
			SELECT 0 i UNION SELECT 1  UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
		)t0, (
		
			SELECT 0 i UNION SELECT 1  UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
		)t1, (
		
			SELECT 0 i UNION SELECT 1  UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
		)t2, (
		
			SELECT 0 i UNION SELECT 1  UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
		)t3, (
		
			SELECT 0 i UNION SELECT 1  UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
		)t4
		)v
		WHERE selected_date
		BETWEEN  (SELECT 
					case when date_add(min(record_ts),INTERVAL -1 MONTH) > date_add(now(),INTERVAL -1 MONTH)
					then date_add(min(record_ts),INTERVAL -1 MONTH) 
					else date_add(now(),INTERVAL -1 MONTH) end as dt FROM `ftb_product_tracker` where pid = '#arguments.pid#')
		AND  CURRENT_DATE
	</cfquery> --->

	<cfreturn qgetPriceHistory>
</cffunction>

<cffunction name="addUsersMovers" hint="Add into users searched product in tracking system">
	<cfargument name="pdetails" required="true" type="struct">
	
	<cftry>
		<cfquery name="q_addUsersMovers" datasource="#application.dsn#">
			INSERT INTO `ftb_trackers_pid`
			(`pid`, `type`, `link`, `image`, `last_price`, `title`, `description`, `category`, `batch`) 
			VALUES ('#arguments.pdetails.pid#',#arguments.pdetails.type#,'#arguments.pdetails.link#',
			'#arguments.pdetails.IMAGE#',#arguments.pdetails.price#,'#arguments.pdetails.title#','#arguments.pdetails.DESCRIPTION#','',20)
		</cfquery>
	<cfcatch>
		<cftry>
			<cfquery name="q_addUsersMovers" datasource="#application.dsn#">
				update `ftb_trackers_pid` set last_price = #arguments.pdetails.price#, last_tracked = CURRENT_TIMESTAMP
				where pid = '#arguments.pdetails.pid#'
			</cfquery>
		<cfcatch>
		</cfcatch>
		</cftry>
	</cfcatch>
	</cftry>
	
	<cftry>
		<cfquery name="q_addUsersMovers" datasource="#application.dsn#">
			INSERT INTO `ftb_product_tracker`
			(`pid`, `price`, `track_group_sk`) 
			VALUES ('#arguments.pdetails.pid#',#arguments.pdetails.price#,'user')
		</cfquery>
		<cfquery name="addindb" datasource="#application.dsn#">
			INSERT INTO `ftb_product_tracker`(`pid`, `price`,`track_group_sk`) 
			VALUES ('#arguments.pdetails.pid#',#arguments.pdetails.price#,'USER_SEARCHED')
		</cfquery>
	<cfcatch>
	</cfcatch>
	</cftry>
	
	
</cffunction>

<cffunction name="adduser" hint="Add into users searched product in tracking system" returnformat="JSON" access="remote">
	<cfargument name="email" required="true" type="string">
	<cfargument name="pid" required="true" type="string">
	<cfargument name="dropto" required="true" type="string">
	<cfset var user_sk = createuuID()>
	<cfset var ret = structnew()>
	
	<cfset ret.user_sk = user_sk>
	<cfset ret.isexisting = 0>
	<cfset ret.isaccountsetup = 0>
	<cfset ret.error = 0>
	
	<cftry>
	
		<cfquery name="q_check" datasource="#application.dsn#">
			select email, password,record_id,user_sk from `ftb_users`
			where upper(email) = upper('#arguments.email#')
		</cfquery>
		
		<cfif q_check.recordcount>
			<cfset ret.user_sk = q_check.user_sk>
			<cfset ret.isexisting = 1>
			<cfif len(q_check.password)>
				<cfset ret.isaccountsetup = 1>
			</cfif>
			
		<cfelse>
		
			<cfquery name="q_adduser" datasource="#application.dsn#">
				INSERT INTO `ftb_users`(`email`, `user_sk` ) VALUES ('#arguments.email#','#ret.user_sk#')
			</cfquery>
		
		</cfif>
		
		<cfquery name="q_getprice" datasource="#application.dsn#">
			select last_price from ftb_trackers_pid where pid = '#arguments.pid#'
		</cfquery>
		
		<cfif q_getprice.recordcount>
			<cfset price = q_getprice.last_price>
			<cfset range = {from:0,to:0}>
			
			<cfswitch expression="#arguments.dropto#">
				<cfcase value="1">
					<cfset range = {from:#price-(price*0.01)#,to:#price-(price*0.05)#}>
				</cfcase>
				<cfcase value="2">
					<cfset range = {from:#price-(price*0.06)#,to:#price-(price*0.1)#}>
				</cfcase>
				<cfcase value="3">
					<cfset range = {from:#price-(price*0.11)#,to:#price-(price*0.2)#}>
				</cfcase>
				<cfcase value="4">
					<cfset range = {from:#price-(price*0.21)#,to:#price-(price*0.5)#}>
				</cfcase>
				<cfcase value="5">
					<cfset range = {from:#price-(price*0.51)#,to:0}>
				</cfcase>
			</cfswitch>
			
			<cfif range.from eq price>
				<cfset range.from = price-1>
			</cfif>
			
			<cfif range.to eq price>
				<cfset range.to = price-2>
			</cfif>
			
			<cfquery name="q_gettrack" datasource="#application.dsn#">
				select user_sk from `ftb_alerts`
				where user_sk= '#ret.user_sk#' and pid = '#arguments.pid#' 
			</cfquery>
			
			<cfif q_gettrack.recordcount>
				<cfquery name="q_trackalert" datasource="#application.dsn#">
					update `ftb_alerts`
					set price = #price#, rangefrom=#range.from#,rangeto=#range.to#, rule=#arguments.dropto#
					where user_sk= '#ret.user_sk#' and pid = '#arguments.pid#' 
				</cfquery>
			<cfelse>
				<cfquery name="q_trackalert" datasource="#application.dsn#">
					INSERT INTO `ftb_alerts`( `user_sk`, `pid`, `price`, `rangefrom`, `rangeto`,`rule`) 
					VALUES ('#ret.user_sk#','#arguments.pid#',#price#,#range.from#,#range.to#,#arguments.dropto#)
				</cfquery>
			</cfif>
		<cfelse>
			<cfif len(arguments.pid) eq 10>
				<cfset type = 1>
			<cfelse>
				<cfset type = 0>
			</cfif>
			<cfquery name="q_trackqueue" datasource="#application.dsn#">
				INSERT INTO `ftp_users_trackers_pid`
				( `pid`,  `type`,  `user_sk`,`rule`) 
				VALUES ('#arguments.pid#',#type#,'#ret.user_sk#',#arguments.dropto#)
			</cfquery>
		</cfif>
	<cfcatch>
		<cfset ret.error = 1>
		<cfdump var="#cfcatch#">
		<cfabort>

	</cfcatch>
	</cftry>
	
	<cfreturn ret>
		
</cffunction>

<cffunction name="subscribe" hint="Add into users searched product in tracking system" returnformat="JSON" access="remote">
	<cfargument name="email" required="true" type="string">
	<cfset var user_sk = createuuID()>
	<cfset var ret = structnew()>
	
	<cfset ret.user_sk = user_sk>
	<cfset ret.isexisting = 0>
	<cfset ret.isaccountsetup = 0>
	<cfset ret.error = 0>
	
	<cftry>
	
		<cfquery name="q_check" datasource="#application.dsn#">
			select email, password,record_id,user_sk from `ftb_users`
			where upper(email) = upper('#arguments.email#')
		</cfquery>
		
		<cfif q_check.recordcount>
			<cfset ret.user_sk = q_check.user_sk>
			<cfset ret.isexisting = 1>
			<cfif len(q_check.password)>
				<cfset ret.isaccountsetup = 1>
			</cfif>
		<cfelse>
			<cfquery name="q_adduser" datasource="#application.dsn#">
				INSERT INTO `ftb_users`(`email`, `user_sk`,`password` ) VALUES ('#arguments.email#','#ret.user_sk#','subscribe')
			</cfquery>
		</cfif>
		
	<cfcatch>
		<cfset ret.error = 1>
	</cfcatch>
	</cftry>
	<cfset session.showsub = 0>
	<cfreturn ret>
		
</cffunction>

<cffunction name="setupAccount" hint="Setup account" returnformat="JSON" access="remote">
	<cfargument name="user_sk" required="true" type="string">
	<cfargument name="password" required="true" type="string">
	
	<cfset var ret = structnew()>
	<cfset ret.error = 0>
	<cftry>
	
		<cfquery name="q_setup" datasource="#application.dsn#">
			update `ftb_users` set password = '#arguments.password#', passhash = '#hash(arguments.password)#'
			where user_sk = '#arguments.user_sk#'
		</cfquery>
		
	<cfcatch>
		<cfset ret.error = 1>
	</cfcatch>
	</cftry>
	
	<cfreturn ret>
		
</cffunction>

<cffunction name="addIssue" hint="" returnformat="JSON" access="remote">
	<cfargument name="user_sk" required="true" type="string">
	<cfargument name="issue" required="true" type="string">
	
	<cfset var ret = structnew()>
	<cfset ret.error = 0>
	<cftry>
	
		<cfquery name="q_addIssue" datasource="#application.dsn#">
			insert into `ftb_issuetracker` set user_sk = '#arguments.user_sk#', issue = '#arguments.issue#'
		</cfquery>
		
	<cfcatch>
		<cfset ret.error = 1>
	</cfcatch>
	</cftry>
	
	<cfreturn ret>
		
</cffunction>

<cffunction name="updateAlert" access="remote">
	<cfargument name="email" required="true" type="string">
	<cfargument name="pid" required="true" type="string">
	<cfargument name="rule" required="true" type="string">
	<cfargument name="active" required="true" type="string">
	<cfargument name="record_id" required="true" type="string">
	
	<cfset ret = adduser(email,pid,rule)>
	<cftry>
		<cfquery name="q_addUsersMovers" datasource="#application.dsn#">
			update `ftb_alerts` set active=#arguments.active#
			where record_id = #arguments.record_id#
		</cfquery>
	<cfcatch>
	</cfcatch>
	</cftry>
	
	
</cffunction>

<cffunction name="sendPassword" access="remote" returnformat="JSON">
	<cfargument name="email" required="true" type="string">
	
	<cfset var ret = structnew()>
	
	<cftry>
		<cfquery name="q_check" datasource="#application.dsn#">
			select email, password,record_id,user_sk from `ftb_users`
			where upper(email) = upper('#arguments.email#')
		</cfquery>
			
		<cfif q_check.recordcount>
			<cfset ret.user_sk = q_check.user_sk>
			
		<cfelse>
			<cfset ret.user_sk = createuUID()>
			<cfquery name="q_adduser" datasource="#application.dsn#">
				INSERT INTO `ftb_users`(`email`, `user_sk` ) VALUES ('#arguments.email#','#ret.user_sk#')
			</cfquery>
		
		</cfif>
		
		<cfmail from="hello@quirkycrackers.com" to="#arguments.email#" type="html" failto="tushars2001@gmail.com" subject="FindTrackBuy.com. Password Reset">
			<cfoutput>
				<html>
					<head>
					</head>
					<body>
						<div>Dear User,</div>
						<br><br>
						<div><a href="http://www.findtrackbuy.com/login/reset/?user_sk=#ret.user_sk#">Reset Password</a></div>
						<div>or copy paste below link:</div>
						<div>http://www.findtrackbuy.com/login/reset/?user_sk=#ret.user_sk#</div>
						<br><br>
						<div>Best Regards,</div>
						<div>FindTrackBuy Team</div>
					</body>
				</html>
			</cfoutput>
		</cfmail>
		<cfset ret.mail=1>
	<cfcatch>
		<cfdump var="#cfcatch#">
		<cfabort>

	</cfcatch>
	</cftry>
	
	<cfreturn ret>
</cffunction>

<cffunction name="getUserBySk">
	<cfargument name="user_sk" required="true">
	<cfset var ret = querynew('')>
	
	<cfquery name="ret" datasource="#application.dsn#">
			select email, record_id,user_sk from `ftb_users`
			where upper(user_sk) = upper('#arguments.user_sk#')
	</cfquery>
	
	<cfreturn ret/>
	
</cffunction>

<cffunction name="searchLog">
	<cfargument name="searchterm" required="true">
	<cfargument name="searchtype" required="true">
	<cfset var ret = querynew('')>
	
	<cftry>
		<cfquery name="ret" datasource="#application.dsn#">
				INSERT INTO `ftb_search_log`(`searchterm`, `searchtype`) 
				VALUES ('#arguments.searchterm#',#arguments.searchtype#)
		</cfquery>
	<cfcatch>
	</cfcatch>
	</cftry>
	
	
	
</cffunction>

<cffunction name="setSince" access="remote" returnformat="JSON">
	<cfargument name="days" required="true" type="string">
	
	<cfset session.dropsince = arguments.days>
	<cfreturn session.dropsince>
</cffunction>

<cffunction name="setRange" access="remote" returnformat="JSON">
	<cfargument name="from" required="true" type="string">
	<cfargument name="vto" required="true" type="string">
	
	<cfset session.rangeFrom = arguments.from>
	<cfset session.rangeTo = arguments.vto>
	
	<cfreturn session>
</cffunction>

<cffunction name="setPriceRange" access="remote" returnformat="JSON">
	<cfargument name="from" required="true" type="string">
	<cfargument name="vto" required="true" type="string">
	
	<cfset session.prangeFrom = arguments.from>
	<cfset session.prangeTo = arguments.vto>
	
	<cfreturn session>
</cffunction>

<cffunction name="setfluctuate" access="remote" returnformat="JSON">
	<cfparam name="session.fluctuate" default="0">
	
	<cfif session.fluctuate>
		<cfset session.fluctuate = 0>
	<cfelse>	
		<cfset session.fluctuate = 1>
	</cfif>
	
	<cfreturn session>
</cffunction>

<cffunction name="setReset" access="remote" returnformat="JSON">
	<cfset structDelete(session,"fluctuate")>	
	<cfset structDelete(session,"prangeFrom")>
	<cfset structDelete(session,"prangeTo")>
	<cfset structDelete(session,"rangeTo")>	
	<cfset structDelete(session,"rangeFrom")>
	<cfset structDelete(session,"dropsince")>
	<cfset structDelete(session,"saveme")>
	<cfset structDelete(session,"usermsg")>
	<cfset structDelete(session,"sort")>
	
	<cfset session.usermsg = ''>
	<cfset session.dropsince = 1>
	
	<cfreturn session>
</cffunction>

<cffunction name="clearSession" access="remote" returnformat="JSON">
	<cfset structDelete(session,"fluctuate")>	
	<cfset structDelete(session,"prangeFrom")>
	<cfset structDelete(session,"prangeTo")>
	<cfset structDelete(session,"rangeTo")>	
	<cfset structDelete(session,"rangeFrom")>
	<cfset structDelete(session,"dropsince")>
	<cfset structDelete(session,"saveme")>
	<cfset structDelete(session,"usermsg")>
	<cfset structDelete(session,"mobile")>
	<cfset structDelete(session,"force")>
	<cfset session.dropsince = 1>
	
	<cfreturn session>
</cffunction>

<cffunction name="setKeyword" access="remote" returnformat="JSON">
	<cfargument name="pid" required="true" type="string">
	<cfargument name="keyword" required="true" type="string">
	
	
</cffunction>

<cffunction name="recal">
	<cfargument name="pid" required="true" type="string">
	
	<cfquery name="getRecord" datasource="#application.dsn#">
		SELECT * FROM  `ftb_product_tracker` 
				where pid = '#arguments.pid#'
		order by record_ts desc
	</cfquery>
	
	<cfset base = getRecord.price[1]>
	<cfset was_at_on = dateAdd('d',-1,getRecord.record_ts[1])>
	<cfset minval = base>
	
	<cfloop query="getRecord">
		<cfif getRecord.price neq base>
			<cfset minval = getRecord.price>
			<cfbreak>
		</cfif>
	</cfloop>
	
	<!--- <cfset minval = ListFirst(ListSort(ListRest(valueList(getRecord.price)),"numeric"))>
	<cfif not len(minval)>
		<cfset minval = base>
	</cfif> --->
	<cfset difference = base-minval>
	<cfset track_count = getRecord.recordcount>
	<cfset variance = DecimalFormat(((difference)/minval)*100)>
	<cfset variance = replace(variance,',','','all')>
	<cfset minval = DecimalFormat(minval)>
	<cfset minval = replace(minval,',','','all')>
	<cfset pid = arguments.pid>
	<cftransaction>
		<cfquery name="getBatchData" datasource="#application.dsn#">
			delete from `ftb_movers` where `pid` ='#pid#'
		</cfquery>
		<cfquery name="getBatchData" datasource="#application.dsn#">
			INSERT INTO `ftb_movers`(`pid`, `variance`, `track_count`, `difference`,`was_at`,was_at_on) 
			values ('#pid#',#variance#,#track_count#,#difference#,#minval#,'#dateFormat(was_at_on,"yyyy-mm-dd")#')
		</cfquery>
	</cftransaction>	
	
</cffunction>

<cffunction name="addbrowse" access="remote" returnformat="plain">
	<cfargument name="pids" required="true" type="string">
	<cfset var ret = structnew()>
	<cfif isdefined("arguments.pids") and len(arguments.pids)>
		<cfset ret.inputs = listlen(arguments.pids)>
		<cfif len(listFirst(arguments.pids)) eq 10>
			<cfset type = 1>
		<cfelse>
			<cfset type = 0>
		</cfif>
		<cfset ins = 0>
		<cfloop list="#arguments.pids#" index="pid">
			<cftry>
				<cfquery name="addindb" datasource="#application.dsn#">
					INSERT INTO `ftb_browse_pid`(`pid`, `type`) 
					VALUES ('#pid#',#type#)
				</cfquery>
				<cfset ins = ins+1>
			<cfcatch></cfcatch></cftry>
		</cfloop>
		
			<cftry>
				<cfquery name="addindb" datasource="#application.dsn#">
					INSERT INTO `ftb_pid_campaign`(`pid`, `campaign`) VALUES ('#pid#','DIWALI')
				</cfquery>
			<cfcatch></cfcatch></cftry>
		
		
		
		<cfquery name="addindb" datasource="#application.dsn#">
				SELECT bp.pid FROM `ftb_browse_pid` bp, ftb_trackers_pid tp where bp.pid = tp.pid
		</cfquery>
		
		<cfquery name="del" datasource="#application.dsn#" result="res">
				delete from `ftb_browse_pid`
				where pid in (<cfqueryPARAM value = "#valueList(addindb.pid)#" CFSQLType="cf_sql_char" list="true">)
		</cfquery>
		<cfset ret.ins = ins>
		<cfset ret.del = res.recordcount>
	</cfif>
	<cfreturn "myfun(" & serializeJSON(ret) & "); function myfun(res){alert('done."&replace(serializeJSON(ret),'"','','all')&"')};">
</cffunction>

<cffunction name="setSaveme" access="remote" returnformat="JSON">
	<cfargument name="rs" required="true" type="string">
	
	<cfset session.saveme = arguments.rs>
	<cfreturn session.saveme>
</cffunction>

<cffunction name="setSortby" access="remote" returnformat="JSON">
	<cfargument name="what" required="true" type="string">
	<cfargument name="order" required="false" type="string" default="desc">
	
	<cfif structkeyexists(session,"sort") and structkeyexists(session.sort,"#arguments.what#")>
		<cfif session.sort['#arguments.what#'] eq 'desc'>
			<cfset session.sort['#arguments.what#'] = 'asc'>
		<cfelse>
			<cfset session.sort['#arguments.what#'] = 'desc'>
		</cfif>
	<cfelse>
		<cfset session.sort['#arguments.what#'] = '#arguments.order#'>
	</cfif>
	
	<cfloop collection=#session.sort# item="key">
		<cfif key neq arguments.what>
			<cfset structdelete(session.sort,key)>
		</cfif>
	</cfloop>
	
	<cfreturn session.sort>
</cffunction>

<cffunction name="setMeter" access="remote" returnformat="JSON">
	<cfargument name="arg" required="true" type="string">
	<cfargument name="pricerange" required="false">
	<cfargument name="since" required="false">
	<cfargument name="saveme" required="false">
	<cfset argj = deserializeJSON(replace(arg,'\','','all'))>

	<cfset session.rangeFrom = argj.droprange.from>
	<cfset session.rangeTo = argj.droprange.to>
	<cfset session.prangeFrom = argj.pricerange.from>
	<cfset session.prangeTo = argj.pricerange.to>
	<cfset session.dropsince = argj.since>
	<cfset session.saveme = argj.saveme>
	
	<cfreturn arguments>
</cffunction>

<cffunction name="setSessionVar" access="remote" returnformat="JSON">
	<cfargument name="what" required="true" type="string">
	<cfargument name="value" required="true">

	<cfset session['#arguments.what#'] = arguments.value>
	
	<cfreturn session>
</cffunction>

<cffunction name="setClientVar" access="remote" returnformat="JSON">
	<cfargument name="what" required="true" type="string">
	<cfargument name="value" required="true">

	<cfset client['#arguments.what#'] = arguments.value>
	
	<cfreturn client>
</cffunction>

<cffunction name="setproductbrand" access="remote" returnformat="JSON">
	<cfargument name="pid" required="true" type="string">
	<cfargument name="brand" required="true">
	<cfargument name="product" required="true">
	<cfargument name="model" required="true">
	<cfargument name="keywords" required="true">

	<cfquery name="updatetitle" datasource="#application.dsn#">
		update `ftb_trackers_pid` set brand = '#arguments.brand#', 
		product='#arguments.product#', model = '#arguments.model#', brandtracked=1,keywords="#arguments.keywords#"
		where pid = '#arguments.pid#'
	</cfquery>
	
	<cfreturn arguments>
</cffunction>



<cffunction name="maintain" >
	<!--- <cfquery name="samedaydups" datasource="#application.dsn#">
	delete from `ftb_product_tracker` where record_id in (
	select imp.record_id from (
	SELECT  min(record_id) as record_id FROM `ftb_product_tracker` 
	group by pid, DATE_FORMAT(record_ts,'%m-%d-%Y')
	having count(pid) > 1 ) imp
	  
	)
	</cfquery> --->
	
	<cfquery name="initrec" datasource="#application.dsn#">
		insert into ftb_product_tracker(pid,price,track_group_sk,record_ts) 
		select pid, last_price,'INIT',last_tracked from ftb_trackers_pid t where t.pid not in (
		    select distinct pid from ftb_product_tracker
		)
	</cfquery>
	
	<cfquery name="perdayadded" datasource="#application.dsn#">
		SELECT DATE_FORMAT(record_ts,'%m-%d-%Y'), count(DATE_FORMAT(record_ts,'%m-%d-%Y')) FROM `ftb_product_tracker` 
		where track_group_sk in ('INIT','SYSTEM','user','USER_SEARCHED')
		group by DATE_FORMAT(record_ts,'%m-%d-%Y')
		ORDER BY DATE_FORMAT(record_ts,'%m-%d-%Y')  DESC
	</cfquery>
	
	<cfquery name="batchfk" datasource="#application.dsn#">
		update ftb_trackers_pid set batch=20 where batch is null and type=0
	</cfquery>
	
	
</cffunction>

<cffunction name="trending">
	<cfargument name="page" required="false" default="1">
	<cfargument name="LOT" required="FAlse" Default="12">
	<cfquery name="trends" datasource="#application.dsn#">
		SELECT trend 
			FROM  `ftb_trends` 
	</cfquery>
	<cfquery name="q_getMovers" datasource="#application.dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
		select * from (
		select * from (
		SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.titlelong as title, t.type, FLOOR(RAND() * 50000) as sortorder
			FROM  `ftb_movers` m, ftb_trackers_pid t
			WHERE m.pid = t.pid
			and m.`variance` >= -75
			and m.`variance` < -1
			and t.available =1
			and (
				 (
				<cfloop query="trends">
					t.titlelong like '%#trends.trend#%' or
				</cfloop>
				1=0
				)
				or (
				<cfloop query="trends">
					t.description like '%#trends.trend#%' or
				</cfloop>
				1=0
				)
				or (
				<cfloop query="trends">
					t.category like '%#trends.trend#%' or
				</cfloop>
				1=0
				)
			)
			and (
				(m.`variance` >= -5 and m.`variance` < 0 and m.`difference` < -350)
				or
				(m.`variance` >= -20 and m.`variance` < -5 and m.`difference` < -100)
				or
				(m.`variance` >= -50 and m.`variance` < -20 and m.`difference` < -500)
				or
				(m.`variance` < -50 and m.`difference` < -1000)
			)
			
			
		
		union
		select * from (
		SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.titlelong as title, t.type, FLOOR(RAND() * 50000) as sortorder
			FROM  `ftb_movers` m, ftb_trackers_pid t, ftb_alerts a
			WHERE m.pid = t.pid
			and a.pid = m.pid
			and m.`variance` >= -75
			and m.`variance` < -1
		) o2
		) o
		where 1=1
		 <cfif (isdefined('session.rangeFrom') and session.rangeFrom gte -100) and (isdefined('session.rangeTo') and session.rangeTo lte 100)>
				and `variance` >= #session.rangeFrom# and `variance` <= #session.rangeTo# 
			</cfif>
			<cfif (isdefined('session.prangeFrom') and session.prangeFrom gte 0) and (isdefined('session.prangeTo') and session.prangeTo lte 25000)>
				and last_price >= #session.prangeFrom# <cfif session.prangeTo neq 25000>and last_price <= #session.prangeTo# </cfif>
			</cfif>
			<cfif isdefined('session.saveme') and session.saveme gt 0>
				<cfif session.saveme eq 100>
					and difference >= -100 and difference < 0
				</cfif>
				<cfif session.saveme eq 500>
					and difference >= -500 and difference < -100
				</cfif>
				<cfif session.saveme eq 1000>
					and difference >= -1000 and difference < -500
				</cfif>
				<cfif session.saveme eq 1001>
					and difference < -1000
				</cfif>
			</cfif>
			
			<cfif structkeyexists(session,"sort") and isstruct(session.sort)>
				order by  #StructKeyArray(session.sort)[1]# #session.sort[StructKeyArray(session.sort)[1]]#
			<cfelse>
				order by sortorder
			</cfif>
		limit #(arguments.page-1)*arguments.lot#,#arguments.lot#
		) fin
		<!--- limit #(arguments.page-1)*arguments.lot#,#arguments.lot# --->
	</cfquery>
	
	<cfreturn q_getMovers/>
	
</cffunction>

<cffunction name="getProductById" hint="return 1 prod">
	<cfargument name="pid" required="true">
	<cfset var q_kwcat = QUERYNew('')>
	
	
	<cfquery name="q_kwcat" datasource="#application.dsn#">
		select * from (
			SELECT m.`record_id` , m.`pid` , m.`variance` , m.`track_count` , m.`difference` , t.last_price, t.image, t.last_tracked, t.link, t.titlelong as title, t.type, t.description
			FROM  `ftb_movers` m, ftb_trackers_pid t
			WHERE m.pid = t.pid
			and t.available = 1
			and m.`variance` < 350 
			and m.`variance` > -80 
			) fnl
			where image != '/fkaz/images/noimage.png'
			and pid = '#arguments.pid#'
		</cfquery>
	<cfreturn q_kwcat>
</cffunction>

</cfcomponent>