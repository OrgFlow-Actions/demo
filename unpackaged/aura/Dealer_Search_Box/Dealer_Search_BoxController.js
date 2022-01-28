({
	closeQA: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	refreshQA: function (component, event, helper) {
		$A.get('e.force:refreshView').fire();
	}
})