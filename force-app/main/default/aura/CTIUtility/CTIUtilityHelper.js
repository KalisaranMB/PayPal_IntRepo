({
    helperMethod : function() {

    },
    startWebsocketConnection : function()  {
        if(this.portsList.length<1){
            //Call the Apex controller to get the list of ports
        }
        try{
        this.ws = new WebSocket(`wss://desktopwss.paypalcorp.com:${this.portsList[this.currentPortNumberIndex]}`)
        }
        catch(e){
            console.log(JSON.stringify(e))
        }
    },
    ws:{},
    currentContext:{
    //InteractionID 
    //CaseID
    },
    onOpen: function(event){
        console.log("PDA Connected Successfully")
        //TODO Now try to Login
    },
    onError : function(error) {
        if(error.reason == 'INVALID_LOGIN'){
            if(this.currentPortNumberIndex < portsList.length){
                //Show reconnecting message in SF
                this.currentPortNumberIndex++
                this.startWebsocketConnection()
            }
            else
            {
                //Show error that unable to connect to PDA
            }
        }
        else{
            //Show Error message that unable to connect to PDA and log the message to FPTI.
        }
    },
    onMessage : function(data)  {

    },
    createLoginRequest: function(data) {
        //If any conditions need to be checked or if any logic needs to be performed do it here 
        //this.ws?this.ws.send(JSON.stringify(data)): error("Websocket Connection not present")
        return {message_type:"LOGIN"}
    },
    handleCreateCase: function(message, component) {
        //call the apex controller to create a case
        console.log("handleCreateCase")
    },
    handleCustomerInformation :function (message, component) {
        //pop the case or update the case based on logic of what is returned from the controller
        console.log("handleCustomerInformation")
    },
    handleEndContact: function(message, component) {
        //call a controller and close the case
        console.log("handleEndContact")
    },
    handleTransferComplete: function (message, component) {
        //call the controller and close the case
        console.log("handleTransferComplete")
    },
    handleCompassEvents:function (message, component) {
        //hande compass events
        console.log("handleCompassEvents")
    },
    getLoginInfo:function (){

        //TODO pass all the information needed for Login
        return JSON.stringify({message_type:"LOGIN", format_type:"JSON", payload:{
            nt_id : this.ntId,
            application_id : this.applicationId
        }})
    },
    currentPortNumberIndex:0,
    portsList:[8080],
    applicationId:"5C371B91-41F6-4CE8-9134-3EA9B865FC8E",
    ntId:"raanchala"
})