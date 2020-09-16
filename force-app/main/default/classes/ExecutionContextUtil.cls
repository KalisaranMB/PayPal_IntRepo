public class ExecutionContextUtil {
    private static PayPalContext ppContext = null;
    private static String ppCorrelationId = null;
    private static String ppNamedCredential = null;
    private static Integer ppAPITimeout = null;       // Timeout for the API callout
    private static Integer ppApiCacheTime = null;     // API Cache Time in minutes
    private static Boolean correlationIdFlag = null;
    private static Boolean skipServerSideCache = false;
    private static Boolean isCaseSessionDetermined = false;
    private static Case_Session__c caseSession = null;
    private static SecurityContextDO securityContext = null;

    // Initialize PayPal Context with individual attributes
    public static void initContextData(PayPalContext.Actor actorType, Id caseId, Id accountId)
    {
        ppContext = new PayPalContext();

        // Assingn SERVER as actor type in case the passed in value is null
        ppContext.actorType  = (actorType != null) ? actorType : PayPalContext.Actor.SERVER;

        ppContext.caseId = caseId;
        ppContext.accountId = accountId;

        // Get the current user id. Please note that most of the transactions including batch and
        // inbound API calls will be associated with some user in Salesforce.
        ppContext.userId = UserInfo.getUserId();

        System.debug('Context Initialized with individual attributes: ' + JSON.serialize(ppContext));
    }

    // Initialize PayPal Context using the context JSON string obtained previously from getContextDataAsJSON method
    // This method is mostly useful in scenarios where we need to pass the context to an asynchronous apex
    public static void initContextData(String contextJSON)
    {
        System.debug('Initializing context with JSON String: ' + contextJSON);
        ppContext = new PayPalContext();
        
        if(String.isNotBlank(contextJSON))
        {
            ppContext = PayPalContext.parse(contextJSON);
        }

        System.debug('Actual Context Initialized from the JSON is: ' + JSON.serialize(ppContext));
    }

    // Get PayPal context as JSON string so that it can be passed to another transaction like asynchronous apex
    public static String getContextDataAsJSON()
    {
        if(ppContext != null)
        {
            return JSON.serialize(ppContext);
        }

        return null;
    }

    // Get the Named Credential API name for the current execution context
    public static String getPayPalNamedCredential()
    {
        // If named Credential is already available in the current execution context, return it
        if (ppNamedCredential != null)
        {
            System.debug('Returned PayPal Named Credential API name - ' + ppNamedCredential);
            return ppNamedCredential;
        }

        // Default it to SERVER since that is the fallback one to use
        String label = PayPalContext.Actor.SERVER.name();

        // Assign it to teammate if so
        if((ppContext != null) && (ppContext.actorType != null) && (ppContext.actorType == PayPalContext.Actor.TEAMMATE))
        {
            label = PayPalContext.Actor.TEAMMATE.name();
        }

        // Query the Custom Metadata type config to get the API name of the named credential
        PayPal_Named_Credential__mdt namedCredential = [SELECT API_Name__c FROM PayPal_Named_Credential__mdt 
                                                        WHERE MasterLabel = :label LIMIT 1];
        ppNamedCredential = namedCredential.API_Name__c;

        System.debug('Derived PayPal Named Credential API name - ' + ppNamedCredential);
        return ppNamedCredential;
    }

    // Generate the correlation id for the current execution context
    public static String getPayPalCorrelationId()
    {
        // If Correlation Id is already available in the current execution context, return it
        if(ppCorrelationId != null)
        {
            System.debug('Returned Correlation Id - ' + ppCorrelationId);
            return ppCorrelationId;
        }
        
        try
        {
            String rawId = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
            if (rawId.length() >= 13)
            {
                ppCorrelationId = rawId.substring(rawid.length()-13);
            }
        }
        catch (Exception e)
        {
            // This is not a critical failure, so let us not over-react and fail silently
            System.debug('Failed to generate the PayPal Correlation Id. Excepttion Message - ' + e.getMessage());
        }

        System.debug('Derived Correlation Id - ' + ppCorrelationId);
        return ppCorrelationId;
    }

    // Set the Correlation id in case we receive it from external systems
    public static void setPayPalCorrelationId(String corrId)
    {
        if (String.isNotBlank(corrId))
        {
            ppCorrelationId = corrId;
        }
        return;
    }

    // Get the default cache time for PayPal APIs / Data
    public static Integer getPayPalAPICacheTimeDefault()
    {
        if(ppApiCacheTime != null)
        {
            System.debug('Returned Default PayPal API Cache Time - ' + ppApiCacheTime + ' minutes');
            return ppApiCacheTime;
        }

        Cache_Duration__mdt cacheTime = [SELECT Cache_Time__c FROM Cache_Duration__mdt 
                                         WHERE MasterLabel='PayPalDefault' LIMIT 1];
        ppApiCacheTime = (Integer) cacheTime.Cache_Time__c;

        System.debug('Derived Default PayPal API Cache Time - ' + ppApiCacheTime + ' minutes');
        return ppApiCacheTime;
    }

    // Is Correlation Id enabled to send it to PayPal in the header
    public static Boolean isCorrelationIdEnabled()
    {
        if(correlationIdFlag != null)
        {
            System.debug('Returned: Is Correlation Id enabled? ' + correlationIdFlag);
            return correlationIdFlag;
        }

        System_Flag__mdt flag = [SELECT Value__c FROM System_Flag__mdt 
                                 WHERE MasterLabel='Send Correlation Id' LIMIT 1];
        correlationIdFlag = flag.Value__c;

        System.debug('Derived: Is Correlation Id enabled? ' + correlationIdFlag);
        return correlationIdFlag;
    }

    // Get PayPal API Timeout value to set in the Callout
    public static Integer getPayPalAPITimeout()
    {
        if(ppAPITimeout != null)
        {
            System.debug('Returned PayPal API Timeout - ' + ppAPITimeout);
            return ppAPITimeout;
        }

        API_Timeout__mdt timeoutConfig = [SELECT Timeout_Time__c FROM API_Timeout__mdt 
                                    WHERE MasterLabel='PayPal Default' LIMIT 1];
        ppAPITimeout = (Integer) timeoutConfig.Timeout_Time__c;

        System.debug('Derived PayPal API Timeout - ' + ppAPITimeout);
        return ppAPITimeout;
    }

    // Set PayPal API Timeout value for the callout based on the config name
    public static void setPayPalAPITimeout(String configName)
    {
        if (String.isBlank(configName))
        {
            // Dont bother
            System.debug('Timeout config name passed in the request is blank');
            return;
        }

        // Get the timeout config row for the config name
        List<API_Timeout__mdt> timeoutConfigArray = [SELECT Timeout_Time__c FROM API_Timeout__mdt 
                                                    WHERE MasterLabel=:configName LIMIT 1];
        
        if (timeoutConfigArray.size() == 0)
        {
            System.debug(LoggingLevel.ERROR, 'Unable to find the timeout config for the config name - ' + configName);
            return;
        }

        ppAPITimeout = (Integer) timeoutConfigArray[0].Timeout_Time__c;

        System.debug('PayPal API Timeout value is set to - ' + ppAPITimeout + ' ms');
        return;
    }

    // Get the security JSON context based on the current context
    public static String getPayPalSecurityContextJSON()
    {
        if (isCaseSessionDetermined)
        {
            if (caseSession == null)
            {
                System.debug('Returned PayPal Security Context: null');
                return null; 
            }

            System.debug('Returned PayPal Security Context from the Case Session');
            return caseSession.Security_Context__c;
        }

        // If we are here, case session is not identified already, lets go ahead and do it
        isCaseSessionDetermined = true;
        caseSession = getCaseSessionForCurrentContext();

        if (caseSession != null)
        {
            System.debug('Derived PayPal Security Context from the Case Session');
            return caseSession.Security_Context__c;
        }
        
        System.debug('Derived PayPal Security Context from the Case Session: null');
        return null;
    }

    // Get the security context object based on the current context
    public static SecurityContextDO getPayPalSecurityContext()
    {
        if (isCaseSessionDetermined)
        {
            System.debug('Returned PayPal Security Context DO');
            return securityContext;
        }

        // If we are here, case session is not identified already, lets go ahead and do it
        isCaseSessionDetermined = true;
        caseSession = getCaseSessionForCurrentContext();
        
        System.debug('Derived PayPal Security Context DO from the Case Session');
        return securityContext;
    }

    // Get Correlating Session Id (GSID) from the current case session if any
    // Correlating GSID is the session id of the user or other teammate channels
    // like IVR which is passed across as part of the current contact
    public static String getCorrelatingSessionId()
    {
        if (isCaseSessionDetermined)
        {
            if (caseSession == null)
            {
                System.debug('Returned Correlating Session Id: null');
                return null; 
            }

            System.debug('Returned Correlating Session Id from the Case Session');
            return caseSession.Correlating_GSID__c;
        }

        // If we are here, case session is not identified already, lets go ahead and do it
        isCaseSessionDetermined = true;
        caseSession = getCaseSessionForCurrentContext();

        if (caseSession != null)
        {
            System.debug('Derived Correlating Session Id from the Case Session');
            return caseSession.Correlating_GSID__c;
        }
        
        System.debug('Derived Correlating Session Id from the Case Session: null');
        return null;
    }

    // Get Current Session Id (GSID) from the current case session if any
    public static String getCurrentSessionId()
    {
        if (isCaseSessionDetermined)
        {
            if (securityContext == null)
            {
                System.debug('Returned Current Session Id: null');
                return null; 
            }

            System.debug('Returned Current Session Id from the Security Context');
            return securityContext.global_session_id;
        }

        // If we are here, case session is not identified already, lets go ahead and do it
        isCaseSessionDetermined = true;
        caseSession = getCaseSessionForCurrentContext();

        if (securityContext != null)
        {
            System.debug('Derived Current Session Id from the Case Session');
            return securityContext.global_session_id;
        }
        
        System.debug('Derived Current Session Id from the Case Session: null');
        return null;
    }

    private static Case_Session__c getCaseSessionForCurrentContext()
    {
        // Session can be derived only if the actor is TEAMMATE and the teammate is working in a case
        if ((ppContext == null) || (ppContext.actorType != PayPalContext.Actor.TEAMMATE) ||
            (String.isBlank(ppContext.caseId)))
        {
            System.debug('Either the actor is not TEAMMATE or the Case Id is missing - cannot identify Case Session');
            return null;
        }

        String caseId = ppContext.caseId;
        String accountId = ppContext.accountId;

        try {
            // If the account Id in context is null, lets try to get the account linked with the case
            if (String.isBlank(accountId))
            {
                Case currentCase = [SELECT Id, AccountId from Case WHERE Id = :caseId];
                accountId = currentCase.AccountId;

                // If the case is not linked to any account yet, lets break the flow
                if (String.isBlank(accountId))
                {
                    System.debug('The case is not linked with any account to identify the session');
                    return null;
                }
            }

            // Lets get the Case Session
            // Ideally we should include current teammate as well in this query, but it needs an
            // updated design from the Risk side to handle scenarios like transfer and avoid double stepup
            Case_Session__c sessionObj = [SELECT Id, Security_Context__c, Correlating_GSID__c FROM Case_Session__c
                                          WHERE Case__c = :caseId AND Account__c = :accountId];
            
            if (sessionObj == null)
            {
                System.debug('Failed to find Case Session for the Case - ' + caseId + ', Account - ' + accountId);
                return null;
            }

            if (String.isNotBlank(sessionObj.Security_Context__c))
            {
                try {
                    securityContext = SecurityContextDO.parse(sessionObj.Security_Context__c);
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Failed to parse security context JSON to DO. Exception - ' + e.getMessage());
                }
            }

            System.debug('Woohoo! Successfully determined the case session');
            return sessionObj;
            
        } catch (Exception e) {
            // This could be a critical failure depending on the context, but it is not critical enough to break
            System.debug('Failed to retrieve Case Session for the current case/account - ' + e.getMessage());
        }

        return null;
    }

    public static Boolean getSkipServerSideCache()
    {
        return skipServerSideCache;
    }

    public static void setSkipServerSideCache(Boolean skipCache)
    {
        skipServerSideCache = skipCache;
    }
}