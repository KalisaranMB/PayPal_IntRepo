({ /*
    JWaggoner:
    This was merely to understand the idea of adding a background utility. 
    I may keep using this to try and probe how to reach different objects or figure out how to do things.
    */


    onTabCreated: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function (tabInfo) {
            console.log("tabInfo ", tabInfo);
            tabInfo.forEach((data) => {
                console.log("data.subtabs ", JSON.stringify(data.subtabs, null, "  "));
            })
        });
    },

    openAcctTab1: function (component, event, helper) {
        helper.openAcctTab2(component);
    },

    createCase1: function (component, event, helper) {
        helper.createCase2("2122740026176000000", component);
    },
    /*
        openAcctTab: function (component, event, helper) {
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
    */
    openCaseTab: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: '5005B000007sFv3QAE', //Case 00001012
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

    openCaseAndAcct: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            recordId: '0015B00001A7637QAB', //Smith's Computer Limited
            focus: true
        }).then(function (response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                recordId: '5005B000007sFv3QAE', //Case 00001012
                focus: true
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    openCaseInAcct: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var acctRecord = '0015B00001A7637QAB'; //Smith's Computer Limited
        var targetTabId;

        workspaceAPI.getAllTabInfo().then(function (tabInfo) {
            tabInfo.forEach((data) => {
                //iterate over tabs and find the account we want
                if (acctRecord == data.recordId) {
                    targetTabId = data.tabId;
                    //and then open the case under it
                    workspaceAPI.openSubtab({
                        parentTabId: targetTabId,
                        recordId: '5005B000007sFv3QAE', //Case 00001012
                        focus: true
                    })
                        .catch(function (error) {
                            console.log(error);
                        });
                };
            })
        });
    },

    closeAcctTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var acctRecord = "0015B00001A7637QAB"; //Smith's Computer Limited
        var targetTabId;
        workspaceAPI.getAllTabInfo().then(function (tabInfo) {
            tabInfo.forEach((data) => {
                //iterate over tabs and find the one we want to close based on whatever info given
                if (acctRecord == data.recordId) {
                    targetTabId = data.tabId;
                    //and then close it
                    workspaceAPI.closeTab({ tabId: targetTabId })
                        .catch(function (error) {
                            console.log(error);
                        });
                };
            })
        });
    },

    closeCaseTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var caseRecord = '5005B000007sFv3QAE'; //Case 00001012
        var targetTabId;
        workspaceAPI.getAllTabInfo().then(function (tabInfo) {
            tabInfo.forEach((data) => {
                //iterate over tabs and find the one we want to close based on whatever info given
                if (caseRecord == data.recordId) {
                    targetTabId = data.tabId;
                    //and then close it
                    workspaceAPI.closeTab({ tabId: targetTabId })
                        .catch(function (error) {
                            console.log(error);
                        });
                };
            });
        });
    },

    closeCaseInAcct: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var caseRecord = '5005B000007sFv3QAE'; //Case 00001012
        var targetTabId;
        workspaceAPI.getAllTabInfo().then(function (tabInfo) {
            //go over main tabs
            tabInfo.forEach((tab) => {
                //to go over subTabs
                //console.log("tab ", tab);

                tab.subtabs.forEach((data) => {
                    //to find the subTab to close
                    if (caseRecord == data.recordId) {
                        targetTabId = data.tabId;
                        //and then close it
                        workspaceAPI.closeTab({ tabId: targetTabId })
                            .catch(function (error) {
                                console.log(error);
                            });
                    };
                });

            });
        });
    },




})