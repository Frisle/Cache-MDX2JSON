Include MDX2JSON.MDX2JSON

/// Class with methods related to DeepSee Dashboard and Widget processing.
Class MDX2JSON.DashboardFilters Extends MDX2JSON.Dashboard
{

/// Converts %DeepSee.Dashboard.Definition widgets into %Library.DynamicObject.
ClassMethod WidgetsToProxyObject(Dashboard As %DeepSee.Dashboard.Definition, Output Widgetlist As %Library.DynamicObject) As %Status
{
	#Dim widget As %DeepSee.Dashboard.Widget
	set Widgetlist = $$$NewDynObj
	set Widgetlist.widgets = $$$NewDynObjList
	set Widgetlist.filters = $$$NewDynObjList
	set Widgetlist.displayInfo = ..GetDashboardDisplayInfo(Dashboard)
	set Widgetlist.info = ..GetDashboardInfo(Dashboard)

	set st = $$$OK
	try {
		for i=1:1:Dashboard.widgets.Count() {
			$$$Insert(Widgetlist.widgets,..WidgetToProxyObject(Dashboard.widgets.GetAt(i), ..GetWidgetCube(Dashboard, i)))
			#dim filters As %ListOfObjects
			set filters = ..WidgetFiltersToProxyObject(Dashboard.widgets.GetAt(i), ..GetWidgetCube(Dashboard, i))
			for j=1:1:$$$ListSize(filters) {
				$$$Insert(Widgetlist.filters,$$$ListGet(filters,j))
			}
		}
	} catch ex {
		set st = ex.AsStatus()
		do ex.Log()
	}
	return st
}

/// Converts relevant parts of %DeepSee.Dashboard.Widget object into %Library.DynamicObject.
ClassMethod WidgetFiltersToProxyObject(Widget As %DeepSee.Dashboard.Widget, CubeName As %String) As %Library.DynamicObject [ Internal ]
{
	set obj = $$$NewDynObjList
	for i=1:1:Widget.controls.Count()
	{
		set filter = ..WidgetFilterToProxyObject(Widget, i, CubeName)
		if $IsObject(filter){
			$$$Insert(obj,filter)
		}
	}
	return obj
}

/// Converts %DeepSee.Dashboard.Control object into %ZEN.proxyObject, handles run-time DeepSee variables.
ClassMethod WidgetControlToProxyObject(Widget As %DeepSee.Dashboard.Widget, Number As %Integer, Cube As %String) As %Library.DynamicObject [ Internal ]
{
	// last OR is suppose to show filters variable in dropdown menu in case of applyVariable type filter
	return:((Widget.controls.GetAt(Number).action="applyFilter") || (Widget.controls.GetAt(Number).action="setFilter") || (Widget.controls.GetAt(Number).action="applyVariable")) ""
	return ##class(MDX2JSON.Dashboard).WidgetControlToProxyObject(Widget,Number,Cube)
}

/// Converts %DeepSee.Dashboard.Control object into %Library.DynamicObject, handles run-time DeepSee variables.
ClassMethod WidgetFilterToProxyObject(Widget As %DeepSee.Dashboard.Widget, Number As %Integer, Cube As %String) As %Library.DynamicObject [ Internal ]
{
	// last OR is suppose to show filters variable in dropdown menu in case of applyVariable type filter
	return:'((Widget.controls.GetAt(Number).action="applyFilter") || (Widget.controls.GetAt(Number).action="setFilter") || (Widget.controls.GetAt(Number).action="applyVariable")) ""
	return ##class(MDX2JSON.Dashboard).WidgetControlToProxyObject(Widget,Number,Cube)
}

}
