({
    doInit : function(component, event, helper) {
        //TODO Call controler and set the ports list, nt_id, and application id and set them in he setPDAAttributes for persistence and later consumption for retries etc.
        //helper.setPDAAttributes()
        helper.startWebsocketConnection()
        helper.ws.onerror = (error) =>{
            console.log("Websocket Error", JSON.parse(error))
            if(error.reason == 'INVALID_LOGIN'){
                if(helper.currentPortNumberIndex < helper.portsList.length){
                    //TODO Show reconnecting message in SF
                    
                    //Retrying with the next available port
                    helper.currentPortNumberIndex++
                    helper.startWebsocketConnection()
                }
                else
                {
                    //TODO Show error that unable to connect to PDA
                }
            }
            else{
                //TODO Show Error message that unable to connect to PDA and log the message to FPTI.
            }
        }
        helper.ws.onclose = (data) =>{
            console.log("CLOSED WS CONNECTION", data)
            error = JSON.parse(data)
            if(error.reason == 'INVALID_LOGIN'){
                if(helper.currentPortNumberIndex < helper.portsList.length){
                    //TODO Show reconnecting message in SF
                    
                    //Retrying with the next available port
                    helper.currentPortNumberIndex++
                    helper.startWebsocketConnection()
                }
                else
                {
                    //TODO Show error that unable to connect to PDA
                }
            }
            else{
                //TODO Show Error message that unable to connect to PDA and log the message to FPTI.
            }
        }
        helper.ws.onmessage = (event) => {
            let message = JSON.parse(event.data)
            console.log("received message from PDA",message)
            let operations = {
                "SHOW_AVATAR_CASE":helper.handleCreateCase,
                "CUSTOMER_INFORMATION":helper.handleCustomerInformation,
                "END_OF_CONTACT":helper.handleEndContact,
                "TRANSFER_COMPLETED":helper.handleTransferComplete,
                "AVATAR_COMPASS_EVENTS":helper.handleCompassEvents,
            }
            //TODO check for attribute to be present in the list or elese have a generic log to denote what we got for PDA
            operations[message.message_type](message, component)
        }
        helper.ws.onopen = (data) => {
            console.log("Websocket Connected")
            helper.ws.send(helper.getLoginInfo())
        }
        
    },
})