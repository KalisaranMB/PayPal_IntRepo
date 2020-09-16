({
    helperMethod: function () {

    },

    openAcctTab2: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: '0015B00001A7637QAB', //Smith's Computer Limited
            focus: true
        }).then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function (tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    createCase2: function (accountNumber, component) {
        console.log("so basic ", accountNumber);
        var action = component.get("c.dummyCaseCreation");
        action.setParams(
            {
                acctNo: accountNumber
            }
        );

        action.setCallback(this, function (response) {
            var state = response.getState();

            console.log("dummyCaseCreation response ", response);

            if (state === "SUCCESS") {
                console.log("Success ", response.getReturnValue());
                this.openCase(response.getReturnValue(), component);

            } else {

            }

        })

        $A.enqueueAction(action);

    },


    openCase: function (caseID, component) {
        console.log("caseID is ", caseID)
        var workspaceAPI = component.find("workspace");

        workspaceAPI.openTab({
            recordId: caseID,
            focus: true
        }).then(function (response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function (tabInfo) {
                console.log("The url for this tab is: " + tabInfo.url);
            });
        })
            .catch(function (error) {
                console.log("open tab after case created error ", error);
            });

    },


})