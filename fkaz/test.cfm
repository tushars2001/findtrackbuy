
<cfset obj = createobject("component","cmp")>
<cfset data = obj.ItemLookup('B00B5EQX06')>
<cfset data = obj.ConvertXmlToStruct(data,structnew())>
<cfdump var="#data#">