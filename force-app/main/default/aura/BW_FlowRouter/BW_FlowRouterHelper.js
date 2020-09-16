({
	getCurrentFlowName : function(component) {
		const t = this;
        let action = component.get("c.getCurrentFlowName");
        action.setParams({
            caseId : component.get("v.recordId")
        })
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.currentFlowName", response.getReturnValue());
                t.renderFlow(component);
            }
        });
        $A.enqueueAction(action);
	},
    
    renderFlow: function(component) {
        const flow = component.find("flowData");
        const inputVariables = [{
            name: "caseId",
            type: "String",
            value: component.get("v.recordId")
        }];
        flow.startFlow(component.get("v.currentFlowName"), inputVariables);
    }
})