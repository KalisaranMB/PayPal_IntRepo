({
	doInit : function(component, event, helper) {
        helper.getCurrentFlowName(component);
	},
    
    handleStatusChange: function(component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            helper.getCaseInformation(component);
        }
    }
})